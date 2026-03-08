import SwiftUI
import Combine
import Supabase
import Network
import UIKit

// MARK: - Network Monitor (Inline)
class FocusFlowNetworkMonitor: ObservableObject {
    static let shared = FocusFlowNetworkMonitor()
    
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
    private let networkMonitor = FocusFlowNetworkMonitor.shared
    
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
        setupSupabase()
        loadUserData()
        setupNetworkMonitoring()
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
            self?.startNetworkMonitoring()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.stopNetworkMonitoring()
        }
    }
    
    private func syncPendingOfflineActions() async {
        guard isAuthenticated, let userId = currentUser?.id else { return }
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
        }
    }
    
    func signIn(email: String, password: String) async {
        guard let supabase = supabase else { return }
        isLoading = true
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            isAuthenticated = true
            isLoading = false
            
            // Sync data after login
            await syncFromCloud(userId: session.user.id.uuidString)
        } catch {
            isLoading = false
            syncError = error.localizedDescription
        }
    }
    
    func signOut() async {
        guard let supabase = supabase else { return }
        
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
            isSyncing = false
        } catch {
            syncError = error.localizedDescription
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
        }
    }
    
    // MARK: - Cloud Sync
    
    func syncFromCloud(userId: String) async {
        guard let supabase = supabase else { return }
        isSyncing = true
        
        do {
            // Fetch profile
            let profiles: [Profile] = try await supabase
                .database
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
                .database
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
        }
    }
    
    // MARK: - Data Management
    
    private var networkTimer: Timer?
    
    func loadUserData() {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "focusflow_user"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isOnboarded = user.goal != nil
        }
        
        if let progressData = UserDefaults.standard.data(forKey: "focusflow_progress"),
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
            UserDefaults.standard.set(data, forKey: "focusflow_user")
        }
        
        if let prog = progress,
           let data = try? JSONEncoder().encode(prog) {
            UserDefaults.standard.set(data, forKey: "focusflow_progress")
        }
    }
    
    func resetOnboarding() {
        currentUser = nil
        progress = nil
        isOnboarded = false
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "focusflow_user")
        UserDefaults.standard.removeObject(forKey: "focusflow_progress")
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
