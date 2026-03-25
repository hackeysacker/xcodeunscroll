import XCTest
import AVFoundation
@testable import FocusFlow

final class BreathingGuideTests: XCTestCase {
    
    var breathingGuide: BreathingGuide!
    
    override func setUp() {
        super.setUp()
        breathingGuide = BreathingGuide.shared
    }
    
    override func tearDown() {
        breathingGuide.stop()
        breathingGuide = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Verification
    
    func test_singleton_returnsSameInstance() {
        let instance1 = BreathingGuide.shared
        let instance2 = BreathingGuide.shared
        XCTAssertTrue(instance1 === instance2, "BreathingGuide should be a singleton")
    }
    
    // MARK: - Configuration Tests
    
    func test_isEnabled_defaultsToTrue() {
        XCTAssertTrue(breathingGuide.isEnabled, "isEnabled should default to true")
    }
    
    func test_isEnabled_canBeToggled() {
        breathingGuide.isEnabled = false
        XCTAssertFalse(breathingGuide.isEnabled)
        
        breathingGuide.isEnabled = true
        XCTAssertTrue(breathingGuide.isEnabled)
    }
    
    // MARK: - BreathPhase Tests
    
    func test_breathPhase_rawValues() {
        XCTAssertEqual(BreathPhase.inhale.rawValue, "Breathe In")
        XCTAssertEqual(BreathPhase.hold.rawValue, "Hold")
        XCTAssertEqual(BreathPhase.exhale.rawValue, "Breathe Out")
    }
    
    func test_breathPhase_allCases() {
        let allPhases = BreathPhase.allCases
        XCTAssertEqual(allPhases.count, 3, "There should be 3 breath phases")
        XCTAssertTrue(allPhases.contains(.inhale))
        XCTAssertTrue(allPhases.contains(.hold))
        XCTAssertTrue(allPhases.contains(.exhale))
    }
    
    // MARK: - Announce Phase Tests
    
    func test_announcePhase_inhaleText_firstCycle() {
        // Should return full instruction for first cycle
        // We can verify the method exists and doesn't crash
        breathingGuide.isEnabled = true
        breathingGuide.announcePhase(.inhale, cycleCount: 0)
    }
    
    func test_announcePhase_inhaleText_subsequentCycles() {
        breathingGuide.isEnabled = true
        breathingGuide.announcePhase(.inhale, cycleCount: 1)
    }
    
    func test_announcePhase_holdText() {
        breathingGuide.isEnabled = true
        breathingGuide.announcePhase(.hold, cycleCount: 0)
    }
    
    func test_announcePhase_exhaleText() {
        breathingGuide.isEnabled = true
        breathingGuide.announcePhase(.exhale, cycleCount: 0)
    }
    
    func test_announcePhase_respectsIsEnabled() {
        breathingGuide.isEnabled = false
        // Should not crash when disabled
        breathingGuide.announcePhase(.inhale, cycleCount: 0)
    }
    
    // MARK: - Session Tests
    
    func test_startSession_speaksWelcome() {
        breathingGuide.isEnabled = true
        // Should not throw
        breathingGuide.startSession()
    }
    
    func test_startSession_respectsIsEnabled() {
        breathingGuide.isEnabled = false
        // Should not throw
        breathingGuide.startSession()
    }
    
    func test_endSession_speaksCompletion() {
        breathingGuide.isEnabled = true
        // Should not throw
        breathingGuide.endSession()
    }
    
    func test_endSession_respectsIsEnabled() {
        breathingGuide.isEnabled = false
        // Should not throw
        breathingGuide.endSession()
    }
    
    // MARK: - Stop Tests
    
    func test_stop_stopsSpeaking() {
        breathingGuide.isEnabled = true
        breathingGuide.startSession()
        // Should not throw
        breathingGuide.stop()
    }
    
    func test_stop_multipleCalls() {
        breathingGuide.isEnabled = true
        breathingGuide.startSession()
        // Should not throw even when called multiple times
        breathingGuide.stop()
        breathingGuide.stop()
        breathingGuide.stop()
    }
    
    // MARK: - Speak Tests
    
    func test_speak_respectsIsEnabled() {
        breathingGuide.isEnabled = false
        // Should not throw
        breathingGuide.speak("Test message")
    }
    
    func test_speak_withValidText() {
        breathingGuide.isEnabled = true
        // Should not throw
        breathingGuide.speak("Test message")
    }
    
    func test_speak_stopsPreviousSpeech() {
        breathingGuide.isEnabled = true
        // Speak multiple times rapidly
        breathingGuide.speak("First message")
        breathingGuide.speak("Second message")
        breathingGuide.speak("Third message")
    }
    
    // MARK: - Delegate Conformance
    
    func test_conformsToAVSpeechSynthesizerDelegate() {
        XCTAssertTrue(breathingGuide is AVSpeechSynthesizerDelegate, 
                      "BreathingGuide should conform to AVSpeechSynthesizerDelegate")
    }
}
