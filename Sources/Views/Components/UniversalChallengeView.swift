import SwiftUI
import AVFoundation
import UIKit

// MARK: - Breath Phase Enum
enum BreathPhase: String {
    case inhale = "Breathe In"
    case hold = "Hold"
    case exhale = "Breathe Out"
}

// MARK: - Haptic Manager
class HapticManager {
    static let shared = HapticManager()
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    func prepare() {
        light.prepare()
        medium.prepare()
        heavy.prepare()
        selection.prepare()
        notification.prepare()
    }

    func lightTap() { light.impactOccurred() }
    func mediumTap() { medium.impactOccurred() }
    func heavyTap() { heavy.impactOccurred() }
    func selectionChanged() { selection.selectionChanged() }
    func success() { notification.notificationOccurred(.success) }
    func warning() { notification.notificationOccurred(.warning) }
    func error() { notification.notificationOccurred(.error) }
}

// MARK: - Sound Manager
class SoundManager {
    static let shared = SoundManager()
    var isEnabled: Bool = true

    func playTap() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    func playSuccess() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1025)
    }

    func playFail() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1053)
    }

    func playLevelUp() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1026)
    }
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

struct UniversalChallengeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let challenge: AllChallengeType

    @State private var score: Int = 0
    @State private var isActive: Bool = false
    @State private var timeRemaining: Double = 0
    @State private var showResults: Bool = false
    @State private var challengeTime: Int = 0

    @State private var targetPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var level: Int = 1
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathProgress: Double = 0
    @State private var guidedAudioEnabled: Bool = true
    @State private var gameState: ReactionState = .waiting
    @State private var startTimeReact: Date = Date()
    @State private var reactionTime: Double = 0
    @State private var personalBestTime: Double = 0
    @State private var reactionTimes: [Double] = []
    @State private var averageReactionTime: Double = 0
    @State private var cycleCount: Int = 0
    @State private var temptationLevel: Double = 0
    @State private var combo: Int = 0
    @State private var maxCombo: Int = 0
    @State private var totalTaps: Int = 0
    @State private var targetScale: CGFloat = 1.0
    @State private var lastTapPosition: CGPoint = .zero
    @State private var showRipple: Bool = false
    @State private var difficulty: Double = 0.0  // Increases with score for harder challenges

    enum ReactionState {
        case waiting, ready, go, tooEarly
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if showResults {
                resultsView
            } else if isActive {
                activeChallengeView
            } else {
                previewView
            }
        }
    }

    // MARK: - Preview
    var previewView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(challenge.color.opacity(0.3))
                    .frame(width: 120, height: 120)
                Image(systemName: challenge.icon)
                    .font(.system(size: 50))
                    .foregroundColor(challenge.color)
            }

            Text(challenge.rawValue)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text(challenge.description)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 32) {
                VStack {
                    Text("\(challenge.duration)s")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("Duration")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                VStack {
                    Text("\(challenge.xpReward)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("XP")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button(action: { startChallenge() }) {
                Text("Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(challenge.color)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Active Challenge
    var activeChallengeView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { endChallenge() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                    Text("\(Int(timeRemaining))s")
                }
                .foregroundColor(timeRemaining < 10 ? .red : .white)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                    Text("\(score)")
                }
                .foregroundColor(.yellow)
                .frame(width: 44)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            challengeContent.padding(.horizontal, 24)
            Spacer()
        }
    }

    // MARK: - Save and Dismiss
    func saveAndDismiss() {
        // Calculate rewards
        let gemsEarned = max(1, score / 10)
        let xpEarned = challenge.xpReward

        // Save progress to AppState (which handles cloud sync)
        appState.completeChallenge(type: challenge, score: score, xpEarned: xpEarned)

        // Dismiss the challenge view
        dismiss()
    }

    // MARK: - Results
    var resultsView: some View {
        let gemsEarned = max(1, score / 10)

        return VStack(spacing: 24) {
            Spacer()

            Image(systemName: score >= 50 ? "star.fill" : "arrow.clockwise")
                .font(.system(size: 60))
                .foregroundColor(score >= 50 ? .yellow : .gray)

            Text("Challenge Complete!")
                .font(.title)
                .foregroundColor(.white)

            Text("Score: \(score)")
                .font(.title2)
                .foregroundColor(.yellow)

            HStack(spacing: 24) {
                VStack {
                    Text("+\(challenge.xpReward)")
                        .font(.headline)
                        .foregroundColor(.green)
                    Text("XP")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                VStack {
                    Text("+\(gemsEarned)")
                        .font(.headline)
                        .foregroundColor(.purple)
                    Text("Gems")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Gem animation indicator
            if score >= 50 {
                HStack(spacing: 4) {
                    Image(systemName: "gem.fill")
                        .foregroundColor(.purple)
                    Text("+\(gemsEarned + 2) Bonus!")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.purple.opacity(0.2)))
            }

            Button(action: saveAndDismiss) {
                Text("Continue")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }

            Spacer()
        }
    }

    // MARK: - Challenge Content
    @ViewBuilder
    var challengeContent: some View {
        switch challenge.category {
        case .focus:
            focusContent
        case .memory:
            memoryContent
        case .reaction:
            reactionContent
        case .breathing:
            breathingContent
        case .discipline:
            disciplineContent
        case .speed:
            focusContent
        case .impulse:
            disciplineContent
        case .calm:
            breathingContent
            disciplineContent
        }
    }

    // MARK: - Focus
    var focusContent: some View {
        GeometryReader { geo in
            ZStack {
                // Grid
                ForEach(0..<4, id: \.self) { row in
                    ForEach(0..<3, id: \.self) { col in
                        Rectangle()
                            .fill(Color.white.opacity(0.02))
                            .frame(width: geo.size.width / 3, height: geo.size.width / 3)
                            .position(
                                x: geo.size.width / 6 + CGFloat(col) * geo.size.width / 3,
                                y: geo.size.width / 6 + CGFloat(row) * geo.size.width / 3
                            )
                    }
                }

                // Combo
                if combo > 1 {
                    VStack {
                        Text("\(combo)x COMBO!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("+\(15 * min(combo, 10))")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    }
                    .position(x: geo.size.width / 2, y: 50)
                }

                // Ripple
                if showRipple {
                    Circle()
                        .stroke(challenge.color.opacity(0.5), lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .position(lastTapPosition)
                }

                // Target - gets smaller as difficulty increases
                ZStack {
                    Circle()
                        .fill(challenge.color.opacity(0.2))
                        .frame(width: (70 + sin(Date().timeIntervalSinceReferenceDate * 3) * 10) * targetScale, height: (70 + sin(Date().timeIntervalSinceReferenceDate * 3) * 10) * targetScale)
                        .position(targetPosition)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white, challenge.color],
                                center: .center,
                                startRadius: 0,
                                endRadius: 25
                            )
                        )
                        .frame(width: 50 * targetScale, height: 50 * targetScale)
                        .scaleEffect(targetScale)
                        .position(targetPosition)
                        .onTapGesture {
                            handleFocusTap(in: geo.size)
                        }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    targetScale = 1.15
                }
            }
        }
    }

    func handleFocusTap(in size: CGSize) {
        totalTaps += 1
        lastTapPosition = targetPosition
        showRipple = true
        combo += 1
        maxCombo = max(maxCombo, combo)

        // Update difficulty based on time and score
        let timeDifficulty = Double(challenge.duration - Int(timeRemaining)) / Double(challenge.duration)
        let scoreDifficulty = min(Double(score) / 500.0, 1.0)  // Max difficulty at 500 points
        difficulty = (timeDifficulty + scoreDifficulty) / 2

        score += 15 * min(combo, 10) + Int(difficulty * 10)

        // Decrease target size as difficulty increases (harder)
        targetScale = max(0.6, 1.0 - difficulty * 0.4)

        // Haptics and Sound
        if combo > 5 {
            HapticManager.shared.success()
            SoundManager.shared.playSuccess()
        } else {
            HapticManager.shared.lightTap()
            SoundManager.shared.playTap()
        }

        // Milestone sounds
        if combo == 10 || combo == 25 || combo == 50 {
            HapticManager.shared.success()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showRipple = false
        }

        // Speed increases with difficulty
        let animDuration = max(0.15, 0.5 - difficulty * 0.35)
        withAnimation(.easeInOut(duration: animDuration)) {
            targetPosition = CGPoint(
                x: CGFloat.random(in: 0.1...0.9) * size.width,
                y: CGFloat.random(in: 0.1...0.7) * size.height
            )
        }
    }

    // MARK: - Memory
    var memoryContent: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(level)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    HStack(spacing: 4) {
                        ForEach(0..<min(level + 1, 6), id: \.self) { i in
                            Circle()
                                .fill(i < level - 1 ? challenge.color : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("points")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Text("Memorize!")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(challenge.color)
                .padding(.vertical, 8)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(0..<9, id: \.self) { index in
                    Button(action: { handleMemoryTap(index) }) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(index < level && index % 2 == 0 ? challenge.color : Color.white.opacity(0.1))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal)

            HStack {
                Text("Combo: \(combo)x")
                    .foregroundColor(.orange)
                Spacer()
                Text("Score: \(score)")
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal)
        }
        .onAppear {
            level = 1
            score = 0
            combo = 0
        }
    }

    func handleMemoryTap(_ index: Int) {
        if index % 2 == 0 && index < level * 2 {
            combo += 1
            score += 10 * min(combo, 5)
            HapticManager.shared.lightTap()
            SoundManager.shared.playTap()
        } else {
            combo = 0
            score = max(0, score - 5)
            HapticManager.shared.error()
            SoundManager.shared.playFail()
        }

        if score > level * 30 {
            level += 1
            combo = 0
            HapticManager.shared.success()
            SoundManager.shared.playLevelUp()
        }
    }

    // MARK: - Reaction
    var reactionContent: some View {
        VStack(spacing: 24) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Reaction")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text(reactionInstructionText)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("score")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(reactionCircleColor.opacity(0.1))
                    .frame(width: 250, height: 250)

                Circle()
                    .stroke(reactionCircleColor.opacity(0.3), lineWidth: 2)
                    .frame(width: 220, height: 220)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [reactionCircleColor, reactionCircleColor.opacity(0.5)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 180, height: 180)

                VStack(spacing: 8) {
                    Text(reactionCircleText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    if gameState == .go {
                        Text("TAP NOW!")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .onTapGesture {
                handleReactionTap()
            }

            if reactionTime > 0 {
                VStack {
                    Text("\(Int(reactionTime * 1000))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(reactionTimeColor)
                    Text("milliseconds")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(reactionTimeRating)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(reactionTimeColor)
                    
                    // Personal Best & Average
                    if personalBestTime > 0 || averageReactionTime > 0 {
                        HStack(spacing: 24) {
                            if personalBestTime > 0 {
                                VStack {
                                    Text("\(Int(personalBestTime * 1000))")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.yellow)
                                    Text("Best")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                            if averageReactionTime > 0 && reactionTimes.count > 1 {
                                VStack {
                                    Text("\(Int(averageReactionTime * 1000))")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.blue)
                                    Text("Avg")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
                .background(Capsule().fill(reactionTimeColor.opacity(0.1)))
            }

            Spacer()
        }
        .padding()
    }

    var reactionInstructionText: String {
        switch gameState {
        case .waiting: return "Wait..."
        case .ready: return "Ready..."
        case .go: return "TAP!"
        case .tooEarly: return "Too early!"
        }
    }

    var reactionCircleColor: Color {
        switch gameState {
        case .waiting, .ready: return .red
        case .go: return .green
        case .tooEarly: return .orange
        }
    }

    var reactionCircleText: String {
        switch gameState {
        case .waiting, .ready: return "Wait..."
        case .go: return "TAP!"
        case .tooEarly: return "Early!"
        }
    }

    var reactionTimeColor: Color {
        if reactionTime < 0.15 { return .green }
        if reactionTime < 0.25 { return .yellow }
        if reactionTime < 0.35 { return .orange }
        return .red
    }

    var reactionTimeRating: String {
        if reactionTime < 0.15 { return "⚡️ Lightning!" }
        if reactionTime < 0.25 { return "🔥 Great!" }
        if reactionTime < 0.35 { return "💪 Good" }
        return "🎯 Practice"
    }

    func handleReactionTap() {
        if gameState == .waiting || gameState == .ready {
            gameState = .tooEarly
            HapticManager.shared.warning()
            SoundManager.shared.playFail()
            return
        }

        if gameState == .go {
            reactionTime = Date().timeIntervalSince(startTimeReact)
            score = max(0, Int((0.3 - reactionTime) * 1000))
            
            // Track personal best
            if personalBestTime == 0 || reactionTime < personalBestTime {
                personalBestTime = reactionTime
            }
            
            // Track reaction times for average
            reactionTimes.append(reactionTime)
            averageReactionTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)

            if reactionTime < 0.15 {
                HapticManager.shared.success()
                SoundManager.shared.playLevelUp()
            } else if reactionTime < 0.25 {
                HapticManager.shared.mediumTap()
                SoundManager.shared.playSuccess()
            } else {
                HapticManager.shared.lightTap()
                SoundManager.shared.playTap()
            }

            gameState = .waiting
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...3)) {
                startReaction()
            }
        }
    }

    func startReaction() {
        guard isActive else { return }
        gameState = .ready
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...3)) {
            gameState = .go
            startTimeReact = Date()
        }
    }

    // MARK: - Breathing
    var breathingContent: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Cycle \(cycleCount + 1)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(cycleCount) done")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                    Text("calm")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    .frame(width: 250, height: 250)

                Circle()
                    .trim(from: 0, to: breathProgress)
                    .stroke(breathGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [breathColor, breathColor.opacity(0.3)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 100 + breathProgress * 100, height: 100 + breathProgress * 100)

                VStack(spacing: 8) {
                    Image(systemName: breathIcon)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text(breathPhase.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            Text(breathText)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))

            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("Breathe naturally")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    guidedAudioEnabled.toggle()
                    BreathingGuide.shared.isEnabled = guidedAudioEnabled
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: guidedAudioEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 12))
                        Text(guidedAudioEnabled ? "Voice On" : "Voice Off")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(guidedAudioEnabled ? .green : .gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(guidedAudioEnabled ? Color.green.opacity(0.2) : Color.gray.opacity(0.2)))
                }
            }
        }
        .padding()
    }

    var breathColor: Color {
        switch breathPhase {
        case .inhale: return .purple
        case .hold: return .blue
        case .exhale: return .green
        }
    }

    var breathGradient: LinearGradient {
        switch breathPhase {
        case .inhale:
            return LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .hold:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .exhale:
            return LinearGradient(colors: [.cyan, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var breathIcon: String {
        switch breathPhase {
        case .inhale: return "arrow.up"
        case .hold: return "pause.circle"
        case .exhale: return "arrow.down"
        }
    }

    var breathText: String {
        switch breathPhase {
        case .inhale: return "Breathe in slowly"
        case .hold: return "Hold gently"
        case .exhale: return "Release slowly"
        }
    }

    // MARK: - Discipline
    var disciplineContent: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Stay Focused")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(combo) resisted")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("discipline")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.purple)
                    Text("Temptation")
                        .font(.system(size: 14))
                    Spacer()
                    Text("\(Int(temptationLevel * 100))%")
                        .foregroundColor(temptColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [.green, .yellow, .orange, .red], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * temptationLevel, height: 12)
                    }
                }
                .frame(height: 12)

                Text(encouragementText)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal)

            Spacer()

            ZStack {
                Circle()
                    .fill(temptColor.opacity(0.2))
                    .frame(width: 180, height: 180)
                Circle()
                    .stroke(temptColor, lineWidth: 3)
                    .frame(width: 160, height: 160)
                VStack(spacing: 12) {
                    Image(systemName: temptIcon)
                        .font(.system(size: 50))
                        .foregroundColor(temptColor)
                    Text("Don't tap!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            HStack(spacing: 32) {
                VStack {
                    Text("\(combo)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green)
                    Text("Resisted")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                VStack {
                    Text("\(score)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("Score")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }

    var temptColor: Color {
        if temptationLevel < 0.3 { return .green }
        if temptationLevel < 0.6 { return .yellow }
        if temptationLevel < 0.8 { return .orange }
        return .red
    }

    var temptIcon: String {
        let icons = ["bell.badge.fill", "app.badge", "hand.tap.fill", "bubble.left.fill", "exclamationmark.triangle.fill"]
        return icons[Int(timeRemaining) % icons.count]
    }

    var encouragementText: String {
        if temptationLevel < 0.3 { return "You're doing great!" }
        if temptationLevel < 0.6 { return "Keep resisting!" }
        if temptationLevel < 0.8 { return "Focus on breath!" }
        return "Almost there!"
    }

    // MARK: - Timer
    func startChallenge() {
        isActive = true
        timeRemaining = Double(challenge.duration)
        score = 0
        combo = 0
        level = 1
        cycleCount = 0
        temptationLevel = 0.3
        personalBestTime = 0
        reactionTimes = []
        averageReactionTime = 0

        HapticManager.shared.prepare()
        SoundManager.shared.playSuccess()  // Start sound

        // Start guided breathing audio if it's a breathing challenge
        if challenge.category == .breathing {
            BreathingGuide.shared.isEnabled = guidedAudioEnabled
            BreathingGuide.shared.startSession()
        }

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 0.1
                self.challengeTime = self.challenge.duration - Int(self.timeRemaining)

                let difficultyProgress = 1.0 - (self.timeRemaining / Double(self.challenge.duration))

                // Focus: time bonus
                if self.challenge.category == .focus && Int(self.timeRemaining * 10) % 5 == 0 {
                    self.score += Int(difficultyProgress * 2)
                }

                // Discipline: temptation grows
                if self.challenge.category == .discipline {
                    self.temptationLevel = min(1.0, 0.3 + difficultyProgress * 0.7)
                    if Int(self.timeRemaining * 10) % 10 == 0 {
                        self.score += 1
                    }
                }

                // Breathing: cycles
                if self.challenge.category == .breathing {
                    self.breathProgress = (self.breathProgress + 0.01).truncatingRemainder(dividingBy: 1.0)
                    if self.breathProgress < 0.33 {
                        self.breathPhase = .inhale
                        BreathingGuide.shared.announcePhase(.inhale, cycleCount: self.cycleCount)
                    } else if self.breathProgress < 0.66 {
                        self.breathPhase = .hold
                        BreathingGuide.shared.announcePhase(.hold, cycleCount: self.cycleCount)
                    } else {
                        self.breathPhase = .exhale
                        BreathingGuide.shared.announcePhase(.exhale, cycleCount: self.cycleCount)
                    }
                    if Int(self.breathProgress * 100) == 0 {
                        self.cycleCount += 1
                    }
                }

                // Reaction: starts
                if self.challenge.category == .reaction && self.gameState == .waiting {
                    self.startReaction()
                }

                // Memory: level up
                if self.challenge.category == .memory && self.score > self.level * 30 {
                    self.level += 1
                    HapticManager.shared.mediumTap()
                }
            } else {
                timer.invalidate()
                self.showResults = true

                // End guided breathing audio if it was a breathing challenge
                if self.challenge.category == .breathing {
                    BreathingGuide.shared.endSession()
                }

                if self.score > 50 {
                    HapticManager.shared.success()
                }
            }
        }
    }

    func endChallenge() {
        isActive = false
        showResults = true

        // Play completion sounds
        if score >= 50 {
            HapticManager.shared.success()
            SoundManager.shared.playLevelUp()
        } else if score > 0 {
            HapticManager.shared.lightTap()
            SoundManager.shared.playSuccess()
        } else {
            HapticManager.shared.error()
            SoundManager.shared.playFail()
        }
    }
}

#Preview {
    UniversalChallengeView(challenge: .movingTarget)
        .environmentObject(AppState())
}
