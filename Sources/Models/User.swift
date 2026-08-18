import Foundation

struct User: Codable, Identifiable {
    var id: String
    var email: String?
    var createdAt: Date
    var goal: GoalType?
    var isPremium: Bool
    var onboardingData: OnboardingData?
    var displayName: String?
    var avatarEmoji: String?
}

enum GoalType: String, Codable, CaseIterable {
    case improveFocus = "Improve Focus"
    case reduceScreenTime = "Reduce Screen Time"
    case buildDiscipline = "Build Discipline"
    case increaseProductivity = "Increase Productivity"

    var description: String {
        switch self {
        case .improveFocus: return "Train your brain to focus longer"
        case .reduceScreenTime: return "Spend less time scrolling"
        case .buildDiscipline: return "Build daily habits"
        case .increaseProductivity: return "Get more done each day"
        }
    }

    var emoji: String {
        switch self {
        case .improveFocus: return "🎯"
        case .reduceScreenTime: return "📵"
        case .buildDiscipline: return "💪"
        case .increaseProductivity: return "⚡️"
        }
    }
}

struct OnboardingData: Codable {
    var screenTime: Double
    var baselineScore: Int
    var commitmentLevel: Int
    var selectedGoal: GoalType?
}
