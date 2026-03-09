import XCTest
@testable import FocusFlow

@MainActor
final class HeartRefillManagerTests: XCTestCase {
    
    var manager: HeartRefillManager!
    var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        // Use a separate suite for tests
        userDefaults = UserDefaults(suiteName: "test_heart_refill")
        UserDefaults.standard.removeObject(forKey: "heart_refill_hearts")
        UserDefaults.standard.removeObject(forKey: "heart_refill_slots")
        UserDefaults.standard.removeObject(forKey: "heart_refill_next")
        UserDefaults.standard.removeObject(forKey: "heart_refill_last_update")
        
        // Create manager (singleton, so we need to reset it)
        manager = HeartRefillManager.shared
        manager.hearts = 5
        manager.refillSlots = 3
        manager.nextRefillTime = nil
        manager.saveState()
    }
    
    override func tearDown() {
        // Reset to defaults
        manager.hearts = 5
        manager.refillSlots = 3
        manager.nextRefillTime = nil
        manager.saveState()
        
        UserDefaults.standard.removeObject(forKey: "heart_refill_hearts")
        UserDefaults.standard.removeObject(forKey: "heart_refill_slots")
        UserDefaults.standard.removeObject(forKey: "heart_refill_next")
        UserDefaults.standard.removeObject(forKey: "heart_refill_last_update")
        
        super.tearDown()
    }
    
    // MARK: - Configuration Tests
    
    func testMaxHearts() {
        XCTAssertEqual(manager.maxHearts, 5, "Max hearts should be 5")
    }
    
    func testMaxRefillSlots() {
        XCTAssertEqual(manager.maxRefillSlots, 3, "Max refill slots should be 3")
    }
    
    func testRefillTimeMinutes() {
        XCTAssertEqual(manager.refillTimeMinutes, 30, "Refill time should be 30 minutes")
    }
    
    // MARK: - Initial State Tests
    
    func testDefaultInitialState() {
        // Test that manager starts with full hearts and slots
        XCTAssertEqual(manager.hearts, 5, "Should start with 5 hearts")
        XCTAssertEqual(manager.refillSlots, 3, "Should start with 3 refill slots")
    }
    
    // MARK: - Use Heart Tests
    
    func testUseHeartDecrementsHearts() {
        let initialHearts = manager.hearts
        _ = manager.useHeart()
        
        XCTAssertEqual(manager.hearts, initialHearts - 1, "Hearts should decrease by 1")
    }
    
    func testUseHeartReturnsTrueWhenHeartsAvailable() {
        let result = manager.useHeart()
        
        XCTAssertTrue(result, "useHeart should return true when hearts are available")
    }
    
    func testUseHeartReturnsFalseWhenNoHearts() {
        manager.hearts = 0
        manager.saveState()
        
        let result = manager.useHeart()
        
        XCTAssertFalse(result, "useHeart should return false when no hearts available")
    }
    
    func testUseHeartDoesNotGoNegative() {
        manager.hearts = 0
        manager.refillSlots = 0
        manager.saveState()
        
        _ = manager.useHeart()
        
        XCTAssertGreaterThanOrEqual(manager.hearts, 0, "Hearts should not go negative")
    }
    
    func testUseHeartStartsRefillWhenSlotsAvailable() {
        manager.hearts = 4
        manager.refillSlots = 2
        manager.nextRefillTime = nil
        manager.saveState()
        
        _ = manager.useHeart()
        
        XCTAssertNotNil(manager.nextRefillTime, "Refill should start when slots are available")
    }
    
    // MARK: - Add Heart Tests
    
    func testAddHeartIncrementsHearts() {
        manager.hearts = 3
        manager.saveState()
        
        manager.addHeart()
        
        XCTAssertEqual(manager.hearts, 4, "Hearts should increase by 1")
    }
    
    func testAddHeartRespectsMaxHearts() {
        manager.hearts = 5
        manager.saveState()
        
        manager.addHeart()
        
        XCTAssertEqual(manager.hearts, 5, "Hearts should not exceed max")
    }
    
    // MARK: - Refill All Hearts Tests
    
    func testRefillAllHeartsSetsToMax() {
        manager.hearts = 1
        manager.saveState()
        
        manager.refillAllHearts()
        
        XCTAssertEqual(manager.hearts, 5, "All hearts should be refilled")
    }
    
    // MARK: - Earn Refill Slot Tests
    
    func testEarnRefillSlotIncrementsSlots() {
        manager.refillSlots = 1
        manager.saveState()
        
        manager.earnRefillSlot()
        
        XCTAssertEqual(manager.refillSlots, 2, "Refill slots should increase by 1")
    }
    
    func testEarnRefillSlotRespectsMax() {
        manager.refillSlots = 3
        manager.saveState()
        
        manager.earnRefillSlot()
        
        XCTAssertEqual(manager.refillSlots, 3, "Refill slots should not exceed max")
    }
    
    func testEarnRefillSlotStartsRefillIfHeartsMissing() {
        manager.hearts = 3
        manager.refillSlots = 1
        manager.nextRefillTime = nil
        manager.saveState()
        
        manager.earnRefillSlot()
        
        XCTAssertNotNil(manager.nextRefillTime, "Refill should start when hearts are missing")
    }
    
    // MARK: - Tick Tests
    
    func testTickAddsHeartWhenTimeReached() {
        manager.hearts = 4
        manager.refillSlots = 1
        manager.nextRefillTime = Date().addingTimeInterval(-60) // 1 minute ago
        manager.saveState()
        
        manager.tick()
        
        XCTAssertEqual(manager.hearts, 5, "Heart should be added when time reached")
    }
    
    func testTickDecrementsSlotWhenHeartAdded() {
        manager.hearts = 4
        manager.refillSlots = 1
        manager.nextRefillTime = Date().addingTimeInterval(-60)
        manager.saveState()
        
        manager.tick()
        
        XCTAssertEqual(manager.refillSlots, 0, "Slot should be used when heart added")
    }
    
    func testTickDoesNotAddHeartWhenNoSlots() {
        manager.hearts = 4
        manager.refillSlots = 0
        manager.nextRefillTime = Date().addingTimeInterval(-60)
        manager.saveState()
        
        manager.tick()
        
        XCTAssertEqual(manager.hearts, 4, "Heart should not be added when no slots")
    }
    
    func testTickDoesNotAddHeartWhenAlreadyFull() {
        manager.hearts = 5
        manager.refillSlots = 1
        manager.nextRefillTime = Date().addingTimeInterval(-60)
        manager.saveState()
        
        manager.tick()
        
        XCTAssertEqual(manager.hearts, 5, "Heart should not be added when already full")
    }
    
    // MARK: - Display Tests
    
    func testHeartsDisplayShowsCorrectEmojis() {
        manager.hearts = 3
        manager.saveState()
        
        let display = manager.heartsDisplay
        
        XCTAssertEqual(display, "❤️❤️❤️🖤🖤", "Should show 3 full and 2 empty hearts")
    }
    
    func testHeartsDisplayFullHearts() {
        manager.hearts = 5
        manager.saveState()
        
        let display = manager.heartsDisplay
        
        XCTAssertEqual(display, "❤️❤️❤️❤️❤️", "Should show 5 full hearts")
    }
    
    func testHeartsDisplayEmptyHearts() {
        manager.hearts = 0
        manager.saveState()
        
        let display = manager.heartsDisplay
        
        XCTAssertEqual(display, "🖤🖤🖤🖤🖤", "Should show 5 empty hearts")
    }
    
    func testRefillSlotsDisplay() {
        manager.refillSlots = 2
        manager.saveState()
        
        let display = manager.refillSlotsDisplay
        
        XCTAssertEqual(display, "Slots: 2/3", "Should show correct slot count")
    }
    
    func testNextRefillTextNoRefill() {
        manager.refillSlots = 3
        manager.nextRefillTime = nil
        manager.saveState()
        
        let text = manager.nextRefillText
        
        XCTAssertEqual(text, "All slots full", "Should indicate all slots full")
    }
    
    func testNextRefillTextWithUpcomingRefill() {
        let futureDate = Date().addingTimeInterval(15 * 60) // 15 minutes
        manager.nextRefillTime = futureDate
        manager.saveState()
        
        let text = manager.nextRefillText
        
        XCTAssertTrue(text.contains("Heart in"), "Should show time until heart")
    }
    
    // MARK: - Timer Tests
    
    func testTimersCanBeStarted() {
        manager.stopTimers()
        
        manager.startTimers()
        
        XCTAssertTrue(manager.isTimerRunning, "Timers should be running after start")
    }
    
    func testTimersCanBeStopped() {
        manager.startTimers()
        
        manager.stopTimers()
        
        XCTAssertFalse(manager.isTimerRunning, "Timers should not be running after stop")
    }
    
    // MARK: - Persistence Tests
    
    func testSaveAndLoadState() {
        manager.hearts = 2
        manager.refillSlots = 1
        manager.nextRefillTime = Date().addingTimeInterval(1000)
        manager.saveState()
        
        // Reload
        manager.loadState()
        
        XCTAssertEqual(manager.hearts, 2, "Hearts should persist")
        XCTAssertEqual(manager.refillSlots, 1, "Refill slots should persist")
    }
    
    func testLoadStateDefaultsToFullWhenZero() {
        UserDefaults.standard.set(0, forKey: "heart_refill_hearts")
        
        manager.loadState()
        
        XCTAssertEqual(manager.hearts, 5, "Should default to full hearts when 0")
    }
    
    // MARK: - Purchase Tests
    
    func testPurchaseHeartWithGemsSuccessful() {
        // Create a mock AppState with gems
        let appState = AppState()
        appState.gems = 10
        appState.saveState()
        
        manager.hearts = 4
        manager.saveState()
        
        let result = manager.purchaseHeartWithGems(cost: 5, appState: appState)
        
        XCTAssertTrue(result, "Purchase should succeed")
        XCTAssertEqual(manager.hearts, 5, "Heart should be added")
    }
    
    func testPurchaseHeartWithGemsFailsNoGems() {
        let appState = AppState()
        appState.gems = 0
        appState.saveState()
        
        let result = manager.purchaseHeartWithGems(cost: 5, appState: appState)
        
        XCTAssertFalse(result, "Purchase should fail when no gems")
    }
    
    func testPurchaseHeartWithGemsFailsAlreadyFull() {
        let appState = AppState()
        appState.gems = 10
        appState.saveState()
        
        manager.hearts = 5
        manager.saveState()
        
        let result = manager.purchaseHeartWithGems(cost: 5, appState: appState)
        
        XCTAssertFalse(result, "Purchase should fail when hearts full")
    }
    
    func testPurchaseSlotWithGemsSuccessful() {
        let appState = AppState()
        appState.gems = 10
        appState.saveState()
        
        manager.refillSlots = 2
        manager.saveState()
        
        let result = manager.purchaseRefillSlotWithGems(cost: 5, appState: appState)
        
        XCTAssertTrue(result, "Purchase should succeed")
        XCTAssertEqual(manager.refillSlots, 3, "Slot should be added")
    }
    
    func testPurchaseSlotWithGemsFailsNoGems() {
        let appState = AppState()
        appState.gems = 0
        appState.saveState()
        
        let result = manager.purchaseRefillSlotWithGems(cost: 5, appState: appState)
        
        XCTAssertFalse(result, "Purchase should fail when no gems")
    }
    
    func testPurchaseSlotWithGemsFailsAlreadyFull() {
        let appState = AppState()
        appState.gems = 10
        appState.saveState()
        
        manager.refillSlots = 3
        manager.saveState()
        
        let result = manager.purchaseRefillSlotWithGems(cost: 5, appState: appState)
        
        XCTAssertFalse(result, "Purchase should fail when slots full")
    }
}
