import XCTest
@testable import FocusFlow

final class GameProgressTests: XCTestCase {
    
    // MARK: - XP Calculations
    
    func testXPForNextLevel() {
        // Level 1: 1 * 100 + 0 * 50 = 100 XP needed
        XCTAssertEqual(GameProgress(level: 1, totalXP: 0, streakDays: 0, hearts: 5, gems: 0, completedChallenges: [], skills: [:]).xpForNextLevel, 100)
        
        // Level 2: 2 * 100 + 1 * 50 = 250 XP needed
        XCTAssertEqual(GameProgress(level: 2, totalXP: 100, streakDays: 0, hearts: 5, gems: 0, completedChallenges: [], skills: [:]).xpForNextLevel, 250)
        
        // Level 3: 3 * 100 + 2 * 50 = 400 XP needed
        XCTAssertEqual(GameProgress(level: 3, totalXP: 350, streakDays: 0, hearts: 5, gems: 0, completedChallenges: [], skills: [:]).xpForNextLevel, 400)
    }
    
    func testCurrentLevelXP() {
        // Fresh level 1 player has 0 current level XP
        var progress = GameProgress(level: 1, totalXP: 0, streakDays: 0, hearts: 5, gems: 0, completedChallenges: [], skills: [:])
        XCTAssertEqual(progress.currentLevelXP, 0)
        
        // Level 2 with 150 total XP = 50 current level XP
        progress = GameProgress(level: 2, totalXP: 150, streakDays: 0, hearts: 5, gems: 0, completedChallenges: [], skills: [:])
        XCTAssertEqual(progress.currentLevelXP, 50)
    }
    
    func testProgressToNextLevel() {
        var progress = GameProgress(level: 1, totalXP: 0, streakDays: 0, hearts: 5, gems: 0, completedChallenges: [], skills: [:])
        
        // 0/100 = 0%
        XCTAssertEqual(progress.progressToNextLevel, 0.0, accuracy: 0.001)
        
        // 50/100 = 50%
        progress = GameProgress(level: 1, totalXP: 50, streakDays: 0, hearts: 5, gems: 0, completedChallenges: [], skills: [:])
        XCTAssertEqual(progress.progressToNextLevel, 0.5, accuracy: 0.001)
        
        // 100/100 = 100% (capped)
        progress = GameProgress(level: 1, totalXP: 100, streakDays: 0, hearts: 5, gems: 0, completedChallenges: [], skills: [:])
        XCTAssertEqual(progress.progressToNextLevel, 1.0, accuracy: 0.001)
        
        // Over 100% should be capped at 1.0
        progress = GameProgress(level: 1, totalXP: 150, streakDays: 0, hearts: 5, gems: 0, completedChallenges: [], skills: [:])
        XCTAssertEqual(progress.progressToNextLevel, 1.0, accuracy: 0.001)
    }
    
    // MARK: - Difficulty XP Multipliers
    
    func testDifficultyXPMultiplier() {
        XCTAssertEqual(Difficulty.easy.xpMultiplier, 1.0)
        XCTAssertEqual(Difficulty.medium.xpMultiplier, 1.5)
        XCTAssertEqual(Difficulty.hard.xpMultiplier, 2.0)
        XCTAssertEqual(Difficulty.extreme.xpMultiplier, 3.0)
    }
    
    // MARK: - Daily Challenge XP Rewards
    
    func testDailyChallengeXPReward() {
        let easy = DailyChallenge(challengeType: .movingTarget, difficulty: .easy, isCompleted: false)
        let medium = DailyChallenge(challengeType: .movingTarget, difficulty: .medium, isCompleted: false)
        let hard = DailyChallenge(challengeType: .movingTarget, difficulty: .hard, isCompleted: false)
        let extreme = DailyChallenge(challengeType: .movingTarget, difficulty: .extreme, isCompleted: false)
        
        XCTAssertEqual(easy.xpReward, 20)
        XCTAssertEqual(medium.xpReward, 35)
        XCTAssertEqual(hard.xpReward, 50)
        XCTAssertEqual(extreme.xpReward, 80)
    }
    
    // MARK: - Challenge Attempt
    
    func testChallengeAttemptCreation() {
        let attempt = ChallengeAttempt(
            id: UUID().uuidString,
            challengeTypeRaw: AllChallengeType.movingTarget.rawValue,
            level: 1,
            score: 100,
            duration: 30.0,
            isPerfect: true,
            xpEarned: 50,
            attemptedAt: Date()
        )
        
        XCTAssertEqual(attempt.challenge, .movingTarget)
        XCTAssertTrue(attempt.isPerfect)
    }
    
    // MARK: - Game Progress Initialization
    
    func testDefaultGameProgress() {
        let progress = GameProgress()
        
        XCTAssertEqual(progress.level, 1)
        XCTAssertEqual(progress.totalXP, 0)
        XCTAssertEqual(progress.streakDays, 0)
        XCTAssertEqual(progress.hearts, 5)
        XCTAssertEqual(progress.gems, 0)
        XCTAssertEqual(progress.focusScore, GameProgress.defaultFocusScore)
        XCTAssertEqual(progress.impulseControlScore, GameProgress.defaultImpulseControlScore)
        XCTAssertEqual(progress.distractionResistanceScore, GameProgress.defaultDistractionResistanceScore)
    }
}
