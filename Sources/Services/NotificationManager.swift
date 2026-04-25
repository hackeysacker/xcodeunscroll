import Foundation
import os.log
import UserNotifications

/// Manages local notifications for FocusFlow
/// Handles daily reminders, streak warnings, and challenge notifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    
    private init() {}
    private static let logger = Logger(subsystem: "com.unscroll.focusflow", category: "NotificationManager")
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            Self.logger.error("Notification authorization error: \(error.localizedDescription)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    // MARK: - Daily Reminder
    
    func scheduleDailyReminder(hour: Int = 9, minute: Int = 0) {
        // Cancel existing daily reminder first
        cancelNotification(identifier: "daily_reminder")
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 Time to Train Your Brain!"
        content.body = "Complete your daily challenges to keep your streak going. You're doing great!"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Self.logger.error("Failed to schedule daily reminder: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Streak Warning
    
    func scheduleStreakWarning() {
        // Cancel existing streak warning first
        cancelNotification(identifier: "streak_warning")
        
        // Schedule for 8 PM the same day if not completed
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak at Risk!"
        content.body = "You haven't completed your daily challenges yet. Complete at least one to keep your streak!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "streak_warning",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Self.logger.error("Failed to schedule streak warning: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Streak Milestone
    
    func scheduleStreakMilestoneNotification(streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Amazing! \(streakDays) Day Streak!"
        content.body = "You've maintained your focus for \(streakDays) days in a row! Keep it up, champion!"
        content.sound = .default
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "streak_milestone_\(streakDays)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Self.logger.error("Failed to schedule streak milestone: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Level Up
    
    func scheduleLevelUpNotification(newLevel: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Level Up!"
        content.body = "Congratulations! You've reached Level \(newLevel). Your brain training is paying off!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "level_up_\(newLevel)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Self.logger.error("Failed to schedule level up notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Heart Refill Ready
    
    func scheduleHeartRefillNotification() {
        // Cancel existing
        cancelNotification(identifier: "hearts_refilled")
        
        let content = UNMutableNotificationContent()
        content.title = "❤️ Hearts Refilled!"
        content.body = "Your hearts are full again. Ready for more brain training?"
        content.sound = .default
        
        // Schedule for 3 hours from now (when hearts refill)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "hearts_refilled",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Self.logger.error("Failed to schedule heart refill notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - New Challenge Available
    
    func scheduleNewChallengeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🆕 New Challenge Available!"
        content.body = "A new challenge has been added. Try it now and earn bonus XP!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "new_challenge",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Self.logger.error("Failed to schedule new challenge notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Badge Earned
    
    func scheduleBadgeNotification(badgeName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 Badge Earned!"
        content.body = "You've earned the \(badgeName) badge! Check your profile to see all your achievements."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "badge_\(badgeName.lowercased().replacingOccurrences(of: " ", with: "_"))",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Self.logger.error("Failed to schedule badge notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }
    
    // MARK: - Reschedule Based on Settings
    
    func rescheduleNotifications(enabled: Bool, reminderHour: Int, reminderMinute: Int) {
        if enabled {
            scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
        } else {
            cancelNotification(identifier: "daily_reminder")
        }
    }
}
