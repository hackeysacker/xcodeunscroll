import SwiftUI
import Combine
import Supabase

@MainActor
class AppState: ObservableObject {
    @Published var isOnboarded: Bool = true
    @Published var isLoading: Bool = true
    @Published var currentUser: User?
    @Published var progress: GameProgress?
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
    
    // Supabase client
    private let supabaseUrl = "https://sxgpcsfwbzptlmwfddda.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4Z3Bjc2Z3YnpwdGxtd2ZkZGRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3NTI0NzYsImV4cCI6MjA3OTMyODQ3Nn0.kkQc632Gu8ozuCD5HoZVS35yGbxA4l2kmuq96bCBg4w"
    
    private var supabase: SupabaseClient?
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case progress = "Progress"
        case path = "Path"
        case screenTime = "Focus"
        case practice = "Practice"
        case profile = "Profile"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .progress: return "chart.line.uptrend.xyaxis"
            case .path: return "map.fill"
            case .screenTime: return "hourglass"
            case .practice: return "brain.head.profile"
            case .profile: return "person.fill"
            }
        }
    }
    
    init() {
        setupSupabase()
        loadUserData()
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
        }
    }
    
    // MARK: - Data Management
    
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
        }
        
        isLoading = false
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
            skills: [:]
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
        
        // Update streak
        updateStreak()
        
        // Award gems based on score
        let gemsEarned = score / 10
        prog.gems += gemsEarned
        
        progress = prog
        saveData()
        
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
