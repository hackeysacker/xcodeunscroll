import SwiftUI
import Combine
import Supabase
import Network
import UIKit
import StoreKit
import BackgroundTasks
import os

#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

// MARK: - Network Monitor (Inline)
class UnscrollNetworkMonitor: ObservableObject {
    static let shared = UnscrollNetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}

// MARK: - Data Migration
final class DataMigrationService {
    static let shared = DataMigrationService()

    private let userDefaults: UserDefaults
    private let schemaVersionKey = "unscroll_data_schema_version"
    private let currentSchemaVersion = 2

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func migrateIfNeeded() {
        let storedVersion = userDefaults.integer(forKey: schemaVersionKey)
        guard storedVersion < currentSchemaVersion else { return }

        if storedVersion < 1 {
            migrateLegacyBrandingKeys()
        }
        if storedVersion < 2 {
            normalizeProgressBounds()
        }

        userDefaults.set(currentSchemaVersion, forKey: schemaVersionKey)
    }

    private func migrateLegacyBrandingKeys() {
        migrateKey(from: "focusflow_user", to: "unscroll_user")
        migrateKey(from: "focusflow_progress", to: "unscroll_progress")
        migrateKey(from: "focusflow_offline_queue", to: "unscroll_offline_queue")
    }

    private func normalizeProgressBounds() {
        guard let data = userDefaults.data(forKey: "unscroll_progress"),
              var progress = try? JSONDecoder().decode(GameProgress.self, from: data)
        else {
            return
        }

        var didChange = false

        let clampedHearts = max(0, min(progress.hearts, GameProgress.maxHearts))
        if clampedHearts != progress.hearts {
            progress.hearts = clampedHearts
            didChange = true
        }

        let clampedRefillSlots = max(0, min(progress.heartRefillSlots, GameProgress.maxRefillSlots))
        if clampedRefillSlots != progress.heartRefillSlots {
            progress.heartRefillSlots = clampedRefillSlots
            didChange = true
        }

        let clampedLevel = max(1, progress.level)
        if clampedLevel != progress.level {
            progress.level = clampedLevel
            didChange = true
        }

        if progress.totalXP < 0 {
            progress.totalXP = 0
            didChange = true
        }

        if progress.gems < 0 {
            progress.gems = 0
            didChange = true
        }

        if didChange, let updatedData = try? JSONEncoder().encode(progress) {
            userDefaults.set(updatedData, forKey: "unscroll_progress")
        }
    }

    private func migrateKey(from oldKey: String, to newKey: String) {
        if userDefaults.object(forKey: newKey) == nil,
           let oldValue = userDefaults.object(forKey: oldKey) {
            userDefaults.set(oldValue, forKey: newKey)
        }
        userDefaults.removeObject(forKey: oldKey)
    }
}

// MARK: - Privacy
struct PrivacyExportPayload: Codable {
    let exportedAt: Date
    let appVersion: String
    let user: User?
    let progress: GameProgress?
    let privacyPreferences: PrivacyService.PrivacyPreferences
    let notificationPreferences: PrivacyService.NotificationPreferences
    let cacheSummary: PrivacyService.CacheSummary
}

@MainActor
final class PrivacyService: ObservableObject {
    static let shared = PrivacyService()

    struct PrivacyPreferences: Codable {
        var analyticsEnabled: Bool
        var crashReportingEnabled: Bool
        var personalizedRecommendationsEnabled: Bool
        var acceptedPrivacyPolicyAt: Date?
        var consentUpdatedAt: Date?
    }

    struct NotificationPreferences: Codable {
        var notificationsEnabled: Bool
        var reminderHour: Int
        var reminderMinute: Int
        var streakWarningEnabled: Bool
    }

    struct CacheSummary: Codable {
        var pendingSyncCount: Int
        var lastSyncAt: Date?
    }

    @Published var analyticsEnabled: Bool {
        didSet { save() }
    }
    @Published var crashReportingEnabled: Bool {
        didSet { save() }
    }
    @Published var personalizedRecommendationsEnabled: Bool {
        didSet { save() }
    }
    @Published var acceptedPrivacyPolicyAt: Date? {
        didSet { save() }
    }
    @Published var consentUpdatedAt: Date? {
        didSet { save() }
    }

    private let userDefaults = UserDefaults.standard
    private let storageKey = "privacy_preferences_v1"

    private init() {
        if let data = userDefaults.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(PrivacyPreferences.self, from: data) {
            analyticsEnabled = saved.analyticsEnabled
            crashReportingEnabled = saved.crashReportingEnabled
            personalizedRecommendationsEnabled = saved.personalizedRecommendationsEnabled
            acceptedPrivacyPolicyAt = saved.acceptedPrivacyPolicyAt
            consentUpdatedAt = saved.consentUpdatedAt
        } else {
            analyticsEnabled = false
            crashReportingEnabled = false
            personalizedRecommendationsEnabled = true
            acceptedPrivacyPolicyAt = nil
            consentUpdatedAt = nil
        }
    }

    var hasAcceptedPrivacyPolicy: Bool {
        acceptedPrivacyPolicyAt != nil
    }

    func acceptPrivacyPolicy() {
        if acceptedPrivacyPolicyAt == nil {
            acceptedPrivacyPolicyAt = Date()
        }
        consentUpdatedAt = Date()
    }

    func exportUserData(user: User?, progress: GameProgress?) throws -> URL {
        let lastSyncTimestamp = userDefaults.double(forKey: "cache_last_sync")
        let lastSyncAt = lastSyncTimestamp > 0 ? Date(timeIntervalSince1970: lastSyncTimestamp) : nil

        let payload = PrivacyExportPayload(
            exportedAt: Date(),
            appVersion: "1.0.0",
            user: user,
            progress: progress,
            privacyPreferences: PrivacyPreferences(
                analyticsEnabled: analyticsEnabled,
                crashReportingEnabled: crashReportingEnabled,
                personalizedRecommendationsEnabled: personalizedRecommendationsEnabled,
                acceptedPrivacyPolicyAt: acceptedPrivacyPolicyAt,
                consentUpdatedAt: consentUpdatedAt
            ),
            notificationPreferences: NotificationPreferences(
                notificationsEnabled: userDefaults.bool(forKey: "notifications_enabled"),
                reminderHour: userDefaults.object(forKey: "reminder_hour") as? Int ?? 9,
                reminderMinute: userDefaults.object(forKey: "reminder_minute") as? Int ?? 0,
                streakWarningEnabled: userDefaults.object(forKey: "streak_warning_enabled") as? Bool ?? true
            ),
            cacheSummary: CacheSummary(
                pendingSyncCount: pendingOfflineQueueCount(),
                lastSyncAt: lastSyncAt
            )
        )

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let filename = "unscroll_data_export_\(formatter.string(from: Date())).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        try data.write(to: url, options: Data.WritingOptions.atomic)
        return url
    }

    private func pendingOfflineQueueCount() -> Int {
        guard let queueData = userDefaults.data(forKey: "unscroll_offline_queue"),
              let queue = try? JSONDecoder().decode([OfflineQueue.PendingAction].self, from: queueData) else {
            return 0
        }
        return queue.count
    }

    private func save() {
        let preferences = PrivacyPreferences(
            analyticsEnabled: analyticsEnabled,
            crashReportingEnabled: crashReportingEnabled,
            personalizedRecommendationsEnabled: personalizedRecommendationsEnabled,
            acceptedPrivacyPolicyAt: acceptedPrivacyPolicyAt,
            consentUpdatedAt: consentUpdatedAt
        )
        if let data = try? JSONEncoder().encode(preferences) {
            userDefaults.set(data, forKey: storageKey)
        }
    }
}

@MainActor
class AppState: ObservableObject {
    @Published var isOnboarded: Bool = true
    @Published var isLoading: Bool = true
    @Published var currentUser: User?
    @Published var progress: GameProgress? {
        didSet {
            // Only auto-save after initial load is complete
            if !isLoading {
                saveData()
            }
        }
    }
    @Published var selectedTab: Tab = .home
    @Published var showSettings: Bool = false
    @Published var showLeaderboard: Bool = false
    @Published var showFocusShield: Bool = false
    @Published var showInsights: Bool = false
    
    // Testing mode
    @Published var testingModeEnabled: Bool = false
    @Published var testingDuration: Int = 5
    
    // Selected challenge for navigation
    @Published var selectedChallenge: AllChallengeType?
    @Published var startChallengeFromPath: Bool = false
    
    // Supabase integration
    @Published var isAuthenticated: Bool = false
    @Published var isSyncing: Bool = false
    @Published var syncError: String?
    
    // Offline mode support
    @Published var isOnline: Bool = true
    @Published var hasPendingSync: Bool = false
    
    // Achievement tracking
    @Published var newlyUnlockedAchievements: [Achievement] = []
    
    // Network monitor
    private let networkMonitor = UnscrollNetworkMonitor.shared
    
    // Supabase client
    private let supabaseUrl = "https://sxgpcsfwbzptlmwfddda.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4Z3Bjc2Z3YnpwdGxtd2ZkZGRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3NTI0NzYsImV4cCI6MjA3OTMyODQ3Nn0.kkQc632Gu8ozuCD5HoZVS35yGbxA4l2kmuq96bCBg4w"
    
    private var supabase: SupabaseClient?
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case path = "Path"
        case screenTime = "Focus"
        case practice = "Practice"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .home:       return "house.fill"
            case .path:       return "map.fill"
            case .screenTime: return "hourglass"
            case .practice:   return "brain.head.profile"
            case .profile:    return "person.fill"
            }
        }
    }
    
    init() {
        DataMigrationService.shared.migrateIfNeeded()
        setupSupabase()
        loadUserData()
        setupNetworkMonitoring()
        CrashReportingService.shared.setUserID(currentUser?.id)
    }
    
    private func setupNetworkMonitoring() {
        // Observe network changes
        isOnline = networkMonitor.isConnected
        
        // Start monitoring only when app is active
        startNetworkMonitoring()
        
        // Listen for app lifecycle events to pause/resume monitoring
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.startNetworkMonitoring()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.stopNetworkMonitoring()
            }
        }
    }
    
    private func syncPendingOfflineActions() async {
        guard isAuthenticated, currentUser?.id != nil else { return }
        // Sync would happen here - for now just clear the flag
        hasPendingSync = false
    }
    
    private func setupSupabase() {
        supabase = SupabaseClient(
            supabaseURL: URL(string: supabaseUrl)!,
            supabaseKey: supabaseKey
        )
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String) async {
        guard let supabase = supabase else { return }
        isLoading = true
        
        do {
            _ = try await supabase.auth.signUp(email: email, password: password)
            isLoading = false
            // Note: User needs to verify email before signing in
        } catch {
            isLoading = false
            syncError = error.localizedDescription
            CrashReportingService.shared.record(error: error, context: "auth_sign_up")
        }
    }
    
    func signIn(email: String, password: String) async {
        guard let supabase = supabase else { return }
        isLoading = true
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            isAuthenticated = true
            isLoading = false
            CrashReportingService.shared.setUserID(session.user.id.uuidString)
            
            // Sync data after login
            await syncFromCloud(userId: session.user.id.uuidString)
        } catch {
            isLoading = false
            syncError = error.localizedDescription
            CrashReportingService.shared.record(error: error, context: "auth_sign_in")
        }
    }
    
    func signOut() async {
        guard let supabase = supabase else { return }
        
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
            isSyncing = false
            CrashReportingService.shared.setUserID(nil)
        } catch {
            syncError = error.localizedDescription
            CrashReportingService.shared.record(error: error, context: "auth_sign_out")
        }
    }
    
    func checkAuthStatus() async {
        guard let supabase = supabase else { return }
        
        do {
            let session = try await supabase.auth.session
            isAuthenticated = true
            await syncFromCloud(userId: session.user.id.uuidString)
        } catch {
            isAuthenticated = false
            CrashReportingService.shared.record(error: error, context: "auth_check_status")
        }
    }
    
    // MARK: - Cloud Sync
    
    func syncFromCloud(userId: String) async {
        guard let supabase = supabase else { return }
        isSyncing = true
        
        do {
            // Fetch profile
            let profiles: [Profile] = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            
            if let profile = profiles.first {
                // Update local gems
                if var prog = progress {
                    prog.gems = profile.gems ?? prog.gems
                    progress = prog
                }
            }
            
            // Note: Full progress sync requires careful merging strategy
            // For now, we keep local progress and only sync gems
            
            isSyncing = false
            saveData()
        } catch {
            isSyncing = false
            syncError = error.localizedDescription
            CrashReportingService.shared.record(error: error, context: "sync_from_cloud")
        }
    }
    
    // MARK: - Refresh Progress
    func refreshProgress() async {
        guard let userId = currentUser?.id else {
            // For anonymous/offline mode, just reload from local storage
            loadUserData()
            return
        }
        await syncFromCloud(userId: userId)
    }
    
    func syncToCloud(userId: String) async {
        guard let supabase = supabase else { return }
        isSyncing = true
        
        do {
            // Update profile (gems)
            try await supabase
                .from("profiles")
                .update(["gems": progress?.gems ?? 0])
                .eq("id", value: userId)
                .execute()
            
            // Note: Full game progress sync requires proper Codable structs
            // For now, we sync gems only
            
            isSyncing = false
        } catch {
            isSyncing = false
            syncError = error.localizedDescription
            CrashReportingService.shared.record(error: error, context: "sync_to_cloud")
        }
    }

    func performBackgroundSync() async -> Bool {
        guard isAuthenticated else { return true }
        guard let userId = currentUser?.id else { return true }

        syncError = nil
        await syncToCloud(userId: userId)
        if let syncError {
            CrashReportingService.shared.log(message: "Background sync failed: \(syncError)")
            return false
        }
        return true
    }
    
    // MARK: - Data Management
    
    private var networkTimer: Timer?
    
    func loadUserData() {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "unscroll_user"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isOnboarded = user.goal != nil
            CrashReportingService.shared.setUserID(user.id)
        }
        
        if let progressData = UserDefaults.standard.data(forKey: "unscroll_progress"),
           let prog = try? JSONDecoder().decode(GameProgress.self, from: progressData) {
            progress = prog
            // Process any missed heart refills when loading
            processMissedHeartRefills()
            // Check daily login streak
            progress?.checkDailyLogin()
        }
        
        isLoading = false
    }
    
    func startNetworkMonitoring() {
        // Only start timer when app is active
        networkTimer?.invalidate()
        networkTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                let wasOnline = self.isOnline
                self.isOnline = self.networkMonitor.isConnected
                
                // Auto-sync when coming back online
                if !wasOnline && self.isOnline {
                    await self.syncPendingOfflineActions()
                }
            }
        }
    }
    
    func stopNetworkMonitoring() {
        networkTimer?.invalidate()
        networkTimer = nil
    }
    
    func completeOnboarding(goal: GoalType) {
        let user = User(
            id: UUID().uuidString,
            email: "guest@local",
            createdAt: Date(),
            goal: goal,
            isPremium: true,
            onboardingData: nil
        )
        currentUser = user
        isOnboarded = true
        CrashReportingService.shared.setUserID(user.id)
        
        // Initialize progress
        progress = GameProgress()
        
        saveData()
    }
    
    func updateStreak() {
        guard var prog = progress else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = prog.lastActivityDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            
            if lastDay == today {
                // Already played today, no change
                return
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                      lastDay == yesterday {
                // Played yesterday, increment streak
                prog.streakDays += 1
                // Reset freeze after using it
                if prog.streakFreezeUsed {
                    prog.streakFreezeUsed = false
                }
            } else {
                // Missed a day - check if we can use streak freeze
                if prog.streakFreezesAvailable > 0 && !prog.streakFreezeUsed {
                    // Use streak freeze to preserve streak
                    prog.streakFreezeUsed = true
                    prog.lastActivityDate = Date()
                    progress = prog
                    saveData()
                    return
                }
                // Streak broken, reset to 1
                prog.streakDays = 1
            }
        } else {
            // First time playing
            prog.streakDays = 1
        }
        
        prog.lastActivityDate = Date()
        progress = prog
        saveData()
    }
    
    func saveData() {
        if let user = currentUser,
           let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "unscroll_user")
        }
        
        if let prog = progress,
           let data = try? JSONEncoder().encode(prog) {
            UserDefaults.standard.set(data, forKey: "unscroll_progress")
        }
    }

    func exportUserData() throws -> URL {
        try PrivacyService.shared.exportUserData(user: currentUser, progress: progress)
    }

    func clearLocalData() {
        let userDefaults = UserDefaults.standard

        let keysToRemove = [
            "unscroll_user",
            "unscroll_progress",
            "unscroll_offline_queue",
            "achievements_v2",
            "cache_profile",
            "cache_game_progress",
            "cache_skill_progress",
            "cache_heart_state",
            "cache_badges",
            "cache_last_sync",
            "cache_pending_sync"
        ]
        keysToRemove.forEach { userDefaults.removeObject(forKey: $0) }

        OfflineQueue.shared.clear()

        currentUser = nil
        progress = nil
        isOnboarded = false
        isAuthenticated = false
        isSyncing = false
        hasPendingSync = false
        newlyUnlockedAchievements = []
    }
    
    func resetOnboarding() {
        clearLocalData()
    }
    
    // MARK: - Gems System
    
    func addGems(_ amount: Int) {
        guard var prog = progress else { return }
        prog.gems += amount
        progress = prog
        saveData()
    }
    
    func spendGems(_ amount: Int) -> Bool {
        guard var prog = progress else { return false }
        if prog.gems >= amount {
            prog.gems -= amount
            progress = prog
            saveData()
            return true
        }
        return false
    }
    
    // MARK: - Hearts System
    
    /// Check and process heart refill if ready
    func checkHeartRefill() {
        guard var prog = progress else { return }
        
        // Only refill if we have slots and aren't at max hearts
        guard prog.hearts < GameProgress.maxHearts,
              prog.heartRefillSlots > 0,
              let lastRefill = prog.lastHeartRefill else {
            return
        }
        
        let nextRefillTime = lastRefill.addingTimeInterval(TimeInterval(GameProgress.refillIntervalMinutes * 60))
        
        if Date() >= nextRefillTime {
            // Refill a heart
            prog.hearts += 1
            prog.heartRefillSlots -= 1
            prog.lastHeartRefill = Date()
            progress = prog
            saveData()
        }
    }
    
    /// Process any missed refills (e.g., after app was closed)
    func processMissedHeartRefills() {
        guard var prog = progress,
              prog.heartRefillSlots > 0,
              let lastRefill = prog.lastHeartRefill else {
            return
        }
        
        let now = Date()
        var refillsToApply = 0
        var currentTime = lastRefill
        
        // Calculate how many hearts we should have refilled
        while prog.hearts < GameProgress.maxHearts && prog.heartRefillSlots > 0 {
            let nextRefillTime = currentTime.addingTimeInterval(TimeInterval(GameProgress.refillIntervalMinutes * 60))
            
            if now >= nextRefillTime {
                refillsToApply += 1
                prog.heartRefillSlots -= 1
                currentTime = nextRefillTime
            } else {
                break
            }
            
            // Safety limit
            if refillsToApply >= 3 {
                break
            }
        }
        
        if refillsToApply > 0 {
            prog.hearts = min(prog.hearts + refillsToApply, GameProgress.maxHearts)
            prog.lastHeartRefill = currentTime
            progress = prog
            saveData()
        }
    }
    
    /// Purchase hearts with gems
    func purchaseHeart() -> Bool {
        guard var prog = progress else { return false }
        guard prog.hearts < GameProgress.maxHearts else { return false }
        guard prog.gems >= 50 else { return false }
        
        prog.gems -= 50
        prog.hearts += 1
        progress = prog
        saveData()
        return true
    }
    
    /// Purchase refill slot with gems
    func purchaseRefillSlot() -> Bool {
        guard var prog = progress else { return false }
        guard prog.heartRefillSlots < GameProgress.maxRefillSlots else { return false }
        guard prog.gems >= 25 else { return false }
        
        prog.gems -= 25
        prog.heartRefillSlots += 1
        progress = prog
        saveData()
        return true
    }
    
    /// Purchase streak freeze with gems (preserves streak when missing a day)
    func purchaseStreakFreeze() -> Bool {
        guard var prog = progress else { return false }
        guard prog.streakFreezesAvailable < 3 else { return false }  // Max 3 freezes
        guard prog.gems >= 100 else { return false }
        
        prog.gems -= 100
        prog.streakFreezesAvailable += 1
        progress = prog
        saveData()
        return true
    }
    
    /// Get additional streak freezes (gem store)
    func buyStreakFreeze() -> Bool {
        return purchaseStreakFreeze()
    }
    
    func loseHeart() {
        guard var prog = progress else { return }
        if prog.hearts > 0 {
            prog.hearts -= 1
            // Reset refill timer when heart is lost
            prog.lastHeartRefill = Date()
            progress = prog
            saveData()
        }
    }
    
    func addHeart() {
        guard var prog = progress else { return }
        if prog.hearts < GameProgress.maxHearts {
            prog.hearts += 1
            progress = prog
            saveData()
        }
    }
    
    func refillHearts() {
        guard var prog = progress else { return }
        prog.hearts = GameProgress.maxHearts
        prog.heartRefillSlots = GameProgress.maxRefillSlots
        prog.lastHeartRefill = Date()
        progress = prog
        saveData()
    }
    
    // MARK: - XP & Leveling

    func addXP(_ amount: Int) {
        guard var prog = progress else { return }
        prog.totalXP += amount
        applyLevelUps(to: &prog)
        progress = prog
        saveData()
    }

    private func applyLevelUps(to prog: inout GameProgress) {
        var leveled = false
        while prog.currentLevelXP >= prog.xpForNextLevel {
            prog.totalXP -= prog.xpForNextLevel   // consume level's XP
            prog.level += 1
            prog.gems += 15                        // bonus per level
            leveled = true
        }
        if leveled { SoundManager.shared.playLevelUp() }
    }

    // MARK: - Challenge Completion

    func completeChallenge(type: AllChallengeType, score: Int, xpEarned: Int) {
        guard var prog = progress else { return }

        // XP reward (scale by score: full reward at 100+ pts)
        let scaledXP = max(5, Int(Double(xpEarned) * min(1.0, Double(max(score, 10)) / 80.0)))
        prog.totalXP += scaledXP
        applyLevelUps(to: &prog)

        // Gems: base 3 + 1 per 20 score points
        let gemsEarned = 3 + score / 20
        prog.gems += gemsEarned

        // Record attempt
        let attempt = ChallengeAttempt(
            id: UUID().uuidString,
            challengeTypeRaw: type.rawValue,
            level: prog.level,
            score: score,
            duration: TimeInterval(type.duration),
            isPerfect: score >= 150,
            xpEarned: scaledXP,
            attemptedAt: Date()
        )
        prog.completedChallenges.append(attempt)

        // Skill progression
        prog.updateSkills(for: type.category, score: score)

        progress = prog

        // Streak + achievements
        updateStreak()
        checkAchievements()
        saveData()

        // Cloud sync
        if isAuthenticated, let userId = currentUser?.id {
            if isOnline {
                Task { await syncToCloud(userId: userId) }
            } else {
                hasPendingSync = true
            }
        }
    }
    
    // MARK: - Achievements
    
    private func checkAchievements() {
        guard var prog = progress else { return }
        
        let achievementStore = AchievementStore()
        let previousUnlocked = achievementStore.unlockedCount()
        
        achievementStore.checkAndUnlock(progress: prog)
        let newUnlocked = achievementStore.unlockedCount()
        
        // Get newly unlocked achievements
        if newUnlocked > previousUnlocked {
            let achievements = achievementStore.achievements.filter { $0.isUnlocked }
            newlyUnlockedAchievements = Array(achievements.suffix(newUnlocked - previousUnlocked))
            
            // Award XP for new achievements
            for achievement in newlyUnlockedAchievements {
                prog.totalXP += achievement.xpReward
                prog.gems += achievement.xpReward / 10 // Bonus gems
            }
            progress = prog
        }
    }
    
    func clearNewAchievements() {
        newlyUnlockedAchievements = []
    }
}
// MARK: - Theme

enum AppTheme: String, CaseIterable, Codable, Identifiable {
    case midnight
    case ocean
    case forest
    case sunrise

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .midnight: return "Midnight"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        case .sunrise: return "Sunrise"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .midnight:
            return [Color(hex: "06060F"), Color(hex: "0A0F1C"), Color(hex: "0D1526")]
        case .ocean:
            return [Color(hex: "031A2F"), Color(hex: "0B3A5B"), Color(hex: "0A5D7A")]
        case .forest:
            return [Color(hex: "04190D"), Color(hex: "0F3B24"), Color(hex: "1C5D2F")]
        case .sunrise:
            return [Color(hex: "2A1228"), Color(hex: "63304D"), Color(hex: "B55E4A")]
        }
    }

    var accentColor: Color {
        switch self {
        case .midnight: return .purple
        case .ocean: return .cyan
        case .forest: return .green
        case .sunrise: return .orange
        }
    }
}

@MainActor
final class ThemeService: ObservableObject {
    static let shared = ThemeService()

    enum Appearance: String, CaseIterable, Codable, Identifiable {
        case system
        case dark
        case light

        var id: String { rawValue }

        var label: String {
            switch self {
            case .system: return "System"
            case .dark: return "Dark"
            case .light: return "Light"
            }
        }

        var preferredColorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .dark: return .dark
            case .light: return .light
            }
        }
    }

    @Published var selectedTheme: AppTheme {
        didSet { save() }
    }

    @Published var appearance: Appearance {
        didSet { save() }
    }

    private let userDefaults = UserDefaults.standard
    private let themeKey = "app_theme"
    private let appearanceKey = "app_appearance"

    private init() {
        selectedTheme = AppTheme(rawValue: userDefaults.string(forKey: themeKey) ?? "") ?? .midnight
        appearance = Appearance(rawValue: userDefaults.string(forKey: appearanceKey) ?? "") ?? .dark
    }

    private func save() {
        userDefaults.set(selectedTheme.rawValue, forKey: themeKey)
        userDefaults.set(appearance.rawValue, forKey: appearanceKey)
    }
}

// MARK: - Social

struct FriendProfile: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var avatar: String
    var xp: Int
    var streak: Int
    var isOnline: Bool
}

struct FriendChallengeInvite: Identifiable, Codable {
    let id: UUID
    let friendId: String
    let challengeTitle: String
    let createdAt: Date
    var status: ChallengeStatus

    enum ChallengeStatus: String, Codable {
        case pending
        case accepted
        case completed
        case declined
    }
}

@MainActor
final class SocialService: ObservableObject {
    static let shared = SocialService()

    @Published private(set) var friends: [FriendProfile]
    @Published private(set) var sentInvites: [FriendChallengeInvite]

    private let userDefaults = UserDefaults.standard
    private let friendsKey = "social_friends_v1"
    private let invitesKey = "social_invites_v1"

    private init() {
        if let data = userDefaults.data(forKey: friendsKey),
           let decoded = try? JSONDecoder().decode([FriendProfile].self, from: data),
           !decoded.isEmpty {
            friends = decoded
        } else {
            friends = [
                FriendProfile(id: UUID().uuidString, name: "Maya", avatar: "🧠", xp: 9400, streak: 14, isOnline: true),
                FriendProfile(id: UUID().uuidString, name: "Noah", avatar: "⚡", xp: 8200, streak: 10, isOnline: false),
                FriendProfile(id: UUID().uuidString, name: "Aria", avatar: "🔥", xp: 10120, streak: 19, isOnline: true),
                FriendProfile(id: UUID().uuidString, name: "Leo", avatar: "🎯", xp: 7600, streak: 7, isOnline: true)
            ]
        }

        if let data = userDefaults.data(forKey: invitesKey),
           let decoded = try? JSONDecoder().decode([FriendChallengeInvite].self, from: data) {
            sentInvites = decoded
        } else {
            sentInvites = []
        }
    }

    func addFriend(name: String, avatar: String = "👤") {
        let friend = FriendProfile(
            id: UUID().uuidString,
            name: name,
            avatar: avatar,
            xp: Int.random(in: 1200...7000),
            streak: Int.random(in: 1...12),
            isOnline: Bool.random()
        )
        friends.append(friend)
        save()
    }

    func removeFriend(id: String) {
        friends.removeAll { $0.id == id }
        sentInvites.removeAll { $0.friendId == id }
        save()
    }

    @discardableResult
    func challengeFriend(friendId: String, challengeTitle: String) -> FriendChallengeInvite? {
        guard friends.contains(where: { $0.id == friendId }) else { return nil }

        let invite = FriendChallengeInvite(
            id: UUID(),
            friendId: friendId,
            challengeTitle: challengeTitle,
            createdAt: Date(),
            status: .pending
        )
        sentInvites.insert(invite, at: 0)
        save()
        return invite
    }

    func friend(for id: String) -> FriendProfile? {
        friends.first(where: { $0.id == id })
    }

    func leaderboardEntries(currentUserName: String, currentUserAvatar: String, currentUserXP: Int, currentUserStreak: Int, mode: LeaderboardMode) -> [LeaderboardData] {
        var list = friends.map {
            LeaderboardData(name: $0.name, avatar: $0.avatar, xp: $0.xp, streak: $0.streak)
        }
        list.append(LeaderboardData(name: currentUserName, avatar: currentUserAvatar, xp: currentUserXP, streak: currentUserStreak, isCurrentUser: true))

        switch mode {
        case .global:
            list += [
                LeaderboardData(name: "ZenMaster", avatar: "🥷", xp: 12000, streak: 30),
                LeaderboardData(name: "FocusWave", avatar: "🌊", xp: 11050, streak: 21),
                LeaderboardData(name: "ClarityCore", avatar: "💎", xp: 10400, streak: 17)
            ]
        case .friends:
            break
        }

        return list
            .sorted(by: { $0.xp > $1.xp })
            .prefix(20)
            .map { $0 }
    }

    private func save() {
        if let friendsData = try? JSONEncoder().encode(friends) {
            userDefaults.set(friendsData, forKey: friendsKey)
        }
        if let invitesData = try? JSONEncoder().encode(sentInvites) {
            userDefaults.set(invitesData, forKey: invitesKey)
        }
    }
}

enum LeaderboardMode {
    case global
    case friends
}

struct LeaderboardData: Identifiable {
    let id = UUID()
    let name: String
    let avatar: String
    let xp: Int
    let streak: Int
    var isCurrentUser: Bool = false
}

// MARK: - Purchases

enum AppProductID: String, CaseIterable {
    case gemsSmall = "com.unscroll.gems.small"
    case gemsMedium = "com.unscroll.gems.medium"
    case noAds = "com.unscroll.noads.lifetime"
    case advancedAnalytics = "com.unscroll.analytics.monthly"
    case customThemes = "com.unscroll.themes.pack"

    var gemReward: Int {
        switch self {
        case .gemsSmall: return 250
        case .gemsMedium: return 1200
        default: return 0
        }
    }
}

@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoadingProducts: Bool = false
    @Published var noAdsEnabled: Bool {
        didSet { userDefaults.set(noAdsEnabled, forKey: noAdsKey) }
    }
    @Published var advancedAnalyticsEnabled: Bool {
        didSet { userDefaults.set(advancedAnalyticsEnabled, forKey: advancedAnalyticsKey) }
    }
    @Published var customThemesEnabled: Bool {
        didSet { userDefaults.set(customThemesEnabled, forKey: customThemesKey) }
    }

    private let userDefaults = UserDefaults.standard
    private let noAdsKey = "premium_no_ads_enabled"
    private let advancedAnalyticsKey = "premium_advanced_analytics_enabled"
    private let customThemesKey = "premium_custom_themes_enabled"

    private init() {
        noAdsEnabled = userDefaults.bool(forKey: noAdsKey)
        advancedAnalyticsEnabled = userDefaults.bool(forKey: advancedAnalyticsKey)
        customThemesEnabled = userDefaults.bool(forKey: customThemesKey)
    }

    func loadProductsIfNeeded() async {
        guard products.isEmpty else { return }
        await loadProducts()
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let ids = AppProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: ids)
        } catch {
            CrashReportingService.shared.record(error: error, context: "load_products")
        }
    }

    func displayPrice(for productID: AppProductID) -> String {
        if let product = products.first(where: { $0.id == productID.rawValue }) {
            return product.displayPrice
        }
        switch productID {
        case .gemsSmall: return "$2.99"
        case .gemsMedium: return "$9.99"
        case .noAds: return "$4.99"
        case .advancedAnalytics: return "$2.99/mo"
        case .customThemes: return "$1.99"
        }
    }

    @discardableResult
    func purchase(_ productID: AppProductID, appState: AppState?) async -> Bool {
        if let product = products.first(where: { $0.id == productID.rawValue }) {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        applyEntitlement(for: productID, appState: appState)
                        await transaction.finish()
                        return true
                    case .unverified:
                        return false
                    }
                case .userCancelled:
                    return false
                case .pending:
                    return false
                @unknown default:
                    return false
                }
            } catch {
                CrashReportingService.shared.record(error: error, context: "purchase_\(productID.rawValue)")
                return false
            }
        }

        // Fallback for development builds without products configured.
        applyEntitlement(for: productID, appState: appState)
        return true
    }

    private func applyEntitlement(for productID: AppProductID, appState: AppState?) {
        switch productID {
        case .gemsSmall, .gemsMedium:
            appState?.addGems(productID.gemReward)
        case .noAds:
            noAdsEnabled = true
        case .advancedAnalytics:
            advancedAnalyticsEnabled = true
        case .customThemes:
            customThemesEnabled = true
        }
    }
}

// MARK: - Crash Reporting

final class CrashReportingService {
    static let shared = CrashReportingService()

    private let logger = Logger(subsystem: "com.unscroll.app", category: "crash")

    private init() { }

    func setUserID(_ userID: String?) {
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().setUserID(userID ?? "")
        #endif
    }

    func record(error: Error, context: String, metadata: [String: String] = [:]) {
        let metadataString = metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
        logger.error("Error (\(context, privacy: .public)): \(error.localizedDescription, privacy: .public) \(metadataString, privacy: .public)")
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().setCustomValue(context, forKey: "context")
        metadata.forEach { Crashlytics.crashlytics().setCustomValue($0.value, forKey: $0.key) }
        Crashlytics.crashlytics().record(error: error)
        #endif
    }

    func log(message: String) {
        logger.info("\(message, privacy: .public)")
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().log(message)
        #endif
    }
}

// MARK: - Background Sync

final class BackgroundSyncService {
    static let shared = BackgroundSyncService()

    let taskIdentifier = "com.unscroll.app.background-sync"
    var syncHandler: (() async -> Bool)?

    private var didRegister = false

    private init() { }

    func register() {
        guard !didRegister else { return }
        didRegister = true

        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handle(task: task)
        }
    }

    func scheduleNextSync() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            CrashReportingService.shared.record(error: error, context: "schedule_background_sync")
        }
    }

    private func handle(task: BGTask) {
        guard let refreshTask = task as? BGAppRefreshTask else {
            task.setTaskCompleted(success: false)
            return
        }

        scheduleNextSync()

        let syncTask = Task {
            let success = await (syncHandler?() ?? false)
            refreshTask.setTaskCompleted(success: success)
        }

        refreshTask.expirationHandler = {
            syncTask.cancel()
        }
    }
}
