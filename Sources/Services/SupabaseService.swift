import Foundation
import Supabase

// Lazy Supabase client - only initialized when first accessed
// This improves app launch time by deferring network client creation
var supabase: SupabaseClient {
    if _supabaseClient == nil {
        _supabaseClient = SupabaseClient(
            supabaseURL: URL(string: AppConfig.supabaseUrl)!,
            supabaseKey: AppConfig.supabaseAnonKey
        )
    }
    return _supabaseClient!
}

private var _supabaseClient: SupabaseClient?

// MARK: - Database Models (matching Supabase schema)

struct Profile: Codable, Identifiable {
    var id: String
    var email: String?
    var createdAt: Date?
    var goal: String?
    var isPremium: Bool?
    var updatedAt: Date?
    var gems: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, email, goal, gems
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isPremium = "is_premium"
    }
}

struct GameProgressRecord: Codable, Identifiable {
    var id: String { userId }
    var userId: String
    var level: Int
    var xp: Int
    var totalXp: Int
    var streak: Int
    var longestStreak: Int
    var lastSessionDate: Date?
    var streakFreezeUsed: Bool?
    var totalSessionsCompleted: Int
    var totalChallengesCompleted: Int
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case level, xp
        case totalXp = "total_xp"
        case streak
        case longestStreak = "longest_streak"
        case lastSessionDate = "last_session_date"
        case streakFreezeUsed = "streak_freeze_used"
        case totalSessionsCompleted = "total_sessions_completed"
        case totalChallengesCompleted = "total_challenges_completed"
        case updatedAt = "updated_at"
    }
}

struct SkillProgressRecord: Codable, Identifiable {
    var id: String { userId }
    var userId: String
    var focusScore: Int
    var impulseControlScore: Int
    var distractionResistanceScore: Int
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case focusScore = "focus_score"
        case impulseControlScore = "impulse_control_score"
        case distractionResistanceScore = "distraction_resistance_score"
        case updatedAt = "updated_at"
    }
}

struct HeartStateRecord: Codable, Identifiable {
    var id: String { userId }
    var userId: String
    var currentHearts: Int
    var maxHearts: Int
    var lastHeartLost: Date?
    var lastMidnightReset: Date?
    var perfectStreakCount: Int
    var totalLost: Int
    var totalGained: Int
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case currentHearts = "current_hearts"
        case maxHearts = "max_hearts"
        case lastHeartLost = "last_heart_lost"
        case lastMidnightReset = "last_midnight_reset"
        case perfectStreakCount = "perfect_streak_count"
        case totalLost = "total_lost"
        case totalGained = "total_gained"
        case updatedAt = "updated_at"
    }
}

// MARK: - Supabase Service

@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false
    @Published var currentUserId: String?
    
    private init() {}
    
    /// Get the Supabase client (instance or global)
    private var client: SupabaseClient {
        return supabase // Uses global
    }
    
    // MARK: - User Management
    
    /// Sign up a new user
    func signUp(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response = try await supabase.auth.signUp(email: email, password: password)
        if let session = response.session {
            currentUserId = session.user.id.uuidString
        }
    }
    
    /// Sign in existing user
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let session = try await supabase.auth.signIn(email: email, password: password)
        currentUserId = session.user.id.uuidString
        isConnected = true
    }
    
    /// Sign out
    func signOut() async throws {
        try await supabase.auth.signOut()
        currentUserId = nil
        isConnected = false
    }
    
    /// Get current session
    func getCurrentSession() async -> Session? {
        do {
            let session = try await supabase.auth.session
            currentUserId = session.user.id.uuidString
            isConnected = true
            return session
        } catch {
            return nil
        }
    }
    
    // MARK: - Profile Operations
    
    /// Fetch user profile
    func fetchProfile(userId: String) async throws -> Profile? {
        let response: [Profile] = try await supabase
            .database
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        return response.first
    }
    
    /// Update user profile
    func updateProfile(userId: String, updates: Profile) async throws {
        try await supabase
            .database
            .from("profiles")
            .update(updates)
            .eq("id", value: userId)
            .execute()
    }
    
    /// Update gems
    func updateGems(userId: String, gems: Int) async throws {
        try await supabase
            .database
            .from("profiles")
            .update(Profile(id: userId, gems: gems))
            .eq("id", value: userId)
            .execute()
    }
    
    // MARK: - Game Progress Operations
    
    /// Fetch game progress
    func fetchGameProgress(userId: String) async throws -> GameProgressRecord? {
        let response: [GameProgressRecord] = try await supabase
            .database
            .from("game_progress")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return response.first
    }
    
    /// Update game progress
    func updateGameProgress(userId: String, progress: GameProgressRecord) async throws {
        try await supabase
            .database
            .from("game_progress")
            .update(progress)
            .eq("user_id", value: userId)
            .execute()
    }
    
    /// Create or update game progress
    func upsertGameProgress(_ progress: GameProgressRecord) async throws {
        try await supabase
            .database
            .from("game_progress")
            .upsert(progress, onConflict: "user_id")
            .execute()
    }
    
    // MARK: - Skill Progress Operations
    
    /// Fetch skill progress
    func fetchSkillProgress(userId: String) async throws -> SkillProgressRecord? {
        let response: [SkillProgressRecord] = try await supabase
            .database
            .from("skill_progress")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return response.first
    }
    
    /// Update skill progress
    func updateSkillProgress(userId: String, focusScore: Int, impulseControlScore: Int, distractionResistanceScore: Int) async throws {
        let skillData = SkillProgressRecord(
            userId: userId,
            focusScore: focusScore,
            impulseControlScore: impulseControlScore,
            distractionResistanceScore: distractionResistanceScore,
            updatedAt: Date()
        )
        
        try await supabase
            .database
            .from("skill_progress")
            .upsert(skillData, onConflict: "user_id")
            .execute()
    }
    
    // MARK: - Heart State Operations
    
    /// Fetch heart state
    func fetchHeartState(userId: String) async throws -> HeartStateRecord? {
        let response: [HeartStateRecord] = try await supabase
            .database
            .from("heart_state")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return response.first
    }
    
    /// Update heart state
    func updateHeartState(userId: String, currentHearts: Int) async throws {
        try await supabase
            .database
            .from("heart_state")
            .update(["current_hearts": currentHearts])
            .eq("user_id", value: userId)
            .execute()
    }
    
    // MARK: - Challenge Results
    
    /// Challenge result to save
    struct ChallengeResultInput: Encodable {
        let userId: String
        let challengeType: String
        let score: Int
        let duration: Int
        let xpEarned: Int
        let isPerfect: Bool
        let accuracy: Double?
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case challengeType = "challenge_type"
            case score
            case duration
            case xpEarned = "xp_earned"
            case isPerfect = "is_perfect"
            case accuracy
        }
    }
    
    /// Save challenge result
    func saveChallengeResult(
        userId: String,
        challengeType: String,
        score: Int,
        duration: Int,
        xpEarned: Int,
        isPerfect: Bool,
        accuracy: Double?
    ) async throws {
        let result = ChallengeResultInput(
            userId: userId,
            challengeType: challengeType,
            score: score,
            duration: duration,
            xpEarned: xpEarned,
            isPerfect: isPerfect,
            accuracy: accuracy
        )
        
        try await supabase
            .database
            .from("challenge_results")
            .insert(result)
            .execute()
    }
    
    // MARK: - Sync Local Data to Cloud
    
    /// Sync all local data to Supabase
    func syncToCloud(userId: String, gameProgress: GameProgress) async throws {
        let progressRecord = GameProgressRecord(
            userId: userId,
            level: gameProgress.level,
            xp: gameProgress.totalXP,
            totalXp: gameProgress.totalXP,
            streak: gameProgress.streakDays,
            longestStreak: gameProgress.streakDays,
            lastSessionDate: gameProgress.lastActivityDate,
            streakFreezeUsed: false,
            totalSessionsCompleted: gameProgress.completedChallenges.count,
            totalChallengesCompleted: gameProgress.completedChallenges.count,
            updatedAt: Date()
        )
        
        try await upsertGameProgress(progressRecord)
        
        // Update gems
        try await updateGems(userId: userId, gems: gameProgress.gems)
    }
    
    /// Fetch all data from cloud
    func fetchFromCloud(userId: String) async throws -> (GameProgressRecord?, Profile?, SkillProgressRecord?, HeartStateRecord?) {
        async let progress = fetchGameProgress(userId: userId)
        async let profile = fetchProfile(userId: userId)
        async let skills = fetchSkillProgress(userId: userId)
        async let hearts = fetchHeartState(userId: userId)
        
        return try await (progress, profile, skills, hearts)
    }
    
    // MARK: - Leaderboard Operations
    
    /// Leaderboard entry model
    struct LeaderboardEntryData: Codable, Identifiable {
        var id: String { userId }
        let userId: String
        let displayName: String
        let avatarEmoji: String?
        let totalXp: Int
        let level: Int
        let streak: Int
        let rank: Int
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case displayName = "display_name"
            case avatarEmoji = "avatar_emoji"
            case totalXp = "total_xp"
            case level
            case streak
            case rank
        }
    }
    
    /// Fetch global leaderboard
    func fetchLeaderboard(limit: Int = 50) async throws -> [LeaderboardEntryData] {
        // Try to fetch from user_stats view/table
        let response: [LeaderboardEntryData] = try await supabase
            .from("user_stats")
            .select("user_id, display_name, avatar_emoji, total_xp, level, streak")
            .order("total_xp", ascending: false)
            .limit(limit)
            .execute()
            .value
        
        // Add rank based on order
        return response.enumerated().map { index, entry in
            LeaderboardEntryData(
                userId: entry.userId,
                displayName: entry.displayName,
                avatarEmoji: entry.avatarEmoji,
                totalXp: entry.totalXp,
                level: entry.level,
                streak: entry.streak,
                rank: index + 1
            )
        }
    }
    
    /// Fetch user's rank
    func fetchUserRank(userId: String) async throws -> Int {
        let allUsers: [LeaderboardEntryData] = try await supabase
            .from("user_stats")
            .select("user_id, total_xp")
            .order("total_xp", ascending: false)
            .execute()
            .value
        
        for (index, user) in allUsers.enumerated() {
            if user.userId == userId {
                return index + 1
            }
        }
        return allUsers.count + 1
    }
}
