import XCTest
@testable import FocusFlow

final class CoreChallengesTests: XCTestCase {
    
    // MARK: - Core Challenge Count
    
    func testCoreChallengeCount() {
        // Core Challenge has 15 challenges (3 per category)
        XCTAssertEqual(CoreChallenge.allCases.count, 15)
    }
    
    func testAllCasesUniqueIDs() {
        let ids = CoreChallenge.allCases.map { $0.id }
        XCTAssertEqual(ids.count, Set(ids).count, "All CoreChallenge IDs should be unique")
    }
    
    // MARK: - Category Tests
    
    func testFocusChallenges() {
        let focusChallenges = CoreChallenge.allCases.filter { $0.category == .focus }
        XCTAssertEqual(focusChallenges.count, 3)
        XCTAssertTrue(focusChallenges.contains(.rapidTarget))
        XCTAssertTrue(focusChallenges.contains(.gazeLock))
        XCTAssertTrue(focusChallenges.contains(.focusZone))
    }
    
    func testMemoryChallenges() {
        let memoryChallenges = CoreChallenge.allCases.filter { $0.category == .memory }
        XCTAssertEqual(memoryChallenges.count, 3)
        XCTAssertTrue(memoryChallenges.contains(.memoryGrid))
        XCTAssertTrue(memoryChallenges.contains(.numberChain))
        XCTAssertTrue(memoryChallenges.contains(.patternMaster))
    }
    
    func testSpeedChallenges() {
        let speedChallenges = CoreChallenge.allCases.filter { $0.category == .speed }
        XCTAssertEqual(speedChallenges.count, 3)
        XCTAssertTrue(speedChallenges.contains(.lightningTap))
        XCTAssertTrue(speedChallenges.contains(.colorBlitz))
        XCTAssertTrue(speedChallenges.contains(.reflexTest))
    }
    
    func testImpulseChallenges() {
        let impulseChallenges = CoreChallenge.allCases.filter { $0.category == .impulse }
        XCTAssertEqual(impulseChallenges.count, 3)
        XCTAssertTrue(impulseChallenges.contains(.redGreenStop))
        XCTAssertTrue(impulseChallenges.contains(.waitForIt))
        XCTAssertTrue(impulseChallenges.contains(.dontTap))
    }
    
    func testCalmChallenges() {
        let calmChallenges = CoreChallenge.allCases.filter { $0.category == .calm }
        XCTAssertEqual(calmChallenges.count, 3)
        XCTAssertTrue(calmChallenges.contains(.breathingCircle))
        XCTAssertTrue(calmChallenges.contains(.zenMode))
        XCTAssertTrue(calmChallenges.contains(.calmWaves))
    }
    
    // MARK: - ID Tests
    
    func testChallengeIDs() {
        XCTAssertEqual(CoreChallenge.rapidTarget.id, "Rapid Target")
        XCTAssertEqual(CoreChallenge.gazeLock.id, "Gaze Lock")
        XCTAssertEqual(CoreChallenge.focusZone.id, "Focus Zone")
        XCTAssertEqual(CoreChallenge.memoryGrid.id, "Memory Grid")
        XCTAssertEqual(CoreChallenge.numberChain.id, "Number Chain")
        XCTAssertEqual(CoreChallenge.patternMaster.id, "Pattern Master")
        XCTAssertEqual(CoreChallenge.lightningTap.id, "Lightning Tap")
        XCTAssertEqual(CoreChallenge.colorBlitz.id, "Color Blitz")
        XCTAssertEqual(CoreChallenge.reflexTest.id, "Reflex Test")
        XCTAssertEqual(CoreChallenge.redGreenStop.id, "Red Light")
        XCTAssertEqual(CoreChallenge.waitForIt.id, "Wait For It")
        XCTAssertEqual(CoreChallenge.dontTap.id, "Don't Tap")
        XCTAssertEqual(CoreChallenge.breathingCircle.id, "Breathe")
        XCTAssertEqual(CoreChallenge.zenMode.id, "Zen Mode")
        XCTAssertEqual(CoreChallenge.calmWaves.id, "Calm Waves")
    }
    
    // MARK: - Icon Tests
    
    func testRapidTargetIcon() {
        XCTAssertEqual(CoreChallenge.rapidTarget.icon, "target")
    }
    
    func testGazeLockIcon() {
        XCTAssertEqual(CoreChallenge.gazeLock.icon, "eye.fill")
    }
    
    func testFocusZoneIcon() {
        XCTAssertEqual(CoreChallenge.focusZone.icon, "scope")
    }
    
    func testMemoryGridIcon() {
        XCTAssertEqual(CoreChallenge.memoryGrid.icon, "square.grid.3x3.fill")
    }
    
    func testNumberChainIcon() {
        XCTAssertEqual(CoreChallenge.numberChain.icon, "number.circle.fill")
    }
    
    func testPatternMasterIcon() {
        XCTAssertEqual(CoreChallenge.patternMaster.icon, "circle.hexagonpath.fill")
    }
    
    func testLightningTapIcon() {
        XCTAssertEqual(CoreChallenge.lightningTap.icon, "bolt.fill")
    }
    
    func testColorBlitzIcon() {
        XCTAssertEqual(CoreChallenge.colorBlitz.icon, "sparkles")
    }
    
    func testReflexTestIcon() {
        XCTAssertEqual(CoreChallenge.reflexTest.icon, "speedometer")
    }
    
    func testRedGreenStopIcon() {
        XCTAssertEqual(CoreChallenge.redGreenStop.icon, "hand.raised.fill")
    }
    
    func testWaitForItIcon() {
        XCTAssertEqual(CoreChallenge.waitForIt.icon, "clock.fill")
    }
    
    func testDontTapIcon() {
        XCTAssertEqual(CoreChallenge.dontTap.icon, "xmark.circle.fill")
    }
    
    func testBreathingCircleIcon() {
        XCTAssertEqual(CoreChallenge.breathingCircle.icon, "wind")
    }
    
    func testZenModeIcon() {
        XCTAssertEqual(CoreChallenge.zenMode.icon, "leaf.fill")
    }
    
    func testCalmWavesIcon() {
        XCTAssertEqual(CoreChallenge.calmWaves.icon, "water.waves")
    }
    
    // MARK: - Description Tests
    
    func testRapidTargetDescription() {
        XCTAssertEqual(CoreChallenge.rapidTarget.description, "Tap targets as fast as you can")
    }
    
    func testGazeLockDescription() {
        XCTAssertEqual(CoreChallenge.gazeLock.description, "Hold your gaze on the target")
    }
    
    func testFocusZoneDescription() {
        XCTAssertEqual(CoreChallenge.focusZone.description, "Find targets in your peripheral vision")
    }
    
    func testMemoryGridDescription() {
        XCTAssertEqual(CoreChallenge.memoryGrid.description, "Remember where the tiles are")
    }
    
    func testNumberChainDescription() {
        XCTAssertEqual(CoreChallenge.numberChain.description, "Recall the number sequence")
    }
    
    func testPatternMasterDescription() {
        XCTAssertEqual(CoreChallenge.patternMaster.description, "Repeat the pattern")
    }
    
    func testLightningTapDescription() {
        XCTAssertEqual(CoreChallenge.lightningTap.description, "React as fast as possible")
    }
    
    func testColorBlitzDescription() {
        XCTAssertEqual(CoreChallenge.colorBlitz.description, "Tap the matching color")
    }
    
    func testReflexTestDescription() {
        XCTAssertEqual(CoreChallenge.reflexTest.description, "Test your reaction time")
    }
    
    func testRedGreenStopDescription() {
        XCTAssertEqual(CoreChallenge.redGreenStop.description, "Stop when red, go when green")
    }
    
    func testWaitForItDescription() {
        XCTAssertEqual(CoreChallenge.waitForIt.description, "Wait for the perfect moment")
    }
    
    func testDontTapDescription() {
        XCTAssertEqual(CoreChallenge.dontTap.description, "Resist the urge to tap")
    }
    
    func testBreathingCircleDescription() {
        XCTAssertEqual(CoreChallenge.breathingCircle.description, "Follow the breathing guide")
    }
    
    func testZenModeDescription() {
        XCTAssertEqual(CoreChallenge.zenMode.description, "Find your calm")
    }
    
    func testCalmWavesDescription() {
        XCTAssertEqual(CoreChallenge.calmWaves.description, "Sync with the waves")
    }
    
    // MARK: - Duration Tests
    
    func testRapidTargetDuration() {
        XCTAssertEqual(CoreChallenge.rapidTarget.duration, 30)
    }
    
    func testGazeLockDuration() {
        XCTAssertEqual(CoreChallenge.gazeLock.duration, 20)
    }
    
    func testFocusZoneDuration() {
        XCTAssertEqual(CoreChallenge.focusZone.duration, 45)
    }
    
    func testMemoryGridDuration() {
        XCTAssertEqual(CoreChallenge.memoryGrid.duration, 60)
    }
    
    func testNumberChainDuration() {
        XCTAssertEqual(CoreChallenge.numberChain.duration, 45)
    }
    
    func testPatternMasterDuration() {
        XCTAssertEqual(CoreChallenge.patternMaster.duration, 40)
    }
    
    func testLightningTapDuration() {
        XCTAssertEqual(CoreChallenge.lightningTap.duration, 30)
    }
    
    func testColorBlitzDuration() {
        XCTAssertEqual(CoreChallenge.colorBlitz.duration, 30)
    }
    
    func testReflexTestDuration() {
        XCTAssertEqual(CoreChallenge.reflexTest.duration, 30)
    }
    
    func testRedGreenStopDuration() {
        XCTAssertEqual(CoreChallenge.redGreenStop.duration, 40)
    }
    
    func testWaitForItDuration() {
        XCTAssertEqual(CoreChallenge.waitForIt.duration, 30)
    }
    
    func testDontTapDuration() {
        XCTAssertEqual(CoreChallenge.dontTap.duration, 25)
    }
    
    func testBreathingCircleDuration() {
        XCTAssertEqual(CoreChallenge.breathingCircle.duration, 60)
    }
    
    func testZenModeDuration() {
        XCTAssertEqual(CoreChallenge.zenMode.duration, 90)
    }
    
    func testCalmWavesDuration() {
        XCTAssertEqual(CoreChallenge.calmWaves.duration, 60)
    }
    
    // MARK: - XP Reward Tests
    
    func testRapidTargetXPReward() {
        XCTAssertEqual(CoreChallenge.rapidTarget.xpReward, 25)
    }
    
    func testGazeLockXPReward() {
        XCTAssertEqual(CoreChallenge.gazeLock.xpReward, 30)
    }
    
    func testFocusZoneXPReward() {
        XCTAssertEqual(CoreChallenge.focusZone.xpReward, 35)
    }
    
    func testMemoryGridXPReward() {
        XCTAssertEqual(CoreChallenge.memoryGrid.xpReward, 40)
    }
    
    func testNumberChainXPReward() {
        XCTAssertEqual(CoreChallenge.numberChain.xpReward, 35)
    }
    
    func testPatternMasterXPReward() {
        XCTAssertEqual(CoreChallenge.patternMaster.xpReward, 45)
    }
    
    func testLightningTapXPReward() {
        XCTAssertEqual(CoreChallenge.lightningTap.xpReward, 30)
    }
    
    func testColorBlitzXPReward() {
        XCTAssertEqual(CoreChallenge.colorBlitz.xpReward, 35)
    }
    
    func testReflexTestXPReward() {
        XCTAssertEqual(CoreChallenge.reflexTest.xpReward, 25)
    }
    
    func testRedGreenStopXPReward() {
        XCTAssertEqual(CoreChallenge.redGreenStop.xpReward, 30)
    }
    
    func testWaitForItXPReward() {
        XCTAssertEqual(CoreChallenge.waitForIt.xpReward, 35)
    }
    
    func testDontTapXPReward() {
        XCTAssertEqual(CoreChallenge.dontTap.xpReward, 40)
    }
    
    func testBreathingCircleXPReward() {
        XCTAssertEqual(CoreChallenge.breathingCircle.xpReward, 20)
    }
    
    func testZenModeXPReward() {
        XCTAssertEqual(CoreChallenge.zenMode.xpReward, 25)
    }
    
    func testCalmWavesXPReward() {
        XCTAssertEqual(CoreChallenge.calmWaves.xpReward, 20)
    }
    
    // MARK: - Total XP Calculation
    
    func testTotalXPRewardsForAllChallenges() {
        let totalXP = CoreChallenge.allCases.reduce(0) { $0 + $1.xpReward }
        // Sum: 25+30+35 + 40+35+45 + 30+35+25 + 30+35+40 + 20+25+20 = 480
        XCTAssertEqual(totalXP, 480)
    }
    
    // MARK: - Average Duration
    
    func testAverageDuration() {
        let totalDuration = CoreChallenge.allCases.reduce(0) { $0 + $1.duration }
        let average = Double(totalDuration) / Double(CoreChallenge.allCases.count)
        // Total: 20+30+45 + 60+45+40 + 30+30+30 + 40+30+25 + 60+90+60 = 635
        XCTAssertEqual(totalDuration, 635)
        XCTAssertEqual(average, 42.333333333333336, accuracy: 0.01)
    }
}
