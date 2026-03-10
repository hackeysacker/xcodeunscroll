import XCTest
@testable import FocusFlow

// MARK: - Supabase Service Models Tests

final class SupabaseModelsTests: XCTestCase {
    
    // MARK: - Profile Tests
    
    func testProfileInitialization() {
        let profile = Profile(
            id: "test-user-123",
            email: "test@example.com",
            createdAt: Date(),
            goal: "focus",
            isPremium: true,
            updatedAt: Date(),
            gems: 100
        )
        
        XCTAssertEqual(profile.id, "test-user-123")
        XCTAssertEqual(profile.email, "test@example.com")
        XCTAssertEqual(profile.goal, "focus")
        XCTAssertTrue(profile.isPremium == true)
        XCTAssertEqual(profile.gems, 100)
    }
    
    func testProfileCodable() throws {
        let profile = Profile(
            id: "test-user-123",
            email: "test@example.com",
            goal: "focus",
            gems: 100
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(profile)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Profile.self, from: data)
        
        XCTAssertEqual(decoded.id, profile.id)
        XCTAssertEqual(decoded.email, profile.email)
        XCTAssertEqual(decoded.goal, profile.goal)
        XCTAssertEqual(decoded.gems, profile.gems)
    }
    
    func testProfileCodingKeys() throws {
        let profile = Profile(
            id: "test-user-123",
            email: "test@example.com",
            createdAt: Date(),
            goal: "focus",
            isPremium: true,
            updatedAt: Date(),
            gems: 100
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(profile)
        
        let jsonString = String(data: data, encoding: .utf8)!
        
        // Verify snake_case keys
        XCTAssertTrue(jsonString.contains("created_at"))
        XCTAssertTrue(jsonString.contains("is_premium"))
        XCTAssertTrue(jsonString.contains("updated_at"))
        XCTAssertFalse(jsonString.contains("createdAt")) // Should use snake_case
        XCTAssertFalse(jsonString.contains("isPremium"))
    }
    
    // MARK: - GameProgressRecord Tests
    
    func testGameProgressRecordInitialization() {
        let progress = GameProgressRecord(
            userId: "user-123",
            level: 10,
            xp: 250,
            totalXp: 5000,
            streak: 7,
            longestStreak: 30,
            lastSessionDate: Date(),
            streakFreezeUsed: false,
            totalSessionsCompleted: 50,
            totalChallengesCompleted: 150,
            updatedAt: Date()
        )
        
        XCTAssertEqual(progress.userId, "user-123")
        XCTAssertEqual(progress.level, 10)
        XCTAssertEqual(progress.xp, 250)
        XCTAssertEqual(progress.totalXp, 5000)
        XCTAssertEqual(progress.streak, 7)
        XCTAssertEqual(progress.longestStreak, 30)
        XCTAssertEqual(progress.totalSessionsCompleted, 50)
        XCTAssertEqual(progress.totalChallengesCompleted, 150)
    }
    
    func testGameProgressRecordId() {
        let progress = GameProgressRecord(
            userId: "user-123",
            level: 1,
            xp: 0,
            totalXp: 0,
            streak: 0,
            longestStreak: 0,
            totalSessionsCompleted: 0,
            totalChallengesCompleted: 0
        )
        
        XCTAssertEqual(progress.id, "user-123")
    }
    
    func testGameProgressRecordCodable() throws {
        let progress = GameProgressRecord(
            userId: "user-123",
            level: 5,
            xp: 100,
            totalXp: 1000,
            streak: 3,
            longestStreak: 10,
            totalSessionsCompleted: 20,
            totalChallengesCompleted: 50
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(progress)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GameProgressRecord.self, from: data)
        
        XCTAssertEqual(decoded.userId, progress.userId)
        XCTAssertEqual(decoded.level, progress.level)
        XCTAssertEqual(decoded.xp, progress.xp)
    }
    
    // MARK: - SkillProgressRecord Tests
    
    func testSkillProgressRecordInitialization() {
        let skills = SkillProgressRecord(
            userId: "user-123",
            focusScore: 75,
            impulseControlScore: 60,
            distractionResistanceScore: 80,
            updatedAt: Date()
        )
        
        XCTAssertEqual(skills.userId, "user-123")
        XCTAssertEqual(skills.focusScore, 75)
        XCTAssertEqual(skills.impulseControlScore, 60)
        XCTAssertEqual(skills.distractionResistanceScore, 80)
    }
    
    func testSkillProgressRecordId() {
        let skills = SkillProgressRecord(
            userId: "user-456",
            focusScore: 50,
            impulseControlScore: 50,
            distractionResistanceScore: 50
        )
        
        XCTAssertEqual(skills.id, "user-456")
    }
    
    func testSkillProgressRecordCodable() throws {
        let skills = SkillProgressRecord(
            userId: "user-123",
            focusScore: 75,
            impulseControlScore: 60,
            distractionResistanceScore: 80
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(skills)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SkillProgressRecord.self, from: data)
        
        XCTAssertEqual(decoded.focusScore, skills.focusScore)
        XCTAssertEqual(decoded.impulseControlScore, skills.impulseControlScore)
    }
    
    // MARK: - HeartStateRecord Tests
    
    func testHeartStateRecordInitialization() {
        let hearts = HeartStateRecord(
            userId: "user-123",
            currentHearts: 4,
            maxHearts: 5,
            lastHeartLost: Date(),
            lastMidnightReset: Date(),
            perfectStreakCount: 3,
            totalLost: 10,
            totalGained: 15,
            updatedAt: Date()
        )
        
        XCTAssertEqual(hearts.userId, "user-123")
        XCTAssertEqual(hearts.currentHearts, 4)
        XCTAssertEqual(hearts.maxHearts, 5)
        XCTAssertEqual(hearts.perfectStreakCount, 3)
        XCTAssertEqual(hearts.totalLost, 10)
        XCTAssertEqual(hearts.totalGained, 15)
    }
    
    func testHeartStateRecordId() {
        let hearts = HeartStateRecord(
            userId: "user-789",
            currentHearts: 5,
            maxHearts: 5,
            perfectStreakCount: 0,
            totalLost: 0,
            totalGained: 0
        )
        
        XCTAssertEqual(hearts.id, "user-789")
    }
    
    func testHeartStateRecordCodable() throws {
        let hearts = HeartStateRecord(
            userId: "user-123",
            currentHearts: 3,
            maxHearts: 5,
            perfectStreakCount: 5,
            totalLost: 20,
            totalGained: 25
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(hearts)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HeartStateRecord.self, from: data)
        
        XCTAssertEqual(decoded.currentHearts, hearts.currentHearts)
        XCTAssertEqual(decoded.totalLost, hearts.totalLost)
    }
}
