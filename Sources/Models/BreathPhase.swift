import Foundation

/// Breathing phases for breathing exercises
enum BreathPhase: String, CaseIterable {
    case inhale = "Breathe In"
    case holdAfterInhale = "Hold after inhale"
    case exhale = "Breathe Out"
    case holdAfterExhale = "Hold after exhale"
}