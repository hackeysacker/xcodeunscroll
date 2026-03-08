import Foundation
import AVFoundation
import UIKit

// MARK: - Breath Phase Enum
enum BreathPhase: String {
    case inhale = "Breathe In"
    case hold = "Hold"
    case exhale = "Breathe Out"
}

// MARK: - Breathing Guide (Guided Audio)
class BreathingGuide: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = BreathingGuide()
    private let synthesizer = AVSpeechSynthesizer()
    var isEnabled: Bool = true
    private var lastSpokenPhase: BreathPhase?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        guard isEnabled else { return }
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        utterance.pitchMultiplier = 0.9
        utterance.volume = 0.7
        synthesizer.speak(utterance)
    }

    func announcePhase(_ phase: BreathPhase, cycleCount: Int) {
        guard isEnabled else { return }
        guard phase != lastSpokenPhase else { return }
        lastSpokenPhase = phase

        let text: String
        switch phase {
        case .inhale:
            text = cycleCount == 0 ? "Breathe in slowly through your nose" : "Breathe in"
        case .hold:
            text = "Hold"
        case .exhale:
            text = "Breathe out slowly"
        }
        speak(text)
    }

    func startSession() {
        speak("Welcome to your breathing exercise. Get comfortable and follow my voice.")
    }

    func endSession() {
        synthesizer.stopSpeaking(at: .immediate)
        speak("Well done. Session complete.")
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
