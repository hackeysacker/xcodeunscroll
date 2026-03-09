import XCTest
@testable import FocusFlow

final class AllChallengesTests: XCTestCase {
    
    // MARK: - AllChallengeType Tests
    
    func testAllChallengeTypesCount() {
        let allTypes = AllChallengeType.allCases
        // Should have all the focus, memory, reaction, breathing, and discipline challenges
        XCTAssertFalse(allTypes.isEmpty, "AllChallengeType should have cases")
    }
    
    func testAllChallengeTypesHaveIds() {
        for challengeType in AllChallengeType.allCases {
            XCTAssertFalse(challengeType.id.isEmpty, "\(challengeType) should have non-empty id")
        }
    }
    
    func testAllChallengeTypesHaveCategories() {
        for challengeType in AllChallengeType.allCases {
            let category = challengeType.category
            XCTAssertNotNil(category, "\(challengeType) should have a category")
        }
    }
    
    func testFocusCategoryChallenges() {
        let focusChallenges = AllChallengeType.allCases.filter { $0.category == .focus }
        XCTAssertGreaterThan(focusChallenges.count, 0, "Should have focus challenges")
        
        // Verify specific focus challenges exist
        XCTAssertTrue(focusChallenges.contains(where: { $0 == .movingTarget }))
        XCTAssertTrue(focusChallenges.contains(where: { $0 == .multiObjectTracking }))
        XCTAssertTrue(focusChallenges.contains(where: { $0 == .focusSprint }))
    }
    
    func testMemoryCategoryChallenges() {
        let memoryChallenges = AllChallengeType.allCases.filter { $0.category == .memory }
        XCTAssertGreaterThan(memoryChallenges.count, 0, "Should have memory challenges")
        
        // Verify specific memory challenges exist
        XCTAssertTrue(memoryChallenges.contains(where: { $0 == .memoryFlash }))
        XCTAssertTrue(memoryChallenges.contains(where: { $0 == .colorPattern }))
    }
    
    func testReactionCategoryChallenges() {
        let reactionChallenges = AllChallengeType.allCases.filter { $0.category == .reaction }
        XCTAssertGreaterThan(reactionChallenges.count, 0, "Should have reaction challenges")
        
        // Verify specific reaction challenges exist
        XCTAssertTrue(reactionChallenges.contains(where: { $0 == .reactionInhibition }))
        XCTAssertTrue(reactionChallenges.contains(where: { $0 == .impulseSpikeTest }))
    }
    
    func testBreathingCategoryChallenges() {
        let breathingChallenges = AllChallengeType.allCases.filter { $0.category == .breathing }
        XCTAssertGreaterThan(breathingChallenges.count, 0, "Should have breathing challenges")
        
        // Verify specific breathing challenges exist
        XCTAssertTrue(breathingChallenges.contains(where: { $0 == .boxBreathing }))
        XCTAssertTrue(breathingChallenges.contains(where: { $0 == .controlledBreathing }))
    }
    
    func testDisciplineCategoryChallenges() {
        let disciplineChallenges = AllChallengeType.allCases.filter { $0.category == .discipline }
        XCTAssertGreaterThan(disciplineChallenges.count, 0, "Should have discipline challenges")
        
        // Verify specific discipline challenges exist
        XCTAssertTrue(disciplineChallenges.contains(where: { $0 == .fakeNotifications }))
        XCTAssertTrue(disciplineChallenges.contains(where: { $0 == .notificationResistance }))
    }
    
    func testAllChallengeTypesAreIdentifiable() {
        let allTypes = AllChallengeType.allCases
        let ids = allTypes.map { $0.id }
        
        // All IDs should be unique
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "All challenge type IDs should be unique")
    }
    
    func testAllChallengeTypesAreCodable() {
        for challengeType in AllChallengeType.allCases {
            do {
                let data = try JSONEncoder().encode(challengeType)
                let decoded = try JSONDecoder().decode(AllChallengeType.self, from: data)
                XCTAssertEqual(challengeType, decoded, "\(challengeType) should be Codable")
            } catch {
                XCTFail("\(challengeType) should be Codable but got error: \(error)")
            }
        }
    }
    
    // MARK: - ChallengeCategory Tests
    
    func testChallengeCategoryAllCases() {
        let categories = ChallengeCategory.allCases
        XCTAssertEqual(categories.count, 5, "Should have 5 challenge categories")
        XCTAssertTrue(categories.contains(.focus))
        XCTAssertTrue(categories.contains(.memory))
        XCTAssertTrue(categories.contains(.reaction))
        XCTAssertTrue(categories.contains(.breathing))
        XCTAssertTrue(categories.contains(.discipline))
    }
    
    func testChallengeCategoryDescriptions() {
        XCTAssertFalse(ChallengeCategory.focus.description.isEmpty)
        XCTAssertFalse(ChallengeCategory.memory.description.isEmpty)
        XCTAssertFalse(ChallengeCategory.reaction.description.isEmpty)
        XCTAssertFalse(ChallengeCategory.breathing.description.isEmpty)
        XCTAssertFalse(ChallengeCategory.discipline.description.isEmpty)
    }
    
    func testChallengeCategoryIcons() {
        XCTAssertFalse(ChallengeCategory.focus.icon.isEmpty)
        XCTAssertFalse(ChallengeCategory.memory.icon.isEmpty)
        XCTAssertFalse(ChallengeCategory.reaction.icon.isEmpty)
        XCTAssertFalse(ChallengeCategory.breathing.icon.isEmpty)
        XCTAssertFalse(ChallengeCategory.discipline.icon.isEmpty)
    }
    
    // MARK: - Difficulty Tests
    
    func testDifficultyAllCases() {
        let difficulties = Difficulty.allCases
        XCTAssertEqual(difficulties.count, 4, "Should have 4 difficulty levels")
        XCTAssertTrue(difficulties.contains(.easy))
        XCTAssertTrue(difficulties.contains(.medium))
        XCTAssertTrue(difficulties.contains(.hard))
        XCTAssertTrue(difficulties.contains(.extreme))
    }
    
    func testDifficultyMultipliers() {
        XCTAssertEqual(Difficulty.easy.xpMultiplier, 1.0)
        XCTAssertEqual(Difficulty.medium.xpMultiplier, 1.5)
        XCTAssertEqual(Difficulty.hard.xpMultiplier, 2.0)
        XCTAssertEqual(Difficulty.extreme.xpMultiplier, 3.0)
    }
    
    func testDifficultyDisplayNames() {
        XCTAssertEqual(Difficulty.easy.displayName, "Easy")
        XCTAssertEqual(Difficulty.medium.displayName, "Medium")
        XCTAssertEqual(Difficulty.hard.displayName, "Hard")
        XCTAssertEqual(Difficulty.extreme.displayName, "Extreme")
    }
    
    // MARK: - ChallengeDuration Tests
    
    func testChallengeDurationAllCases() {
        let durations = ChallengeDuration.allCases
        XCTAssertEqual(durations.count, 4, "Should have 4 duration options")
    }
    
    func testChallengeDurationSeconds() {
        XCTAssertEqual(ChallengeDuration.short.seconds, 30)
        XCTAssertEqual(ChallengeDuration.medium.seconds, 60)
        XCTAssertEqual(ChallengeDuration.long.seconds, 120)
        XCTAssertEqual(ChallengeDuration.extended.seconds, 180)
    }
    
    func testChallengeDurationDisplayNames() {
        XCTAssertEqual(ChallengeDuration.short.displayName, "30s")
        XCTAssertEqual(ChallengeDuration.medium.displayName, "1m")
        XCTAssertEqual(ChallengeDuration.long.displayName, "2m")
        XCTAssertEqual(ChallengeDuration.extended.displayName, "3m")
    }
}
