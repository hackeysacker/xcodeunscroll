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
