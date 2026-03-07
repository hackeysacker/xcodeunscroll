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
    case improve_focus = "Improve Focus"
    case reduce_screen_time = "Reduce Screen Time"
    case build_discipline = "Build Discipline"
    case increase_productivity = "Increase Productivity"
    
    var description: String {
        switch self {
        case .improve_focus: return "Train your brain to focus longer"
        case .reduce_screen_time: return "Spend less time scrolling"
        case .build_discipline: return "Build daily habits"
        case .increase_productivity: return "Get more done each day"
        }
    }
    
    var emoji: String {
        switch self {
        case .improve_focus: return "🎯"
        case .reduce_screen_time: return "📵"
        case .build_discipline: return "💪"
        case .increase_productivity: return "⚡️"
        }
    }
}

struct OnboardingData: Codable {
    var screenTime: Double
    var baselineScore: Int
    var commitmentLevel: Int
    var selectedGoal: GoalType?
}
