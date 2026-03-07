import SwiftUI

// MARK: - All Challenge Types (25 fully interactive challenges)
enum AllChallengeType: String, CaseIterable, Identifiable, Codable {
    // Focus & Attention (5)
    case targetHunt      = "Target Hunt"
    case numberRush      = "Number Rush"
    case laserLock       = "Laser Lock"
    case peripheralScan  = "Peripheral Scan"
    case dualTask        = "Dual Task"

    // Memory (5)
    case numberVault     = "Number Vault"
    case gridRecall      = "Grid Recall"
    case colorChain      = "Color Chain"
    case sequenceEcho    = "Sequence Echo"
    case mathBlitz       = "Math Blitz"

    // Reaction (5)
    case goNoGo          = "Go / No-Go"
    case timingGate      = "Timing Gate"
    case flashMatch      = "Flash Match"
    case reflexTap       = "Reflex Tap"
    case colorSurge      = "Color Surge"

    // Breathing & Calm (5)
    case breathBalloon   = "Breath Balloon"
    case boxMaster       = "Box Master"
    case relaxRelease    = "Relax & Release"
    case fourSevenEight  = "4-7-8 Master"
    case rhythmBreath    = "Rhythm Breath"

    // Discipline & Resistance (5)
    case notificationWall = "Notification Wall"
    case greenLightOnly   = "Green Light Only"
    case impulseFortress  = "Impulse Fortress"
    case tapDelay         = "Tap Delay"
    case silentCounter    = "Silent Counter"

    var id: String { rawValue }

    // MARK: - Category
    var category: ChallengeCategory {
        switch self {
        case .targetHunt, .numberRush, .laserLock, .peripheralScan, .dualTask:
            return .focus
        case .numberVault, .gridRecall, .colorChain, .sequenceEcho, .mathBlitz:
            return .memory
        case .goNoGo, .timingGate, .flashMatch, .reflexTap, .colorSurge:
            return .reaction
        case .breathBalloon, .boxMaster, .relaxRelease, .fourSevenEight, .rhythmBreath:
            return .breathing
        case .notificationWall, .greenLightOnly, .impulseFortress, .tapDelay, .silentCounter:
            return .discipline
        }
    }

    // MARK: - Icon
    var icon: String {
        switch self {
        case .targetHunt:       return "scope"
        case .numberRush:       return "number.circle.fill"
        case .laserLock:        return "laser.burst"
        case .peripheralScan:   return "eye.circle.fill"
        case .dualTask:         return "rectangle.split.2x1.fill"
        case .numberVault:      return "lock.fill"
        case .gridRecall:       return "square.grid.3x3.fill"
        case .colorChain:       return "circle.hexagongrid.fill"
        case .sequenceEcho:     return "waveform.circle.fill"
        case .mathBlitz:        return "function"
        case .goNoGo:           return "hand.raised.circle.fill"
        case .timingGate:       return "gauge.with.needle.fill"
        case .flashMatch:       return "bolt.horizontal.fill"
        case .reflexTap:        return "hand.tap.fill"
        case .colorSurge:       return "paintpalette.fill"
        case .breathBalloon:    return "balloon.fill"
        case .boxMaster:        return "square.dashed"
        case .relaxRelease:     return "wind"
        case .fourSevenEight:   return "lungs.fill"
        case .rhythmBreath:     return "waveform.path.ecg"
        case .notificationWall: return "bell.slash.fill"
        case .greenLightOnly:   return "circle.fill"
        case .impulseFortress:  return "shield.fill"
        case .tapDelay:         return "clock.badge.checkmark.fill"
        case .silentCounter:    return "minus.circle.fill"
        }
    }

    // MARK: - Color
    var color: Color {
        switch category {
        case .focus:      return .purple
        case .memory:     return .blue
        case .reaction:   return .orange
        case .breathing:  return .green
        case .discipline: return .red
        }
    }

    // MARK: - Description
    var description: String {
        switch self {
        case .targetHunt:
            return "Shapes swarm the screen—only tap the target shape. Combo hits stack your multiplier. 3 lives."
        case .numberRush:
            return "Numbers scatter randomly. Tap 1, 2, 3… in order as fast as you can. Time bonus per digit."
        case .laserLock:
            return "A needle sweeps back and forth. Tap when it hits the glowing target zone—precision wins."
        case .peripheralScan:
            return "Shapes flash around the screen. The target shape is shown in the center. Tap target shapes quickly—ignore the distractors."
        case .dualTask:
            return "Two tasks run at once: track a moving target on top AND tap the correct number on the bottom. Split your focus without cracking."
        case .numberVault:
            return "A number sequence flashes briefly. Enter it exactly on the numpad. 3 lives. Sequences grow."
        case .gridRecall:
            return "Watch which grid cells light up, then recreate the pattern from memory. More cells each round."
        case .colorChain:
            return "Watch the color sequence flash. Repeat it exactly. Each round adds one more step. 3 lives."
        case .sequenceEcho:
            return "Watch the colored pads light up in a sequence. Then repeat it exactly. Each round adds one more step. 3 lives."
        case .mathBlitz:
            return "A math equation flashes for 1.5 seconds. Pick the correct answer from 4 choices. Wrong answers cost lives. Equations get harder as your streak grows."
        case .goNoGo:
            return "Green circle: tap it fast. Red circle: hold back. False taps cost you. Speed ramps up."
        case .timingGate:
            return "Tap the moving needle precisely as it enters the target zone. The zone shrinks as you level up."
        case .flashMatch:
            return "Two symbols flash in quick succession. Tap if they match. Wait if they differ. Accuracy + speed."
        case .reflexTap:
            return "A glowing target blinks onto the screen. Tap it before it vanishes. Speed earns bonus points. Miss 3 and you're out."
        case .colorSurge:
            return "A wave of color floods the screen. Tap only when the target color fills the screen. Every hesitation costs points—every wrong tap costs a life."
        case .breathBalloon:
            return "Hold to inflate on inhale. Release to deflate on exhale. Sync your breath with the balloon."
        case .boxMaster:
            return "A dot traces a square: inhale → hold → exhale → hold. Tap each corner to confirm your breath."
        case .relaxRelease:
            return "Follow the 4-7-8 pattern: breathe in 4, hold 7, out 8. Tap each phase to confirm. 3 full cycles."
        case .fourSevenEight:
            return "Inhale for 4 seconds, hold for 7, exhale for 8. Follow the ring and confirm each phase. 3 complete cycles to finish."
        case .rhythmBreath:
            return "A pulsing wave sets your breathing rhythm. Match your inhale and exhale to the wave peaks. Stay in sync for 5 full cycles to complete."
        case .notificationWall:
            return "Fake banners flood the screen. Tap ✕ to dismiss each. Real green targets appear—tap those too."
        case .greenLightOnly:
            return "Tap every green circle that appears. Red circles appear where green ones just were—don't be fooled."
        case .impulseFortress:
            return "The giant pulsing button WILL trick you. Tap the small safe buttons around it. Never the big one."
        case .tapDelay:
            return "A target appears and a bar fills slowly. Wait until it's fully green, then tap as fast as possible. Tapping early costs you a life."
        case .silentCounter:
            return "A hidden counter ticks up randomly in your mind—you can't see it. When you think it hits 10, press STOP. The closer you are, the more points you earn. No peeking, no cheating your own brain."
        }
    }

    // MARK: - Duration (seconds)
    var duration: Int {
        switch self {
        case .targetHunt:       return 60
        case .numberRush:       return 60
        case .laserLock:        return 45
        case .peripheralScan:   return 60
        case .dualTask:         return 60
        case .numberVault:      return 90
        case .gridRecall:       return 90
        case .colorChain:       return 90
        case .sequenceEcho:     return 90
        case .mathBlitz:        return 60
        case .goNoGo:           return 45
        case .timingGate:       return 45
        case .flashMatch:       return 45
        case .reflexTap:        return 45
        case .colorSurge:       return 50
        case .breathBalloon:    return 90
        case .boxMaster:        return 64
        case .relaxRelease:     return 57
        case .fourSevenEight:   return 76
        case .rhythmBreath:     return 80
        case .notificationWall: return 60
        case .greenLightOnly:   return 60
        case .impulseFortress:  return 60
        case .tapDelay:         return 60
        case .silentCounter:    return 60
        }
    }

    // MARK: - XP Reward
    var xpReward: Int {
        switch self {
        case .targetHunt:       return 25
        case .numberRush:       return 25
        case .laserLock:        return 30
        case .peripheralScan:   return 30
        case .dualTask:         return 40
        case .numberVault:      return 30
        case .gridRecall:       return 30
        case .colorChain:       return 25
        case .sequenceEcho:     return 35
        case .mathBlitz:        return 35
        case .goNoGo:           return 25
        case .timingGate:       return 30
        case .flashMatch:       return 25
        case .reflexTap:        return 25
        case .colorSurge:       return 30
        case .breathBalloon:    return 20
        case .boxMaster:        return 25
        case .relaxRelease:     return 25
        case .fourSevenEight:   return 25
        case .rhythmBreath:     return 30
        case .notificationWall: return 30
        case .greenLightOnly:   return 25
        case .impulseFortress:  return 35
        case .tapDelay:         return 30
        case .silentCounter:    return 40
        }
    }

    // MARK: - Gem Reward
    var gemReward: Int {
        switch self {
        case .dualTask, .silentCounter, .mathBlitz:   return 8
        case .impulseFortress, .sequenceEcho:          return 7
        case .laserLock, .gridRecall, .numberVault,
             .timingGate, .tapDelay, .peripheralScan,
             .colorSurge, .rhythmBreath:               return 6
        default:                                       return 5
        }
    }
}

// MARK: - Category
enum ChallengeCategory: String, CaseIterable {
    case focus      = "Focus"
    case memory     = "Memory"
    case reaction   = "Reaction"
    case breathing  = "Breathing"
    case discipline = "Discipline"

    var icon: String {
        switch self {
        case .focus:      return "eye.fill"
        case .memory:     return "brain.head.profile"
        case .reaction:   return "bolt.fill"
        case .breathing:  return "wind"
        case .discipline: return "hand.raised.fill"
        }
    }
}

// MARK: - Daily Challenges
extension AllChallengeType {
    static func dailyChallenges() -> [AllChallengeType] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let focus:     [AllChallengeType] = [.targetHunt, .numberRush, .laserLock, .peripheralScan, .dualTask]
        let memory:    [AllChallengeType] = [.numberVault, .gridRecall, .colorChain, .sequenceEcho, .mathBlitz]
        let reaction:  [AllChallengeType] = [.goNoGo, .timingGate, .flashMatch, .reflexTap, .colorSurge]
        return [
            focus[(dayOfYear - 1) % focus.count],
            memory[(dayOfYear - 1) % memory.count],
            reaction[(dayOfYear - 1) % reaction.count],
        ]
    }

    static func isDailyChallenge(_ challenge: AllChallengeType) -> Bool {
        dailyChallenges().contains(challenge)
    }
}
