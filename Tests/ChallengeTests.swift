import XCTest
@testable import FocusFlow

@MainActor
final class ChallengeTests: XCTestCase {
    
    // MARK: - AllChallengeType Tests
    
    func testAllChallengeTypeCount() {
        // Verify we have challenge types in all categories
        let allTypes = AllChallengeType.allCases
        XCTAssertFalse(allTypes.isEmpty, "Should have challenge types defined")
    }
    
    func testAllChallengeTypesHaveValidID() {
        for challenge in AllChallengeType.allCases {
            XCTAssertFalse(challenge.id.isEmpty, "Challenge \(challenge) should have valid id")
        }
    }
    
    func testAllChallengeTypesHaveCategory() {
        for challenge in AllChallengeType.allCases {
            XCTAssertNotNil(challenge.category, "Challenge \(challenge) should have category")
        }
    }
    
    func testFocusChallenges() {
        let focusChallenges: [AllChallengeType] = [
            .movingTarget, .multiObjectTracking, .gazeHold, .focusHold,
            .focusSprint, .stillnessTest, .slowTracking, .focusEndurance
        ]
        
        for challenge in focusChallenges {
            XCTAssertEqual(challenge.category, .focus, "\(challenge) should be in focus category")
        }
    }
    
    func testMemoryChallenges() {
        let memoryChallenges: [AllChallengeType] = [
            .memoryFlash, .memoryPuzzle, .numberSequence, .patternMatching,
            .colorPattern, .tapPattern, .spatialPuzzle
        ]
        
        for challenge in memoryChallenges {
            XCTAssertEqual(challenge.category, .memory, "\(challenge) should be in memory category")
        }
    }
    
    func testReactionChallenges() {
        let reactionChallenges: [AllChallengeType] = [
            .reactionInhibition, .impulseSpikeTest, .rhythmTap, .delayUnlock, .resetChallenge
        ]
        
        for challenge in reactionChallenges {
            XCTAssertEqual(challenge.category, .reaction, "\(challenge) should be in reaction category")
        }
    }
    
    func testBreathingChallenges() {
        let breathingChallenges: [AllChallengeType] = [
            .boxBreathing, .controlledBreathing, .breathPacing, .slowBreathing,
            .bodyScan, .fiveSenses, .urgeSurfing, .calmVisual, .breathingBasics,
            .calmFocus, .stressRelief, .energyBoost, .deepBreath, .breathingAdvanced,
            .meditationMaster
        ]
        
        for challenge in breathingChallenges {
            XCTAssertEqual(challenge.category, .breathing, "\(challenge) should be in breathing category")
        }
    }
    
    func testDisciplineChallenges() {
        let disciplineChallenges: [AllChallengeType] = [
            .antiScrollSwipe, .appSwitchResistance, .fakeNotifications, .fingerHold,
            .fingerTracing, .impulseDelay, .distractionLog, .lookAway, .multiTaskTap,
            .notificationResistance, .popupIgnore, .tapOnlyCorrect, .wordPuzzle, .logicPuzzle
        ]
        
        for challenge in disciplineChallenges {
            XCTAssertEqual(challenge.category, .discipline, "\(challenge) should be in discipline category")
        }
    }
    
    // MARK: - ChallengeCategory Tests
    
    func testChallengeCategoryAllCases() {
        let categories = ChallengeCategory.allCases
        XCTAssertEqual(categories.count, 8, "Should have 8 challenge categories")
        XCTAssertTrue(categories.contains(.focus))
        XCTAssertTrue(categories.contains(.memory))
        XCTAssertTrue(categories.contains(.reaction))
        XCTAssertTrue(categories.contains(.breathing))
        XCTAssertTrue(categories.contains(.discipline))
        XCTAssertTrue(categories.contains(.speed))
        XCTAssertTrue(categories.contains(.impulse))
        XCTAssertTrue(categories.contains(.calm))
    }
    
    func testChallengeCategoryIcons() {
        XCTAssertFalse(ChallengeCategory.focus.icon.isEmpty)
        XCTAssertFalse(ChallengeCategory.memory.icon.isEmpty)
        XCTAssertFalse(ChallengeCategory.reaction.icon.isEmpty)
        XCTAssertFalse(ChallengeCategory.breathing.icon.isEmpty)
        XCTAssertFalse(ChallengeCategory.discipline.icon.isEmpty)
    }
    
    // MARK: - Difficulty Tests
    
    func testDifficultyXPValues() {
        XCTAssertEqual(Difficulty.easy.xpMultiplier, 1.0)
        XCTAssertEqual(Difficulty.medium.xpMultiplier, 1.5)
        XCTAssertEqual(Difficulty.hard.xpMultiplier, 2.0)
        XCTAssertEqual(Difficulty.extreme.xpMultiplier, 3.0)
    }
    
    // MARK: - DailyChallenge Tests
    
    func testDailyChallengeCreation() {
        let challenge = DailyChallenge(
            challengeType: .focusSprint,
            difficulty: .medium,
            isCompleted: false,
            score: nil,
            xpEarned: nil
        )
        
        XCTAssertEqual(challenge.challengeType, .focusSprint)
        XCTAssertEqual(challenge.difficulty, .medium)
        XCTAssertFalse(challenge.isCompleted)
        XCTAssertNil(challenge.score)
        XCTAssertNil(challenge.xpEarned)
    }
    
    func testDailyChallengeCompletion() {
        var challenge = DailyChallenge(
            challengeType: .focusSprint,
            difficulty: .medium,
            isCompleted: false,
            score: nil,
            xpEarned: nil
        )
        
        challenge.isCompleted = true
        challenge.score = 85
        challenge.xpEarned = 35
        
        XCTAssertTrue(challenge.isCompleted)
        XCTAssertEqual(challenge.score, 85)
        XCTAssertEqual(challenge.xpEarned, 35)
    }
    
    func testDailyChallengeXPRewardByDifficulty() {
        let easyChallenge = DailyChallenge(challengeType: .focusSprint, difficulty: .easy, isCompleted: false)
        let mediumChallenge = DailyChallenge(challengeType: .focusSprint, difficulty: .medium, isCompleted: false)
        let hardChallenge = DailyChallenge(challengeType: .focusSprint, difficulty: .hard, isCompleted: false)
        
        XCTAssertEqual(easyChallenge.xpReward, 20)
        XCTAssertEqual(mediumChallenge.xpReward, 35)
        XCTAssertEqual(hardChallenge.xpReward, 50)
    }
    
    func testDailyChallengeCodable() throws {
        let original = DailyChallenge(
            challengeType: .memoryFlash,
            difficulty: .hard,
            isCompleted: true,
            score: 95,
            xpEarned: 50
        )
        
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DailyChallenge.self, from: data)
        
        XCTAssertEqual(decoded.challengeType, original.challengeType)
        XCTAssertEqual(decoded.difficulty, original.difficulty)
        XCTAssertEqual(decoded.isCompleted, original.isCompleted)
        XCTAssertEqual(decoded.score, original.score)
        XCTAssertEqual(decoded.xpEarned, original.xpEarned)
    }
    
    // MARK: - ChallengeAttempt Tests
    
    func testChallengeAttemptCreation() {
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
        
        XCTAssertFalse(attempt.id.isEmpty)
        XCTAssertEqual(attempt.challengeTypeRaw, AllChallengeType.movingTarget.rawValue)
        XCTAssertEqual(attempt.score, 85)
        XCTAssertEqual(attempt.xpEarned, 50)
    }
    
    func testChallengeAttemptPerfectScore() {
        let attempt = ChallengeAttempt(
            id: UUID().uuidString,
            challengeTypeRaw: AllChallengeType.focusSprint.rawValue,
            level: 1,
            score: 100,
            duration: 30.0,
            isPerfect: true,
            xpEarned: 75,
            attemptedAt: Date()
        )
        
        XCTAssertTrue(attempt.isPerfect)
        XCTAssertEqual(attempt.score, 100)
    }
    
    func testChallengeAttemptCodable() throws {
        let original = ChallengeAttempt(
            id: "test-id-123",
            challengeTypeRaw: AllChallengeType.boxBreathing.rawValue,
            level: 5,
            score: 90,
            duration: 120.0,
            isPerfect: false,
            xpEarned: 40,
            attemptedAt: Date()
        )
        
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ChallengeAttempt.self, from: data)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.challengeTypeRaw, original.challengeTypeRaw)
        XCTAssertEqual(decoded.level, original.level)
        XCTAssertEqual(decoded.score, original.score)
    }
}
