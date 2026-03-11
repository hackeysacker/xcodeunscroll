import XCTest
@testable import FocusFlow

@MainActor
final class AppAudioManagerTests: XCTestCase {
    
    var audioManager: AppAudioManager!
    
    override func setUp() {
        super.setUp()
        audioManager = AppAudioManager.shared
    }
    
    override func tearDown() {
        audioManager = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Verification
    
    func test_singleton_returnsSameInstance() {
        let instance1 = AppAudioManager.shared
        let instance2 = AppAudioManager.shared
        XCTAssertTrue(instance1 === instance2, "AppAudioManager should be a singleton")
    }
    
    // MARK: - Configuration Tests
    
    func test_soundEnabled_defaultsToTrue() {
        XCTAssertTrue(audioManager.soundEnabled, "soundEnabled should default to true")
    }
    
    func test_hapticEnabled_defaultsToTrue() {
        XCTAssertTrue(audioManager.hapticEnabled, "hapticEnabled should default to true")
    }
    
    func test_soundEnabled_canBeToggled() {
        audioManager.soundEnabled = false
        XCTAssertFalse(audioManager.soundEnabled)
        
        audioManager.soundEnabled = true
        XCTAssertTrue(audioManager.soundEnabled)
    }
    
    func test_hapticEnabled_canBeToggled() {
        audioManager.hapticEnabled = false
        XCTAssertFalse(audioManager.hapticEnabled)
        
        audioManager.hapticEnabled = true
        XCTAssertTrue(audioManager.hapticEnabled)
    }
    
    // MARK: - ObservableObject Conformance
    
    func test_conformsToObservableObject() {
        XCTAssertTrue(audioManager is any ObservableObject, "AppAudioManager should conform to ObservableObject")
    }
    
    // MARK: - Haptic Methods - Verify No Crash
    
    func test_lightImpact_noCrash() {
        audioManager.hapticEnabled = true
        // Should not throw - just verify it can be called
        audioManager.lightImpact()
    }
    
    func test_mediumImpact_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.mediumImpact()
    }
    
    func test_heavyImpact_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.heavyImpact()
    }
    
    func test_softImpact_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.softImpact()
    }
    
    func test_rigidImpact_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.rigidImpact()
    }
    
    func test_selection_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.selection()
    }
    
    func test_success_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.success()
    }
    
    func test_warning_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.warning()
    }
    
    func test_error_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.error()
    }
    
    // MARK: - Haptic Methods - Disabled State
    
    func test_lightImpact_disabled_noCrash() {
        audioManager.hapticEnabled = false
        audioManager.lightImpact()
    }
    
    func test_mediumImpact_disabled_noCrash() {
        audioManager.hapticEnabled = false
        audioManager.mediumImpact()
    }
    
    func test_success_disabled_noCrash() {
        audioManager.hapticEnabled = false
        audioManager.success()
    }
    
    // MARK: - Combo Haptic Tests
    
    func test_comboHaptic_level0_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.comboHaptic(0)
    }
    
    func test_comboHaptic_level5_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.comboHaptic(5)
    }
    
    func test_comboHaptic_level10_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.comboHaptic(10)
    }
    
    func test_comboHaptic_level15_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.comboHaptic(15)
    }
    
    func test_comboHaptic_level20_noCrash() {
        audioManager.hapticEnabled = true
        audioManager.comboHaptic(20)
    }
    
    func test_comboHaptic_disabled_noCrash() {
        audioManager.hapticEnabled = false
        audioManager.comboHaptic(20)
    }
    
    // MARK: - Sound Methods - Verify No Crash
    
    func test_playTap_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playTap()
    }
    
    func test_playUISelect_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playUISelect()
    }
    
    func test_playSuccess_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playSuccess()
    }
    
    func test_playError_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playError()
    }
    
    func test_playWarning_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playWarning()
    }
    
    func test_playLevelUp_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playLevelUp()
    }
    
    func test_playReward_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playReward()
    }
    
    func test_playHeartLoss_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playHeartLoss()
    }
    
    func test_playHeartGain_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playHeartGain()
    }
    
    func test_playGemEarn_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playGemEarn()
    }
    
    func test_playButtonTap_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playButtonTap()
    }
    
    func test_playChallengeStart_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playChallengeStart()
    }
    
    func test_playChallengeComplete_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playChallengeComplete()
    }
    
    func test_playPerfect_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playPerfect()
    }
    
    // MARK: - Sound Methods - Disabled State
    
    func test_playTap_disabled_noCrash() {
        audioManager.soundEnabled = false
        audioManager.playTap()
    }
    
    func test_playSuccess_disabled_noCrash() {
        audioManager.soundEnabled = false
        audioManager.playSuccess()
    }
    
    func test_playLevelUp_disabled_noCrash() {
        audioManager.soundEnabled = false
        audioManager.playLevelUp()
    }
    
    // MARK: - Combo Sound Tests
    
    func test_playCombo_multiple_noCrash() {
        audioManager.soundEnabled = true
        audioManager.hapticEnabled = true
        
        // Test various combo levels
        audioManager.playCombo(0)
        audioManager.playCombo(5)
        audioManager.playCombo(10)
        audioManager.playCombo(15)
        audioManager.playCombo(20)
    }
    
    // MARK: - Countdown Tests
    
    func test_playCountdownTick_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playCountdownTick()
    }
    
    func test_playCountdownFinal_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playCountdownFinal()
    }
    
    // MARK: - Achievement/Streak Tests
    
    func test_playAchievement_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playAchievement()
    }
    
    func test_playStreak_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playStreak()
    }
    
    func test_playStreakBroken_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playStreakBroken()
    }
    
    // MARK: - Purchase Tests
    
    func test_playPurchase_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playPurchase()
    }
    
    func test_playInsufficientFunds_noCrash() {
        audioManager.soundEnabled = true
        audioManager.playInsufficientFunds()
    }
    
    // MARK: - Prepare Haptics
    
    func test_prepareHaptics_noCrash() {
        audioManager.prepareHaptics()
    }
}
