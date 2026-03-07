import SwiftUI

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let xpReward: Int
    let gemReward: Int
    var isUnlocked: Bool = false
    var unlockedAt: Date?
    var progress: Double = 0   // 0–1, computed at runtime

    // Legacy compat
    var requirement: Int { xpReward }

    enum AchievementCategory: String, Codable, CaseIterable {
        case progress = "Progress"
        case streak   = "Streak"
        case mastery  = "Mastery"
        case gems     = "Gems"
        case special  = "Special"
    }

    enum Rarity: String {
        case common    = "Common"
        case uncommon  = "Uncommon"
        case rare      = "Rare"
        case epic      = "Epic"
        case legendary = "Legendary"
        var color: Color {
            switch self {
            case .common:    return .gray
            case .uncommon:  return .green
            case .rare:      return .blue
            case .epic:      return .purple
            case .legendary: return .yellow
            }
        }
    }

    var rarity: Rarity {
        switch xpReward {
        case 0..<50:    return .common
        case 50..<100:  return .uncommon
        case 100..<200: return .rare
        case 200..<400: return .epic
        default:        return .legendary
        }
    }
}

// MARK: - All Achievements
extension Achievement {
    static let allAchievements: [Achievement] = [
        // Progress
        Achievement(id: "first_challenge",  title: "First Step",        description: "Complete your first challenge",          icon: "star.fill",                 category: .progress, xpReward: 25,  gemReward: 3),
        Achievement(id: "challenges_10",    title: "Getting Started",   description: "Complete 10 challenges",                 icon: "star.circle.fill",          category: .progress, xpReward: 50,  gemReward: 8),
        Achievement(id: "challenges_25",    title: "On Fire",           description: "Complete 25 challenges",                 icon: "flame.circle.fill",         category: .progress, xpReward: 75,  gemReward: 12),
        Achievement(id: "challenges_50",    title: "Dedicated",         description: "Complete 50 challenges",                 icon: "rosette",                   category: .progress, xpReward: 100, gemReward: 18),
        Achievement(id: "challenges_100",   title: "Centurion",         description: "Complete 100 challenges",                icon: "crown.fill",                category: .progress, xpReward: 200, gemReward: 30),
        Achievement(id: "challenges_250",   title: "Champion",          description: "Complete 250 challenges",                icon: "trophy.fill",               category: .progress, xpReward: 350, gemReward: 50),
        Achievement(id: "level_5",          title: "Rising Star",       description: "Reach Level 5",                         icon: "arrow.up.circle.fill",      category: .progress, xpReward: 40,  gemReward: 8),
        Achievement(id: "level_10",         title: "Focus Apprentice",  description: "Reach Level 10",                        icon: "bolt.circle.fill",          category: .progress, xpReward: 80,  gemReward: 15),
        Achievement(id: "level_25",         title: "Focus Expert",      description: "Reach Level 25",                        icon: "star.square.fill",          category: .progress, xpReward: 150, gemReward: 25),
        Achievement(id: "level_50",         title: "Focus Master",      description: "Reach Level 50",                        icon: "crown.fill",                category: .progress, xpReward: 300, gemReward: 45),

        // Streak
        Achievement(id: "streak_3",         title: "Habit Forming",     description: "Maintain a 3-day streak",               icon: "flame.fill",                category: .streak, xpReward: 30,   gemReward: 5),
        Achievement(id: "streak_7",         title: "Week Warrior",      description: "Maintain a 7-day streak",               icon: "flame.fill",                category: .streak, xpReward: 60,   gemReward: 10),
        Achievement(id: "streak_14",        title: "Fortnight Focus",   description: "Maintain a 14-day streak",              icon: "flame.circle.fill",         category: .streak, xpReward: 100,  gemReward: 18),
        Achievement(id: "streak_30",        title: "Monthly Master",    description: "Maintain a 30-day streak",              icon: "sparkles",                  category: .streak, xpReward: 200,  gemReward: 30),
        Achievement(id: "streak_100",       title: "Century Streak",    description: "Maintain a 100-day streak",             icon: "bolt.fill",                 category: .streak, xpReward: 400,  gemReward: 60),
        Achievement(id: "streak_365",       title: "Year of Focus",     description: "Maintain a 365-day streak",             icon: "sun.max.fill",              category: .streak, xpReward: 1000, gemReward: 150),

        // Mastery
        Achievement(id: "all_focus",        title: "Focus Fanatic",     description: "Complete all 5 Focus challenges",       icon: "eye.fill",                  category: .mastery, xpReward: 120, gemReward: 20),
        Achievement(id: "all_memory",       title: "Memory Palace",     description: "Complete all 5 Memory challenges",      icon: "brain.head.profile",        category: .mastery, xpReward: 120, gemReward: 20),
        Achievement(id: "all_reaction",     title: "Reflex God",        description: "Complete all 5 Reaction challenges",    icon: "bolt.fill",                 category: .mastery, xpReward: 120, gemReward: 20),
        Achievement(id: "all_breathing",    title: "Zen Mind",          description: "Complete all 5 Breathing challenges",   icon: "wind",                      category: .mastery, xpReward: 120, gemReward: 20),
        Achievement(id: "all_discipline",   title: "Iron Will",         description: "Complete all 5 Discipline challenges",  icon: "hand.raised.fill",          category: .mastery, xpReward: 120, gemReward: 20),
        Achievement(id: "all_challenges",   title: "Complete Package",  description: "Complete every single challenge",       icon: "star.circle.fill",          category: .mastery, xpReward: 500, gemReward: 100),
        Achievement(id: "perfect_score",    title: "Perfectionist",     description: "Score 150+ pts on any challenge",       icon: "checkmark.seal.fill",       category: .mastery, xpReward: 80,  gemReward: 15),

        // Gems
        Achievement(id: "gems_50",          title: "Gem Collector",     description: "Accumulate 50 gems",                    icon: "diamond.fill",              category: .gems, xpReward: 30,  gemReward: 0),
        Achievement(id: "gems_200",         title: "Gem Hoarder",       description: "Accumulate 200 gems",                   icon: "diamond.circle.fill",       category: .gems, xpReward: 60,  gemReward: 0),
        Achievement(id: "gems_500",         title: "Gem Lord",          description: "Accumulate 500 gems total",             icon: "sparkles",                  category: .gems, xpReward: 120, gemReward: 0),

        // Special
        Achievement(id: "early_bird",       title: "Early Bird",        description: "Complete a challenge before 7 AM",      icon: "sunrise.fill",              category: .special, xpReward: 50,  gemReward: 10),
        Achievement(id: "night_owl",        title: "Night Owl",         description: "Complete a challenge after 11 PM",      icon: "moon.stars.fill",           category: .special, xpReward: 50,  gemReward: 10),
        Achievement(id: "daily_triple",     title: "Triple Threat",     description: "Complete 3 challenges in one day",      icon: "3.circle.fill",             category: .special, xpReward: 60,  gemReward: 12),
        Achievement(id: "shield_user",      title: "Focus Guard",       description: "Activate the Focus Shield",             icon: "shield.fill",               category: .special, xpReward: 35,  gemReward: 7),
        Achievement(id: "routine_creator",  title: "Routine Builder",   description: "Create a custom focus routine",         icon: "clock.badge.checkmark.fill",category: .special, xpReward: 35,  gemReward: 7),
    ]
}

// MARK: - Achievement Store
@MainActor
class AchievementStore: ObservableObject {
    @Published var achievements: [Achievement] = []

    init() { achievements = loadSaved() ?? Achievement.allAchievements }

    // MARK: - Unlock checking (called after any significant action)
    func checkAndUnlock(progress: GameProgress) {
        let completed      = progress.completedChallenges
        let count          = completed.count
        let streak         = progress.streakDays
        let level          = progress.level
        let gems           = progress.gems
        let completedRaws  = Set(completed.map { $0.challengeTypeRaw })

        func categoryDone(_ cat: ChallengeCategory) -> Bool {
            AllChallengeType.allCases.filter { $0.category == cat }.allSatisfy { completedRaws.contains($0.rawValue) }
        }
        func categoryCount(_ cat: ChallengeCategory) -> Int {
            AllChallengeType.allCases.filter { $0.category == cat }.filter { completedRaws.contains($0.rawValue) }.count
        }
        let categorySize = 5  // each category now has 5 challenges

        let hour        = Calendar.current.component(.hour, from: Date())
        let today       = Calendar.current.startOfDay(for: Date())
        let todayCount  = completed.filter { Calendar.current.startOfDay(for: $0.attemptedAt) == today }.count

        var changed = false
        for i in achievements.indices {
            guard !achievements[i].isUnlocked else {
                // Still update progress for locked ones that show bars
                continue
            }

            var unlock = false
            switch achievements[i].id {
            case "first_challenge":   unlock = count >= 1
            case "challenges_10":     unlock = count >= 10
            case "challenges_25":     unlock = count >= 25
            case "challenges_50":     unlock = count >= 50
            case "challenges_100":    unlock = count >= 100
            case "challenges_250":    unlock = count >= 250
            case "level_5":           unlock = level >= 5
            case "level_10":          unlock = level >= 10
            case "level_25":          unlock = level >= 25
            case "level_50":          unlock = level >= 50
            case "streak_3":          unlock = streak >= 3
            case "streak_7":          unlock = streak >= 7
            case "streak_14":         unlock = streak >= 14
            case "streak_30":         unlock = streak >= 30
            case "streak_100":        unlock = streak >= 100
            case "streak_365":        unlock = streak >= 365
            case "all_focus":         unlock = categoryDone(.focus)
            case "all_memory":        unlock = categoryDone(.memory)
            case "all_reaction":      unlock = categoryDone(.reaction)
            case "all_breathing":     unlock = categoryDone(.breathing)
            case "all_discipline":    unlock = categoryDone(.discipline)
            case "all_challenges":    unlock = ChallengeCategory.allCases.allSatisfy { categoryDone($0) }
            case "perfect_score":     unlock = completed.contains { $0.score >= 150 }
            case "gems_50":           unlock = gems >= 50
            case "gems_200":          unlock = gems >= 200
            case "gems_500":          unlock = gems >= 500
            case "early_bird":        unlock = hour < 7 && count > 0
            case "night_owl":         unlock = hour >= 23 && count > 0
            case "daily_triple":      unlock = todayCount >= 3
            default: break
            }

            if unlock {
                achievements[i].isUnlocked = true
                achievements[i].unlockedAt = Date()
                changed = true
            }

            // Update real-time progress bar
            achievements[i].progress = computeProgress(
                id: achievements[i].id, count: count, streak: streak,
                level: level, gems: gems, todayCount: todayCount,
                completedRaws: completedRaws, categoryCount: categoryCount,
                categorySize: categorySize
            )
        }
        if changed { save() }
    }

    func computeProgress(id: String, count: Int, streak: Int, level: Int, gems: Int, todayCount: Int,
                         completedRaws: Set<String>,
                         categoryCount: (ChallengeCategory) -> Int,
                         categorySize: Int) -> Double {
        switch id {
        case "first_challenge":   return min(Double(count), 1)
        case "challenges_10":     return min(Double(count) / 10,  1)
        case "challenges_25":     return min(Double(count) / 25,  1)
        case "challenges_50":     return min(Double(count) / 50,  1)
        case "challenges_100":    return min(Double(count) / 100, 1)
        case "challenges_250":    return min(Double(count) / 250, 1)
        case "level_5":           return min(Double(level) / 5,   1)
        case "level_10":          return min(Double(level) / 10,  1)
        case "level_25":          return min(Double(level) / 25,  1)
        case "level_50":          return min(Double(level) / 50,  1)
        case "streak_3":          return min(Double(streak) / 3,   1)
        case "streak_7":          return min(Double(streak) / 7,   1)
        case "streak_14":         return min(Double(streak) / 14,  1)
        case "streak_30":         return min(Double(streak) / 30,  1)
        case "streak_100":        return min(Double(streak) / 100, 1)
        case "streak_365":        return min(Double(streak) / 365, 1)
        case "all_focus":         return min(Double(categoryCount(.focus))      / Double(categorySize), 1)
        case "all_memory":        return min(Double(categoryCount(.memory))     / Double(categorySize), 1)
        case "all_reaction":      return min(Double(categoryCount(.reaction))   / Double(categorySize), 1)
        case "all_breathing":     return min(Double(categoryCount(.breathing))  / Double(categorySize), 1)
        case "all_discipline":    return min(Double(categoryCount(.discipline)) / Double(categorySize), 1)
        case "gems_50":           return min(Double(gems) / 50,  1)
        case "gems_200":          return min(Double(gems) / 200, 1)
        case "gems_500":          return min(Double(gems) / 500, 1)
        case "daily_triple":      return min(Double(todayCount) / 3, 1)
        default:                  return completedRaws.isEmpty ? 0 : 0
        }
    }

    func unlockedCount() -> Int { achievements.filter { $0.isUnlocked }.count }
    func progressPercentage() -> Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(unlockedCount()) / Double(achievements.count)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: "achievements_v2")
        }
    }

    private func loadSaved() -> [Achievement]? {
        guard let data = UserDefaults.standard.data(forKey: "achievements_v2"),
              let saved = try? JSONDecoder().decode([Achievement].self, from: data)
        else { return nil }
        let savedIds = Set(saved.map { $0.id })
        let newOnes  = Achievement.allAchievements.filter { !savedIds.contains($0.id) }
        return saved + newOnes
    }
}

enum AchievementTier: String { case bronze, silver, gold, platinum }

// MARK: - Category helpers
extension Achievement.AchievementCategory {
    var icon: String {
        switch self {
        case .progress: return "chart.line.uptrend.xyaxis"
        case .streak:   return "flame.fill"
        case .mastery:  return "crown.fill"
        case .gems:     return "diamond.fill"
        case .special:  return "star.fill"
        }
    }
    var color: Color {
        switch self {
        case .progress: return .green
        case .streak:   return .orange
        case .mastery:  return .purple
        case .gems:     return .cyan
        case .special:  return .pink
        }
    }
}
