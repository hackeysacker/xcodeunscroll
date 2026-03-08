import SwiftUI
import Combine
import Supabase
import Network

@MainActor
class AppState: ObservableObject {
    @Published var isOnboarded: Bool = true
    @Published var isLoading: Bool = true
    @Published var currentUser: User?
    @Published var progress: GameProgress?
    @Published var achievementStore = AchievementStore()
    @Published var selectedTab: Tab = .home
    @Published var showSettings: Bool = false
    @Published var showLeaderboard: Bool = false
    @Published var showFocusShield: Bool = false
    @Published var showInsights: Bool = false
    @Published var showThemeSelection: Bool = false
    
    // Level up celebration
    @Published var showLevelUpCelebration: Bool = false
    @Published var levelUpFrom: Int = 0
    
    // Daily login rewards
    @Published var showDailyLoginReward: Bool = false
    @Published var dailyLoginGems: Int = 0
    @Published var dailyLoginStreak: Int = 0
    
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
    
    // Network & Offline support
    @Published var isOnline: Bool = true
    @Published var pendingSyncCount: Int = 0
    
    // Color scheme preference
    @Published var colorScheme: ColorScheme? = .dark
    
    // Notification settings
    @Published var notificationsEnabled: Bool = true
    @Published var reminderHour: Int = 9
    @Published var reminderMinute: Int = 0
    @Published var streakWarningEnabled: Bool = true
    @Published var heartRefillNotifications: Bool = true
    @Published var badgeNotifications: Bool = true
    
    // Notification manager instance
    let notificationManager = NotificationManager.shared
    
    // Supabase client - use global supabase client from SupabaseService
    private let networkMonitor = NetworkMonitor.shared
    private let syncQueue = SyncQueue.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case progress = "Progress"
        case path = "Path"
        case screenTime = "Focus"
        case practice = "Practice"
        case profile = "Profile"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .progress: return "chart.line.uptrend.xyaxis"
            case .path: return "map.fill"
            case .screenTime: return "hourglass"
            case .practice: return "brain.head.profile"
            case .profile: return "person.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    init() {
        setupNetworkMonitoring()
        loadUserData()
    }
    
    private func setupNetworkMonitoring() {
        // Monitor network changes
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isOnline = isConnected
                if isConnected {
                    // Try to sync when back online
                    Task { @MainActor in
                        await self?.processSyncQueue()
                    }
                }
            }
            .store(in: &cancellables)
        
        // Monitor pending sync count
        syncQueue.$pendingOperations
            .receive(on: DispatchQueue.main)
            .map { $0.count }
            .assign(to: &$pendingSyncCount)
    }
    
    /// Process queued sync operations
    func processSyncQueue() async {
        guard isOnline, isAuthenticated, let userId = currentUser?.id else { return }
        
        await syncQueue.processQueue(supabaseService: SupabaseService.shared, userId: userId)
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String) async {
        
        isLoading = true
        
        do {
            let response = try await supabase.auth.signUp(email: email, password: password)
            isLoading = false
            
            // If sign up successful and we have a session, create profile
            if let session = response.session {
                isAuthenticated = true
                currentUser = User(
                    id: session.user.id.uuidString,
                    email: email,
                    createdAt: Date(),
                    goal: nil,
                    isPremium: false,
                    onboardingData: nil
                )
                
                // Create profile in Supabase
                try await createUserProfile(userId: session.user.id.uuidString, email: email)
                
                // Initialize game progress in Supabase
                await initializeGameProgress(userId: session.user.id.uuidString)
                
                // Save locally
                saveData()
            }
        } catch {
            isLoading = false
            syncError = error.localizedDescription
        }
    }
    
    private func createUserProfile(userId: String, email: String) async throws {
        
        
        let profile = Profile(id: userId, email: email, isPremium: false, gems: 0)
        
        try await supabase.from("profiles").insert(profile).execute()
    }
    
    private func initializeGameProgress(userId: String) async {
        
        
        let progress = GameProgressRecord(
            userId: userId,
            level: 1,
            xp: 0,
            totalXp: 0,
            streak: 0,
            longestStreak: 0,
            lastSessionDate: nil,
            streakFreezeUsed: false,
            totalSessionsCompleted: 0,
            totalChallengesCompleted: 0,
            updatedAt: Date()
        )
        
        do {
            try await supabase.from("game_progress").insert(progress).execute()
        } catch {
            print("Error initializing game progress: \(error)")
        }
        
        // Initialize heart state
        let heartState = HeartStateRecord(
            userId: userId,
            currentHearts: 5,
            maxHearts: 5,
            lastHeartLost: nil,
            lastMidnightReset: nil,
            perfectStreakCount: 0,
            totalLost: 0,
            totalGained: 0,
            updatedAt: Date()
        )
        
        do {
            try await supabase.from("heart_state").insert(heartState).execute()
        } catch {
            print("Error initializing heart state: \(error)")
        }
    }
    
    func signIn(email: String, password: String) async {
        
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
        
        
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
            isSyncing = false
        } catch {
            syncError = error.localizedDescription
        }
    }
    
    func checkAuthStatus() async {
        
        
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
        }
    }
    
    /// Queue a sync operation for later (when offline)
    func queueSyncOperation(_ operation: SyncOperation) {
        syncQueue.enqueue(operation)
    }
    
    func syncToCloud(userId: String) async {
        // If offline, queue the operation for later
        guard isOnline else {
            // Queue gems update
            if let gems = progress?.gems {
                let operation = SyncOperation(type: .updateGems(gems: gems))
                queueSyncOperation(operation)
            }
            // Queue skill progress update
            if let prog = progress {
                let skillOp = SyncOperation(type: .updateSkillProgress(
                    focus: prog.focusScore,
                    impulse: prog.impulseControlScore,
                    distraction: prog.distractionResistanceScore
                ))
                queueSyncOperation(skillOp)
            }
            return
        }
        
        
        isSyncing = true
        
        do {
            // Update profile (gems)
            try await supabase
                .from("profiles")
                .update(["gems": progress?.gems ?? 0])
                .eq("id", value: userId)
                .execute()
            
            // Sync skill progress to cloud
            if let prog = progress {
                let skillData = SkillProgressRecord(
                    userId: userId,
                    focusScore: prog.focusScore,
                    impulseControlScore: prog.impulseControlScore,
                    distractionResistanceScore: prog.distractionResistanceScore,
                    updatedAt: Date()
                )
                
                // Upsert skill progress
                try await supabase
                    .from("skill_progress")
                    .upsert(skillData, onConflict: "user_id")
                    .execute()
            }
            
            isSyncing = false
        } catch {
            isSyncing = false
            // Queue for retry when back online
            if let gems = progress?.gems {
                let operation = SyncOperation(type: .updateGems(gems: gems))
                queueSyncOperation(operation)
            }
            // Queue skill progress for retry
            if let prog = progress {
                let skillOp = SyncOperation(type: .updateSkillProgress(
                    focus: prog.focusScore,
                    impulse: prog.impulseControlScore,
                    distraction: prog.distractionResistanceScore
                ))
                queueSyncOperation(skillOp)
            }
            syncError = error.localizedDescription
        }
    }
    
    // MARK: - Data Management
    
    func loadUserData() {
        // Load notification settings first
        loadNotificationSettings()
        
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "focusflow_user"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isOnboarded = user.goal != nil
            
            // If we have a user, check if authenticated and sync from cloud
            if let userId = currentUser?.id, !userId.isEmpty {
                isAuthenticated = true
                // Sync from cloud in background
                Task {
                    await syncFullProgressFromCloud(userId: userId)
                }
            }
        }
        
        if let progressData = UserDefaults.standard.data(forKey: "focusflow_progress"),
           let prog = try? JSONDecoder().decode(GameProgress.self, from: progressData) {
            progress = prog
        }
        
        // Check for daily login reward after loading user data
        checkDailyLoginReward()
        
        // Configure notifications if enabled
        configureNotifications()
        
        isLoading = false
    }
    
    /// Full sync from cloud - fetches all progress data and merges with local
    func syncFullProgressFromCloud(userId: String) async {
        
        isSyncing = true
        
        do {
            // Fetch all data from cloud in parallel
            async let progressTask = fetchGameProgressRecord(userId: userId)
            async let profileTask = fetchProfile(userId: userId)
            async let skillTask = fetchSkillProgressRecord(userId: userId)
            async let heartTask = fetchHeartStateRecord(userId: userId)
            
            let (cloudProgress, cloudProfile, cloudSkills, cloudHearts) = try await (
                progressTask, profileTask, skillTask, heartTask
            )
            
            // Merge with local progress
            if var localProgress = progress {
                // Merge game progress - prefer higher values
                if let cloud = cloudProgress {
                    localProgress.totalXP = max(localProgress.totalXP, cloud.totalXp)
                    localProgress.streakDays = max(localProgress.streakDays, cloud.streak)
                    localProgress.level = max(localProgress.level, cloud.level)
                }
                
                // Merge gems - prefer higher
                if let profile = cloudProfile, let cloudGems = profile.gems {
                    localProgress.gems = max(localProgress.gems, cloudGems)
                }
                
                // Merge skills - prefer higher scores
                if let skills = cloudSkills {
                    localProgress.focusScore = max(localProgress.focusScore, skills.focusScore)
                    localProgress.impulseControlScore = max(localProgress.impulseControlScore, skills.impulseControlScore)
                    localProgress.distractionResistanceScore = max(localProgress.distractionResistanceScore, skills.distractionResistanceScore)
                }
                
                // Merge hearts - prefer higher
                if let hearts = cloudHearts {
                    localProgress.hearts = max(localProgress.hearts, hearts.currentHearts)
                }
                
                progress = localProgress
                saveData()
            }
            
            isSyncing = false
        } catch {
            isSyncing = false
            syncError = error.localizedDescription
        }
    }
    
    // MARK: - Cloud Fetch Helpers
    
    private func fetchGameProgressRecord(userId: String) async throws -> GameProgressRecord? {
        
        
        let records: [GameProgressRecord] = try await supabase
            .from("game_progress")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return records.first
    }
    
    private func fetchProfile(userId: String) async throws -> Profile? {
        
        
        let records: [Profile] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        return records.first
    }
    
    private func fetchSkillProgressRecord(userId: String) async throws -> SkillProgressRecord? {
        
        
        let records: [SkillProgressRecord] = try await supabase
            .from("skill_progress")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return records.first
    }
    
    private func fetchHeartStateRecord(userId: String) async throws -> HeartStateRecord? {
        
        
        let records: [HeartStateRecord] = try await supabase
            .from("heart_state")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return records.first
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
        progress = GameProgress(
            level: 1,
            totalXP: 0,
            streakDays: 0,
            lastActivityDate: nil,
            hearts: 5,
            gems: 0,
            completedChallenges: [],
            skills: [:],
            focusScore: GameProgress.defaultFocusScore,
            impulseControlScore: GameProgress.defaultImpulseControlScore,
            distractionResistanceScore: GameProgress.defaultDistractionResistanceScore,
            streakFreezeUsed: false
        )
        
        saveData()
    }
    
    func updateStreak() {
        guard var prog = progress else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var oldStreak = prog.streakDays
        
        if let lastDate = prog.lastActivityDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            
            if lastDay == today {
                // Already played today, no change
                return
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                      lastDay == yesterday {
                // Played yesterday, increment streak
                prog.streakDays += 1
            } else {
                // Streak broken, reset to 1
                prog.streakDays = 1
            }
        } else {
            // First time playing
            prog.streakDays = 1
        }
        
        // Award streak bonus gems if we hit a milestone
        if let milestoneName = prog.streakMilestoneName {
            prog.gems += prog.streakBonusGems
            print("🎉 \(milestoneName) Bonus: +\(prog.streakBonusGems) gems!")
            
            // Trigger streak milestone notification
            notificationManager.scheduleStreakMilestoneNotification(streakDays: prog.streakDays)
        }
        
        prog.lastActivityDate = Date()
        progress = prog
        saveData()
    }
    
    func resetProgress() {
        progress?.streakDays = 0
        progress?.totalXP = 0
        progress?.hearts = 5
        progress?.level = 1
        progress?.focusScore = GameProgress.defaultFocusScore
        progress?.impulseControlScore = GameProgress.defaultImpulseControlScore
        progress?.distractionResistanceScore = GameProgress.defaultDistractionResistanceScore
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
        
        // Save notification settings
        UserDefaults.standard.set(notificationsEnabled, forKey: "focusflow_notifications_enabled")
        UserDefaults.standard.set(reminderHour, forKey: "focusflow_reminder_hour")
        UserDefaults.standard.set(reminderMinute, forKey: "focusflow_reminder_minute")
        UserDefaults.standard.set(streakWarningEnabled, forKey: "focusflow_streak_warning")
        UserDefaults.standard.set(heartRefillNotifications, forKey: "focusflow_heart_refill")
        UserDefaults.standard.set(badgeNotifications, forKey: "focusflow_badge_notifications")
        
        // Configure notifications based on settings
        configureNotifications()
    }
    
    /// Load notification settings from UserDefaults
    func loadNotificationSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: "focusflow_notifications_enabled")
        reminderHour = UserDefaults.standard.integer(forKey: "focusflow_reminder_hour")
        reminderMinute = UserDefaults.standard.integer(forKey: "focusflow_reminder_minute")
        streakWarningEnabled = UserDefaults.standard.object(forKey: "focusflow_streak_warning") as? Bool ?? true
        heartRefillNotifications = UserDefaults.standard.object(forKey: "focusflow_heart_refill") as? Bool ?? true
        badgeNotifications = UserDefaults.standard.object(forKey: "focusflow_badge_notifications") as? Bool ?? true
        
        // Default reminder to 9 AM if not set
        if reminderHour == 0 && reminderMinute == 0 {
            reminderHour = 9
        }
    }
    
    /// Configure local notifications based on current settings
    func configureNotifications() {
        guard notificationsEnabled else {
            notificationManager.cancelAllNotifications()
            return
        }
        
        // Schedule daily reminder
        notificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
        
        // Schedule streak warning if enabled
        if streakWarningEnabled {
            notificationManager.scheduleStreakWarning()
        }
    }
    
    /// Request notification authorization from user
    func requestNotificationPermission() async {
        let granted = await notificationManager.requestAuthorization()
        if granted {
            configureNotifications()
        }
    }
    
    // MARK: - Daily Login Rewards
    
    /// Check and award daily login rewards - call after user is loaded
    func checkDailyLoginReward() {
        guard let _ = currentUser, let prog = progress else { return }
        
        let lastLoginKey = "focusflow_last_login_\(currentUser?.id ?? "default")"
        let lastLoginDate = UserDefaults.standard.object(forKey: lastLoginKey) as? Date
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if already claimed today
        if let lastLogin = lastLoginDate {
            let lastLoginDay = calendar.startOfDay(for: lastLogin)
            if lastLoginDay == today {
                // Already claimed today
                return
            }
            
            // Check if it's a consecutive day (within 2 days to account for timezone)
            let daysDifference = calendar.dateComponents([.day], from: lastLoginDay, to: today).day ?? 0
            if daysDifference > 1 {
                // Streak broken - reset to day 1
                dailyLoginStreak = 1
            } else {
                // Consecutive day - increment streak
                dailyLoginStreak = prog.streakDays > 0 ? prog.streakDays : 1
            }
        } else {
            // First login ever
            dailyLoginStreak = 1
        }
        
        // Calculate rewards based on streak
        // Day 1: 5 gems, Day 2: 10 gems, Day 3: 15 gems... up to 50 gems max
        // Bonus XP: 25 XP per day
        let baseGems = 5
        let gemBonus = min(dailyLoginStreak * 5, 50) // Max 50 gems
        dailyLoginGems = baseGems + gemBonus
        
        // Award the gems
        addGems(dailyLoginGems)
        
        // Add bonus XP
        addXP(25)
        
        // Save last login date
        UserDefaults.standard.set(Date(), forKey: lastLoginKey)
        
        // Show the reward (only if this is the first check after login, not every time)
        if !showDailyLoginReward && !showLevelUpCelebration {
            showDailyLoginReward = true
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
    
    // MARK: - Gem Purchases
    
    /// Purchase streak freeze (protects streak for one day even if user doesn't play)
    func purchaseStreakFreeze() -> Bool {
        let cost = 25
        guard spendGems(cost) else { return false }
        
        guard var prog = progress else { return false }
        prog.streakFreezeUsed = false  // Reset for new use
        progress = prog
        saveData()
        return true
    }
    
    /// Purchase hearts with gems
    func purchaseHeart() -> Bool {
        let cost = 15
        guard spendGems(cost) else { return false }
        
        addHeart()  // Uses existing addHeart method
        return true
    }
    
    /// Purchase full heart refill (restore to 5 hearts)
    func purchaseHeartRefill() -> Bool {
        let cost = 50
        guard var prog = progress else { return false }
        
        let heartsNeeded = 5 - prog.hearts
        guard heartsNeeded > 0 else { return false }  // Already full
        
        let costTotal = cost  // Flat rate for full refill
        guard spendGems(costTotal) else { return false }
        
        prog.hearts = 5
        progress = prog
        saveData()
        return true
    }
    
    /// Get gem balance
    var gemBalance: Int {
        progress?.gems ?? 0
    }
    
    // MARK: - Hearts System
    
    func loseHeart() {
        guard var prog = progress else { return }
        if prog.hearts > 0 {
            prog.hearts -= 1
            progress = prog
            saveData()
        }
    }
    
    func addHeart() {
        guard var prog = progress else { return }
        if prog.hearts < 5 {
            prog.hearts += 1
            progress = prog
            saveData()
        }
    }
    
    func refillHearts() {
        guard var prog = progress else { return }
        prog.hearts = 5
        progress = prog
        saveData()
    }
    
    // MARK: - Skill Progress
    
    func updateSkillProgress(_ prog: inout GameProgress, type: AllChallengeType, score: Int) {
        // Map challenge categories to skills
        switch type.category {
        case .focus:
            prog.incrementSkill(.focus, performanceScore: score)
            prog.incrementSkill(.distractionResistance, performanceScore: score)
        case .memory:
            prog.incrementSkill(.focus, performanceScore: score)
        case .reaction:
            prog.incrementSkill(.focus, performanceScore: score)
            prog.incrementSkill(.impulseControl, performanceScore: score)
        case .breathing:
            prog.incrementSkill(.impulseControl, performanceScore: score)
            prog.incrementSkill(.distractionResistance, performanceScore: score)
        case .discipline:
            prog.incrementSkill(.impulseControl, performanceScore: score)
        case .speed:
            prog.incrementSkill(.focus, performanceScore: score)
        case .impulse:
            prog.incrementSkill(.impulseControl, performanceScore: score)
        case .calm:
            prog.incrementSkill(.distractionResistance, performanceScore: score)
            prog.incrementSkill(.distractionResistance, performanceScore: score)
        }
    }
    
    // MARK: - XP & Leveling
    
    func addXP(_ amount: Int) {
        guard var prog = progress else { return }
        let previousLevel = prog.level
        prog.totalXP += amount
        
        // Check for level up
        let xpForNextLevel = prog.level * 100
        if prog.totalXP >= xpForNextLevel {
            prog.level += 1
            // Bonus gems on level up
            prog.gems += 10
            // Trigger level up celebration
            if prog.level > previousLevel {
                levelUpFrom = previousLevel
                showLevelUpCelebration = true
                // Trigger level up notification
                notificationManager.scheduleLevelUpNotification(newLevel: prog.level)
            }
        }
        
        progress = prog
        saveData()
    }
    
    // MARK: - Challenge Completion
    
    func completeChallenge(type: AllChallengeType, score: Int, xpEarned: Int) {
        guard var prog = progress else { return }
        let previousLevel = prog.level
        
        // Add XP
        prog.totalXP += xpEarned
        
        // Check level up
        let xpForNextLevel = prog.xpForNextLevel
        if prog.totalXP >= xpForNextLevel {
            prog.level += 1
            prog.gems += 10 // Level up bonus
            // Trigger level up celebration
            if prog.level > previousLevel {
                levelUpFrom = previousLevel
                showLevelUpCelebration = true
            }
        }
        
        // Add to completed challenges
        let attempt = ChallengeAttempt(
            id: UUID().uuidString,
            challengeTypeRaw: type.rawValue,
            level: prog.level,
            score: score,
            duration: 0,
            isPerfect: score >= 100,
            xpEarned: xpEarned,
            attemptedAt: Date()
        )
        prog.completedChallenges.append(attempt)
        
        // Update skill progress based on challenge type
        updateSkillProgress(&prog, type: type, score: score)
        
        // Update streak
        updateStreak()
        
        // Award gems based on score
        let gemsEarned = score / 10
        prog.gems += gemsEarned
        
        progress = prog
        saveData()
        
        // Check and unlock achievements
        achievementStore.checkAndUnlock(progress: prog)
        
        // Sync to cloud if authenticated
        if isAuthenticated, let userId = currentUser?.id {
            Task {
                await syncToCloud(userId: userId)
            }
        }
    }
    
    // MARK: - Daily Challenges
    
    func generateDailyChallengesIfNeeded() {
        guard var prog = progress else { return }
        prog.generateDailyChallenges()
        progress = prog
        saveData()
    }
    
    func getDailyChallenges() -> [DailyChallenge] {
        generateDailyChallengesIfNeeded()
        return progress?.dailyChallenges ?? []
    }
    
    func completeDailyChallenge(_ challengeType: AllChallengeType, score: Int) {
        guard var prog = progress else { return }
        
        // Find and complete the daily challenge
        if let index = prog.dailyChallenges?.firstIndex(where: { $0.challengeType == challengeType && !$0.isCompleted }) {
            prog.dailyChallenges?[index].isCompleted = true
            prog.dailyChallenges?[index].score = score
            
            let xpReward = prog.dailyChallenges?[index].xpReward ?? 20
            let gemReward = prog.dailyChallenges?[index].gemReward ?? 2
            
            prog.dailyChallenges?[index].xpEarned = xpReward
            prog.totalXP += xpReward
            prog.gems += gemReward
            
            // Check level up
            let previousLevel = prog.level
            if prog.totalXP >= prog.xpForNextLevel {
                prog.level += 1
                prog.gems += 10
                // Trigger level up celebration
                if prog.level > previousLevel {
                    levelUpFrom = previousLevel
                    showLevelUpCelebration = true
                }
            }
            
            // Update streak
            updateStreak()
            
            progress = prog
            saveData()
            
            // Check and unlock achievements
            achievementStore.checkAndUnlock(progress: prog)
            
            // Sync to cloud
            if isAuthenticated, let userId = currentUser?.id {
                Task {
                    await syncToCloud(userId: userId)
                }
            }
        }
    }
    
    var dailyChallengeProgress: (completed: Int, total: Int) {
        guard let prog = progress else { return (0, 0) }
        return (prog.dailyChallengesCompleted, prog.dailyChallengesTotal)
    }
    
    var allDailyChallengesCompleted: Bool {
        progress?.allDailyChallengesCompleted ?? false
    }
}
