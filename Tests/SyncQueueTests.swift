import XCTest
@testable import FocusFlow

final class SyncQueueTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear any existing state
        UserDefaults.standard.removeObject(forKey: "focusflow_sync_queue")
    }
    
    override func tearDown() {
        super.tearDown()
        // Clean up
        UserDefaults.standard.removeObject(forKey: "focusflow_sync_queue")
    }
    
    // MARK: - SyncOperation Tests
    
    func testSyncOperationInitialization() {
        let operation = SyncOperation(type: .updateGems(gems: 100))
        
        XCTAssertNotNil(operation.id)
        XCTAssertNotNil(operation.createdAt)
    }
    
    func testSyncOperationTypeUpdateGems() {
        let gems = 500
        let operation = SyncOperation(type: .updateGems(gems: gems))
        
        if case .updateGems(let storedGems) = operation.type {
            XCTAssertEqual(storedGems, gems)
        } else {
            XCTFail("Expected updateGems operation type")
        }
    }
    
    func testSyncOperationTypeUpdateHearts() {
        let hearts = 3
        let operation = SyncOperation(type: .updateHearts(hearts: hearts))
        
        if case .updateHearts(let storedHearts) = operation.type {
            XCTAssertEqual(storedHearts, hearts)
        } else {
            XCTFail("Expected updateHearts operation type")
        }
    }
    
    func testSyncOperationTypeSaveChallengeResult() {
        let resultData = ChallengeResultData(
            challengeType: "focus",
            score: 100,
            duration: 30,
            xpEarned: 50,
            isPerfect: true,
            accuracy: 0.95
        )
        let operation = SyncOperation(type: .saveChallengeResult(resultData))
        
        if case .saveChallengeResult(let stored) = operation.type {
            XCTAssertEqual(stored.challengeType, "focus")
            XCTAssertEqual(stored.score, 100)
            XCTAssertEqual(stored.xpEarned, 50)
            XCTAssertTrue(stored.isPerfect)
            XCTAssertEqual(stored.accuracy, 0.95)
        } else {
            XCTFail("Expected saveChallengeResult operation type")
        }
    }
    
    func testSyncOperationTypeUpdateSkillProgress() {
        let focus = 75
        let impulse = 60
        let distraction = 80
        let operation = SyncOperation(type: .updateSkillProgress(focus: focus, impulse: impulse, distraction: distraction))
        
        if case .updateSkillProgress(let f, let i, let d) = operation.type {
            XCTAssertEqual(f, focus)
            XCTAssertEqual(i, impulse)
            XCTAssertEqual(d, distraction)
        } else {
            XCTFail("Expected updateSkillProgress operation type")
        }
    }
    
    func testSyncOperationTypeUpdateProgress() {
        let progress = GameProgressRecord(
            userId: UUID().uuidString,
            level: 5,
            xp: 250,
            totalXp: 1000,
            streak: 3,
            longestStreak: 7,
            lastSessionDate: nil,
            streakFreezeUsed: nil,
            totalSessionsCompleted: 10,
            totalChallengesCompleted: 50,
            updatedAt: Date()
        )
        let operation = SyncOperation(type: .updateProgress(progress))
        
        if case .updateProgress(let stored) = operation.type {
            XCTAssertEqual(stored.totalXp, 1000)
            XCTAssertEqual(stored.level, 5)
            XCTAssertEqual(stored.streak, 3)
        } else {
            XCTFail("Expected updateProgress operation type")
        }
    }
    
    // MARK: - ChallengeResultData Tests
    
    func testChallengeResultDataInitialization() {
        let result = ChallengeResultData(
            challengeType: "memory",
            score: 250,
            duration: 45,
            xpEarned: 75,
            isPerfect: false,
            accuracy: 0.88
        )
        
        XCTAssertEqual(result.challengeType, "memory")
        XCTAssertEqual(result.score, 250)
        XCTAssertEqual(result.duration, 45)
        XCTAssertEqual(result.xpEarned, 75)
        XCTAssertFalse(result.isPerfect)
        XCTAssertEqual(result.accuracy, 0.88)
    }
    
    func testChallengeResultDataCodable() throws {
        let original = ChallengeResultData(
            challengeType: "reaction",
            score: 150,
            duration: 20,
            xpEarned: 40,
            isPerfect: true,
            accuracy: 0.99
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ChallengeResultData.self, from: encoded)
        
        XCTAssertEqual(decoded.challengeType, original.challengeType)
        XCTAssertEqual(decoded.score, original.score)
        XCTAssertEqual(decoded.xpEarned, original.xpEarned)
        XCTAssertEqual(decoded.isPerfect, original.isPerfect)
    }
    
    // MARK: - SyncOperation Codable Tests
    
    func testSyncOperationCodable() throws {
        let operation = SyncOperation(type: .updateGems(gems: 999))
        
        let encoded = try JSONEncoder().encode(operation)
        let decoded = try JSONDecoder().decode(SyncOperation.self, from: encoded)
        
        XCTAssertEqual(operation.id, decoded.id)
        
        if case .updateGems(let originalGems) = operation.type,
           case .updateGems(let decodedGems) = decoded.type {
            XCTAssertEqual(originalGems, decodedGems)
        } else {
            XCTFail("Expected updateGems operation type after decode")
        }
    }
    
    func testSyncOperationArrayCodable() throws {
        let operations = [
            SyncOperation(type: .updateGems(gems: 100)),
            SyncOperation(type: .updateHearts(hearts: 4)),
            SyncOperation(type: .saveChallengeResult(ChallengeResultData(
                challengeType: "focus",
                score: 50,
                duration: 30,
                xpEarned: 25,
                isPerfect: false,
                accuracy: 0.8
            )))
        ]
        
        let encoded = try JSONEncoder().encode(operations)
        let decoded = try JSONDecoder().decode([SyncOperation].self, from: encoded)
        
        XCTAssertEqual(decoded.count, 3)
        
        // Verify each operation
        if case .updateGems(let gems) = decoded[0].type {
            XCTAssertEqual(gems, 100)
        }
        
        if case .updateHearts(let hearts) = decoded[1].type {
            XCTAssertEqual(hearts, 4)
        }
        
        if case .saveChallengeResult(let result) = decoded[2].type {
            XCTAssertEqual(result.challengeType, "focus")
            XCTAssertEqual(result.score, 50)
        }
    }
}
