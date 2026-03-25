import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

// MARK: - Screen Time Category
struct ScreenTimeCategory: Identifiable {
    let id: String
    let name: String
    var minutes: Int
    var color: Color
    
    init(name: String, minutes: Int, color: Color) {
        self.id = UUID().uuidString
        self.name = name
        self.minutes = minutes
        self.color = color
    }
}

// MARK: - Focus Mode
enum FocusMode: String, CaseIterable, Codable {
    case off = "Off"
    case work = "Work"
    case personal = "Personal"
    case evening = "Evening"
    case sleep = "Sleep"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .off: return "shield.slash"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .evening: return "sunset.fill"
        case .sleep: return "moon.fill"
        case .custom: return "slider.horizontal.3"
        }
    }
    
    var color: Color {
        switch self {
        case .off: return .gray
        case .work: return .blue
        case .personal: return .green
        case .evening: return .orange
        case .sleep: return .indigo
        case .custom: return .purple
        }
    }
    
    var description: String {
        switch self {
        case .off: return "Shield is disabled"
        case .work: return "Block distractions during work hours"
        case .personal: return "Personal time focus"
        case .evening: return "Wind down in the evening"
        case .sleep: return "Prepare for better sleep"
        case .custom: return "Your custom settings"
        }
    }
    
    var defaultBlockedCategories: [String] {
        switch self {
        case .off: return []
        case .work: return ["Social Media", "Games", "Entertainment"]
        case .personal: return ["Social Media"]
        case .evening: return ["Social Media", "News", "Games"]
        case .sleep: return ["Social Media", "Entertainment", "Games", "News"]
        case .custom: return []
        }
    }
}

import SwiftUI

@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    
    @Published var isAuthorized: Bool = false
    @Published var todayMinutes: Int = 0
    @Published var weeklyMinutes: Int = 0
    @Published var pickupCount: Int = 0
    @Published var notificationsCount: Int = 0
    @Published var mostUsedApp: String = "None"
    @Published var categories: [ScreenTimeCategory] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()
    
    // Store for shields
    @Published var blockedApps: Set<String> = []
    @Published var activeFocusMode: FocusMode = .off
    
    init() {
        checkAuthorization()
    }
    
    // MARK: - Authorization
    
    func checkAuthorization() {
        let status = center.authorizationStatus
        isAuthorized = (status == .approved)
        
        if isAuthorized {
            fetchScreenTimeData()
        }
    }
    
    func requestAuthorization() {
        isLoading = true
        error = nil
        
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                await MainActor.run {
                    self.isAuthorized = true
                    self.isLoading = false
                    self.fetchScreenTimeData()
                }
            } catch {
                await MainActor.run {
                    self.isAuthorized = false
                    self.isLoading = false
                    self.error = "Authorization failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Data Fetching
    
    func fetchScreenTimeData() {
        guard isAuthorized else {
            // Use demo data when not authorized
            loadDemoData()
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // Try to fetch real data from DeviceActivity
                try await fetchDeviceActivity()
                
                await MainActor.run {
                    self.processActivityData()
                    self.isLoading = false
                }
            } catch {
                // Fall back to demo data
                await MainActor.run {
                    self.loadDemoData()
                    self.isLoading = false
                }
            }
        }
    }
    
    private func fetchDeviceActivity() async throws {
        // In a real implementation, you would:
        // 1. Create a DeviceActivityReport extension
        // 2. Use the center.activity(from:to:) method
        // 3. Process the returned activity data
        
        // For now, throw to fall back to demo
        throw NSError(domain: "ScreenTime", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data"])
    }
    
    private func processActivityData() {
        // Process real data here when available
        // For now, use demo
        loadDemoData()
    }
    
    private func loadDemoData() {
        // Demo data for display
        todayMinutes = 127
        weeklyMinutes = 892
        pickupCount = 43
        notificationsCount = 18
        mostUsedApp = "Instagram"
        
        categories = [
            ScreenTimeCategory(name: "Social", minutes: 45, color: .blue),
            ScreenTimeCategory(name: "Entertainment", minutes: 35, color: .purple),
            ScreenTimeCategory(name: "Productivity", minutes: 25, color: .green),
            ScreenTimeCategory(name: "Games", minutes: 15, color: .orange),
            ScreenTimeCategory(name: "Other", minutes: 7, color: .gray)
        ]
    }
    
    // MARK: - Focus Mode Control
    
    func activateFocusMode(_ mode: FocusMode) {
        activeFocusMode = mode
        
        switch mode {
        case .off:
            deactivateShields()
        case .work:
            configureWorkMode()
        case .personal:
            configurePersonalMode()
        case .evening:
            configureEveningMode()
        case .sleep:
            configureSleepMode()
        case .custom:
            configureCustomMode()
        }
    }
    
    private func configureWorkMode() {
        // Block entertainment apps
        let blockedBundleIds = [
            "com.burbn.instagram",
            "com.twitter.twitter",
            "com.tiktok",
            "com.facebook.Facebook",
            "com.snapchat.Snapchat"
        ]
        
        // In real implementation, use:
        // store.shield.applications = Set(blockedBundleIds)
        // store.shield.webDomains = Set(["twitter.com", "instagram.com"])
        
        print("Work mode activated - blocking \(blockedBundleIds.count) entertainment apps")
    }
    
    private func configureStudyMode() {
        // Block everything except education
        let allowedApps = [
            "com.apple.Pages",
            "com.apple.Keynote",
            "com.apple.Numbers"
        ]
        
        print("Study mode activated - allowing \(allowedApps.count) educational apps")
    }
    
    private func configurePersonalMode() {
        // Block only social media
        print("Personal mode activated - blocking social media")
    }
    
    private func configureEveningMode() {
        // Block social media and news
        print("Evening mode activated - wind down")
    }
    
    private func configureSleepMode() {
        // Block most apps
        print("Sleep mode activated - blocking all apps except essentials")
    }
    
    private func configureCustomMode() {
        // Use user's custom configuration
        for app in blockedApps {
            print("Blocking custom app: \(app)")
        }
    }
    
    func disableShield() { deactivateShields() }

    private func deactivateShields() {
        // store.shield.applications = nil
        // store.shield.webDomains = nil
        activeFocusMode = .off
        print("All shields deactivated")
    }
    
    // MARK: - App Blocking
    
    func blockApp(_ bundleId: String) {
        blockedApps.insert(bundleId)
        // store.shield.applications?.insert(bundleId)
    }
    
    func unblockApp(_ bundleId: String) {
        blockedApps.remove(bundleId)
        // store.shield.applications?.remove(bundleId)
    }
    
    func toggleApp(_ bundleId: String) {
        if blockedApps.contains(bundleId) {
            unblockApp(bundleId)
        } else {
            blockApp(bundleId)
        }
    }
    
    // MARK: - Routines
    
    @Published var routines: [ScreenTimeFocusRoutine] = []
    
    func addRoutine(_ routine: ScreenTimeFocusRoutine) {
        routines.append(routine)
    }
    
    func removeRoutine(at index: Int) {
        guard index < routines.count else { return }
        routines.remove(at: index)
    }
    
    func activateRoutine(_ routine: ScreenTimeFocusRoutine) {
        activateFocusMode(routine.mode)
        blockedApps = routine.blockedApps
    }
    
    // MARK: - Time Limits
    
    func setAppLimit(_ bundleId: String, minutes: Int) {
        // store.shield.timeLimits = ...
        print("Setting \(minutes) min limit for \(bundleId)")
    }
    
    // MARK: - Helpers
    
    func getDayMinutes(_ day: Int) -> Int {
        // Return varied data for weekly view
        let base = weeklyMinutes / 7
        return base + Int.random(in: -30...30)
    }
}

// MARK: - Focus Routine Model
struct ScreenTimeFocusRoutine: Identifiable, Codable {
    let id: String
    var name: String
    var startTime: Date
    var endTime: Date
    var daysOfWeek: [Int] // 1-7 (Sunday-Saturday)
    var mode: FocusMode
    var blockedApps: Set<String>
    var isEnabled: Bool
    
    init(name: String, startTime: Date, endTime: Date, daysOfWeek: [Int], mode: FocusMode, blockedApps: Set<String>) {
        self.id = UUID().uuidString
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.daysOfWeek = daysOfWeek
        self.mode = mode
        self.blockedApps = blockedApps
        self.isEnabled = true
    }
    
    var isActiveNow: Bool {
        let now = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.weekday, from: now)
        
        guard daysOfWeek.contains(currentDay) else { return false }
        
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)
        
        let currentTotal = currentHour * 60 + currentMinute
        let startTotal = startHour * 60 + startMinute
        let endTotal = endHour * 60 + endMinute
        
        return currentTotal >= startTotal && currentTotal <= endTotal
    }
}
