import SwiftUI

// MARK: - Core 15 Challenges (Quality First)

enum CoreChallenge: String, CaseIterable, Identifiable {
    // Focus (3)
    case rapidTarget = "Rapid Target"
    case gazeLock = "Gaze Lock"
    case focusZone = "Focus Zone"
    
    // Memory (3)
    case memoryGrid = "Memory Grid"
    case numberChain = "Number Chain"
    case patternMaster = "Pattern Master"
    
    // Speed (3)
    case lightningTap = "Lightning Tap"
    case colorBlitz = "Color Blitz"
    case reflexTest = "Reflex Test"
    
    // Impulse (3)
    case redGreenStop = "Red Light"
    case waitForIt = "Wait For It"
    case dontTap = "Don't Tap"
    
    // Calm (3)
    case breathingCircle = "Breathe"
    case zenMode = "Zen Mode"
    case calmWaves = "Calm Waves"
    
    var id: String { rawValue }
    
    var category: ChallengeCategory {
        switch self {
        case .rapidTarget, .gazeLock, .focusZone: return .focus
        case .memoryGrid, .numberChain, .patternMaster: return .memory
        case .lightningTap, .colorBlitz, .reflexTest: return .speed
        case .redGreenStop, .waitForIt, .dontTap: return .impulse
        case .breathingCircle, .zenMode, .calmWaves: return .calm
        }
    }
    
    var icon: String {
        switch self {
        case .rapidTarget: return "target"
        case .gazeLock: return "eye.fill"
        case .focusZone: return "scope"
        case .memoryGrid: return "square.grid.3x3.fill"
        case .numberChain: return "number.circle.fill"
        case .patternMaster: return "circle.hexagonpath.fill"
        case .lightningTap: return "bolt.fill"
        case .colorBlitz: return "sparkles"
        case .reflexTest: return "speedometer"
        case .redGreenStop: return "hand.raised.fill"
        case .waitForIt: return "clock.fill"
        case .dontTap: return "xmark.circle.fill"
        case .breathingCircle: return "wind"
        case .zenMode: return "leaf.fill"
        case .calmWaves: return "water.waves"
        }
    }
    
    var description: String {
        switch self {
        case .rapidTarget: return "Tap targets as fast as you can"
        case .gazeLock: return "Hold your gaze on the target"
        case .focusZone: return "Find targets in your peripheral vision"
        case .memoryGrid: return "Remember where the tiles are"
        case .numberChain: return "Recall the number sequence"
        case .patternMaster: return "Repeat the pattern"
        case .lightningTap: return "React as fast as possible"
        case .colorBlitz: return "Tap the matching color"
        case .reflexTest: return "Test your reaction time"
        case .redGreenStop: return "Stop when red, go when green"
        case .waitForIt: return "Wait for the perfect moment"
        case .dontTap: return "Resist the urge to tap"
        case .breathingCircle: return "Follow the breathing guide"
        case .zenMode: return "Find your calm"
        case .calmWaves: return "Sync with the waves"
        }
    }
    
    var duration: Int {
        switch self {
        case .rapidTarget, .lightningTap, .reflexTest: return 30
        case .gazeLock: return 20
        case .focusZone: return 45
        case .memoryGrid: return 60
        case .numberChain: return 45
        case .patternMaster: return 40
        case .colorBlitz: return 30
        case .redGreenStop: return 40
        case .waitForIt: return 30
        case .dontTap: return 25
        case .breathingCircle: return 60
        case .zenMode: return 90
        case .calmWaves: return 60
        }
    }
    
    var xpReward: Int {
        switch self {
        case .rapidTarget: return 25
        case .gazeLock: return 30
        case .focusZone: return 35
        case .memoryGrid: return 40
        case .numberChain: return 35
        case .patternMaster: return 45
        case .lightningTap: return 30
        case .colorBlitz: return 35
        case .reflexTest: return 25
        case .redGreenStop: return 30
        case .waitForIt: return 35
        case .dontTap: return 40
        case .breathingCircle: return 20
        case .zenMode: return 25
        case .calmWaves: return 20
        }
    }
}
