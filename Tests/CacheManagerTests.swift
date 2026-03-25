import XCTest
@testable import FocusFlow

/// CacheManagerTests - Unit tests for offline caching system
final class CacheManagerTests: XCTestCase {
    
    var cacheManager: CacheManager!
    
    override func setUp() {
        super.setUp()
        cacheManager = CacheManager.shared
        // Clear cache before each test
        cacheManager.clearCache()
    }
    
    override func tearDown() {
        // Clear cache after each test
        cacheManager.clearCache()
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSingletonInstance() {
        let instance1 = CacheManager.shared
        let instance2 = CacheManager.shared
        XCTAssertTrue(instance1 === instance2, "CacheManager should be a singleton")
    }
    
    // MARK: - Cache Metadata Tests
    
    func testInitialCacheState() {
        XCTAssertFalse(cacheManager.isCacheValid, "Cache should not be valid initially")
        XCTAssertNil(cacheManager.lastCacheUpdate, "Last cache update should be nil initially")
    }
    
    func testCacheValidityAfterUpdate() {
        // Cache user profile to trigger timestamp update
        let testUser = createTestUser()
        cacheManager.cacheUserProfile(testUser)
        
        XCTAssertTrue(cacheManager.isCacheValid, "Cache should be valid after caching data")
        XCTAssertNotNil(cacheManager.lastCacheUpdate, "Last cache update should be set after caching")
    }
    
    func testCacheAgeHours() {
        XCTAssertNil(cacheManager.getCacheAgeHours(), "Cache age should be nil when cache is empty")
        
        let testUser = createTestUser()
        cacheManager.cacheUserProfile(testUser)
        
        let age = cacheManager.getCacheAgeHours()
        XCTAssertNotNil(age, "Cache age should not be nil after caching")
        XCTAssertGreaterThanOrEqual(age!, 0, "Cache age should be >= 0")
    }
    
    // MARK: - User Profile Cache Tests
    
    func testCacheUserProfile() {
        let testUser = createTestUser()
        cacheManager.cacheUserProfile(testUser)
        
        let cachedUser = cacheManager.getCachedUserProfile()
        XCTAssertNotNil(cachedUser, "Cached user should not be nil")
        XCTAssertEqual(cachedUser?.id, testUser.id, "Cached user ID should match")
        XCTAssertEqual(cachedUser?.email, testUser.email, "Cached user email should match")
    }
    
    func testGetCachedUserProfileWhenEmpty() {
        let cachedUser = cacheManager.getCachedUserProfile()
        XCTAssertNil(cachedUser, "Should return nil when no user is cached")
    }
    
    // MARK: - Game Progress Cache Tests
    
    func testCacheGameProgress() {
        let testProgress = createTestGameProgress()
        cacheManager.cacheGameProgress(testProgress)
        
        let cachedProgress = cacheManager.getCachedGameProgress()
        XCTAssertNotNil(cachedProgress, "Cached progress should not be nil")
        XCTAssertEqual(cachedProgress?.level, testProgress.level, "Cached level should match")
    }
    
    func testGetCachedGameProgressWhenEmpty() {
        let cachedProgress = cacheManager.getCachedGameProgress()
        XCTAssertNil(cachedProgress, "Should return nil when no progress is cached")
    }
    
    // MARK: - Skill Progress Cache Tests
    
    func testCacheSkillProgress() {
        let skills: [String: Double] = [
            "focus": 75.5,
            "impulseControl": 60.0,
            "distractionResistance": 45.5
        ]
        cacheManager.cacheSkillProgress(skills)
        
        let cachedSkills = cacheManager.getCachedSkillProgress()
        XCTAssertNotNil(cachedSkills, "Cached skills should not be nil")
        XCTAssertEqual(cachedSkills?["focus"], 75.5, "Cached focus skill should match")
        XCTAssertEqual(cachedSkills?["impulseControl"], 60.0, "Cached impulse control should match")
        XCTAssertEqual(cachedSkills?["distractionResistance"], 45.5, "Cached distraction resistance should match")
    }
    
    func testGetCachedSkillProgressWhenEmpty() {
        let cachedSkills = cacheManager.getCachedSkillProgress()
        XCTAssertNil(cachedSkills, "Should return nil when no skills are cached")
    }
    
    // MARK: - Achievements Cache Tests
    
    func testCacheAchievements() {
        let achievements = createTestAchievements()
        cacheManager.cacheAchievements(achievements)
        
        let cachedAchievements = cacheManager.getCachedAchievements()
        XCTAssertNotNil(cachedAchievements, "Cached achievements should not be nil")
        XCTAssertEqual(cachedAchievements?.count, achievements.count, "Cached achievements count should match")
    }
    
    func testGetCachedAchievementsWhenEmpty() {
        let cachedAchievements = cacheManager.getCachedAchievements()
        XCTAssertNil(cachedAchievements, "Should return nil when no achievements are cached")
    }
    
    // MARK: - Offline Queue Cache Tests
    
    func testCacheOfflineOperations() {
        let operations = createTestSyncOperations()
        cacheManager.cacheOfflineOperations(operations)
        
        let cachedOperations = cacheManager.getCachedOfflineOperations()
        XCTAssertNotNil(cachedOperations, "Cached operations should not be nil")
        XCTAssertEqual(cachedOperations?.count, operations.count, "Cached operations count should match")
    }
    
    func testGetCachedOfflineOperationsWhenEmpty() {
        let cachedOperations = cacheManager.getCachedOfflineOperations()
        XCTAssertNil(cachedOperations, "Should return nil when no operations are cached")
    }
    
    // MARK: - Cache Management Tests
    
    func testClearCache() {
        // First, populate the cache
        let testUser = createTestUser()
        let testProgress = createTestGameProgress()
        let skills: [String: Double] = ["focus": 50.0]
        let achievements = createTestAchievements()
        let operations = createTestSyncOperations()
        
        cacheManager.cacheUserProfile(testUser)
        cacheManager.cacheGameProgress(testProgress)
        cacheManager.cacheSkillProgress(skills)
        cacheManager.cacheAchievements(achievements)
        cacheManager.cacheOfflineOperations(operations)
        
        XCTAssertTrue(cacheManager.isCacheValid, "Cache should be valid before clearing")
        
        // Now clear the cache
        cacheManager.clearCache()
        
        XCTAssertFalse(cacheManager.isCacheValid, "Cache should not be valid after clearing")
        XCTAssertNil(cacheManager.lastCacheUpdate, "Last update should be nil after clearing")
        XCTAssertNil(cacheManager.getCachedUserProfile(), "User should be nil after clearing")
        XCTAssertNil(cacheManager.getCachedGameProgress(), "Progress should be nil after clearing")
        XCTAssertNil(cacheManager.getCachedSkillProgress(), "Skills should be nil after clearing")
        XCTAssertNil(cacheManager.getCachedAchievements(), "Achievements should be nil after clearing")
    }
    
    func testHasValidCache() {
        XCTAssertFalse(cacheManager.hasValidCache(), "Should return false when cache is empty")
        
        let testProgress = createTestGameProgress()
        cacheManager.cacheGameProgress(testProgress)
        
        XCTAssertTrue(cacheManager.hasValidCache(), "Should return true when game progress is cached")
    }
    
    func testHasValidCacheWithoutProgress() {
        let testUser = createTestUser()
        cacheManager.cacheUserProfile(testUser)
        
        // hasValidCache checks for game progress specifically
        XCTAssertFalse(cacheManager.hasValidCache(), "Should return false without game progress even with user cached")
    }
    
    // MARK: - Refresh Cache Tests
    
    func testRefreshCache() {
        let testUser = createTestUser()
        let testProgress = createTestGameProgress()
        let skills: [String: Double] = ["focus": 80.0]
        let achievements = createTestAchievements()
        
        cacheManager.refreshCache(
            user: testUser,
            progress: testProgress,
            skills: skills,
            achievements: achievements
        )
        
        XCTAssertTrue(cacheManager.isCacheValid, "Cache should be valid after refresh")
        XCTAssertNotNil(cacheManager.getCachedUserProfile(), "User should be cached after refresh")
        XCTAssertNotNil(cacheManager.getCachedGameProgress(), "Progress should be cached after refresh")
        XCTAssertNotNil(cacheManager.getCachedSkillProgress(), "Skills should be cached after refresh")
        XCTAssertNotNil(cacheManager.getCachedAchievements(), "Achievements should be cached after refresh")
    }
    
    func testRefreshCacheWithPartialData() {
        let testProgress = createTestGameProgress()
        
        cacheManager.refreshCache(
            user: nil,
            progress: testProgress,
            skills: nil,
            achievements: nil
        )
        
        XCTAssertTrue(cacheManager.isCacheValid, "Cache should be valid after partial refresh")
        XCTAssertNotNil(cacheManager.getCachedGameProgress(), "Progress should be cached")
        XCTAssertNil(cacheManager.getCachedUserProfile(), "User should not be cached when nil was passed")
    }
    
    // MARK: - Helper Methods
    
    private func createTestUser() -> User {
        User(
            id: "test-user-id-123",
            email: "test@example.com",
            createdAt: Date(),
            goal: .improve_focus,
            isPremium: false,
            onboardingData: nil,
            displayName: "Test User",
            avatarEmoji: "🎯"
        )
    }
    
    private func createTestGameProgress() -> GameProgress {
        var progress = GameProgress()
        progress.level = 5
        progress.totalXP = 1250
        progress.gems = 100
        progress.hearts = 5
        progress.streakDays = 7
        progress.focusScore = 75
        progress.impulseControlScore = 60
        progress.distractionResistanceScore = 45
        return progress
    }
    
    private func createTestAchievements() -> [Achievement] {
        [
            Achievement(
                id: "first_challenge",
                title: "First Step",
                description: "Complete your first challenge",
                icon: "star.fill",
                category: .progress,
                requirement: 1,
                isUnlocked: true,
                unlockedAt: Date(),
                xpReward: 50,
                tier: .bronze,
                tierRequirement: nil
            ),
            Achievement(
                id: "streak_7",
                title: "Week Warrior",
                description: "Maintain a 7-day streak",
                icon: "flame.fill",
                category: .streak,
                requirement: 7,
                isUnlocked: true,
                unlockedAt: Date(),
                xpReward: 100,
                tier: .silver,
                tierRequirement: nil
            )
        ]
    }
    
    private func createTestSyncOperations() -> [SyncOperation] {
        [
            SyncOperation(type: .updateGems(gems: 100)),
            SyncOperation(type: .updateGems(gems: 50))
        ]
    }
}
