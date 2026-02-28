import SwiftUI

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    var isUnlocked: Bool = false
    var unlockedAt: Date?
    var xpReward: Int = 100
    
    var rarity: Rarity {
        switch requirement {
        case 1...10: return .common
        case 11...50: return .uncommon
        case 51...100: return .rare
        case 101...365: return .epic
        default: return .legendary
        }
    }
    
    enum Rarity: String {
        case common = "Common"
        case uncommon = "Uncommon"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .uncommon: return .green
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .yellow
            }
        }
    }
    
    enum AchievementCategory: String, Codable, CaseIterable {
        case progress = "Progress"
        case streak = "Streak"
        case speed = "Speed"
        case social = "Social"
        case mastery = "Mastery"
        case special = "Special"
    }
}

// MARK: - All Achievements
extension Achievement {
    static let allAchievements: [Achievement] = [
        // Progress milestones
        Achievement(id: "first_challenge", title: "First Step", description: "Complete your first challenge", icon: "star.fill", category: .progress, requirement: 1),
        Achievement(id: "ten_challenges", title: "Getting Started", description: "Complete 10 challenges", icon: "star.circle.fill", category: .progress, requirement: 10),
        Achievement(id: "fifty_challenges", title: "Dedicated", description: "Complete 50 challenges", icon: "rosette", category: .progress, requirement: 50),
        Achievement(id: "hundred_challenges", title: "Centurion", description: "Complete 100 challenges", icon: "crown.fill", category: .progress, requirement: 100),
        Achievement(id: "five_hundred", title: "Champion", description: "Complete 500 challenges", icon: "trophy.fill", category: .progress, requirement: 500),
        
        // Streak achievements
        Achievement(id: "streak_7", title: "Week Warrior", description: "Maintain a 7-day streak", icon: "flame.fill", category: .streak, requirement: 7),
        Achievement(id: "streak_30", title: "Monthly Master", description: "Maintain a 30-day streak", icon: "flame.circle.fill", category: .streak, requirement: 30),
        Achievement(id: "streak_100", title: "Century Streak", description: "Maintain a 100-day streak", icon: "bolt.fill", category: .streak, requirement: 100),
        Achievement(id: "streak_365", title: "Year of Focus", description: "Maintain a 365-day streak", icon: "sparkles", category: .streak, requirement: 365),
        
        // Level achievements
        Achievement(id: "level_5", title: "Rising Star", description: "Reach level 5", icon: "arrow.up.circle.fill", category: .progress, requirement: 5),
        Achievement(id: "level_10", title: "Focus Apprentice", description: "Reach level 10", icon: "arrow.up.circle.fill", category: .progress, requirement: 10),
        Achievement(id: "level_25", title: "Focus Expert", description: "Reach level 25", icon: "star.up.fill", category: .progress, requirement: 25),
        Achievement(id: "level_50", title: "Focus Master", description: "Reach level 50", icon: "crown.fill", category: .progress, requirement: 50),
        
        // Speed achievements
        Achievement(id: "speed_demon", title: "Speed Demon", description: "Complete a challenge in under 10 seconds", icon: "bolt.fill", category: .speed, requirement: 10),
        Achievement(id: "quick_learner", title: "Quick Learner", description: "Complete 10 challenges in one day", icon: "clock.fill", category: .speed, requirement: 10),
        
        // Special achievements
        Achievement(id: "early_bird", title: "Early Bird", description: "Complete a challenge before 7 AM", icon: "sunrise.fill", category: .special, requirement: 1),
        Achievement(id: "night_owl", title: "Night Owl", description: "Complete a challenge after midnight", icon: "moon.stars.fill", category: .special, requirement: 1),
        Achievement(id: "perfect_score", title: "Perfectionist", description: "Get 100% on any challenge", icon: "checkmark.seal.fill", category: .mastery, requirement: 100),
        
        // XP achievements
        Achievement(id: "xp_1000", title: "XP Hunter", description: "Earn 1,000 XP", icon: "sparkles", category: .progress, requirement: 1000),
        Achievement(id: "xp_10000", title: "XP Master", description: "Earn 10,000 XP", icon: "star.sparkles", category: .progress, requirement: 10000),
        Achievement(id: "xp_100000", title: "XP Legend", description: "Earn 100,000 XP", icon: "sparkles", category: .progress, requirement: 100000),
    ]
}

// MARK: - Achievement Store
@MainActor
class AchievementStore: ObservableObject {
    @Published var achievements: [Achievement] = Achievement.allAchievements
    
    func checkAndUnlock(progress: GameProgress) {
        let completedCount = progress.completedChallenges.count
        let streak = progress.streakDays
        let level = progress.level
        let totalXP = progress.totalXP
        
        for i in achievements.indices {
            guard !achievements[i].isUnlocked else { continue }
            
            var shouldUnlock = false
            
            switch achievements[i].id {
            case "first_challenge":
                shouldUnlock = completedCount >= 1
            case "ten_challenges":
                shouldUnlock = completedCount >= 10
            case "fifty_challenges":
                shouldUnlock = completedCount >= 50
            case "hundred_challenges":
                shouldUnlock = completedCount >= 100
            case "five_hundred":
                shouldUnlock = completedCount >= 500
            case "streak_7":
                shouldUnlock = streak >= 7
            case "streak_30":
                shouldUnlock = streak >= 30
            case "streak_100":
                shouldUnlock = streak >= 100
            case "streak_365":
                shouldUnlock = streak >= 365
            case "level_5":
                shouldUnlock = level >= 5
            case "level_10":
                shouldUnlock = level >= 10
            case "level_25":
                shouldUnlock = level >= 25
            case "level_50":
                shouldUnlock = level >= 50
            case "xp_1000":
                shouldUnlock = totalXP >= 1000
            case "xp_10000":
                shouldUnlock = totalXP >= 10000
            case "xp_100000":
                shouldUnlock = totalXP >= 100000
            default:
                break
            }
            
            if shouldUnlock {
                achievements[i].isUnlocked = true
                achievements[i].unlockedAt = Date()
            }
        }
    }
    
    func unlockedCount() -> Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    func progressPercentage() -> Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(unlockedCount()) / Double(achievements.count)
    }
}


