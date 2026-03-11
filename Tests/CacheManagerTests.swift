import XCTest
@testable import FocusFlow

final class CacheManagerTests: XCTestCase {
    var cacheManager: CacheManager!
    
    override func setUp() {
        super.setUp()
        cacheManager = CacheManager.shared
        // Clear cache before each test
        cacheManager.clearCache()
    }
    
    override func tearDown() {
        cacheManager.clearCache()
        super.tearDown()
    }
    
    // MARK: - Cache Metadata Tests
    
    func testCacheManagerIsSingleton() {
        let instance1 = CacheManager.shared
        let instance2 = CacheManager.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testInitialCacheState() {
        XCTAssertFalse(cacheManager.isCacheValid)
        XCTAssertNil(cacheManager.lastCacheUpdate)
    }
    
    func testHasValidCacheWhenEmpty() {
        XCTAssertFalse(cacheManager.hasValidCache())
    }
    
    func testGetCacheAgeHoursWhenEmpty() {
        XCTAssertNil(cacheManager.getCacheAgeHours())
    }
    
    // MARK: - User Profile Cache Tests
    
    func testCacheUserProfile() {
        let user = User(
            id: UUID(),
            email: "test@example.com",
            createdAt: Date(),
            gems: 100,
            streak: 5,
            lastLoginDate: Date()
        )
        
        cacheManager.cacheUserProfile(user)
        
        let cached = cacheManager.getCachedUserProfile()
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.email, "test@example.com")
        XCTAssertEqual(cached?.gems, 100)
        XCTAssertTrue(cacheManager.isCacheValid)
    }
    
    func testGetCachedUserProfileWhenEmpty() {
        let cached = cacheManager.getCachedUserProfile()
        XCTAssertNil(cached)
    }
    
    // MARK: - Game Progress Cache Tests
    
    func testCacheGameProgress() {
        let progress = GameProgress(
            id: UUID(),
            userId: UUID(),
            level: 5,
            currentXP: 250,
            totalXP: 500,
            gems: 150,
            hearts: 4,
            streak: 10,
            focusScore: 75.0,
            impulseControlScore: 60.0,
            distractionResistanceScore: 80.0,
            completedChallenges: [],
            lastUpdated: Date()
        )
        
        cacheManager.cacheGameProgress(progress)
        
        let cached = cacheManager.getCachedGameProgress()
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.level, 5)
        XCTAssertEqual(cached?.gems, 150)
        XCTAssertTrue(cacheManager.isCacheValid)
    }
    
    func testGetCachedGameProgressWhenEmpty() {
        let cached = cacheManager.getCachedGameProgress()
        XCTAssertNil(cached)
    }
    
    // MARK: - Skill Progress Cache Tests
    
    func testCacheSkillProgress() {
        let skills: [String: Double] = [
            "focus": 75.5,
            "impulse": 60.0,
            "distraction": 80.0
        ]
        
        cacheManager.cacheSkillProgress(skills)
        
        let cached = cacheManager.getCachedSkillProgress()
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?["focus"], 75.5)
        XCTAssertEqual(cached?["impulse"], 60.0)
        XCTAssertEqual(cached?["distraction"], 80.0)
    }
    
    func testGetCachedSkillProgressWhenEmpty() {
        let cached = cacheManager.getCachedSkillProgress()
        XCTAssertNil(cached)
    }
    
    // MARK: - Achievements Cache Tests
    
    func testCacheAchievements() {
        let achievements = [
            Achievement(id: "1", name: "First Win", description: "Complete your first challenge", icon: "star.fill", category: .progress, requirement: .wins(1), xpReward: 50, gemReward: 10),
            Achievement(id: "2", name: "Streak Master", description: "Get a 7-day streak", icon: "flame.fill", category: .streaks, requirement: .streakDays(7), xpReward: 100, gemReward: 25)
        ]
        
        cacheManager.cacheAchievements(achievements)
        
        let cached = cacheManager.getCachedAchievements()
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.count, 2)
        XCTAssertEqual(cached?.first?.name, "First Win")
    }
    
    func testGetCachedAchievementsWhenEmpty() {
        let cached = cacheManager.getCachedAchievements()
        XCTAssertNil(cached)
    }
    
    // MARK: - Offline Queue Cache Tests
    
    func testCacheOfflineOperations() {
        let operations = [
            SyncOperation(id: UUID(), type: .updateGems, timestamp: Date(), data: nil),
            SyncOperation(id: UUID(), type: .updateHearts, timestamp: Date(), data: nil)
        ]
        
        cacheManager.cacheOfflineOperations(operations)
        
        let cached = cacheManager.getCachedOfflineOperations()
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.count, 2)
    }
    
    func testGetCachedOfflineOperationsWhenEmpty() {
        let cached = cacheManager.getCachedOfflineOperations()
        XCTAssertNil(cached)
    }
    
    // MARK: - Cache Management Tests
    
    func testClearCache() {
        let progress = GameProgress(
            id: UUID(),
            userId: UUID(),
            level: 5,
            currentXP: 250,
            totalXP: 500,
            gems: 150,
            hearts: 4,
            streak: 10,
            focusScore: 75.0,
            impulseControlScore: 60.0,
            distractionResistanceScore: 80.0,
            completedChallenges: [],
            lastUpdated: Date()
        )
        
        cacheManager.cacheGameProgress(progress)
        XCTAssertTrue(cacheManager.hasValidCache())
        
        cacheManager.clearCache()
        
        XCTAssertFalse(cacheManager.isCacheValid)
        XCTAssertNil(cacheManager.lastCacheUpdate)
        XCTAssertFalse(cacheManager.hasValidCache())
    }
    
    func testHasValidCacheWithProgress() {
        let progress = GameProgress(
            id: UUID(),
            userId: UUID(),
            level: 5,
            currentXP: 250,
            totalXP: 500,
            gems: 150,
            hearts: 4,
            streak: 10,
            focusScore: 75.0,
            impulseControlScore: 60.0,
            distractionResistanceScore: 80.0,
            completedChallenges: [],
            lastUpdated: Date()
        )
        
        cacheManager.cacheGameProgress(progress)
        
        XCTAssertTrue(cacheManager.hasValidCache())
    }
    
    // MARK: - Refresh Cache Tests
    
    func testRefreshCache() {
        let user = User(
            id: UUID(),
            email: "test@example.com",
            createdAt: Date(),
            gems: 100,
            streak: 5,
            lastLoginDate: Date()
        )
        
        let progress = GameProgress(
            id: UUID(),
            userId: UUID(),
            level: 5,
            currentXP: 250,
            totalXP: 500,
            gems: 150,
            hearts: 4,
            streak: 10,
            focusScore: 75.0,
            impulseControlScore: 60.0,
            distractionResistanceScore: 80.0,
            completedChallenges: [],
            lastUpdated: Date()
        )
        
        let skills: [String: Double] = [
            "focus": 75.5,
            "impulse": 60.0
        ]
        
        let achievements = [
            Achievement(id: "1", name: "First Win", description: "Complete your first challenge", icon: "star.fill", category: .progress, requirement: .wins(1), xpReward: 50, gemReward: 10)
        ]
        
        cacheManager.refreshCache(
            user: user,
            progress: progress,
            skills: skills,
            achievements: achievements
        )
        
        XCTAssertNotNil(cacheManager.getCachedUserProfile())
        XCTAssertNotNil(cacheManager.getCachedGameProgress())
        XCTAssertNotNil(cacheManager.getCachedSkillProgress())
        XCTAssertNotNil(cacheManager.getCachedAchievements())
        XCTAssertTrue(cacheManager.isCacheValid)
    }
}
