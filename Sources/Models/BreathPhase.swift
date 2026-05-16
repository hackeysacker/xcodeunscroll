import Foundation

/// Breathing phases for breathing exercises
enum BreathPhase: String, CaseIterable {
    case inhale = "Breathe In"
    case hold = "Hold"  // Used for switch exhaustive
    case holdAfterInhale = "Hold after inhale"
    case holdAfterExhale = "Hold after exhale"
    case exhale = "Breathe Out"
}