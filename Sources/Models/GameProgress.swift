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
    
    // Daily challenges
    var dailyChallenges: [DailyChallenge]?
    var lastDailyRefreshDate: Date?
    
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
}
