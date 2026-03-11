import XCTest
@testable import Unscroll

final class SettingsViewTests: XCTestCase {
    
    var settingsViewModel: SettingsViewModel!
    
    override func setUp() {
        super.setUp()
        settingsViewModel = SettingsViewModel()
    }
    
    override func tearDown() {
        settingsViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Sound Settings Tests
    
    func testSoundEnabledByDefault() {
        XCTAssertTrue(settingsViewModel.soundEnabled)
    }
    
    func testToggleSound() {
        settingsViewModel.soundEnabled = false
        XCTAssertFalse(settingsViewModel.soundEnabled)
        settingsViewModel.soundEnabled = true
        XCTAssertTrue(settingsViewModel.soundEnabled)
    }
    
    // MARK: - Haptic Settings Tests
    
    func testHapticsEnabledByDefault() {
        XCTAssertTrue(settingsViewModel.hapticsEnabled)
    }
    
    func testToggleHaptics() {
        settingsViewModel.hapticsEnabled = false
        XCTAssertFalse(settingsViewModel.hapticsEnabled)
        settingsViewModel.hapticsEnabled = true
        XCTAssertTrue(settingsViewModel.hapticsEnabled)
    }
    
    // MARK: - Notification Settings Tests
    
    func testNotificationsEnabledByDefault() {
        XCTAssertTrue(settingsViewModel.notificationsEnabled)
    }
    
    func testToggleNotifications() {
        settingsViewModel.notificationsEnabled = false
        XCTAssertFalse(settingsViewModel.notificationsEnabled)
        settingsViewModel.notificationsEnabled = true
        XCTAssertTrue(settingsViewModel.notificationsEnabled)
    }
    
    // MARK: - Daily Reminder Tests
    
    func testDailyReminderTime() {
        settingsViewModel.dailyReminderHour = 9
        settingsViewModel.dailyReminderMinute = 0
        XCTAssertEqual(settingsViewModel.dailyReminderHour, 9)
        XCTAssertEqual(settingsViewModel.dailyReminderMinute, 0)
    }
    
    func testDailyReminderEnabledByDefault() {
        XCTAssertTrue(settingsViewModel.dailyReminderEnabled)
    }
    
    // MARK: - Dark Mode Tests
    
    func testDarkModeEnabledByDefault() {
        XCTAssertTrue(settingsViewModel.darkModeEnabled)
    }
    
    func testToggleDarkMode() {
        settingsViewModel.darkModeEnabled = false
        XCTAssertFalse(settingsViewModel.darkModeEnabled)
        settingsViewModel.darkModeEnabled = true
        XCTAssertTrue(settingsViewModel.darkModeEnabled)
    }
    
    // MARK: - Account Settings Tests
    
    func testUserEmail() {
        settingsViewModel.userEmail = "test@example.com"
        XCTAssertEqual(settingsViewModel.userEmail, "test@example.com")
    }
    
    func testUserDisplayName() {
        settingsViewModel.userDisplayName = "Test User"
        XCTAssertEqual(settingsViewModel.userDisplayName, "Test User")
    }
    
    // MARK: - Sign Out Tests
    
    func testSignOut() {
        settingsViewModel.isSignedIn = true
        settingsViewModel.signOut()
        XCTAssertFalse(settingsViewModel.isSignedIn)
    }
    
    // MARK: - Heart System Tests (Testing Mode)
    
    func testAddHearts() {
        settingsViewModel.gameProgress.hearts = 3
        settingsViewModel.addTestHeart()
        XCTAssertEqual(settingsViewModel.gameProgress.hearts, 4)
    }
    
    func testRemoveHearts() {
        settingsViewModel.gameProgress.hearts = 5
        settingsViewModel.removeTestHeart()
        XCTAssertEqual(settingsViewModel.gameProgress.hearts, 4)
    }
    
    func testAddGems() {
        settingsViewModel.gameProgress.gems = 100
        settingsViewModel.addTestGems(50)
        XCTAssertEqual(settingsViewModel.gameProgress.gems, 150)
    }
    
    // MARK: - Data Management Tests
    
    func testClearLocalData() {
        settingsViewModel.gameProgress.addXP(100)
        settingsViewModel.gameProgress.addGems(50)
        settingsViewModel.clearLocalData()
        XCTAssertEqual(settingsViewModel.gameProgress.xp, 0)
        XCTAssertEqual(settingsViewModel.gameProgress.gems, 0)
    }
    
    func testExportData() {
        let exportedData = settingsViewModel.exportUserData()
        XCTAssertNotNil(exportedData)
    }
}

// MARK: - SettingsViewModel Helper

class SettingsViewModel: ObservableObject {
    @Published var soundEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    @Published var notificationsEnabled: Bool = true
    @Published var dailyReminderEnabled: Bool = true
    @Published var dailyReminderHour: Int = 9
    @Published var dailyReminderMinute: Int = 0
    @Published var darkModeEnabled: Bool = true
    @Published var userEmail: String = ""
    @Published var userDisplayName: String = ""
    @Published var isSignedIn: Bool = false
    @Published var isTestingMode: Bool = false
    
    let gameProgress: GameProgress
    
    init() {
        self.gameProgress = GameProgress()
    }
    
    func signOut() {
        isSignedIn = false
        userEmail = ""
        userDisplayName = ""
    }
    
    func addTestHeart() {
        if gameProgress.hearts < 5 {
            gameProgress.addHeart()
        }
    }
    
    func removeTestHeart() {
        if gameProgress.hearts > 0 {
            gameProgress.loseHeart()
        }
    }
    
    func addTestGems(_ amount: Int) {
        gameProgress.addGems(amount)
    }
    
    func clearLocalData() {
        gameProgress.xp = 0
        gameProgress.gems = 0
        gameProgress.streak = 0
        gameProgress.hearts = 5
    }
    
    func exportUserData() -> Data? {
        let data: [String: Any] = [
            "xp": gameProgress.xp,
            "level": gameProgress.level,
            "gems": gameProgress.gems,
            "streak": gameProgress.streak,
            "hearts": gameProgress.hearts
        ]
        return try? JSONSerialization.data(withJSONObject: data)
    }
}
