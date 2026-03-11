import XCTest
@testable import Unscroll

final class GameProgressTests: XCTestCase {
    
    var gameProgress: GameProgress!
    
    override func setUp() {
        super.setUp()
        gameProgress = GameProgress()
    }
    
    override func tearDown() {
        gameProgress = nil
        super.tearDown()
    }
    
    // MARK: - XP and Level Tests
    
    func testInitialXPIsZero() {
        XCTAssertEqual(gameProgress.xp, 0)
    }
    
    func testInitialLevelIsOne() {
        XCTAssertEqual(gameProgress.level, 1)
    }
    
    func testAddXPCalculatesLevelCorrectly() {
        // Level 1 requires 100 XP
        gameProgress.addXP(50)
        XCTAssertEqual(gameProgress.xp, 50)
        XCTAssertEqual(gameProgress.level, 1)
        
        // Add 60 more (total 110) - should trigger level 2
        gameProgress.addXP(60)
        XCTAssertEqual(gameProgress.xp, 110)
        XCTAssertEqual(gameProgress.level, 2)
    }
    
    func testLevelUpIncrementsLevel() {
        gameProgress.addXP(500)
        XCTAssertGreaterThan(gameProgress.level, 1)
    }
    
    // MARK: - Streak Tests
    
    func testInitialStreakIsZero() {
        XCTAssertEqual(gameProgress.streak, 0)
    }
    
    func testIncrementStreak() {
        gameProgress.incrementStreak()
        XCTAssertEqual(gameProgress.streak, 1)
    }
    
    func testStreakResetsOnMissedDay() {
        gameProgress.streak = 5
        gameProgress.streak = 0 // Simulate missed day
        XCTAssertEqual(gameProgress.streak, 0)
    }
    
    // MARK: - Gems Tests
    
    func testInitialGemsIsZero() {
        XCTAssertEqual(gameProgress.gems, 0)
    }
    
    func testAddGems() {
        gameProgress.addGems(100)
        XCTAssertEqual(gameProgress.gems, 100)
    }
    
    func testSpendGems() {
        gameProgress.addGems(100)
        let success = gameProgress.spendGems(50)
        XCTAssertTrue(success)
        XCTAssertEqual(gameProgress.gems, 50)
    }
    
    func testSpendGemsFailsWhenInsufficient() {
        gameProgress.addGems(30)
        let success = gameProgress.spendGems(50)
        XCTAssertFalse(success)
        XCTAssertEqual(gameProgress.gems, 30)
    }
    
    // MARK: - Hearts Tests
    
    func testInitialHeartsIsFive() {
        XCTAssertEqual(gameProgress.hearts, 5)
    }
    
    func testLoseHeart() {
        gameProgress.loseHeart()
        XCTAssertEqual(gameProgress.hearts, 4)
    }
    
    func testHeartsCannotGoNegative() {
        for _ in 0..<10 {
            gameProgress.loseHeart()
        }
        XCTAssertGreaterThanOrEqual(gameProgress.hearts, 0)
    }
    
    func testAddHeart() {
        gameProgress.hearts = 3
        gameProgress.addHeart()
        XCTAssertEqual(gameProgress.hearts, 4)
    }
    
    func testHeartsCannotExceedFive() {
        gameProgress.hearts = 5
        gameProgress.addHeart()
        XCTAssertEqual(gameProgress.hearts, 5)
    }
    
    // MARK: - Difficulty Multiplier Tests
    
    func testDifficultyMultiplierValues() {
        XCTAssertEqual(ChallengeDifficulty.easy.xpMultiplier, 1.0)
        XCTAssertEqual(ChallengeDifficulty.medium.xpMultiplier, 1.5)
        XCTAssertEqual(ChallengeDifficulty.hard.xpMultiplier, 2.0)
        XCTAssertEqual(ChallengeDifficulty.extreme.xpMultiplier, 3.0)
    }
}
