// Unscroll - Models
// Consolidated unique types only - duplicates removed

import Foundation
import Supabase

// MARK: - Heart State (local)
struct HeartState: Codable {
    var userId: String
    var currentHearts: Int?
    var lastHeartLoss: Date?
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case currentHearts = "current_hearts"
        case lastHeartLoss = "last_heart_loss"
        case updatedAt = "updated_at"
    }
}

// MARK: - User Profile (local app state)
struct UserProfile: Codable, Identifiable {
    let id: String
    var email: String?
    var displayName: String?
    var avatarURL: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Game stats
    var gems: Int
    var hearts: Int
    var level: Int
    var xp: Int
    var streak: Int
    var longestStreak: Int
    
    // Settings
    var soundEnabled: Bool
    var hapticEnabled: Bool
    var darkModeEnabled: Bool
    var notificationsEnabled: Bool
    
    init(id: String = UUID().uuidString) {
        self.id = id
        self.email = nil
        self.displayName = nil
        self.avatarURL = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.gems = 100 // Starting gems
        self.hearts = 5
        self.level = 1
        self.xp = 0
        self.streak = 0
        self.longestStreak = 0
        self.soundEnabled = true
        self.hapticEnabled = true
        self.darkModeEnabled = false
        self.notificationsEnabled = true
    }
}

