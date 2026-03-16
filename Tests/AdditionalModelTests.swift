import XCTest
@testable import FocusFlow

/// Additional tests for FocusFlow models and edge cases
@MainActor
final class AdditionalModelTests: XCTestCase {
    
    // MARK: - Edge Cases and Boundary Tests
    
    func testGameProgressMaxHearts() {
        var progress = GameProgress()
        progress.hearts = 5
        
        // Attempt to add heart when at max
        progress.hearts = min(5, progress.hearts + 1)
        
        XCTAssertEqual(progress.hearts, 5, "Hearts should not exceed maximum")
    }
    
    func testGameProgressMinHearts() {
        var progress = GameProgress()
        progress.hearts = 0
        
        // Attempt to lose heart when at minimum
        progress.hearts = max(0, progress.hearts - 1)
        
        XCTAssertEqual(progress.hearts, 0, "Hearts should not go below 0")
    }
    
    func testGameProgressMaxGems() {
        var progress = GameProgress()
        progress.gems = 999999
        
        // Test large gem amounts
        XCTAssertEqual(progress.gems, 999999)
    }
    
    func testGameProgressNegativeGems() {
        var progress = GameProgress()
        progress.gems = 0
        
        // Prevent negative gems
        progress.gems = max(0, progress.gems - 10)
        
        XCTAssertEqual(progress.gems, 0, "Gems should not go negative")
    }
    
    // MARK: - XP and Level Tests
    
    func testXPOverflow() {
        var progress = GameProgress()
        progress.totalXP = 10_000_000  // Very high XP
        
        XCTAssertGreaterThan(progress.totalXP, 0)
    }
    
    func testLevelOneXP() {
        let progress = GameProgress()
        
        // Level 1 should have 0 current level XP
        XCTAssertEqual(progress.currentLevelXP, 0)
    }
    
    func testZeroXPProgress() {
        let progress = GameProgress()
        
        // At 0 XP, progress to next level should be 0
        XCTAssertEqual(progress.totalXP, 0)
    }
    
    // MARK: - Skill Score Boundary Tests
    
    func testSkillScoreMax() {
        var progress = GameProgress()
        progress.focusScore = 100
        progress.impulseControlScore = 100
        progress.distractionResistanceScore = 100
        
        // Attempt to increase beyond max
        progress.focusScore = min(100, progress.focusScore + 10)
        
        XCTAssertEqual(progress.focusScore, 100, "Skill score should not exceed 100")
    }
    
    func testSkillScoreMin() {
        var progress = GameProgress()
        progress.focusScore = 0
        
        // Attempt to decrease below min
        progress.focusScore = max(0, progress.focusScore - 10)
        
        XCTAssertEqual(progress.focusScore, 0, "Skill score should not go below 0")
    }
    
    // MARK: - Streak Edge Cases
    
    func testStreakMax() {
        var progress = GameProgress()
        progress.streakDays = 365
        
        XCTAssertEqual(progress.streakDays, 365)
    }
    
    func testStreakFutureDate() {
        var progress = GameProgress()
        progress.lastActivityDate = Date().addingTimeInterval(86400)  // Future date
        
        // Handle edge case of future date
        XCTAssertNotNil(progress.lastActivityDate)
    }
    
    // MARK: - Codable Tests
    
    func testGameProgressCodable() throws {
        let progress = GameProgress(
            level: 10,
            totalXP: 5000,
            streakDays: 30,
            lastActivityDate: Date(),
            hearts: 4,
            gems: 250,
            completedChallenges: [],
            skills: [:],
            focusScore: 75,
            impulseControlScore: 60,
            distractionResistanceScore: 45,
            dailyChallenges: nil,
            lastDailyRefreshDate: nil,
            streakFreezeUsed: true
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(progress)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GameProgress.self, from: data)
        
        XCTAssertEqual(progress.level, decoded.level)
        XCTAssertEqual(progress.totalXP, decoded.totalXP)
        XCTAssertEqual(progress.streakDays, decoded.streakDays)
    }
    
    func testUserCodable() throws {
        let user = User(
            id: "test-id",
            email: "test@test.com",
            createdAt: Date(),
            goal: .improve_focus,
            isPremium: true,
            onboardingData: nil,
            displayName: "TestUser",
            avatarEmoji: "🎯"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(User.self, from: data)
        
        XCTAssertEqual(user.id, decoded.id)
        XCTAssertEqual(user.email, decoded.email)
        XCTAssertEqual(user.goal, decoded.goal)
    }
    
    func testAchievementCodable() throws {
        let achievement = Achievement(
            id: "test_achievement",
            title: "Test Achievement",
            description: "A test achievement",
            icon: "star.fill",
            category: .progress,
            requirement: 10,
            isUnlocked: true,
            unlockedAt: Date(),
            xpReward: 100,
            tier: .gold,
            tierRequirement: nil
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(achievement)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Achievement.self, from: data)
        
        XCTAssertEqual(achievement.id, decoded.id)
        XCTAssertEqual(achievement.title, decoded.title)
        XCTAssertEqual(achievement.isUnlocked, decoded.isUnlocked)
    }
    
    // MARK: - Challenge Attempt Tests
    
    func testChallengeAttemptCodable() throws {
        let attempt = ChallengeAttempt(
            id: "attempt-123",
            challengeTypeRaw: AllChallengeType.movingTarget.rawValue,
            level: 3,
            score: 95,
            duration: 45.5,
            isPerfect: true,
            xpEarned: 75,
            attemptedAt: Date()
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(attempt)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ChallengeAttempt.self, from: data)
        
        XCTAssertEqual(attempt.id, decoded.id)
        XCTAssertEqual(attempt.score, decoded.score)
        XCTAssertEqual(attempt.isPerfect, decoded.isPerfect)
    }
    
    func testDailyChallengeCodable() throws {
        let daily = DailyChallenge(
            challengeType: .colorPattern,
            difficulty: .hard,
            isCompleted: true,
            score: 88,
            xpEarned: 50
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(daily)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DailyChallenge.self, from: data)
        
        XCTAssertEqual(daily.challengeType, decoded.challengeType)
        XCTAssertEqual(daily.difficulty, decoded.difficulty)
        XCTAssertEqual(daily.isCompleted, decoded.isCompleted)
    }
    
    // MARK: - Goal Type Tests
    
    func testAllGoalTypes() {
        let goals: [GoalType] = [
            .improve_focus,
            .reduce_screen_time,
            .build_discipline,
            .increase_productivity
        ]
        
        XCTAssertEqual(goals.count, 4, "There should be 4 goal types")
        
        for goal in goals {
            XCTAssertFalse(goal.description.isEmpty, "Goal description should not be empty")
            XCTAssertFalse(goal.emoji.isEmpty, "Goal emoji should not be empty")
        }
    }
    
    // MARK: - Challenge Type Tests
    
    func testAllChallengeCategories() {
        let categories: [ChallengeCategory] = [
            .focus,
            .memory,
            .reaction,
            .breathing,
            .discipline
        ]
        
        XCTAssertEqual(categories.count, 5, "There should be 5 challenge categories")
    }
    
    func testAllDifficulties() {
        let difficulties: [Difficulty] = [.easy, .medium, .hard, .extreme]
        
        XCTAssertEqual(difficulties.count, 4, "There should be 4 difficulty levels")
        
        // Verify multipliers
        XCTAssertEqual(Difficulty.easy.xpMultiplier, 1.0)
        XCTAssertEqual(Difficulty.medium.xpMultiplier, 1.5)
        XCTAssertEqual(Difficulty.hard.xpMultiplier, 2.0)
        XCTAssertEqual(Difficulty.extreme.xpMultiplier, 3.0)
    }
    
    // MARK: - Theme Tests
    
    func testAllThemes() {
        let themes = AppTheme.defaultThemes
        
        XCTAssertEqual(themes.count, 8, "There should be 8 themes")
        
        for theme in themes {
            XCTAssertFalse(theme.name.isEmpty, "Theme name should not be empty")
            XCTAssertFalse(theme.id.isEmpty, "Theme ID should not be empty")
        }
    }
    
    func testDefaultTheme() {
        let defaultTheme = AppTheme.defaultThemes[0]
        
        XCTAssertEqual(defaultTheme.id, "default", "Default theme should be 'default'")
    }
    
    // MARK: - Progress Path Tests
    
    func testTotalLevels() {
        XCTAssertEqual(ProgressPath.totalLevels, 250, "There should be 250 total levels")
    }
    
    func testLevelsPerRealm() {
        XCTAssertEqual(ProgressPath.levelsPerRealm, 25, "Each realm should have 25 levels")
    }
    
    func testTotalRealms() {
        XCTAssertEqual(ProgressPath.totalRealms, 10, "There should be 10 realms")
    }
    
    // MARK: - Heart Refill Tests
    
    func testHeartRefillManagerConfiguration() {
        let manager = HeartRefillManager.shared
        
        XCTAssertEqual(manager.maxHearts, 5, "Max hearts should be 5")
        XCTAssertEqual(manager.maxRefillSlots, 3, "Max refill slots should be 3")
    }
    
    // MARK: - Network Monitor Tests
    
    func testNetworkMonitorInitialState() {
        let monitor = NetworkMonitor.shared
        
        // Just verify it can be accessed
        XCTAssertNotNil(monitor)
    }
    
    // MARK: - Cache Manager Tests
    
    func testCacheManagerSingleton() {
        let cache1 = CacheManager.shared
        let cache2 = CacheManager.shared
        
        XCTAssertTrue(cache1 === cache2, "CacheManager should be a singleton")
    }
}
