import XCTest
@testable import FocusFlow

final class ProgressPathTests: XCTestCase {
    
    // MARK: - Progress Path Static Methods
    
    func testTotalLevels() {
        XCTAssertEqual(ProgressPath.totalLevels, 250)
    }
    
    func testLevelsPerRealm() {
        XCTAssertEqual(ProgressPath.levelsPerRealm, 25)
    }
    
    func testTotalRealms() {
        XCTAssertEqual(ProgressPath.totalRealms, 10)
    }
    
    // MARK: - Realm Calculation Tests
    
    func testRealmForLevel1() {
        let realm = ProgressPath.realm(for: 1)
        XCTAssertEqual(realm.id, 1)
    }
    
    func testRealmForLevel25() {
        let realm = ProgressPath.realm(for: 25)
        XCTAssertEqual(realm.id, 1)
    }
    
    func testRealmForLevel26() {
        let realm = ProgressPath.realm(for: 26)
        XCTAssertEqual(realm.id, 2)
    }
    
    func testRealmForLevel50() {
        let realm = ProgressPath.realm(for: 50)
        XCTAssertEqual(realm.id, 2)
    }
    
    func testRealmForLevel51() {
        let realm = ProgressPath.realm(for: 51)
        XCTAssertEqual(realm.id, 3)
    }
    
    func testRealmForMaxLevel() {
        let realm = ProgressPath.realm(for: 250)
        XCTAssertEqual(realm.id, 10)
    }
    
    func testRealmForOverMaxLevel() {
        // Should cap at max realm
        let realm = ProgressPath.realm(for: 300)
        XCTAssertEqual(realm.id, 10)
    }
    
    // MARK: - Level in Realm Tests
    
    func testLevelInProgressRealm_Level1() {
        XCTAssertEqual(ProgressPath.levelInProgressRealm(for: 1), 1)
    }
    
    func testLevelInProgressRealm_Level25() {
        XCTAssertEqual(ProgressPath.levelInProgressRealm(for: 25), 25)
    }
    
    func testLevelInProgressRealm_Level26() {
        XCTAssertEqual(ProgressPath.levelInProgressRealm(for: 26), 1)
    }
    
    func testLevelInProgressRealm_Level50() {
        XCTAssertEqual(ProgressPath.levelInProgressRealm(for: 50), 25)
    }
    
    func testLevelInProgressRealm_Level100() {
        XCTAssertEqual(ProgressPath.levelInProgressRealm(for: 100), 25)
    }
    
    func testLevelInProgressRealm_Level250() {
        XCTAssertEqual(ProgressPath.levelInProgressRealm(for: 250), 25)
    }
    
    // MARK: - XP Required Tests
    
    func testXpRequiredForLevel1() {
        // 1 * 1 * 10 = 10
        XCTAssertEqual(ProgressPath.xpRequiredFor(level: 1), 10)
    }
    
    func testXpRequiredForLevel5() {
        // 5 * 5 * 10 = 250
        XCTAssertEqual(ProgressPath.xpRequiredFor(level: 5), 250)
    }
    
    func testXpRequiredForLevel10() {
        // 10 * 10 * 10 = 1000
        XCTAssertEqual(ProgressPath.xpRequiredFor(level: 10), 1000)
    }
    
    func testXpRequiredForLevel50() {
        // 50 * 50 * 10 = 25000
        XCTAssertEqual(ProgressPath.xpRequiredFor(level: 50), 25000)
    }
    
    // MARK: - Total XP Tests
    
    func testTotalXpToReachLevel1() {
        XCTAssertEqual(ProgressPath.totalXpToReach(level: 1), 10)
    }
    
    func testTotalXpToReachLevel2() {
        // 10 + 40 = 50
        XCTAssertEqual(ProgressPath.totalXpToReach(level: 2), 50)
    }
    
    func testTotalXpToReachLevel3() {
        // 10 + 40 + 90 = 140
        XCTAssertEqual(ProgressPath.totalXpToReach(level: 3), 140)
    }
    
    func testTotalXpToReachLevel5() {
        // 10 + 40 + 90 + 160 + 250 = 550
        XCTAssertEqual(ProgressPath.totalXpToReach(level: 5), 550)
    }
    
    // MARK: - ProgressRealm Tests
    
    func testAllRealmsCount() {
        XCTAssertEqual(ProgressRealm.allRealms.count, 10)
    }
    
    func testRealmIds() {
        for (index, realm) in ProgressRealm.allRealms.enumerated() {
            XCTAssertEqual(realm.id, index + 1)
        }
    }
    
    func testFirstRealm() {
        let realm = ProgressRealm.allRealms[0]
        XCTAssertEqual(realm.id, 1)
        XCTAssertEqual(realm.name, "Mindful Beginnings")
        XCTAssertEqual(realm.levels.lowerBound, 1)
        XCTAssertEqual(realm.levels.upperBound, 25)
    }
    
    func testLastRealm() {
        let realm = ProgressRealm.allRealms[9]
        XCTAssertEqual(realm.id, 10)
        XCTAssertEqual(realm.levels.lowerBound, 226)
        XCTAssertEqual(realm.levels.upperBound, 250)
    }
    
    func testRealmRewards() {
        let firstRealm = ProgressRealm.allRealms[0]
        XCTAssertTrue(firstRealm.rewards.gems > 0)
        XCTAssertTrue(firstRealm.rewards.xp > 0)
    }
    
    func testRealmThemes() {
        for realm in ProgressRealm.allRealms {
            XCTAssertFalse(realm.theme.primary.isEmpty)
            XCTAssertFalse(realm.theme.gradient.isEmpty)
        }
    }
}
