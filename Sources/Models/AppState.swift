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
    
    // Supabase client
    private let supabaseUrl = "https://sxgpcsfwbzptlmwfddda.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4Z3Bjc2Z3YnpwdGxtd2ZkZGRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3NTI0NzYsImV4cCI6MjA3OTMyODQ3Nn0.kkQc632Gu8ozuCD5HoZVS35yGbxA4l2kmuq96bCBg4w"
    
    private var supabase: SupabaseClient?
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
        setupSupabase()
        setupNetworkMonitoring()
        loadUserData()
    }
    
    private func setupSupabase() {
        supabase = SupabaseClient(
            supabaseURL: URL(string: supabaseUrl)!,
            supabaseKey: supabaseKey
        )
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
        guard let supabase = supabase else { return }
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
        guard let supabase = supabase else { return }
        
        let profile = Profile(id: userId, email: email, isPremium: false, gems: 0)
        
        try await supabase.from("profiles").insert(profile).execute()
    }
    
    private func initializeGameProgress(userId: String) async {
        guard let supabase = supabase else { return }
        
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
        
        guard let supabase = supabase else { return }
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
                let skillData: [String: Any] = [
                    "user_id": userId,
                    "focus_score": prog.focusScore,
                    "impulse_control_score": prog.impulseControlScore,
                    "distraction_resistance_score": prog.distractionResistanceScore,
                    "updated_at": ISO8601DateFormatter().string(from: Date())
                ]
                
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
        
        isLoading = false
    }
    
    /// Full sync from cloud - fetches all progress data and merges with local
    func syncFullProgressFromCloud(userId: String) async {
        guard let supabase = supabase else { return }
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
        guard let supabase = supabase else { return nil }
        
        let records: [GameProgressRecord] = try await supabase
            .from("game_progress")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return records.first
    }
    
    private func fetchProfile(userId: String) async throws -> Profile? {
        guard let supabase = supabase else { return nil }
        
        let records: [Profile] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        return records.first
    }
    
    private func fetchSkillProgressRecord(userId: String) async throws -> SkillProgressRecord? {
        guard let supabase = supabase else { return nil }
        
        let records: [SkillProgressRecord] = try await supabase
            .from("skill_progress")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return records.first
    }
    
    private func fetchHeartStateRecord(userId: String) async throws -> HeartStateRecord? {
        guard let supabase = supabase else { return nil }
        
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
        prog.totalXP += amount
        
        // Check for level up
        let xpForNextLevel = prog.level * 100
        if prog.totalXP >= xpForNextLevel {
            prog.level += 1
            // Bonus gems on level up
            prog.gems += 10
        }
        
        progress = prog
        saveData()
    }
    
    // MARK: - Challenge Completion
    
    func completeChallenge(type: AllChallengeType, score: Int, xpEarned: Int) {
        guard var prog = progress else { return }
        
        // Add XP
        prog.totalXP += xpEarned
        
        // Check level up
        let xpForNextLevel = prog.xpForNextLevel
        if prog.totalXP >= xpForNextLevel {
            prog.level += 1
            prog.gems += 10 // Level up bonus
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
            if prog.totalXP >= prog.xpForNextLevel {
                prog.level += 1
                prog.gems += 10
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
