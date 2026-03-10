import Foundation

struct GameProgress: Codable {
    var level: Int
    var totalXP: Int
    var streakDays: Int
    var lastActivityDate: Date?
    var hearts: Int
    var gems: Int
    var completedChallenges: [ChallengeAttempt]
    var skills: [String: Int]
    
    // Skill scores (0-100)
    var focusScore: Int
    var impulseControlScore: Int
    var distractionResistanceScore: Int
    
    // Daily challenges
    var dailyChallenges: [DailyChallenge]?
    var lastDailyRefreshDate: Date?
    
    // Streak protection
    var streakFreezeUsed: Bool  // True if streak freeze was used today
    
    // Default skill values
    static let defaultFocusScore = 10
    static let defaultImpulseControlScore = 10
    static let defaultDistractionResistanceScore = 10
    
    // Default initializer
    init() {
        self.level = 1
        self.totalXP = 0
        self.streakDays = 0
        self.lastActivityDate = nil
        self.hearts = 5
        self.gems = 0
        self.completedChallenges = []
        self.skills = [:]
        self.focusScore = Self.defaultFocusScore
        self.impulseControlScore = Self.defaultImpulseControlScore
        self.distractionResistanceScore = Self.defaultDistractionResistanceScore
        self.dailyChallenges = nil
        self.lastDailyRefreshDate = nil
        self.streakFreezeUsed = false
    }
    
    // Memberwise initializer
    init(level: Int, totalXP: Int, streakDays: Int, lastActivityDate: Date? = nil, hearts: Int, gems: Int, completedChallenges: [ChallengeAttempt], skills: [String: Int], focusScore: Int, impulseControlScore: Int, distractionResistanceScore: Int, dailyChallenges: [DailyChallenge]? = nil, lastDailyRefreshDate: Date? = nil, streakFreezeUsed: Bool) {
        self.level = level
        self.totalXP = totalXP
        self.streakDays = streakDays
        self.lastActivityDate = lastActivityDate
        self.hearts = hearts
        self.gems = gems
        self.completedChallenges = completedChallenges
        self.skills = skills
        self.focusScore = focusScore
        self.impulseControlScore = impulseControlScore
        self.distractionResistanceScore = distractionResistanceScore
        self.dailyChallenges = dailyChallenges
        self.lastDailyRefreshDate = lastDailyRefreshDate
        self.streakFreezeUsed = streakFreezeUsed
    }
    
    var xpForNextLevel: Int {
        return level * 100 + (level - 1) * 50
    }
    
    var currentLevelXP: Int {
        var xp = 0
        for i in 1..<level {
            xp += i * 100 + (i - 1) * 50
        }
        return totalXP - xp
    }
    
    var progressToNextLevel: Double {
        let needed = xpForNextLevel
        guard needed > 0 else { return 1.0 }
        return min(Double(currentLevelXP) / Double(needed), 1.0)
    }
}

struct ChallengeAttempt: Codable, Identifiable {
    var id: String
    var challengeTypeRaw: String
    var level: Int
    var score: Int
    var duration: TimeInterval
    var isPerfect: Bool
    var xpEarned: Int
    var attemptedAt: Date
    
    var challenge: AllChallengeType {
        AllChallengeType.allCases.first { $0.rawValue == challengeTypeRaw } ?? .movingTarget
    }
}

enum Difficulty: String, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    case extreme = "extreme"
    
    var xpMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        case .extreme: return 3.0
        }
    }
}

// MARK: - Daily Challenge

struct DailyChallenge: Codable, Identifiable {
    var id: String { challengeType.rawValue }
    var challengeType: AllChallengeType
    var difficulty: Difficulty
    var isCompleted: Bool
    var score: Int?
    var xpEarned: Int?
    
    var title: String { challengeType.rawValue }
    var icon: String { challengeType.icon }
    var category: ChallengeCategory { challengeType.category }
    
    var xpReward: Int {
        switch difficulty {
        case .easy: return 20
        case .medium: return 35
        case .hard: return 50
        case .extreme: return 80
        }
    }
    
    var gemReward: Int {
        switch difficulty {
        case .easy: return 2
        case .medium: return 5
        case .hard: return 8
        case .extreme: return 15
        }
    }
}

extension GameProgress {
    mutating func generateDailyChallenges() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we already have today's challenges
        if let lastRefresh = lastDailyRefreshDate,
           calendar.isDate(lastRefresh, inSameDayAs: today),
           let existing = dailyChallenges, !existing.isEmpty {
            return
        }
        
        // Generate 3 random challenges for today
        let allChallenges = AllChallengeType.allCases
        var selectedChallenges: [DailyChallenge] = []
        
        // Seed random with today's date for consistency throughout the day
        let seed = calendar.component(.day, from: today) + 
                   calendar.component(.month, from: today) * 31 +
                   calendar.component(.year, from: today) * 366
        srand48(seed)
        
        // Select one challenge from each category
        let focusChallenges = allChallenges.filter { $0.category == .focus }
        let memoryChallenges = allChallenges.filter { $0.category == .memory }
        let reactionChallenges = allChallenges.filter { $0.category == .reaction }
        
        if let focus = focusChallenges.randomElement() {
            selectedChallenges.append(DailyChallenge(
                challengeType: focus,
                difficulty: .medium,
                isCompleted: false,
                score: nil,
                xpEarned: nil
            ))
        }
        
        if let memory = memoryChallenges.randomElement() {
            selectedChallenges.append(DailyChallenge(
                challengeType: memory,
                difficulty: .medium,
                isCompleted: false,
                score: nil,
                xpEarned: nil
            ))
        }
        
        if let reaction = reactionChallenges.randomElement() {
            selectedChallenges.append(DailyChallenge(
                challengeType: reaction,
                difficulty: .easy,
                isCompleted: false,
                score: nil,
                xpEarned: nil
            ))
        }
        
        dailyChallenges = selectedChallenges
        lastDailyRefreshDate = today
    }
    
    var dailyChallengesCompleted: Int {
        dailyChallenges?.filter { $0.isCompleted }.count ?? 0
    }
    
    var dailyChallengesTotal: Int {
        dailyChallenges?.count ?? 0
    }
    
    var allDailyChallengesCompleted: Bool {
        guard let challenges = dailyChallenges else { return false }
        return !challenges.isEmpty && challenges.allSatisfy { $0.isCompleted }
    }
    
    // MARK: - Streak Rewards
    
    /// Returns bonus gems for reaching streak milestones
    var streakBonusGems: Int {
        switch streakDays {
        case 7: return 50   // 1 week
        case 14: return 75  // 2 weeks
        case 30: return 150 // 1 month
        case 60: return 200 // 2 months
        case 100: return 500 // 100 days
        case 365: return 2000 // 1 year
        default: return 0
        }
    }
    
    /// Check if a streak milestone was just reached (call after incrementing streak)
    var justReachedMilestone: Bool {
        [7, 14, 30, 60, 100, 365].contains(streakDays)
    }
    
    /// Streak milestone name if at a milestone
    var streakMilestoneName: String? {
        switch streakDays {
        case 7: return "1 Week Streak!"
        case 14: return "2 Week Streak!"
        case 30: return "1 Month Streak!"
        case 60: return "2 Month Streak!"
        case 100: return "100 Day Streak!"
        case 365: return "1 Year Streak!"
        default: return nil
        }
    }
    
    // MARK: - Skill Progress
    
    /// Update skill score with a new value, capped at 100
    mutating func updateSkill(_ skillType: SkillType, score: Int) {
        let cappedScore = min(max(score, 0), 100)
        switch skillType {
        case .focus:
            focusScore = cappedScore
        case .impulseControl:
            impulseControlScore = cappedScore
        case .distractionResistance:
            distractionResistanceScore = cappedScore
        }
    }
    
    /// Increment skill score based on performance (0-100 score maps to 1-5 skill points)
    mutating func incrementSkill(_ skillType: SkillType, performanceScore: Int) {
        let currentScore: Int
        switch skillType {
        case .focus:
            currentScore = focusScore
        case .impulseControl:
            currentScore = impulseControlScore
        case .distractionResistance:
            currentScore = distractionResistanceScore
        }
        
        // Score 80+ = +5, 60+ = +3, 40+ = +2, <40 = +1
        let increment: Int
        if performanceScore >= 80 {
            increment = 5
        } else if performanceScore >= 60 {
            increment = 3
        } else if performanceScore >= 40 {
            increment = 2
        } else {
            increment = 1
        }
        
        let newScore = min(currentScore + increment, 100)
        updateSkill(skillType, score: newScore)
    }
    
    /// Get skill score for a specific type
    func getSkillScore(_ skillType: SkillType) -> Int {
        switch skillType {
        case .focus:
            return focusScore
        case .impulseControl:
            return impulseControlScore
        case .distractionResistance:
            return distractionResistanceScore
        }
    }
    
    /// Get skill level description
    func getSkillLevel(_ skillType: SkillType) -> String {
        let score = getSkillScore(skillType)
        switch score {
        case 0..<20: return "Beginner"
        case 20..<40: return "Developing"
        case 40..<60: return "Intermediate"
        case 60..<80: return "Advanced"
        case 80..<100: return "Expert"
        default: return "Master"
        }
    }
}

enum SkillType: String, CaseIterable {
    case focus = "Focus"
    case impulseControl = "Impulse Control"
    case distractionResistance = "Distraction Resistance"
    
    var description: String {
        switch self {
        case .focus: return "Your ability to concentrate on tasks"
        case .impulseControl: return "Your ability to resist urges"
        case .distractionResistance: return "Your ability to stay on task"
        }
    }
    
    var icon: String {
        switch self {
        case .focus: return "target"
        case .impulseControl: return "hand.raised.fill"
        case .distractionResistance: return "shield.fill"
        }
    }
}
