import Foundation
import Combine
import os.log

private let logger = Logger(subsystem: "com.unscroll.focusflow", category: "CacheManager")

/// CacheManager - Local caching system for offline support
/// Provides fast data access and offline resilience
final class CacheManager: ObservableObject {
    static let shared = CacheManager()
    
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    // Cache keys
    private enum CacheKey {
        static let userProfile = "cache_user_profile"
        static let gameProgress = "cache_game_progress"
        static let skillProgress = "cache_skill_progress"
        static let achievements = "cache_achievements"
        static let lastSyncTimestamp = "cache_last_sync"
        static let offlineQueue = "cache_offline_queue"
    }
    
    // Cache configuration
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    
    @Published var isCacheValid: Bool = false
    @Published var lastCacheUpdate: Date?
    
    private init() {
        loadCacheMetadata()
    }
    
    // MARK: - Cache Metadata
    
    private func loadCacheMetadata() {
        if let timestamp = userDefaults.object(forKey: CacheKey.lastSyncTimestamp) as? Date {
            lastCacheUpdate = timestamp
            isCacheValid = Date().timeIntervalSince(timestamp) < cacheExpirationInterval
        }
    }
    
    private func updateCacheTimestamp() {
        let now = Date()
        userDefaults.set(now, forKey: CacheKey.lastSyncTimestamp)
        lastCacheUpdate = now
        isCacheValid = true
    }
    
    // MARK: - User Profile Cache
    
    func cacheUserProfile(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            userDefaults.set(data, forKey: CacheKey.userProfile)
            updateCacheTimestamp()
        } catch {
            logger.error("Failed to cache user profile: \(error.localizedDescription)")
        }
    }
    
    func getCachedUserProfile() -> User? {
        guard let data = userDefaults.data(forKey: CacheKey.userProfile) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(User.self, from: data)
        } catch {
            logger.error("Failed to decode cached user profile: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Game Progress Cache
    
    func cacheGameProgress(_ progress: GameProgress) {
        do {
            let data = try JSONEncoder().encode(progress)
            userDefaults.set(data, forKey: CacheKey.gameProgress)
            updateCacheTimestamp()
        } catch {
            logger.error("Failed to cache game progress: \(error.localizedDescription)")
        }
    }
    
    func getCachedGameProgress() -> GameProgress? {
        guard let data = userDefaults.data(forKey: CacheKey.gameProgress) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(GameProgress.self, from: data)
        } catch {
            logger.error("Failed to decode cached game progress: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Skill Progress Cache
    
    func cacheSkillProgress(_ skills: [String: Double]) {
        userDefaults.set(skills, forKey: CacheKey.skillProgress)
        updateCacheTimestamp()
    }
    
    func getCachedSkillProgress() -> [String: Double]? {
        guard let data = userDefaults.dictionary(forKey: CacheKey.skillProgress) as? [String: Double] else {
            return nil
        }
        return data
    }
    
    // MARK: - Achievements Cache
    
    func cacheAchievements(_ achievements: [Achievement]) {
        do {
            let data = try JSONEncoder().encode(achievements)
            userDefaults.set(data, forKey: CacheKey.achievements)
            updateCacheTimestamp()
        } catch {
            logger.error("Failed to cache achievements: \(error.localizedDescription)")
        }
    }
    
    func getCachedAchievements() -> [Achievement]? {
        guard let data = userDefaults.data(forKey: CacheKey.achievements) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode([Achievement].self, from: data)
        } catch {
            logger.error("Failed to decode cached achievements: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Offline Queue Cache
    
    func cacheOfflineOperations(_ operations: [SyncOperation]) {
        do {
            let data = try JSONEncoder().encode(operations)
            userDefaults.set(data, forKey: CacheKey.offlineQueue)
        } catch {
            logger.error("Failed to cache offline operations: \(error.localizedDescription)")
        }
    }
    
    func getCachedOfflineOperations() -> [SyncOperation]? {
        guard let data = userDefaults.data(forKey: CacheKey.offlineQueue) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode([SyncOperation].self, from: data)
        } catch {
            logger.error("Failed to decode cached offline operations: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Cache Management
    
    /// Clear all cached data
    func clearCache() {
        userDefaults.removeObject(forKey: CacheKey.userProfile)
        userDefaults.removeObject(forKey: CacheKey.gameProgress)
        userDefaults.removeObject(forKey: CacheKey.skillProgress)
        userDefaults.removeObject(forKey: CacheKey.achievements)
        userDefaults.removeObject(forKey: CacheKey.lastSyncTimestamp)
        userDefaults.removeObject(forKey: CacheKey.offlineQueue)
        
        isCacheValid = false
        lastCacheUpdate = nil
    }
    
    /// Check if cache exists and is valid
    func hasValidCache() -> Bool {
        return isCacheValid && getCachedGameProgress() != nil
    }
    
    /// Get cache age in hours
    func getCacheAgeHours() -> Double? {
        guard let lastUpdate = lastCacheUpdate else { return nil }
        return Date().timeIntervalSince(lastUpdate) / 3600
    }
    
    /// Refresh cache from Supabase (called after successful sync)
    func refreshCache(user: User?, progress: GameProgress?, skills: [String: Double]?, achievements: [Achievement]?) {
        if let user = user {
            cacheUserProfile(user)
        }
        if let progress = progress {
            cacheGameProgress(progress)
        }
        if let skills = skills {
            cacheSkillProgress(skills)
        }
        if let achievements = achievements {
            cacheAchievements(achievements)
        }
    }
}

