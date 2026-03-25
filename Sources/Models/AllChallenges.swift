import SwiftUI

// MARK: - All Challenge Types
enum AllChallengeType: String, CaseIterable, Identifiable, Codable {
    // Focus & Attention
    case movingTarget = "Moving Target"
    case multiObjectTracking = "Multi-Object Tracking"
    case gazeHold = "Gaze Hold"
    case focusHold = "Focus Hold"
    case focusSprint = "Focus Sprint"
    case stillnessTest = "Stillness Test"
    case slowTracking = "Slow Tracking"
    
    // Memory
    case memoryFlash = "Memory Flash"
    case memoryPuzzle = "Memory Puzzle"
    case numberSequence = "Number Sequence"
    case patternMatching = "Pattern Matching"
    case colorPattern = "Color Pattern"
    case tapPattern = "Tap Pattern"
    case spatialPuzzle = "Spatial Puzzle"
    
    // Reaction
    case reactionInhibition = "Reaction Inhibition"
    case impulseSpikeTest = "Impulse Spike Test"
    case rhythmTap = "Rhythm Tap"
    case delayUnlock = "Delay Unlock"
    case resetChallenge = "Reset Challenge"
    
    // Breathing & Calm
    case boxBreathing = "Box Breathing"
    case controlledBreathing = "Controlled Breathing"
    case breathPacing = "Breath Pacing"
    case slowBreathing = "Slow Breathing"
    case bodyScan = "Body Scan"
    case fiveSenses = "Five Senses"
    case urgeSurfing = "Urge Surfing"
    case calmVisual = "Calm Visual"
    case breathingBasics = "Breathing Basics"
    case calmFocus = "Calm Focus"
    case stressRelief = "Stress Relief"
    case energyBoost = "Energy Boost"
    case deepBreath = "Deep Breath"
    case breathingAdvanced = "Breathing Advanced"
    case focusEndurance = "Focus Endurance"
    case meditationMaster = "Meditation Master"
    
    // Discipline & Resistance
    case antiScrollSwipe = "Anti-Scroll Swipe"
    case appSwitchResistance = "App Switch Resistance"
    case fakeNotifications = "Fake Notifications"
    case fingerHold = "Finger Hold"
    case fingerTracing = "Finger Tracing"
    case impulseDelay = "Impulse Delay"
    case distractionLog = "Distraction Log"
    case lookAway = "Look Away"
    case multiTaskTap = "Multi-Task Tap"
    case notificationResistance = "Notification Resistance"
    case popupIgnore = "Popup Ignore"
    case tapOnlyCorrect = "Tap Only Correct"
    case wordPuzzle = "Word Puzzle"
    case logicPuzzle = "Logic Puzzle"
    
    var id: String { rawValue }
    
    var category: ChallengeCategory {
        switch self {
        case .movingTarget, .multiObjectTracking, .gazeHold, .focusHold, .focusSprint, .stillnessTest, .slowTracking, .focusEndurance:
            return .focus
        case .memoryFlash, .memoryPuzzle, .numberSequence, .patternMatching, .colorPattern, .tapPattern, .spatialPuzzle:
            return .memory
        case .reactionInhibition, .impulseSpikeTest, .rhythmTap, .delayUnlock, .resetChallenge:
            return .reaction
        case .boxBreathing, .controlledBreathing, .breathPacing, .slowBreathing, .bodyScan, .fiveSenses, .urgeSurfing, .calmVisual, .breathingBasics, .calmFocus, .stressRelief, .energyBoost, .deepBreath, .breathingAdvanced, .meditationMaster:
            return .breathing
        case .antiScrollSwipe, .appSwitchResistance, .fakeNotifications, .fingerHold, .fingerTracing, .impulseDelay, .distractionLog, .lookAway, .multiTaskTap, .notificationResistance, .popupIgnore, .tapOnlyCorrect, .wordPuzzle, .logicPuzzle:
            return .discipline
        }
    }
    
    var icon: String {
        switch self {
        case .movingTarget: return "target"
        case .multiObjectTracking: return "eye.trianglebadge.exclamationmark"
        case .gazeHold: return "eye.fill"
        case .focusHold: return "scope"
        case .focusSprint: return "bolt.fill"
        case .stillnessTest: return "figure.stand"
        case .slowTracking: return "hare.fill"
        case .memoryFlash: return "brain.head.profile"
        case .memoryPuzzle: return "puzzlepiece.fill"
        case .numberSequence: return "number"
        case .patternMatching: return "square.grid.3x3.fill"
        case .colorPattern: return "square.fill"
        case .tapPattern: return "hand.tap.fill"
        case .spatialPuzzle: return "cube.fill"
        case .reactionInhibition: return "hand.raised.fill"
        case .impulseSpikeTest: return "waveform.path.ecg"
        case .rhythmTap: return "music.note"
        case .delayUnlock: return "lock.fill"
        case .resetChallenge: return "arrow.counterclockwise"
        case .boxBreathing: return "wind"
        case .controlledBreathing: return "lungs.fill"
        case .breathPacing: return "timer"
        case .slowBreathing: return "leaf.fill"
        case .bodyScan: return "figure.roll"
        case .fiveSenses: return "sensor.tag.radiowaves.forward"
        case .urgeSurfing: return "water.waves"
        case .calmVisual: return "sparkles"
        case .breathingBasics: return "wind"
        case .calmFocus: return "leaf.fill"
        case .stressRelief: return "water.drop.fill"
        case .energyBoost: return "bolt.fill"
        case .deepBreath: return "lungs.fill"
        case .breathingAdvanced: return "wind.circle.fill"
        case .focusEndurance: return "hourglass"
        case .meditationMaster: return "brain.head.profile"
        case .antiScrollSwipe: return "hand.swipe.left"
        case .appSwitchResistance: return "app.badge"
        case .fakeNotifications: return "bell.badge.fill"
        case .fingerHold: return "hand.point.up.fill"
        case .fingerTracing: return "hand.draw.fill"
        case .impulseDelay: return "clock.fill"
        case .distractionLog: return "list.bullet.clipboard"
        case .lookAway: return "eye.slash.fill"
        case .multiTaskTap: return "hand.tap.fill"
        case .notificationResistance: return "bell.slash.fill"
        case .popupIgnore: return "xmark.square.fill"
        case .tapOnlyCorrect: return "checkmark.circle.fill"
        case .wordPuzzle: return "textformat.abc"
        case .logicPuzzle: return "brain"
        }
    }
    
    var color: Color {
        switch category {
        case .focus: return .purple
        case .memory: return .blue
        case .reaction: return .orange
        case .breathing: return .green
        case .discipline: return .red
        case .speed: return .yellow
        case .impulse: return .pink
        case .calm: return .teal
        }
    }
    
    var description: String {
        switch self {
        case .movingTarget: return "Track and tap the moving target"
        case .multiObjectTracking: return "Follow multiple objects simultaneously"
        case .gazeHold: return "Maintain focus on a single point"
        case .focusHold: return "Hold your focus steady"
        case .focusSprint: return "Complete a focus task quickly"
        case .stillnessTest: return "Stay completely still"
        case .slowTracking: return "Track slowly moving objects"
        case .memoryFlash: return "Remember flashing patterns"
        case .memoryPuzzle: return "Solve memory puzzles"
        case .numberSequence: return "Remember number sequences"
        case .patternMatching: return "Match the patterns"
        case .colorPattern: return "Remember and repeat color sequences"
        case .tapPattern: return "Recreate the tap pattern"
        case .spatialPuzzle: return "Solve spatial puzzles"
        case .reactionInhibition: return "Practice impulse control"
        case .impulseSpikeTest: return "Test your impulse responses"
        case .rhythmTap: return "Follow the rhythm"
        case .delayUnlock: return "Wait before unlocking"
        case .resetChallenge: return "Reset and start fresh"
        case .boxBreathing: return "Practice 4-4-4-4 breathing"
        case .controlledBreathing: return "Controlled breathing exercise"
        case .breathPacing: return "Match the breath pace"
        case .slowBreathing: return "Deep slow breathing"
        case .bodyScan: return "Mindful body scan"
        case .fiveSenses: return "Ground with 5 senses"
        case .urgeSurfing: return "Ride the urge waves"
        case .calmVisual: return "Calming visual meditation"
        case .breathingBasics: return "Learn the basics of breathing"
        case .calmFocus: return "Calm your mind and focus"
        case .stressRelief: return "Release tension and stress"
        case .energyBoost: return "Boost your energy with breath"
        case .deepBreath: return "Deep breathing exercise"
        case .breathingAdvanced: return "Advanced breathing techniques"
        case .focusEndurance: return "Build focus stamina"
        case .meditationMaster: return "Master meditation practices"
        case .antiScrollSwipe: return "Resist scrolling"
        case .appSwitchResistance: return "Don't switch apps"
        case .fakeNotifications: return "Ignore fake notifications"
        case .fingerHold: return "Hold your finger steady"
        case .fingerTracing: return "Trace patterns carefully"
        case .impulseDelay: return "Delay your impulses"
        case .distractionLog: return "Log distractions mindfully"
        case .lookAway: return "Look away mindfully"
        case .multiTaskTap: return "Handle multiple tasks"
        case .notificationResistance: return "Ignore notifications"
        case .popupIgnore: return "Close popups without tapping"
        case .tapOnlyCorrect: return "Only tap correct targets"
        case .wordPuzzle: return "Solve word puzzles"
        case .logicPuzzle: return "Complete logic puzzles"
        }
    }
    
    var duration: Int {
        switch self {
        case .movingTarget, .gazeHold, .focusHold: return 30
        case .multiObjectTracking, .focusSprint: return 45
        case .stillnessTest, .slowTracking: return 60
        case .memoryFlash, .memoryPuzzle: return 60
        case .numberSequence: return 45
        case .patternMatching, .colorPattern, .tapPattern: return 90
        case .spatialPuzzle: return 120
        case .reactionInhibition: return 30
        case .impulseSpikeTest: return 45
        case .rhythmTap: return 60
        case .delayUnlock: return 30
        case .resetChallenge: return 45
        case .boxBreathing, .controlledBreathing: return 120
        case .breathPacing, .slowBreathing: return 90
        case .bodyScan: return 180
        case .fiveSenses: return 60
        case .urgeSurfing: return 120
        case .calmVisual: return 90
        case .breathingBasics: return 60
        case .calmFocus: return 90
        case .stressRelief: return 120
        case .energyBoost: return 60
        case .deepBreath: return 90
        case .breathingAdvanced: return 150
        case .focusEndurance: return 120
        case .meditationMaster: return 180
        case .antiScrollSwipe: return 30
        case .appSwitchResistance: return 60
        case .fakeNotifications: return 45
        case .fingerHold: return 30
        case .fingerTracing: return 60
        case .impulseDelay: return 45
        case .distractionLog: return 60
        case .lookAway: return 30
        case .multiTaskTap: return 45
        case .notificationResistance: return 60
        case .popupIgnore: return 45
        case .tapOnlyCorrect: return 60
        case .wordPuzzle: return 120
        case .logicPuzzle: return 180
        }
    }
    
    var xpReward: Int {
        switch self {
        case .movingTarget, .gazeHold, .focusHold: return 15
        case .multiObjectTracking, .focusSprint: return 20
        case .stillnessTest, .slowTracking: return 25
        case .memoryFlash, .memoryPuzzle: return 20
        case .numberSequence: return 15
        case .patternMatching, .colorPattern, .tapPattern: return 25
        case .spatialPuzzle: return 30
        case .reactionInhibition: return 20
        case .impulseSpikeTest: return 25
        case .rhythmTap: return 15
        case .delayUnlock: return 10
        case .resetChallenge: return 15
        case .boxBreathing, .controlledBreathing: return 20
        case .breathPacing, .slowBreathing: return 15
        case .bodyScan: return 30
        case .fiveSenses: return 15
        case .urgeSurfing: return 25
        case .calmVisual: return 20
        case .breathingBasics: return 10
        case .calmFocus: return 15
        case .stressRelief: return 20
        case .energyBoost: return 15
        case .deepBreath: return 20
        case .breathingAdvanced: return 25
        case .focusEndurance: return 25
        case .meditationMaster: return 30
        case .antiScrollSwipe: return 15
        case .appSwitchResistance: return 20
        case .fakeNotifications: return 25
        case .fingerHold: return 10
        case .fingerTracing: return 20
        case .impulseDelay: return 15
        case .distractionLog: return 20
        case .lookAway: return 10
        case .multiTaskTap: return 25
        case .notificationResistance: return 20
        case .popupIgnore: return 15
        case .tapOnlyCorrect: return 25
        case .wordPuzzle: return 30
        case .logicPuzzle: return 35
        }
    }
}

enum ChallengeCategory: String, CaseIterable {
    case focus = "Focus"
    case memory = "Memory"
    case reaction = "Reaction"
    case breathing = "Breathing"
    case discipline = "Discipline"
    case speed = "Speed"
    case impulse = "Impulse"
    case calm = "Calm"
    
    var icon: String {
        switch self {
        case .focus: return "eye.fill"
        case .memory: return "brain.head.profile"
        case .reaction: return "bolt.fill"
        case .breathing: return "wind"
        case .discipline: return "hand.raised.fill"
        case .speed: return "hare.fill"
        case .impulse: return "waveform.path.ecg"
        case .calm: return "leaf.fill"
        }
    }
    
    var categoryColor: Color {
        switch self {
        case .focus: return .purple
        case .memory: return .blue
        case .reaction: return .orange
        case .breathing: return .green
        case .discipline: return .red
        case .speed: return .yellow
        case .impulse: return .pink
        case .calm: return .teal
        }
    }
}

// MARK: - Daily Challenges

extension AllChallengeType {
    /// Returns daily challenges based on the current date
    /// Each day gets 3 different challenges (one from each category)
    static func dailyChallenges() -> [AllChallengeType] {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        // Rotate through challenges based on day
        let focusChallenges: [AllChallengeType] = [.movingTarget, .multiObjectTracking, .gazeHold, .focusSprint, .focusHold]
        let memoryChallenges: [AllChallengeType] = [.memoryFlash, .numberSequence, .patternMatching, .colorPattern, .tapPattern, .spatialPuzzle]
        let reactionChallenges: [AllChallengeType] = [.reactionInhibition, .rhythmTap, .delayUnlock, .resetChallenge, .impulseSpikeTest]
        
        let focusIdx = (dayOfYear - 1) % focusChallenges.count
        let memoryIdx = (dayOfYear - 1) % memoryChallenges.count
        let reactionIdx = (dayOfYear - 1) % reactionChallenges.count
        
        return [
            focusChallenges[focusIdx],
            memoryChallenges[memoryIdx],
            reactionChallenges[reactionIdx]
        ]
    }
    
    /// Check if today's daily challenges are completed
    static func isDailyChallenge(_ challenge: AllChallengeType) -> Bool {
        let today = dailyChallenges()
        return today.contains(challenge)
    }
}

// MARK: - Additional Challenge Types

