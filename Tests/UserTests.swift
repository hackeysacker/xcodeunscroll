import XCTest
@testable import FocusFlow

final class UserTests: XCTestCase {
    
    // MARK: - User Model Tests
    
    func testUserInitialization() {
        let user = User(
            id: "test-user-id",
            email: "test@example.com",
            createdAt: Date(),
            goal: .improve_focus,
            isPremium: false,
            onboardingData: nil,
            displayName: "Test User",
            avatarEmoji: "🧠"
        )
        
        XCTAssertEqual(user.id, "test-user-id")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.goal, .improve_focus)
        XCTAssertFalse(user.isPremium)
        XCTAssertNil(user.onboardingData)
        XCTAssertEqual(user.displayName, "Test User")
        XCTAssertEqual(user.avatarEmoji, "🧠")
    }
    
    func testUserWithOnboardingData() {
        let onboardingData = OnboardingData(
            screenTime: 4.5,
            baselineScore: 50,
            commitmentLevel: 7,
            selectedGoal: .increase_productivity
        )
        
        let user = User(
            id: "user-123",
            email: "user@test.com",
            createdAt: Date(),
            goal: nil,
            isPremium: true,
            onboardingData: onboardingData,
            displayName: nil,
            avatarEmoji: nil
        )
        
        XCTAssertNotNil(user.onboardingData)
        XCTAssertEqual(user.onboardingData?.screenTime, 4.5)
        XCTAssertEqual(user.onboardingData?.baselineScore, 50)
        XCTAssertEqual(user.onboardingData?.commitmentLevel, 7)
        XCTAssertEqual(user.onboardingData?.selectedGoal, .increase_productivity)
    }
    
    // MARK: - GoalType Tests
    
    func testGoalTypeDescriptions() {
        XCTAssertEqual(GoalType.improve_focus.description, "Train your brain to focus longer")
        XCTAssertEqual(GoalType.reduce_screen_time.description, "Spend less time scrolling")
        XCTAssertEqual(GoalType.build_discipline.description, "Build daily habits")
        XCTAssertEqual(GoalType.increase_productivity.description, "Get more done each day")
    }
    
    func testGoalTypeEmojis() {
        XCTAssertEqual(GoalType.improve_focus.emoji, "🎯")
        XCTAssertEqual(GoalType.reduce_screen_time.emoji, "📵")
        XCTAssertEqual(GoalType.build_discipline.emoji, "💪")
        XCTAssertEqual(GoalType.increase_productivity.emoji, "⚡️")
    }
    
    func testGoalTypeAllCases() {
        let allGoals = GoalType.allCases
        XCTAssertEqual(allGoals.count, 4)
        XCTAssertTrue(allGoals.contains(.improve_focus))
        XCTAssertTrue(allGoals.contains(.reduce_screen_time))
        XCTAssertTrue(allGoals.contains(.build_discipline))
        XCTAssertTrue(allGoals.contains(.increase_productivity))
    }
    
    // MARK: - OnboardingData Tests
    
    func testOnboardingDataInitialization() {
        let data = OnboardingData(
            screenTime: 6.0,
            baselineScore: 30,
            commitmentLevel: 5,
            selectedGoal: .build_discipline
        )
        
        XCTAssertEqual(data.screenTime, 6.0)
        XCTAssertEqual(data.baselineScore, 30)
        XCTAssertEqual(data.commitmentLevel, 5)
        XCTAssertEqual(data.selectedGoal, .build_discipline)
    }
    
    func testOnboardingDataOptionalGoal() {
        let data = OnboardingData(
            screenTime: 3.0,
            baselineScore: 70,
            commitmentLevel: 10,
            selectedGoal: nil
        )
        
        XCTAssertNil(data.selectedGoal)
    }
}
