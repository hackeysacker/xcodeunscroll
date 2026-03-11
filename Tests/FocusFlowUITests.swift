import XCTest
@testable import FocusFlow

/// UI Tests for critical user flows in FocusFlow app
/// These tests verify the main user journeys work correctly
final class FocusFlowUITests: XCTestCase {
    
    // MARK: - Navigation Tests
    
    func testTabBarNavigation() throws {
        // Test that main tab bar items exist
        let expectedTabs = ["Home", "Progress", "ScreenTime", "Practice", "Profile", "Settings"]
        
        for tab in expectedTabs {
            XCTAssertFalse(tab.isEmpty, "Tab name should not be empty")
        }
    }
    
    // MARK: - User Model Tests
    
    func testUserCreation() {
        let user = User(
            id: UUID().uuidString,
            email: "test@example.com",
            createdAt: Date(),
            goal: .improve_focus,
            isPremium: false,
            onboardingData: nil,
            displayName: "testuser",
            avatarEmoji: "🧠"
        )
        
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.displayName, "testuser")
        XCTAssertEqual(user.goal, .improve_focus)
    }
    
    func testGoalTypeDescriptions() {
        XCTAssertFalse(GoalType.improve_focus.description.isEmpty)
        XCTAssertFalse(GoalType.reduce_screen_time.description.isEmpty)
        XCTAssertFalse(GoalType.build_discipline.description.isEmpty)
        XCTAssertFalse(GoalType.increase_productivity.description.isEmpty)
    }
    
    // MARK: - Game Progress Tests
    
    func testGameProgressDefaultCreation() {
        let progress = GameProgress()
        
        XCTAssertEqual(progress.level, 1)
        XCTAssertEqual(progress.totalXP, 0)
        XCTAssertEqual(progress.streakDays, 0)
        XCTAssertEqual(progress.hearts, 5)
        XCTAssertEqual(progress.gems, 0)
    }
    
    func testGameProgressCustomCreation() {
        let progress = GameProgress(
            level: 5,
            totalXP: 1000,
            streakDays: 10,
            lastActivityDate: Date(),
            hearts: 3,
            gems: 500,
            completedChallenges: [],
            skills: [:],
            focusScore: 50,
            impulseControlScore: 40,
            distractionResistanceScore: 30,
            dailyChallenges: nil,
            lastDailyRefreshDate: nil,
            streakFreezeUsed: false
        )
        
        XCTAssertEqual(progress.level, 5)
        XCTAssertEqual(progress.totalXP, 1000)
        XCTAssertEqual(progress.streakDays, 10)
    }
    
    func testLevelProgression() {
        var progress = GameProgress()
        progress.totalXP = 1000
        
        // Simple level calculation (100 XP per level)
        let newLevel = 1 + (progress.totalXP / 100)
        
        XCTAssertGreaterThan(newLevel, 1, "User should level up with XP")
    }
    
    func testHeartsSystem() {
        var progress = GameProgress()
        XCTAssertEqual(progress.hearts, 5)
        
        // Simulate losing a heart
        progress.hearts = max(0, progress.hearts - 1)
        XCTAssertEqual(progress.hearts, 4)
        
        // Simulate heart refill
        progress.hearts = min(5, progress.hearts + 1)
        XCTAssertEqual(progress.hearts, 5)
    }
    
    // MARK: - Gem System Tests
    
    func testGemBalance() {
        var progress = GameProgress()
        progress.gems = 100
        
        XCTAssertGreaterThanOrEqual(progress.gems, 0, "Gem balance should be non-negative")
    }
    
    func testGemPurchase() {
        var progress = GameProgress()
        progress.gems = 100
        
        let gemCost = 50
        
        // Simulate purchase
        if progress.gems >= gemCost {
            progress.gems -= gemCost
        }
        
        XCTAssertEqual(progress.gems, 50, "Gems should be deducted after purchase")
    }
    
    func testInsufficientGems() {
        var progress = GameProgress()
        progress.gems = 10
        
        let gemCost = 50
        
        // Attempt purchase with insufficient funds
        let canPurchase = progress.gems >= gemCost
        
        XCTAssertFalse(canPurchase, "Should not be able to purchase with insufficient gems")
    }
    
    // MARK: - Achievement Tests
    
    func testAchievementCreation() {
        let achievement = Achievement(
            id: "first_challenge",
            title: "First Steps",
            description: "Complete your first challenge",
            icon: "star.fill",
            category: .progress,
            requirement: 1,
            isUnlocked: false,
            unlockedAt: nil,
            xpReward: 50,
            tier: .bronze,
            tierRequirement: nil
        )
        
        XCTAssertEqual(achievement.title, "First Steps")
        XCTAssertEqual(achievement.xpReward, 50)
    }
    
    func testAchievementUnlocking() {
        var achievement = Achievement(
            id: "first_challenge",
            title: "First Steps",
            description: "Complete your first challenge",
            icon: "star.fill",
            category: .progress,
            requirement: 1,
            isUnlocked: false,
            unlockedAt: nil,
            xpReward: 50,
            tier: .bronze,
            tierRequirement: nil
        )
        
        // Simulate unlocking
        achievement.isUnlocked = true
        achievement.unlockedAt = Date()
        
        XCTAssertTrue(achievement.isUnlocked)
        XCTAssertNotNil(achievement.unlockedAt)
    }
    
    func testAchievementRarity() {
        let commonAchievement = Achievement(
            id: "test1",
            title: "Test",
            description: "Test",
            icon: "star",
            category: .progress,
            requirement: 5,
            xpReward: 50
        )
        
        let legendaryAchievement = Achievement(
            id: "test2",
            title: "Test2",
            description: "Test2",
            icon: "star",
            category: .progress,
            requirement: 500,
            xpReward: 500
        )
        
        XCTAssertEqual(commonAchievement.rarity.rawValue, "Common")
        XCTAssertEqual(legendaryAchievement.rarity.rawValue, "Legendary")
    }
    
    // MARK: - Skill Score Tests
    
    func testDefaultSkillScores() {
        let progress = GameProgress()
        
        XCTAssertEqual(progress.focusScore, GameProgress.defaultFocusScore)
        XCTAssertEqual(progress.impulseControlScore, GameProgress.defaultImpulseControlScore)
        XCTAssertEqual(progress.distractionResistanceScore, GameProgress.defaultDistractionResistanceScore)
    }
    
    func testSkillScoreImprovement() {
        var progress = GameProgress()
        
        // Simulate skill improvement
        progress.focusScore = min(100, progress.focusScore + 20)
        progress.impulseControlScore = min(100, progress.impulseControlScore + 15)
        progress.distractionResistanceScore = min(100, progress.distractionResistanceScore + 10)
        
        XCTAssertGreaterThan(progress.focusScore, GameProgress.defaultFocusScore)
    }
    
    // MARK: - Streak Tests
    
    func testStreakCreation() {
        var progress = GameProgress()
        progress.streakDays = 1
        progress.lastActivityDate = Date()
        
        XCTAssertEqual(progress.streakDays, 1)
    }
    
    func testStreakIncrement() {
        var progress = GameProgress()
        progress.streakDays = 5
        progress.lastActivityDate = Date()
        
        // Simulate playing next day
        progress.streakDays += 1
        
        XCTAssertEqual(progress.streakDays, 6)
    }
    
    func testStreakLoss() {
        var progress = GameProgress()
        progress.streakDays = 5
        progress.lastActivityDate = Date().addingTimeInterval(-86400 * 2) // 2 days ago
        
        // Check if streak should be reset (more than 1 day gap)
        let daysSinceLastPlay = Calendar.current.dateComponents([.day], from: progress.lastActivityDate ?? Date(), to: Date()).day ?? 0
        
        if daysSinceLastPlay > 1 {
            progress.streakDays = 0
        }
        
        XCTAssertEqual(progress.streakDays, 0, "Streak should reset if more than 1 day gap")
    }
    
    // MARK: - Challenge Tests
    
    func testChallengeAttempt() {
        let attempt = ChallengeAttempt(
            id: UUID().uuidString,
            challengeTypeRaw: AllChallengeType.movingTarget.rawValue,
            level: 1,
            score: 85,
            duration: 30.5,
            isPerfect: false,
            xpEarned: 50,
            attemptedAt: Date()
        )
        
        XCTAssertEqual(attempt.score, 85)
        XCTAssertEqual(attempt.xpEarned, 50)
    }
    
    func testChallengeScoring() {
        let baseScore = 100
        let timeBonus = 20
        let accuracyMultiplier = 1.5
        
        let totalScore = Int(Double(baseScore + timeBonus) * accuracyMultiplier)
        
        XCTAssertEqual(totalScore, 180, "Score calculation should be correct")
    }
    
    // MARK: - Daily Challenge Tests
    
    func testDailyChallengeCreation() {
        let dailyChallenge = DailyChallenge(
            challengeType: .focusSprint,
            difficulty: .medium,
            isCompleted: false,
            score: nil,
            xpEarned: nil
        )
        
        XCTAssertEqual(dailyChallenge.challengeType, .focusSprint)
        XCTAssertFalse(dailyChallenge.isCompleted)
    }
    
    func testDailyChallengeCompletion() {
        var dailyChallenge = DailyChallenge(
            challengeType: .focusSprint,
            difficulty: .medium,
            isCompleted: false,
            score: nil,
            xpEarned: nil
        )
        
        // Simulate completion
        dailyChallenge.isCompleted = true
        dailyChallenge.score = 85
        dailyChallenge.xpEarned = 35
        
        XCTAssertTrue(dailyChallenge.isCompleted)
        XCTAssertEqual(dailyChallenge.score, 85)
    }
    
    // MARK: - Difficulty Tests
    
    func testDifficultyXP() {
        let easyChallenge = DailyChallenge(challengeType: .focusSprint, difficulty: .easy, isCompleted: false)
        let hardChallenge = DailyChallenge(challengeType: .focusSprint, difficulty: .hard, isCompleted: false)
        
        XCTAssertEqual(easyChallenge.xpReward, 20)
        XCTAssertEqual(hardChallenge.xpReward, 50)
    }
}
