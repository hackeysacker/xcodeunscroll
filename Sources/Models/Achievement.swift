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
    
    // Tier support (Bronze, Silver, Gold)
    var tier: AchievementTier = .bronze
    var tierRequirement: Int?  // For multi-tier achievements
    
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
    
    enum AchievementTier: String, Codable, CaseIterable {
        case bronze = "Bronze"
        case silver = "Silver"
        case gold = "Gold"
        
        var color: Color {
            switch self {
            case .bronze: return Color(hex: "CD7F32")
            case .silver: return Color(hex: "C0C0C0")
            case .gold: return Color(hex: "FFD700")
            }
        }
        
        var icon: String {
            switch self {
            case .bronze: return "1.circle.fill"
            case .silver: return "2.circle.fill"
            case .gold: return "3.circle.fill"
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
        // Progress milestones - Tiered (Bronze, Silver, Gold)
        Achievement(id: "first_challenge", title: "First Step", description: "Complete your first challenge", icon: "star.fill", category: .progress, requirement: 1, tier: .bronze),
        Achievement(id: "ten_challenges", title: "Getting Started", description: "Complete 10 challenges", icon: "star.circle.fill", category: .progress, requirement: 10, tier: .bronze),
        Achievement(id: "fifty_challenges", title: "Dedicated", description: "Complete 50 challenges", icon: "rosette", category: .progress, requirement: 50, tier: .silver),
        Achievement(id: "hundred_challenges", title: "Centurion", description: "Complete 100 challenges", icon: "crown.fill", category: .progress, requirement: 100, tier: .gold),
        Achievement(id: "five_hundred", title: "Champion", description: "Complete 500 challenges", icon: "trophy.fill", category: .progress, requirement: 500, tier: .gold),
        
        // Streak achievements - Tiered
        Achievement(id: "streak_3", title: "3 Day Warrior", description: "Maintain a 3-day streak", icon: "flame.fill", category: .streak, requirement: 3, tier: .bronze),
        Achievement(id: "streak_7", title: "Week Warrior", description: "Maintain a 7-day streak", icon: "flame.circle.fill", category: .streak, requirement: 7, tier: .bronze),
        Achievement(id: "streak_14", title: "Two Weeks Strong", description: "Maintain a 14-day streak", icon: "bolt.fill", category: .streak, requirement: 14, tier: .silver),
        Achievement(id: "streak_30", title: "Monthly Master", description: "Maintain a 30-day streak", icon: "flame.fill", category: .streak, requirement: 30, tier: .silver),
        Achievement(id: "streak_60", title: "Two Month Titan", description: "Maintain a 60-day streak", icon: "flame.fill", category: .streak, requirement: 60, tier: .gold),
        Achievement(id: "streak_100", title: "Century Streak", description: "Maintain a 100-day streak", icon: "bolt.fill", category: .streak, requirement: 100, tier: .gold),
        Achievement(id: "streak_365", title: "Year of Focus", description: "Maintain a 365-day streak", icon: "sparkles", category: .streak, requirement: 365, tier: .gold),
        
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
        
        // XP achievements - Tiered
        Achievement(id: "xp_1000", title: "XP Hunter", description: "Earn 1,000 XP", icon: "sparkles", category: .progress, requirement: 1000, tier: .bronze),
        Achievement(id: "xp_5000", title: "XP Enthusiast", description: "Earn 5,000 XP", icon: "star.fill", category: .progress, requirement: 5000, tier: .silver),
        Achievement(id: "xp_10000", title: "XP Master", description: "Earn 10,000 XP", icon: "star.sparkles", category: .progress, requirement: 10000, tier: .silver),
        Achievement(id: "xp_50000", title: "XP Champion", description: "Earn 50,000 XP", icon: "crown.fill", category: .progress, requirement: 50000, tier: .gold),
        Achievement(id: "xp_100000", title: "XP Legend", description: "Earn 100,000 XP", icon: "sparkles", category: .progress, requirement: 100000, tier: .gold),
        
        // Skill achievements
        Achievement(id: "skill_focus_50", title: "Focused Mind", description: "Reach 50 focus skill", icon: "target", category: .mastery, requirement: 50, tier: .bronze),
        Achievement(id: "skill_focus_80", title: "Laser Focus", description: "Reach 80 focus skill", icon: "scope", category: .mastery, requirement: 80, tier: .gold),
        Achievement(id: "skill_impulse_50", title: "Self Controlled", description: "Reach 50 impulse control", icon: "hand.raised.fill", category: .mastery, requirement: 50, tier: .bronze),
        Achievement(id: "skill_impulse_80", title: "Iron Will", description: "Reach 80 impulse control", icon: "hand.raised.fill", category: .mastery, requirement: 80, tier: .gold),
        
        // Perfect day achievements
        Achievement(id: "perfect_day", title: "Perfect Day", description: "Complete all daily challenges", icon: "checkmark.circle.fill", category: .progress, requirement: 1),
        Achievement(id: "perfect_week", title: "Perfect Week", description: "7 perfect days in a row", icon: "calendar", category: .progress, requirement: 7),
        
        // Comeback achievements
        Achievement(id: "comeback", title: "Comeback Kid", description: "Rebuild streak after losing it", icon: "flame.fill", category: .special, requirement: 1),
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
        
        // Calculate perfect days (this would need tracking in a real implementation)
        let perfectDays = 0  // Placeholder - would need to track actual perfect days
        
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
            case "streak_3":
                shouldUnlock = streak >= 3
            case "streak_7":
                shouldUnlock = streak >= 7
            case "streak_14":
                shouldUnlock = streak >= 14
            case "streak_30":
                shouldUnlock = streak >= 30
            case "streak_60":
                shouldUnlock = streak >= 60
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
            case "xp_5000":
                shouldUnlock = totalXP >= 5000
            case "xp_10000":
                shouldUnlock = totalXP >= 10000
            case "xp_50000":
                shouldUnlock = totalXP >= 50000
            case "xp_100000":
                shouldUnlock = totalXP >= 100000
            case "skill_focus_50":
                shouldUnlock = progress.focusScore >= 50
            case "skill_focus_80":
                shouldUnlock = progress.focusScore >= 80
            case "skill_impulse_50":
                shouldUnlock = progress.impulseControlScore >= 50
            case "skill_impulse_80":
                shouldUnlock = progress.impulseControlScore >= 80
            case "perfect_day":
                shouldUnlock = progress.allDailyChallengesCompleted
            case "perfect_week":
                shouldUnlock = perfectDays >= 7
            case "comeback":
                // This would need additional tracking - placeholder
                shouldUnlock = false
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
    
    /// Get achievements by category
    func achievements(for category: Achievement.AchievementCategory) -> [Achievement] {
        achievements.filter { $0.category == category }
    }
    
    /// Get unlocked achievements
    func unlockedAchievements() -> [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    /// Get locked achievements
    func lockedAchievements() -> [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    /// Get achievements by tier
    func achievements(withTier tier: Achievement.AchievementTier) -> [Achievement] {
        achievements.filter { $0.tier == tier }
    }
}


