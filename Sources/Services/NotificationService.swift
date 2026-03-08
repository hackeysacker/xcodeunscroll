import Foundation
import UserNotifications
import UIKit

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized: Bool = false
    @Published var notificationsEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
            if !notificationsEnabled {
                cancelAllNotifications()
            }
        }
    }
    
    @Published var reminderHour: Int {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: "reminder_hour")
            if notificationsEnabled { scheduleDailyReminder() }
        }
    }
    
    @Published var reminderMinute: Int {
        didSet {
            UserDefaults.standard.set(reminderMinute, forKey: "reminder_minute")
            if notificationsEnabled { scheduleDailyReminder() }
        }
    }
    
    @Published var streakWarningEnabled: Bool {
        didSet {
            UserDefaults.standard.set(streakWarningEnabled, forKey: "streak_warning_enabled")
            if notificationsEnabled { scheduleStreakWarning() }
        }
    }
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        // Load saved preferences
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        reminderHour = UserDefaults.standard.object(forKey: "reminder_hour") as? Int ?? 9
        reminderMinute = UserDefaults.standard.object(forKey: "reminder_minute") as? Int ?? 0
        streakWarningEnabled = UserDefaults.standard.object(forKey: "streak_warning_enabled") as? Bool ?? true
        
        // Check authorization status on init
        checkAuthorization()
    }
    
    func checkAuthorization() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            let granted = try await notificationCenter.requestAuthorization(options: options)
            await MainActor.run {
                self.isAuthorized = granted
                self.notificationsEnabled = granted
            }
            if granted {
                await MainActor.run {
                    self.scheduleAllNotifications()
                }
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func scheduleAllNotifications() {
        guard notificationsEnabled else { return }
        
        scheduleDailyReminder()
        scheduleStreakWarning()
        scheduleNewChallengesNotification()
    }
    
    // MARK: - Daily Reminder
    
    func scheduleDailyReminder() {
        cancelNotifications(withIdentifier: "daily_reminder")
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Train! 🧠"
        content.body = "Your daily challenges are waiting. Keep your streak going!"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }
    
    // MARK: - Streak Warning
    
    func scheduleStreakWarning() {
        cancelNotifications(withIdentifier: "streak_warning")
        
        guard streakWarningEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Streak at Risk! 🔥"
        content.body = "You haven't completed today's challenges yet. Don't lose your streak!"
        content.sound = .default
        
        // Schedule for 8 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streak_warning", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling streak warning: \(error)")
            }
        }
    }
    
    // MARK: - New Challenges Available
    
    func scheduleNewChallengesNotification() {
        cancelNotifications(withIdentifier: "new_challenges")
        
        let content = UNMutableNotificationContent()
        content.title = "New Challenges Available! 🎯"
        content.body = "Fresh challenges are ready for you. Test your skills!"
        content.sound = .default
        
        // Schedule for 7 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "new_challenges", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling new challenges: \(error)")
            }
        }
    }
    
    // MARK: - Streak Milestone Celebration
    
    func sendStreakMilestoneNotification(streak: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak Milestone!"
        content.body = "Amazing! You've maintained a \(streak)-day streak. Keep it up!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "streak_milestone_\(streak)", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    // MARK: - Achievement Unlocked
    
    func sendAchievementNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 Achievement Unlocked!"
        content.body = "\(title): \(body)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "achievement_\(UUID().uuidString)", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    // MARK: - Level Up
    
    func sendLevelUpNotification(newLevel: Int) {
        let content = UNMutableNotificationContent()
        content.title = "⬆️ Level Up!"
        content.body = "Congratulations! You've reached level \(newLevel). Your focus is stronger than ever!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "level_up_\(newLevel)", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    // MARK: - Cancel
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func cancelNotifications(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
