import Foundation

// MARK: - Skill Types
enum SkillType: String, CaseIterable, Codable, Identifiable {
    case focus = "Focus"
    case impulseControl = "Impulse Control"
    case distractionResistance = "Distraction Resistance"
    case memory = "Memory"
    case reactionTime = "Reaction Time"
    case discipline = "Discipline"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .focus: return "Your ability to concentrate on tasks"
        case .impulseControl: return "Your ability to resist immediate urges"
        case .distractionResistance: return "Your ability to stay on task despite interruptions"
        case .memory: return "Your working memory capacity"
        case .reactionTime: return "Your speed of cognitive processing"
        case .discipline: return "Your overall self-discipline"
        }
    }
    
    var icon: String {
        switch self {
        case .focus: return "eye.fill"
        case .impulseControl: return "hand.raised.fill"
        case .distractionResistance: return "shield.fill"
        case .memory: return "brain.head.profile"
        case .reactionTime: return "bolt.fill"
        case .discipline: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .focus: return "6366F1" // Indigo
        case .impulseControl: return "EF4444" // Red
        case .distractionResistance: return "F59E0B" // Amber
        case .memory: return "3B82F6" // Blue
        case .reactionTime: return "10B981" // Emerald
        case .discipline: return "8B5CF6" // Purple
        }
    }
    
    /// Maps challenge categories to skills
    static func from(category: ChallengeCategory) -> [SkillType] {
        switch category {
        case .focus:
            return [.focus]
        case .memory:
            return [.memory]
        case .reaction:
            return [.reactionTime]
        case .breathing:
            return [.focus, .discipline]
        case .discipline:
            return [.impulseControl, .distractionResistance]
        }
    }
    
    /// Max level for any skill
    static let maxLevel = 100
}

// MARK: - Skill Progress
struct SkillProgress: Codable, Identifiable {
    var id: String { skillType.rawValue }
    let skillType: SkillType
    var level: Int
    var xp: Int
    var lastUpdated: Date
    
    var xpForNextLevel: Int {
        return level * 100 + (level - 1) * 25
    }
    
    var progressToNextLevel: Double {
        guard xpForNextLevel > 0 else { return 1.0 }
        return min(Double(xp) / Double(xpForNextLevel), 1.0)
    }
    
    var tier: SkillTier {
        switch level {
        case 0..<10: return .beginner
        case 10..<25: return .intermediate
        case 25..<50: return .advanced
        case 50..<75: return .expert
        default: return .master
        }
    }
    
    enum SkillTier: String {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
        case master = "Master"
        
        var icon: String {
            switch self {
            case .beginner: return "leaf.fill"
            case .intermediate: return "star.fill"
            case .advanced: return "sparkles"
            case .expert: return "crown.fill"
            case .master: return "burst.fill"
            }
        }
    }
    
    init(skillType: SkillType) {
        self.skillType = skillType
        self.level = 1
        self.xp = 0
        self.lastUpdated = Date()
    }
    
    mutating func addXP(_ amount: Int) {
        xp += amount
        lastUpdated = Date()
        
        // Check for level up
        while xp >= xpForNextLevel && level < SkillType.maxLevel {
            xp -= xpForNextLevel
            level += 1
        }
        
        // Cap at max
        if level >= SkillType.maxLevel {
            level = SkillType.maxLevel
            xp = xpForNextLevel
        }
    }
}

// MARK: - Game Progress
struct GameProgress: Codable {
    var level: Int
    var totalXP: Int
    var streakDays: Int
    var lastActivityDate: Date?
    var hearts: Int
    var gems: Int
    var completedChallenges: [ChallengeAttempt]
    var skills: [String: SkillProgress]
    
    // Heart refill system
    var lastHeartRefill: Date?
    var heartRefillSlots: Int  // Max 3 refill slots
    
    // Streak freeze (can use to preserve streak when missing a day)
    var streakFreezeUsed: Bool
    var streakFreezesAvailable: Int
    
    // Constants
    static let maxHearts = 5
    static let maxRefillSlots = 3
    static let refillIntervalMinutes = 30  // Hearts refill every 30 minutes
    
    init() {
        self.level = 1
        self.totalXP = 0
        self.streakDays = 0
        self.lastActivityDate = nil
        self.hearts = 5
        self.gems = 0
        self.completedChallenges = []
        self.skills = [:]
        self.lastHeartRefill = Date()
        self.heartRefillSlots = 3
        self.streakFreezeUsed = false
        self.streakFreezesAvailable = 1  // Start with 1 free freeze
        
        // Initialize all skills
        for skillType in SkillType.allCases {
            skills[skillType.rawValue] = SkillProgress(skillType: skillType)
        }
    }
    
    /// Time until next heart refill
    var timeUntilRefill: TimeInterval? {
        guard let lastRefill = lastHeartRefill,
              hearts < GameProgress.maxHearts,
              heartRefillSlots > 0 else {
            return nil
        }
        
        let nextRefill = lastRefill.addingTimeInterval(TimeInterval(GameProgress.refillIntervalMinutes * 60))
        let remaining = nextRefill.timeIntervalSince(Date())
        return remaining > 0 ? remaining : 0
    }
    
    /// Progress toward next heart refill (0.0 to 1.0)
    var refillProgress: Double {
        guard let remaining = timeUntilRefill else { return 1.0 }
        let totalInterval = TimeInterval(GameProgress.refillIntervalMinutes * 60)
        return 1.0 - (remaining / totalInterval)
    }
    
    /// Check if hearts can be refilled
    var canRefill: Bool {
        return hearts < GameProgress.maxHearts && heartRefillSlots > 0
    }
    
    /// XP required to reach the NEXT level from the current one
    var xpForNextLevel: Int {
        return level * 100 + (level - 1) * 50
    }

    /// XP accumulated within the current level (totalXP is the running balance)
    var currentLevelXP: Int { totalXP }

    /// Progress bar 0–1 toward the next level
    var progressToNextLevel: Double {
        let needed = xpForNextLevel
        guard needed > 0 else { return 1.0 }
        return min(Double(totalXP) / Double(needed), 1.0)
    }
    
    /// Get skill progress for a specific skill
    func getSkill(_ type: SkillType) -> SkillProgress {
        if let existing = skills[type.rawValue] {
            return existing
        }
        return SkillProgress(skillType: type)
    }
    
    /// Update skill XP after completing a challenge
    mutating func updateSkills(for category: ChallengeCategory, score: Int) {
        let relevantSkills = SkillType.from(category: category)
        
        // Calculate XP based on score (higher score = more XP)
        let baseXP = 10
        let scoreBonus = score / 10
        let xpEarned = baseXP + scoreBonus
        
        for skillType in relevantSkills {
            if var skill = skills[skillType.rawValue] {
                skill.addXP(xpEarned)
                skills[skillType.rawValue] = skill
            } else {
                var newSkill = SkillProgress(skillType: skillType)
                newSkill.addXP(xpEarned)
                skills[newSkill.id] = newSkill
            }
        }
    }
}

// MARK: - Challenge Attempt
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
        AllChallengeType.allCases.first { $0.rawValue == challengeTypeRaw } ?? .targetHunt
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
