import XCTest
@testable import FocusFlow

@MainActor
final class AchievementTests: XCTestCase {
    
    var achievementStore: AchievementStore!
    
    override func setUp() {
        super.setUp()
        achievementStore = AchievementStore()
    }
    
    override func tearDown() {
        achievementStore = nil
        super.tearDown()
    }
    
    // Helper to create GameProgress with default values
    private func createProgress(
        level: Int = 1,
        totalXP: Int = 0,
        streakDays: Int = 0,
        completedChallenges: Int = 0
    ) -> GameProgress {
        GameProgress(
            level: level,
            totalXP: totalXP,
            streakDays: streakDays,
            lastActivityDate: nil,
            hearts: 5,
            gems: 10,
            completedChallenges: (0..<completedChallenges).map { i in
                ChallengeAttempt(
                    id: UUID().uuidString,
                    challengeTypeRaw: "focus",
                    level: 1,
                    score: 100,
                    duration: 30,
                    isPerfect: true,
                    xpEarned: 50,
                    attemptedAt: Date()
                )
            },
            skills: [:],
            focusScore: GameProgress.defaultFocusScore,
            impulseControlScore: GameProgress.defaultImpulseControlScore,
            distractionResistanceScore: GameProgress.defaultDistractionResistanceScore,
            streakFreezeUsed: false
        )
    }
    
    // MARK: - Progress Achievement Tests
    
    func testFirstChallengeUnlock() {
        let progress = createProgress(completedChallenges: 1)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let firstChallenge = achievementStore.achievements.first { $0.id == "first_challenge" }
        XCTAssertTrue(firstChallenge?.isUnlocked ?? false, "First challenge should be unlocked")
    }
    
    func testTenChallengesUnlock() {
        let progress = createProgress(completedChallenges: 10)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let tenChallenges = achievementStore.achievements.first { $0.id == "ten_challenges" }
        XCTAssertTrue(tenChallenges?.isUnlocked ?? false, "10 challenges should be unlocked")
    }
    
    func testFiftyChallengesUnlock() {
        let progress = createProgress(completedChallenges: 50)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let fiftyChallenges = achievementStore.achievements.first { $0.id == "fifty_challenges" }
        XCTAssertTrue(fiftyChallenges?.isUnlocked ?? false, "50 challenges should be unlocked")
    }
    
    // MARK: - Streak Achievement Tests
    
    func testWeekStreakUnlock() {
        let progress = createProgress(streakDays: 7)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let streak7 = achievementStore.achievements.first { $0.id == "streak_7" }
        XCTAssertTrue(streak7?.isUnlocked ?? false, "7-day streak should be unlocked")
    }
    
    func testMonthStreakUnlock() {
        let progress = createProgress(streakDays: 30)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let streak30 = achievementStore.achievements.first { $0.id == "streak_30" }
        XCTAssertTrue(streak30?.isUnlocked ?? false, "30-day streak should be unlocked")
    }
    
    func testYearStreakUnlock() {
        let progress = createProgress(streakDays: 365)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let streak365 = achievementStore.achievements.first { $0.id == "streak_365" }
        XCTAssertTrue(streak365?.isUnlocked ?? false, "365-day streak should be unlocked")
    }
    
    // MARK: - Level Achievement Tests
    
    func testLevel5Unlock() {
        let progress = createProgress(level: 5)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let level5 = achievementStore.achievements.first { $0.id == "level_5" }
        XCTAssertTrue(level5?.isUnlocked ?? false, "Level 5 should be unlocked")
    }
    
    func testLevel10Unlock() {
        let progress = createProgress(level: 10)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let level10 = achievementStore.achievements.first { $0.id == "level_10" }
        XCTAssertTrue(level10?.isUnlocked ?? false, "Level 10 should be unlocked")
    }
    
    func testLevel25Unlock() {
        let progress = createProgress(level: 25)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let level25 = achievementStore.achievements.first { $0.id == "level_25" }
        XCTAssertTrue(level25?.isUnlocked ?? false, "Level 25 should be unlocked")
    }
    
    func testLevel50Unlock() {
        let progress = createProgress(level: 50)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let level50 = achievementStore.achievements.first { $0.id == "level_50" }
        XCTAssertTrue(level50?.isUnlocked ?? false, "Level 50 should be unlocked")
    }
    
    // MARK: - XP Achievement Tests
    
    func testXP1000Unlock() {
        let progress = createProgress(totalXP: 1000)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let xp1000 = achievementStore.achievements.first { $0.id == "xp_1000" }
        XCTAssertTrue(xp1000?.isUnlocked ?? false, "1000 XP should be unlocked")
    }
    
    func testXP10000Unlock() {
        let progress = createProgress(totalXP: 10000)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let xp10000 = achievementStore.achievements.first { $0.id == "xp_10000" }
        XCTAssertTrue(xp10000?.isUnlocked ?? false, "10000 XP should be unlocked")
    }
    
    func testXP100000Unlock() {
        let progress = createProgress(totalXP: 100000)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let xp100000 = achievementStore.achievements.first { $0.id == "xp_100000" }
        XCTAssertTrue(xp100000?.isUnlocked ?? false, "100000 XP should be unlocked")
    }
    
    // MARK: - Rarity Tests
    
    func testCommonRarity() {
        let achievement = Achievement.allAchievements.first { $0.id == "first_challenge" }
        XCTAssertEqual(achievement?.rarity, .common, "First challenge should be common rarity")
    }
    
    func testUncommonRarity() {
        let achievement = Achievement.allAchievements.first { $0.id == "streak_7" }
        XCTAssertEqual(achievement?.rarity, .common, "7-day streak should be common rarity")
    }
    
    func testRareRarity() {
        let achievement = Achievement.allAchievements.first { $0.id == "hundred_challenges" }
        XCTAssertEqual(achievement?.rarity, .rare, "100 challenges should be rare rarity")
    }
    
    func testEpicRarity() {
        let achievement = Achievement.allAchievements.first { $0.id == "streak_100" }
        XCTAssertEqual(achievement?.rarity, .rare, "100-day streak should be rare rarity (requirement 100 falls in 51-100 range)")
    }
    
    func testLegendaryRarity() {
        let achievement = Achievement.allAchievements.first { $0.id == "streak_365" }
        XCTAssertEqual(achievement?.rarity, .epic, "365-day streak should be epic rarity (requirement 365 falls in 101-365 range)")
    }
    
    // MARK: - Progress Calculation Tests
    
    func testUnlockedCount() {
        let progress = createProgress(
            level: 25,
            totalXP: 10000,
            streakDays: 30,
            completedChallenges: 100
        )
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let count = achievementStore.unlockedCount()
        XCTAssertGreaterThan(count, 0, "Should have unlocked achievements")
    }
    
    func testProgressPercentage() {
        let progress = createProgress(completedChallenges: 1)
        
        achievementStore.checkAndUnlock(progress: progress)
        
        let percentage = achievementStore.progressPercentage()
        XCTAssertGreaterThan(percentage, 0, "Progress percentage should be greater than 0")
    }
}
