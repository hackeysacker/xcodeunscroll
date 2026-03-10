import XCTest
@testable import FocusFlow

// MARK: - NotificationManager Tests

final class NotificationManagerTests: XCTestCase {
    
    var notificationManager: NotificationManager!
    
    override func setUp() {
        super.setUp()
        notificationManager = NotificationManager.shared
    }
    
    override func tearDown() {
        notificationManager = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Test
    
    func testSingletonInstance() {
        let manager1 = NotificationManager.shared
        let manager2 = NotificationManager.shared
        XCTAssertTrue(manager1 === manager2, "NotificationManager should be a singleton")
    }
    
    // MARK: - Initial State Tests
    
    func testInitialAuthorizationState() {
        // Initially should be false (not checked yet)
        XCTAssertFalse(notificationManager.isAuthorized)
    }
}

// MARK: - BackgroundTaskManager Tests

final class BackgroundTaskManagerTests: XCTestCase {
    
    var backgroundTaskManager: BackgroundTaskManager!
    
    override func setUp() {
        super.setUp()
        backgroundTaskManager = BackgroundTaskManager.shared
    }
    
    override func tearDown() {
        backgroundTaskManager = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Test
    
    func testSingletonInstance() {
        let manager1 = BackgroundTaskManager.shared
        let manager2 = BackgroundTaskManager.shared
        XCTAssertTrue(manager1 === manager2, "BackgroundTaskManager should be a singleton")
    }
    
    // MARK: - Task Identifiers Tests
    
    func testRefreshTaskIdentifier() {
        XCTAssertEqual(BackgroundTaskManager.refreshTaskIdentifier, "com.focusflow.app.refresh")
    }
    
    func testSyncTaskIdentifier() {
        XCTAssertEqual(BackgroundTaskManager.syncTaskIdentifier, "com.focusflow.app.sync")
    }
    
    func testTaskIdentifiersAreUnique() {
        XCTAssertNotEqual(
            BackgroundTaskManager.refreshTaskIdentifier,
            BackgroundTaskManager.syncTaskIdentifier,
            "Task identifiers should be unique"
        )
    }
    
    func testTaskIdentifiersFollowConvention() {
        let refreshId = BackgroundTaskManager.refreshTaskIdentifier
        let syncId = BackgroundTaskManager.syncTaskIdentifier
        
        XCTAssertTrue(refreshId.hasPrefix("com.focusflow.app."), "Refresh task ID should follow bundle convention")
        XCTAssertTrue(syncId.hasPrefix("com.focusflow.app."), "Sync task ID should follow bundle convention")
    }
}
