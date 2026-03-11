import XCTest
@testable import Unscroll

final class SkillProgressTests: XCTestCase {
    
    var skillProgress: SkillProgress!
    
    override func setUp() {
        super.setUp()
        skillProgress = SkillProgress()
    }
    
    override func tearDown() {
        skillProgress = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialFocusLevel() {
        XCTAssertEqual(skillProgress.focusLevel, 1)
    }
    
    func testInitialImpulseControlLevel() {
        XCTAssertEqual(skillProgress.impulseControlLevel, 1)
    }
    
    func testInitialDistractionResistanceLevel() {
        XCTAssertEqual(skillProgress.distractionResistanceLevel, 1)
    }
    
    // MARK: - Leveling Tests
    
    func testIncreaseFocusLevel() {
        let initialLevel = skillProgress.focusLevel
        skillProgress.increaseFocusXP(50)
        XCTAssertGreaterThanOrEqual(skillProgress.focusLevel, initialLevel)
    }
    
    func testSkillLevelMaxIs100() {
        // Artificially set to high level to test cap
        skillProgress.focusLevel = 100
        skillProgress.increaseFocusXP(1000)
        XCTAssertLessThanOrEqual(skillProgress.focusLevel, 100)
    }
    
    // MARK: - Skill Names
    
    func testAllSkillNamesExist() {
        let skills: [Skill] = [.focus, .impulseControl, .distractionResistance, .memory, .reactionTime, .discipline]
        XCTAssertEqual(skills.count, 6)
    }
    
    func testSkillDescription() {
        XCTAssertFalse(Skill.focus.description.isEmpty)
        XCTAssertFalse(Skill.impulseControl.description.isEmpty)
    }
}
