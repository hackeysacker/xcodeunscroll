import XCTest
@testable import FocusFlow

final class UserTests: XCTestCase {
    
    // MARK: - User Model Tests
    
    func testUserInitialization() {
        let user = User(
            id: "test-user-id",
            email: "test@example.com",
            createdAt: Date(),
            goal: .improveFocus,
            isPremium: false,
            onboardingData: nil,
            displayName: "Test User",
            avatarEmoji: "🧠"
        )
        
        XCTAssertEqual(user.id, "test-user-id")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.goal, .improveFocus)
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
            selectedGoal: .increaseProductivity
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
        XCTAssertEqual(user.onboardingData?.selectedGoal, .increaseProductivity)
    }
    
    // MARK: - GoalType Tests
    
    func testGoalTypeDescriptions() {
        XCTAssertEqual(GoalType.improveFocus.description, "Train your brain to focus longer")
        XCTAssertEqual(GoalType.reduceScreenTime.description, "Spend less time scrolling")
        XCTAssertEqual(GoalType.buildDiscipline.description, "Build daily habits")
        XCTAssertEqual(GoalType.increaseProductivity.description, "Get more done each day")
    }
    
    func testGoalTypeEmojis() {
        XCTAssertEqual(GoalType.improveFocus.emoji, "🎯")
        XCTAssertEqual(GoalType.reduceScreenTime.emoji, "📵")
        XCTAssertEqual(GoalType.buildDiscipline.emoji, "💪")
        XCTAssertEqual(GoalType.increaseProductivity.emoji, "⚡️")
    }
    
    func testGoalTypeAllCases() {
        let allGoals = GoalType.allCases
        XCTAssertEqual(allGoals.count, 4)
        XCTAssertTrue(allGoals.contains(.improveFocus))
        XCTAssertTrue(allGoals.contains(.reduceScreenTime))
        XCTAssertTrue(allGoals.contains(.buildDiscipline))
        XCTAssertTrue(allGoals.contains(.increaseProductivity))
    }
    
    // MARK: - OnboardingData Tests
    
    func testOnboardingDataInitialization() {
        let data = OnboardingData(
            screenTime: 6.0,
            baselineScore: 30,
            commitmentLevel: 5,
            selectedGoal: .buildDiscipline
        )
        
        XCTAssertEqual(data.screenTime, 6.0)
        XCTAssertEqual(data.baselineScore, 30)
        XCTAssertEqual(data.commitmentLevel, 5)
        XCTAssertEqual(data.selectedGoal, .buildDiscipline)
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
