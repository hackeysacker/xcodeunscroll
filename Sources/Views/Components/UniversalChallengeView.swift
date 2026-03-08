import SwiftUI
import AVFoundation
import AudioToolbox

// MARK: - Haptic Manager
class HapticManager {
    static let shared = HapticManager()
    var isEnabled: Bool = true
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()
    func lightTap()  { guard isEnabled else { return }; light.impactOccurred() }
    func mediumTap() { guard isEnabled else { return }; medium.impactOccurred() }
    func heavyTap()  { guard isEnabled else { return }; heavy.impactOccurred() }
    func success()   { guard isEnabled else { return }; notification.notificationOccurred(.success) }
    func error()     { guard isEnabled else { return }; notification.notificationOccurred(.error) }
    func warning()   { guard isEnabled else { return }; notification.notificationOccurred(.warning) }
    func selectionChanged() { guard isEnabled else { return }; selection.selectionChanged() }
}

// MARK: - Sound Manager
class SoundManager {
    static let shared = SoundManager()
    var isEnabled: Bool = true
    func playTap()     { guard isEnabled else { return }; AudioServicesPlaySystemSound(1104) }
    func playSuccess() { guard isEnabled else { return }; AudioServicesPlaySystemSound(1025) }
    func playFail()    { guard isEnabled else { return }; AudioServicesPlaySystemSound(1053) }
    func playLevelUp() { guard isEnabled else { return }; AudioServicesPlaySystemSound(1026) }
}

// MARK: - Floating Gem Particle
struct FloatingGemParticle: View {
    let delay: Double
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1
    var body: some View {
        Image(systemName: "diamond.fill").foregroundColor(.cyan)
            .offset(offset).opacity(opacity)
            .onAppear {
                let angle = Double.random(in: 0...360) * .pi / 180
                withAnimation(.easeOut(duration: 1.5).delay(delay)) {
                    offset = CGSize(width: cos(angle)*120, height: sin(angle)*120 - 60)
                    opacity = 0
                }
            }
    }
}

// MARK: - Game Data Types

// Target Hunt
struct HuntShape: Identifiable {
    let id = UUID()
    var type: HuntShapeType
    var position: CGPoint
    var velocity: CGPoint
    var scale: CGFloat = 1.0
    var isWrong: Bool = false
}
enum HuntShapeType: CaseIterable {
    case circle, square, triangle, star, diamond
    var sfSymbol: String {
        switch self {
        case .circle:   return "circle.fill"
        case .square:   return "square.fill"
        case .triangle: return "triangle.fill"
        case .star:     return "star.fill"
        case .diamond:  return "diamond.fill"
        }
    }
    var color: Color {
        switch self {
        case .circle:   return .cyan
        case .square:   return .purple
        case .triangle: return .orange
        case .star:     return .yellow
        case .diamond:  return .pink
        }
    }
}

// Number Rush
struct RushNumber: Identifiable {
    let id = UUID()
    let value: Int
    var position: CGPoint
    var tapped: Bool = false
    var shake: Bool = false
}

// Grid Recall
enum RecallPhase { case showing, recalling, result }

// Color Chain
enum ChainPhase { case showing, inputting }

// Go/No-Go
struct GoCircle: Identifiable {
    let id = UUID()
    let isGo: Bool
    var position: CGPoint
    var opacity: Double = 1.0
    var scale: CGFloat = 0.1
    var tapped: Bool = false
}

// Flash Match
enum MatchPhase { case showingA, showingB, deciding, result }
struct MatchCard {
    let symbol: String
    let color: Color
    var matches: Bool = false
}

// Notification Wall
struct WallNotif: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let isReal: Bool
    var dismissed: Bool = false
    var offset: CGFloat = -120
}

// Green Light Only
struct GLCircle: Identifiable {
    let id = UUID()
    let isGreen: Bool
    var position: CGPoint
    var opacity: Double = 0
    var scale: CGFloat = 0.1
    var tapped: Bool = false
}

// Safe Button (Impulse Fortress)
struct SafeButton: Identifiable {
    let id = UUID()
    var position: CGPoint
    var visible: Bool = true
    var opacity: Double = 0
}

// Peripheral Scan
struct ScanItem: Identifiable {
    let id = UUID()
    var type: HuntShapeType
    var position: CGPoint
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
    var age: Double = 0
    var isTarget: Bool = false
}

// Sequence Echo
enum EchoPhase { case showing, inputting }

// Reflex Tap
struct ReflexTarget: Identifiable {
    let id = UUID()
    var position: CGPoint
    var opacity: Double = 0
    var scale: CGFloat = 0.3
    var age: Double = 0
}

// 4-7-8
enum FourSevenEightPhase: Int {
    case inhale = 0, hold = 1, exhale = 2
    var label: String {
        switch self { case .inhale: return "Breathe In"; case .hold: return "Hold"; case .exhale: return "Breathe Out" }
    }
    var duration: Double {
        switch self { case .inhale: return 4; case .hold: return 7; case .exhale: return 8 }
    }
    var color: Color {
        switch self { case .inhale: return .cyan; case .hold: return .yellow; case .exhale: return .green }
    }
}

// Tap Delay
enum DelayPhase { case waiting, ready, tapped }

// Math Blitz
enum MathBlitzPhase { case showing, choosing, feedback }

// Color Surge
enum ColorSurgePhase { case waiting, filling }

// Rhythm Breath
enum RhythmBreathPhase { case inhale, exhale }

// Silent Counter
enum SilentCounterPhase { case counting, revealed }

// Vault phase
enum VaultPhase { case showing, entering, correct, wrong }
enum BalloonPhase { case inhale, exhale }
enum BoxBreathPhase: Int { case inhale = 0, hold1 = 1, exhale = 2, hold2 = 3
    var label: String {
        switch self { case .inhale: return "Breathe In"; case .hold1: return "Hold";
                      case .exhale: return "Breathe Out"; case .hold2: return "Hold" }
    }
    var color: Color {
        switch self { case .inhale: return .cyan; case .hold1: return .yellow;
                      case .exhale: return .green; case .hold2: return .orange }
    }
}

// MARK: - Universal Challenge View
struct UniversalChallengeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let challenge: AllChallengeType

    // ── Core ──────────────────────────────────────────────────────────────────
    @State private var score: Int = 0
    @State private var isActive: Bool = false
    @State private var timeRemaining: Double = 0
    @State private var showResults: Bool = false
    @State private var level: Int = 1
    @State private var combo: Int = 0
    @State private var lives: Int = 3
    @State private var gameTimer: Timer? = nil
    @State private var shakeOffset: CGFloat = 0

    // ── Target Hunt ──────────────────────────────────────────────────────────
    @State private var huntShapes: [HuntShape] = []
    @State private var huntTarget: HuntShapeType = .circle
    @State private var huntMoveTimer: Timer? = nil

    // ── Number Rush ──────────────────────────────────────────────────────────
    @State private var rushNumbers: [RushNumber] = []
    @State private var rushNext: Int = 1
    @State private var rushTotal: Int = 12
    @State private var rushLayouts: Int = 0

    // ── Laser Lock ────────────────────────────────────────────────────────────
    @State private var lockNeedle: Double = 0       // -1.0 to 1.0
    @State private var lockDirection: Double = 1
    @State private var lockSpeed: Double = 0.6      // units/sec
    @State private var lockZone: Double = 0.30      // half-width of hit zone
    @State private var lockCooldown: Bool = false
    @State private var lockHitFlash: Bool = false
    @State private var lockMissFlash: Bool = false

    // ── Number Vault ─────────────────────────────────────────────────────────
    @State private var vaultSequence: [Int] = []
    @State private var vaultInput: [Int] = []
    @State private var vaultPhase: VaultPhase = .showing
    @State private var vaultShowProgress: Double = 0
    @State private var vaultResultMessage: String = ""

    // ── Grid Recall ───────────────────────────────────────────────────────────
    @State private var recallGrid: [Bool] = Array(repeating: false, count: 16)
    @State private var recallUserGrid: [Bool] = Array(repeating: false, count: 16)
    @State private var recallPhase: RecallPhase = .showing
    @State private var recallCellCount: Int = 4
    @State private var recallShowTimer: Double = 0
    @State private var recallResultOK: Bool = false

    // ── Color Chain ───────────────────────────────────────────────────────────
    @State private var chainSequence: [Int] = []
    @State private var chainInput: [Int] = []
    @State private var chainPhase: ChainPhase = .showing
    @State private var chainFlashIndex: Int = -1
    @State private var chainFlashTimer: Timer? = nil
    @State private var chainColors: [Color] = [.red, .blue, .green, .yellow]
    @State private var chainColorSymbols: [String] = ["circle.fill","square.fill","triangle.fill","star.fill"]

    // ── Go / No-Go ────────────────────────────────────────────────────────────
    @State private var goCircles: [GoCircle] = []
    @State private var goSpawnInterval: Double = 1.2
    @State private var goSpawnTimer: Timer? = nil
    @State private var goFeedback: String = ""
    @State private var goFeedbackColor: Color = .green
    @State private var goFeedbackOpacity: Double = 0

    // ── Timing Gate ───────────────────────────────────────────────────────────
    @State private var gateNeedle: Double = 0       // -1.0 to 1.0
    @State private var gateDirection: Double = 1
    @State private var gateSpeed: Double = 0.55
    @State private var gateZone: Double = 0.28
    @State private var gateCooldown: Bool = false
    @State private var gateHitFlash: Bool = false
    @State private var gateMissFlash: Bool = false
    @State private var gateHits: Int = 0

    // ── Flash Match ────────────────────────────────────────────────────────────
    @State private var matchPhase: MatchPhase = .showingA
    @State private var matchCardA: MatchCard = MatchCard(symbol: "circle.fill", color: .blue)
    @State private var matchCardB: MatchCard = MatchCard(symbol: "circle.fill", color: .blue)
    @State private var matchIsMatch: Bool = false
    @State private var matchFeedback: String = ""
    @State private var matchFeedbackColor: Color = .green
    @State private var matchFeedbackOpacity: Double = 0
    @State private var matchPhaseTimer: Timer? = nil
    @State private var matchUserAnswered: Bool = false

    // ── Breath Balloon ────────────────────────────────────────────────────────
    @State private var balloonPhase: BalloonPhase = .inhale
    @State private var balloonPhaseTime: Double = 0
    @State private var balloonIsPressed: Bool = false
    @State private var balloonSyncScore: Double = 0
    @State private var balloonSize: Double = 0.4    // 0 to 1

    // ── Box Master ─────────────────────────────────────────────────────────────
    @State private var boxPhase: BoxBreathPhase = .inhale
    @State private var boxPhaseTime: Double = 0
    @State private var boxPhaseDurations: [Double] = [4, 4, 4, 4]
    @State private var boxCompletedCycles: Int = 0
    @State private var boxDotProgress: Double = 0  // 0-1 around box
    @State private var boxNearCorner: Bool = false
    @State private var boxCornerTapped: Bool = false

    // ── Relax & Release ────────────────────────────────────────────────────────
    @State private var rlxPhase: Int = 0           // 0=in 1=hold 2=out
    @State private var rlxPhaseDurations: [Double] = [4, 7, 8]
    @State private var rlxPhaseTime: Double = 0
    @State private var rlxCycles: Int = 0
    @State private var rlxConfirmFlash: Bool = false
    @State private var rlxNeedsConfirm: Bool = false
    @State private var rlxRingProgress: Double = 0
    @State private var rlxPhaseNames: [String] = ["Breathe In", "Hold", "Breathe Out"]
    @State private var rlxPhaseColors: [Color] = [.cyan, .yellow, .green]

    // ── Notification Wall ──────────────────────────────────────────────────────
    @State private var wallNotifs: [WallNotif] = []
    @State private var wallSpawnTimer: Timer? = nil
    @State private var wallSpawnInterval: Double = 2.5

    // ── Green Light Only ───────────────────────────────────────────────────────
    @State private var glCircles: [GLCircle] = []
    @State private var glLastGreenPos: CGPoint = .zero
    @State private var glSpawnTimer: Timer? = nil

    // ── Impulse Fortress ───────────────────────────────────────────────────────
    @State private var fortressSafeButtons: [SafeButton] = []
    @State private var fortressBigScale: CGFloat = 1.0
    @State private var fortressBigPulse: Bool = false
    @State private var fortressSpawnTimer: Timer? = nil
    @State private var fortressBigTaps: Int = 0

    // ── Peripheral Scan ────────────────────────────────────────────────────────
    @State private var scanItems: [ScanItem] = []
    @State private var scanTarget: HuntShapeType = .circle
    @State private var scanSpawnTimer: Timer? = nil
    @State private var scanTargetAge: Double = 0

    // ── Sequence Echo ──────────────────────────────────────────────────────────
    @State private var echoSequence: [Int] = []
    @State private var echoInput: [Int] = []
    @State private var echoPhase: EchoPhase = .showing
    @State private var echoFlashIndex: Int = -1
    @State private var echoFlashTimer: Timer? = nil
    @State private var echoRound: Int = 1
    let echoPadColors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]

    // ── Reflex Tap ─────────────────────────────────────────────────────────────
    @State private var reflexTargets: [ReflexTarget] = []
    @State private var reflexHits: Int = 0
    @State private var reflexSpawnTimer: Timer? = nil
    @State private var reflexInterval: Double = 1.8

    // ── 4-7-8 Master ──────────────────────────────────────────────────────────
    @State private var fsbPhase: FourSevenEightPhase = .inhale
    @State private var fsbPhaseTime: Double = 0
    @State private var fsbCycles: Int = 0
    @State private var fsbRingProgress: Double = 0
    @State private var fsbNeedsConfirm: Bool = false
    @State private var fsbConfirmFlash: Bool = false

    // ── Tap Delay ──────────────────────────────────────────────────────────────
    @State private var tdPhase: DelayPhase = .waiting
    @State private var tdBarProgress: Double = 0
    @State private var tdBarDuration: Double = Double.random(in: 2.5...4.5)
    @State private var tdReactionStart: Date? = nil
    @State private var tdLastScore: String = ""
    @State private var tdRound: Int = 0

    // ── Math Blitz ─────────────────────────────────────────────────────────────
    @State private var mbQuestion: String = ""
    @State private var mbAnswer: Int = 0
    @State private var mbChoices: [Int] = []
    @State private var mbPhase: MathBlitzPhase = .showing
    @State private var mbFlashTimer: Timer? = nil
    @State private var mbStreak: Int = 0
    @State private var mbFeedback: String = ""
    @State private var mbFeedbackColor: Color = .green
    @State private var mbFeedbackOpacity: Double = 0

    // ── Color Surge ────────────────────────────────────────────────────────────
    @State private var csCurrentColor: Color = .red
    @State private var csTargetColor: Color = .green
    @State private var csColorName: String = "GREEN"
    @State private var csPhase: ColorSurgePhase = .waiting
    @State private var csSpawnTimer: Timer? = nil
    @State private var csFillProgress: Double = 0
    @State private var csFeedback: String = ""
    @State private var csFeedbackColor: Color = .green
    @State private var csFeedbackOpacity: Double = 0
    let csColors: [(Color, String)] = [(.red,"RED"),(.blue,"BLUE"),(.green,"GREEN"),(.yellow,"YELLOW"),(.orange,"ORANGE"),(.purple,"PURPLE")]

    // ── Rhythm Breath ──────────────────────────────────────────────────────────
    @State private var rbPhase: RhythmBreathPhase = .inhale
    @State private var rbCycles: Int = 0
    @State private var rbProgress: Double = 0
    @State private var rbInhale: Double = 4.0
    @State private var rbExhale: Double = 6.0
    @State private var rbOnTrack: Bool = true

    // ── Silent Counter ─────────────────────────────────────────────────────────
    @State private var scHiddenCount: Int = 0
    @State private var scUserGuess: Int = 0
    @State private var scPhase: SilentCounterPhase = .counting
    @State private var scTickTimer: Timer? = nil
    @State private var scResultDelta: Int = 0
    @State private var scRound: Int = 0
    @State private var scFeedback: String = ""

    // ── Dual Task ──────────────────────────────────────────────────────────────
    @State private var dtTargetPos: CGFloat = 0.5  // 0-1 across screen
    @State private var dtTargetDir: CGFloat = 1
    @State private var dtTargetSpeed: CGFloat = 0.25
    @State private var dtNumbers: [Int] = []
    @State private var dtCorrectNum: Int = 0
    @State private var dtChoices: [Int] = []
    @State private var dtTrackScore: Int = 0
    @State private var dtMathScore: Int = 0
    @State private var dtTapped: Bool = false

    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
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
                Circle().fill(challenge.color.opacity(0.25)).frame(width: 120, height: 120)
                Image(systemName: challenge.icon).font(.system(size: 48)).foregroundColor(challenge.color)
            }
            Text(challenge.rawValue).font(.system(size: 28, weight: .bold)).foregroundColor(.white)
            Text(challenge.description)
                .font(.system(size: 15)).foregroundColor(.gray)
                .multilineTextAlignment(.center).padding(.horizontal, 32)
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(challenge.duration)s").font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                    Text("Duration").font(.caption).foregroundColor(.gray)
                }
                VStack(spacing: 4) {
                    Text("\(challenge.xpReward) XP").font(.system(size: 22, weight: .bold)).foregroundColor(.yellow)
                    Text("Reward").font(.caption).foregroundColor(.gray)
                }
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            Image(systemName: "heart.fill").foregroundColor(.pink).font(.caption)
                        }
                    }
                    Text("Lives").font(.caption).foregroundColor(.gray)
                }
            }
            Spacer()
            Button(action: startChallenge) {
                Text("Start Challenge")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(challenge.color).cornerRadius(14)
            }
            .padding(.horizontal, 24).padding(.bottom, 40)
        }
    }

    // MARK: - Active View
    var activeChallengeView: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Button(action: endChallenge) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                Spacer()
                // Timer
                HStack(spacing: 4) {
                    Image(systemName: "timer").font(.caption)
                    Text("\(Int(timeRemaining))s")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(timeRemaining < 10 ? .red : .white)
                Spacer()
                // Score
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption)
                    Text("\(score)").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 8)

            // Lives
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .foregroundColor(i < lives ? .pink : .gray.opacity(0.4)).font(.caption)
                }
                Spacer()
                if combo > 1 {
                    Text("\(combo)x COMBO").font(.caption2.weight(.bold))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.yellow.opacity(0.15)).cornerRadius(8)
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 4)

            // Progress bar
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 3)
                    Rectangle().fill(challenge.color)
                        .frame(width: g.size.width * (timeRemaining / Double(challenge.duration)), height: 3)
                }
            }
            .frame(height: 3)

            // Challenge content
            challengeContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 16)
        }
    }

    // MARK: - Results
    var resultsView: some View {
        let gemsEarned = score / 10
        return ZStack {
            if gemsEarned > 0 {
                ForEach(0..<min(gemsEarned, 8), id: \.self) { i in FloatingGemParticle(delay: Double(i)*0.15) }
            }
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: score >= 100 ? "star.fill" : score >= 50 ? "checkmark.circle.fill" : "arrow.clockwise")
                    .font(.system(size: 70)).foregroundColor(score >= 100 ? .yellow : score >= 50 ? .green : .gray)
                    .scaleEffect(showResults ? 1 : 0.3).animation(.spring(response: 0.5, dampingFraction: 0.6), value: showResults)
                Text("Challenge Complete!").font(.title.bold()).foregroundColor(.white)
                Text("\(score) pts").font(.system(size: 42, weight: .heavy)).foregroundColor(.yellow)
                HStack(spacing: 24) {
                    VStack(spacing: 4) {
                        Text("+\(challenge.xpReward) XP").font(.headline).foregroundColor(.green)
                        Text("Experience").font(.caption).foregroundColor(.gray)
                    }
                    if gemsEarned > 0 {
                        VStack(spacing: 4) {
                            Text("+\(gemsEarned)").font(.headline).foregroundColor(.cyan)
                            Text("Gems").font(.caption).foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 12).padding(.horizontal, 24)
                .background(Color.white.opacity(0.07)).cornerRadius(14)
                Spacer()
                Button(action: { dismiss() }) {
                    Text("Continue").font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(challenge.color).cornerRadius(14)
                }
                .padding(.horizontal, 24).padding(.bottom, 40)
            }
        }
        .onAppear { HapticManager.shared.success(); SoundManager.shared.playSuccess() }
    }

    // MARK: - Start / End
    func startChallenge() {
        score = 0; level = 1; combo = 0; lives = 3
        timeRemaining = Double(challenge.duration)
        isActive = true
        initChallenge()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in tickGame() }
        }
    }

    func endChallenge() {
        gameTimer?.invalidate(); gameTimer = nil
        huntMoveTimer?.invalidate(); huntMoveTimer = nil
        chainFlashTimer?.invalidate(); chainFlashTimer = nil
        goSpawnTimer?.invalidate(); goSpawnTimer = nil
        matchPhaseTimer?.invalidate(); matchPhaseTimer = nil
        wallSpawnTimer?.invalidate(); wallSpawnTimer = nil
        glSpawnTimer?.invalidate(); glSpawnTimer = nil
        fortressSpawnTimer?.invalidate(); fortressSpawnTimer = nil
        scanSpawnTimer?.invalidate(); scanSpawnTimer = nil
        echoFlashTimer?.invalidate(); echoFlashTimer = nil
        reflexSpawnTimer?.invalidate(); reflexSpawnTimer = nil
        mbFlashTimer?.invalidate(); mbFlashTimer = nil
        csSpawnTimer?.invalidate(); csSpawnTimer = nil
        scTickTimer?.invalidate(); scTickTimer = nil
        isActive = false
        showResults = true
        appState.completeChallenge(type: challenge, score: score, xpEarned: challenge.xpReward)
    }

    func tickGame() {
        guard isActive else { return }
        timeRemaining -= 0.05
        if timeRemaining <= 0 { endChallenge(); return }
        if lives <= 0 { endChallenge(); return }
        updateChallengeState()
    }

    // MARK: - Init Challenge
    func initChallenge() {
        switch challenge {
        case .targetHunt:       initTargetHunt()
        case .numberRush:       initNumberRush()
        case .laserLock:        initLaserLock()
        case .numberVault:      initNumberVault()
        case .gridRecall:       initGridRecall()
        case .colorChain:       initColorChain()
        case .goNoGo:           initGoNoGo()
        case .timingGate:       initTimingGate()
        case .flashMatch:       initFlashMatch()
        case .breathBalloon:    initBreathBalloon()
        case .boxMaster:        initBoxMaster()
        case .relaxRelease:     initRelaxRelease()
        case .notificationWall: initNotificationWall()
        case .greenLightOnly:   initGreenLightOnly()
        case .impulseFortress:  initImpulseFortress()
        case .peripheralScan:   initPeripheralScan()
        case .sequenceEcho:     initSequenceEcho()
        case .reflexTap:        initReflexTap()
        case .fourSevenEight:   initFourSevenEight()
        case .tapDelay:         initTapDelay()
        case .mathBlitz:        initMathBlitz()
        case .colorSurge:       initColorSurge()
        case .rhythmBreath:     initRhythmBreath()
        case .silentCounter:    initSilentCounter()
        case .dualTask:         initDualTask()
        }
    }

    // MARK: - Update Challenge State (called every 0.05s)
    func updateChallengeState() {
        switch challenge {
        case .targetHunt:       updateTargetHunt()
        case .numberRush:       break
        case .laserLock:        updateLaserLock()
        case .numberVault:      updateNumberVault()
        case .gridRecall:       updateGridRecall()
        case .colorChain:       break
        case .goNoGo:           break
        case .timingGate:       updateTimingGate()
        case .flashMatch:       break
        case .breathBalloon:    updateBreathBalloon()
        case .boxMaster:        updateBoxMaster()
        case .relaxRelease:     updateRelaxRelease()
        case .notificationWall: break
        case .greenLightOnly:   updateGreenLightOnly()
        case .impulseFortress:  break
        case .peripheralScan:   updatePeripheralScan()
        case .sequenceEcho:     break
        case .reflexTap:        updateReflexTap()
        case .fourSevenEight:   updateFourSevenEight()
        case .tapDelay:         updateTapDelay()
        case .mathBlitz:        updateMathBlitz()
        case .colorSurge:       updateColorSurge()
        case .rhythmBreath:     updateRhythmBreath()
        case .silentCounter:    break
        case .dualTask:         updateDualTask()
        }
    }

    // MARK: - Challenge Content Router
    @ViewBuilder
    var challengeContent: some View {
        switch challenge {
        case .targetHunt:       targetHuntView
        case .numberRush:       numberRushView
        case .laserLock:        laserLockView
        case .numberVault:      numberVaultView
        case .gridRecall:       gridRecallView
        case .colorChain:       colorChainView
        case .goNoGo:           goNoGoView
        case .timingGate:       timingGateView
        case .flashMatch:       flashMatchView
        case .breathBalloon:    breathBalloonView
        case .boxMaster:        boxMasterView
        case .relaxRelease:     relaxReleaseView
        case .notificationWall: notificationWallView
        case .greenLightOnly:   greenLightOnlyView
        case .impulseFortress:  impulseFortressView
        case .peripheralScan:   peripheralScanView
        case .sequenceEcho:     sequenceEchoView
        case .reflexTap:        reflexTapView
        case .fourSevenEight:   fourSevenEightView
        case .tapDelay:         tapDelayView
        case .mathBlitz:        mathBlitzView
        case .colorSurge:       colorSurgeView
        case .rhythmBreath:     rhythmBreathView
        case .silentCounter:    silentCounterView
        case .dualTask:         dualTaskView
        }
    }

    // =========================================================================
    // MARK: - 1. TARGET HUNT
    // =========================================================================
    func initTargetHunt() {
        huntTarget = HuntShapeType.allCases.randomElement()!
        huntShapes = []
        spawnHuntShapes(count: 8)
        huntMoveTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in self.moveHuntShapes() }
        }
    }

    func spawnHuntShapes(count: Int) {
        for _ in 0..<count {
            let type = HuntShapeType.allCases.randomElement()!
            huntShapes.append(HuntShape(
                type: type,
                position: CGPoint(x: Double.random(in: 60...340), y: Double.random(in: 120...600)),
                velocity: CGPoint(x: Double.random(in: -60...60), y: Double.random(in: -60...60))
            ))
        }
    }

    func moveHuntShapes() {
        guard isActive else { return }
        let dt = 0.05
        for i in huntShapes.indices {
            huntShapes[i].position.x += huntShapes[i].velocity.x * dt
            huntShapes[i].position.y += huntShapes[i].velocity.y * dt
            if huntShapes[i].position.x < 40 || huntShapes[i].position.x > 360 {
                huntShapes[i].velocity.x *= -1
            }
            if huntShapes[i].position.y < 100 || huntShapes[i].position.y > 650 {
                huntShapes[i].velocity.y *= -1
            }
        }
    }

    func updateTargetHunt() {
        // Speed scales with level
        let speedMult = 1.0 + Double(level - 1) * 0.15
        for i in huntShapes.indices {
            let baseSpeed = 60.0 * speedMult
            if abs(huntShapes[i].velocity.x) < baseSpeed * 0.5 { huntShapes[i].velocity.x *= 1.02 }
            if abs(huntShapes[i].velocity.y) < baseSpeed * 0.5 { huntShapes[i].velocity.y *= 1.02 }
        }
    }

    func tapHuntShape(index: Int) {
        guard huntShapes.indices.contains(index) else { return }
        let shape = huntShapes[index]
        if shape.type == huntTarget {
            combo += 1
            let points = 10 * min(combo, 8)
            score += points
            HapticManager.shared.success()
            SoundManager.shared.playSuccess()
            // Replace tapped shape with new one
            let newType = HuntShapeType.allCases.randomElement()!
            huntShapes[index] = HuntShape(
                type: newType,
                position: CGPoint(x: Double.random(in: 60...340), y: Double.random(in: 120...600)),
                velocity: CGPoint(x: Double.random(in: -80...80), y: Double.random(in: -80...80))
            )
            // Every 5 combos change target type
            if combo % 5 == 0 {
                huntTarget = HuntShapeType.allCases.randomElement()!
                SoundManager.shared.playLevelUp()
            }
        } else {
            combo = 0
            score = max(0, score - 10)
            lives -= 1
            HapticManager.shared.error()
            SoundManager.shared.playFail()
            huntShapes[index].isWrong = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if self.huntShapes.indices.contains(index) { self.huntShapes[index].isWrong = false }
            }
        }
    }

    var targetHuntView: some View {
        GeometryReader { geo in
            ZStack {
                // Find target indicator
                VStack(spacing: 6) {
                    Text("FIND:").font(.caption.weight(.bold)).foregroundColor(.gray)
                    ZStack {
                        Circle().fill(huntTarget.color.opacity(0.2)).frame(width: 60, height: 60)
                        Image(systemName: huntTarget.sfSymbol)
                            .font(.system(size: 30)).foregroundColor(huntTarget.color)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 8)

                // Floating shapes
                ForEach(huntShapes.indices, id: \.self) { i in
                    let shape = huntShapes[i]
                    Image(systemName: shape.type.sfSymbol)
                        .font(.system(size: 40))
                        .foregroundColor(shape.isWrong ? .red : shape.type.color)
                        .scaleEffect(shape.isWrong ? 1.3 : 1.0)
                        .shadow(color: shape.type.color.opacity(0.6), radius: 8)
                        .position(shape.position)
                        .onTapGesture { tapHuntShape(index: i) }
                        .animation(.easeInOut(duration: 0.15), value: shape.isWrong)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // =========================================================================
    // MARK: - 2. NUMBER RUSH
    // =========================================================================
    func initNumberRush() {
        rushTotal = 12; rushNext = 1; rushLayouts = 0
        layoutRushNumbers()
    }

    func layoutRushNumbers() {
        // Avoid overlaps via simple grid jitter
        var positions: [CGPoint] = []
        let cols = 4; let rows = Int(ceil(Double(rushTotal) / Double(cols)))
        for i in 0..<rushTotal {
            let col = i % cols; let row = i / cols
            let bx = 50.0 + Double(col) * 80.0
            let by = 100.0 + Double(row) * 110.0
            let pos = CGPoint(x: bx + Double.random(in: -15...15), y: by + Double.random(in: -15...15))
            positions.append(pos)
        }
        let shuffledVals = Array(1...rushTotal).shuffled()
        rushNumbers = zip(shuffledVals, positions).map { val, pos in
            RushNumber(value: val, position: pos)
        }
        rushNext = 1
    }

    func tapRushNumber(index: Int) {
        guard rushNumbers.indices.contains(index), !rushNumbers[index].tapped else { return }
        let num = rushNumbers[index]
        if num.value == rushNext {
            rushNumbers[index].tapped = true
            let timeBonus = max(0, Int(timeRemaining * 0.4))
            score += 10 + timeBonus
            combo += 1
            rushNext += 1
            HapticManager.shared.lightTap()
            // All tapped? Next layout
            if rushNext > rushTotal {
                rushLayouts += 1; level += 1
                score += 50 * level
                SoundManager.shared.playLevelUp()
                rushTotal = min(rushTotal + 2, 20)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.layoutRushNumbers() }
            }
        } else {
            score = max(0, score - 5)
            combo = 0
            HapticManager.shared.error()
            // Briefly shake wrong number
            rushNumbers[index].shake = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if self.rushNumbers.indices.contains(index) { self.rushNumbers[index].shake = false }
            }
        }
    }

    var numberRushView: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 4) {
                    Text("TAP IN ORDER").font(.caption.weight(.bold)).foregroundColor(.gray)
                    Text("Next: \(rushNext)").font(.system(size: 28, weight: .heavy)).foregroundColor(.purple)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top, 4)

                ForEach(rushNumbers.indices, id: \.self) { i in
                    let n = rushNumbers[i]
                    ZStack {
                        Circle()
                            .fill(n.tapped ? Color.gray.opacity(0.15) :
                                  (n.value == rushNext ? Color.purple.opacity(0.35) : Color.purple.opacity(0.12)))
                            .frame(width: 58, height: 58)
                            .shadow(color: n.value == rushNext ? Color.purple : .clear, radius: 10)
                        Text("\(n.value)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(n.tapped ? .gray.opacity(0.3) : .white)
                    }
                    .offset(x: n.shake ? CGFloat.random(in: -4...4) : 0)
                    .position(n.position)
                    .onTapGesture { if !n.tapped { tapRushNumber(index: i) } }
                    .animation(.easeInOut(duration: 0.08), value: n.shake)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // =========================================================================
    // MARK: - 3. LASER LOCK
    // =========================================================================
    func initLaserLock() {
        lockNeedle = 0; lockDirection = 1; lockSpeed = 0.5; lockZone = 0.28
    }

    func updateLaserLock() {
        lockNeedle += lockDirection * lockSpeed * 0.05
        if lockNeedle > 1 { lockNeedle = 1; lockDirection = -1 }
        if lockNeedle < -1 { lockNeedle = -1; lockDirection = 1 }
    }

    func tapLaserLock() {
        guard !lockCooldown else { return }
        lockCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { self.lockCooldown = false }

        let distance = abs(lockNeedle)
        if distance <= lockZone {
            // Hit — score by precision
            let precision = 1.0 - (distance / lockZone)
            let pts = Int(20 + precision * 30)
            score += pts
            combo += 1
            lockHitFlash = true
            HapticManager.shared.success()
            SoundManager.shared.playSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self.lockHitFlash = false }
            // Shrink zone every 4 hits
            if combo % 4 == 0 {
                lockZone = max(0.10, lockZone - 0.03)
                lockSpeed = min(1.4, lockSpeed + 0.07)
                SoundManager.shared.playLevelUp()
                level += 1
            }
        } else {
            score = max(0, score - 15)
            combo = 0
            lockMissFlash = true
            HapticManager.shared.error()
            SoundManager.shared.playFail()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self.lockMissFlash = false }
        }
    }

    var laserLockView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("TAP WHEN NEEDLE IS IN THE ZONE")
                .font(.caption.weight(.bold)).foregroundColor(.gray)
                .multilineTextAlignment(.center)

            // Gauge
            GeometryReader { geo in
                let w = geo.size.width; let h: CGFloat = 120
                let cx = w / 2; let cy = h * 0.85
                let radius = w * 0.42
                ZStack {
                    // Arc background
                    Path { path in
                        path.addArc(center: CGPoint(x: cx, y: cy), radius: radius,
                                    startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    }
                    .stroke(Color.white.opacity(0.1), lineWidth: 14)

                    // Zone arc (center ± lockZone mapped to degrees)
                    let zoneStart = 180.0 + (1 - lockZone) * 90
                    let zoneEnd   = 180.0 + (1 + lockZone) * 90
                    Path { path in
                        path.addArc(center: CGPoint(x: cx, y: cy), radius: radius,
                                    startAngle: .degrees(zoneStart), endAngle: .degrees(zoneEnd), clockwise: false)
                    }
                    .stroke(lockHitFlash ? Color.green : Color.yellow.opacity(0.85), lineWidth: 14)

                    // Needle
                    let needleDeg = 180 + (lockNeedle + 1) * 90
                    let needleRad = needleDeg * .pi / 180
                    let nx = cx + radius * cos(needleRad)
                    let ny = cy + radius * sin(needleRad)
                    Path { path in
                        path.move(to: CGPoint(x: cx, y: cy))
                        path.addLine(to: CGPoint(x: nx, y: ny))
                    }
                    .stroke(lockMissFlash ? Color.red : Color.white, lineWidth: 3)
                    .shadow(color: .white, radius: 4)

                    Circle().fill(lockMissFlash ? Color.red : Color.white)
                        .frame(width: 12, height: 12).position(x: cx, y: cy)
                }
                .frame(width: w, height: h)
            }
            .frame(height: 130)

            // Zone width indicator
            HStack {
                Text("Zone: \(Int(lockZone * 100))%").font(.caption).foregroundColor(.gray)
                Spacer()
                Text("Speed: \(String(format: "%.1f", lockSpeed))x").font(.caption).foregroundColor(.gray)
            }
            .padding(.horizontal, 32)

            // Tap button
            Button(action: tapLaserLock) {
                ZStack {
                    Circle()
                        .fill(lockHitFlash ? Color.green : lockMissFlash ? Color.red : challenge.color)
                        .frame(width: 110, height: 110)
                        .shadow(color: challenge.color.opacity(0.6), radius: 16)
                    Text("TAP").font(.system(size: 24, weight: .heavy)).foregroundColor(.white)
                }
            }
            .disabled(lockCooldown)

            Spacer()
        }
    }

    // =========================================================================
    // MARK: - 4. NUMBER VAULT
    // =========================================================================
    func initNumberVault() {
        vaultPhase = .showing; vaultInput = []; vaultShowProgress = 0
        generateVaultSequence()
    }

    func generateVaultSequence() {
        let length = 3 + level
        vaultSequence = (0..<length).map { _ in Int.random(in: 0...9) }
        vaultPhase = .showing; vaultInput = []; vaultShowProgress = 0
    }

    func updateNumberVault() {
        guard vaultPhase == .showing else { return }
        vaultShowProgress += 0.05
        let showDuration = max(1.8, 3.0 - Double(level) * 0.15)
        if vaultShowProgress >= showDuration {
            vaultPhase = .entering
        }
    }

    func tapVaultDigit(_ digit: Int) {
        guard vaultPhase == .entering else { return }
        vaultInput.append(digit)
        HapticManager.shared.lightTap()
        if vaultInput.count == vaultSequence.count {
            if vaultInput == vaultSequence {
                score += 100 + level * 20
                combo += 1
                vaultResultMessage = "CORRECT! +\(100 + level * 20)"
                vaultPhase = .correct
                HapticManager.shared.success(); SoundManager.shared.playSuccess()
                level += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { self.generateVaultSequence() }
            } else {
                lives -= 1; combo = 0
                vaultResultMessage = "Wrong! Was: \(vaultSequence.map(String.init).joined())"
                vaultPhase = .wrong
                HapticManager.shared.error(); SoundManager.shared.playFail()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    self.vaultInput = []; self.generateVaultSequence()
                }
            }
        }
    }

    func deleteVaultDigit() {
        guard !vaultInput.isEmpty else { return }
        vaultInput.removeLast()
    }

    var numberVaultView: some View {
        VStack(spacing: 20) {
            Spacer()
            // Display area
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 100)
                if vaultPhase == .showing {
                    VStack(spacing: 6) {
                        Text("MEMORIZE").font(.caption.weight(.bold)).foregroundColor(.gray)
                        HStack(spacing: 8) {
                            ForEach(vaultSequence.indices, id: \.self) { i in
                                Text("\(vaultSequence[i])")
                                    .font(.system(size: 36, weight: .heavy)).foregroundColor(.blue)
                                    .frame(width: 36)
                            }
                        }
                        // Show timer
                        let showDuration = max(1.8, 3.0 - Double(level) * 0.15)
                        ProgressView(value: vaultShowProgress / showDuration)
                            .tint(.blue).frame(width: 160)
                    }
                } else if vaultPhase == .entering {
                    VStack(spacing: 6) {
                        Text("ENTER THE NUMBER").font(.caption.weight(.bold)).foregroundColor(.gray)
                        HStack(spacing: 8) {
                            ForEach(0..<vaultSequence.count, id: \.self) { i in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.2)).frame(width: 36, height: 46)
                                    if i < vaultInput.count {
                                        Text("\(vaultInput[i])").font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                                    } else {
                                        Text("_").font(.system(size: 28)).foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Text(vaultResultMessage)
                        .font(.headline)
                        .foregroundColor(vaultPhase == .correct ? .green : .red)
                        .multilineTextAlignment(.center).padding(.horizontal, 12)
                }
            }
            .padding(.horizontal, 24)

            // Numpad
            if vaultPhase == .entering {
                VStack(spacing: 10) {
                    ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.self) { digit in
                                Button(action: { tapVaultDigit(digit) }) {
                                    Text("\(digit)").font(.system(size: 28, weight: .semibold))
                                        .foregroundColor(.white).frame(width: 76, height: 64)
                                        .background(Color.white.opacity(0.09)).cornerRadius(12)
                                }
                            }
                        }
                    }
                    HStack(spacing: 12) {
                        Button(action: deleteVaultDigit) {
                            Image(systemName: "delete.left.fill").font(.system(size: 24))
                                .foregroundColor(.orange).frame(width: 76, height: 64)
                                .background(Color.white.opacity(0.07)).cornerRadius(12)
                        }
                        Button(action: { tapVaultDigit(0) }) {
                            Text("0").font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white).frame(width: 76, height: 64)
                                .background(Color.white.opacity(0.09)).cornerRadius(12)
                        }
                        Color.clear.frame(width: 76, height: 64)
                    }
                }
            }
            Spacer()
        }
    }

    // =========================================================================
    // MARK: - 5. GRID RECALL
    // =========================================================================
    func initGridRecall() {
        recallCellCount = 4; recallPhase = .showing
        generateRecallGrid()
    }

    func generateRecallGrid() {
        recallGrid = Array(repeating: false, count: 16)
        recallUserGrid = Array(repeating: false, count: 16)
        var indices = Array(0..<16).shuffled()
        for i in 0..<recallCellCount { recallGrid[indices[i]] = true }
        recallPhase = .showing; recallShowTimer = 0
    }

    func updateGridRecall() {
        guard recallPhase == .showing else { return }
        recallShowTimer += 0.05
        let showDur = max(1.5, 3.5 - Double(level) * 0.2)
        if recallShowTimer >= showDur { recallPhase = .recalling }
    }

    func tapRecallCell(index: Int) {
        guard recallPhase == .recalling else { return }
        recallUserGrid[index].toggle()
        HapticManager.shared.lightTap()
        // Auto-check when correct count selected
        let selectedCount = recallUserGrid.filter { $0 }.count
        if selectedCount == recallCellCount {
            let correct = zip(recallGrid, recallUserGrid).allSatisfy { $0 == $1 }
            recallPhase = .result; recallResultOK = correct
            if correct {
                score += 60 * level; combo += 1
                HapticManager.shared.success(); SoundManager.shared.playSuccess()
                recallCellCount = min(recallCellCount + 1, 12); level += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { self.generateRecallGrid() }
            } else {
                score = max(0, score - 20); lives -= 1; combo = 0
                HapticManager.shared.error(); SoundManager.shared.playFail()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { self.generateRecallGrid() }
            }
        }
    }

    var gridRecallView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(recallPhase == .showing ? "MEMORIZE THE PATTERN" :
                 recallPhase == .recalling ? "RECREATE IT — \(recallCellCount) CELLS" :
                 recallResultOK ? "CORRECT!" : "WRONG!")
                .font(.caption.weight(.bold))
                .foregroundColor(recallPhase == .result ? (recallResultOK ? .green : .red) : .gray)

            // 4x4 Grid
            VStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(0..<4, id: \.self) { col in
                            let idx = row * 4 + col
                            let isLit: Bool = {
                                if recallPhase == .showing { return recallGrid[idx] }
                                if recallPhase == .result { return recallGrid[idx] }
                                return recallUserGrid[idx]
                            }()
                            let isCorrectCell = recallPhase == .result && recallGrid[idx] && recallUserGrid[idx]
                            let isWrongCell = recallPhase == .result && !recallGrid[idx] && recallUserGrid[idx]
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isWrongCell ? Color.red.opacity(0.7) :
                                      isCorrectCell ? Color.green.opacity(0.7) :
                                      isLit ? Color.blue.opacity(0.85) : Color.white.opacity(0.08))
                                .frame(width: 72, height: 72)
                                .shadow(color: isLit ? .blue : .clear, radius: 6)
                                .onTapGesture { tapRecallCell(index: idx) }
                        }
                    }
                }
            }
            Spacer()
        }
    }

    // =========================================================================
    // MARK: - 6. COLOR CHAIN (Simon Says)
    // =========================================================================
    func initColorChain() {
        chainSequence = []; chainInput = []; chainPhase = .showing
        chainSequence.append(Int.random(in: 0..<4))
        startChainShow()
    }

    func startChainShow() {
        chainInput = []; chainPhase = .showing; chainFlashIndex = -1
        var delay = 0.4
        for (i, colorIdx) in chainSequence.enumerated() {
            let d = delay
            let ci = colorIdx
            DispatchQueue.main.asyncAfter(deadline: .now() + d) {
                self.chainFlashIndex = ci
                HapticManager.shared.lightTap()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + d + 0.5) {
                self.chainFlashIndex = -1
                if i == self.chainSequence.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.chainPhase = .inputting
                    }
                }
            }
            delay += 0.75
        }
    }

    func tapChainButton(_ colorIdx: Int) {
        guard chainPhase == .inputting else { return }
        let expected = chainSequence[chainInput.count]
        chainInput.append(colorIdx)
        chainFlashIndex = colorIdx
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.chainFlashIndex = -1 }

        if colorIdx != expected {
            // Wrong
            lives -= 1; combo = 0
            score = max(0, score - 20)
            HapticManager.shared.error(); SoundManager.shared.playFail()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { self.startChainShow() }
        } else if chainInput.count == chainSequence.count {
            // Correct round
            score += 50 + level * 20; combo += 1; level += 1
            HapticManager.shared.success(); SoundManager.shared.playSuccess()
            chainSequence.append(Int.random(in: 0..<4))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { self.startChainShow() }
        } else {
            HapticManager.shared.lightTap()
        }
    }

    var colorChainView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(chainPhase == .showing ? "WATCH THE SEQUENCE" : "REPEAT THE SEQUENCE")
                .font(.caption.weight(.bold)).foregroundColor(.gray)
            Text("Round \(chainSequence.count)").font(.headline).foregroundColor(.white)

            // 2×2 buttons
            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    chainButton(0); chainButton(1)
                }
                HStack(spacing: 14) {
                    chainButton(2); chainButton(3)
                }
            }
            .disabled(chainPhase == .showing)
            Spacer()
        }
    }

    @ViewBuilder
    func chainButton(_ idx: Int) -> some View {
        let isFlashing = chainFlashIndex == idx
        Button(action: { tapChainButton(idx) }) {
            RoundedRectangle(cornerRadius: 20)
                .fill(chainColors[idx].opacity(isFlashing ? 0.95 : 0.3))
                .frame(width: 140, height: 140)
                .overlay(Image(systemName: chainColorSymbols[idx])
                    .font(.system(size: 44)).foregroundColor(isFlashing ? .white : chainColors[idx].opacity(0.7)))
                .shadow(color: isFlashing ? chainColors[idx] : .clear, radius: 18)
        }
        .animation(.easeInOut(duration: 0.12), value: isFlashing)
    }

    // =========================================================================
    // MARK: - 7. GO / NO-GO
    // =========================================================================
    func initGoNoGo() {
        goCircles = []; goSpawnInterval = 1.4
        scheduleGoSpawn()
    }

    func scheduleGoSpawn() {
        goSpawnTimer?.invalidate()
        guard isActive else { return }
        goSpawnTimer = Timer.scheduledTimer(withTimeInterval: goSpawnInterval, repeats: false) { _ in
            Task { @MainActor in
                self.spawnGoCircle()
                self.goSpawnInterval = max(0.6, self.goSpawnInterval - 0.02)
                self.scheduleGoSpawn()
            }
        }
    }

    func spawnGoCircle() {
        // Remove old untapped circles
        goCircles.removeAll()
        let isGo = Double.random(in: 0...1) < 0.6
        let circle = GoCircle(
            isGo: isGo,
            position: CGPoint(x: Double.random(in: 60...320), y: Double.random(in: 140...560))
        )
        goCircles = [circle]
        // Animate in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let i = self.goCircles.indices.first { self.goCircles[i].scale = 1; self.goCircles[i].opacity = 1 }
        }
        // Auto-dismiss + score missed go
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if let i = self.goCircles.indices.first, !self.goCircles[i].tapped {
                if self.goCircles[i].isGo {
                    self.score = max(0, self.score - 5)
                    self.showGoFeedback("MISSED", color: .orange)
                }
                withAnimation(.easeOut(duration: 0.25)) { self.goCircles[i].opacity = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self.goCircles.removeAll() }
            }
        }
    }

    func tapGoCircle(index: Int) {
        guard goCircles.indices.contains(index), !goCircles[index].tapped else { return }
        goCircles[index].tapped = true
        let circle = goCircles[index]
        withAnimation(.easeOut(duration: 0.2)) { goCircles[index].opacity = 0 }
        if circle.isGo {
            score += 20 + combo * 5; combo += 1
            HapticManager.shared.success()
            showGoFeedback("+\(20 + (combo-1) * 5)", color: .green)
        } else {
            score = max(0, score - 15); combo = 0; lives -= 1
            HapticManager.shared.error(); SoundManager.shared.playFail()
            showGoFeedback("-15 WRONG!", color: .red)
        }
    }

    func showGoFeedback(_ msg: String, color: Color) {
        goFeedback = msg; goFeedbackColor = color; goFeedbackOpacity = 1
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) { goFeedbackOpacity = 0 }
    }

    var goNoGoView: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 4) {
                    Text("GREEN = TAP  |  RED = WAIT")
                        .font(.caption.weight(.bold)).foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top, 8)

                ForEach(goCircles.indices, id: \.self) { i in
                    let c = goCircles[i]
                    ZStack {
                        Circle()
                            .fill(c.isGo ? Color.green.opacity(0.85) : Color.red.opacity(0.85))
                            .frame(width: 110, height: 110)
                            .shadow(color: c.isGo ? .green : .red, radius: 16)
                        VStack(spacing: 2) {
                            Image(systemName: c.isGo ? "hand.tap.fill" : "hand.raised.fill")
                                .font(.system(size: 28)).foregroundColor(.white)
                            Text(c.isGo ? "TAP!" : "WAIT!").font(.caption.weight(.heavy)).foregroundColor(.white)
                        }
                    }
                    .scaleEffect(c.scale).opacity(c.opacity)
                    .position(c.position)
                    .onTapGesture { tapGoCircle(index: i) }
                    .animation(.spring(response: 0.2), value: c.scale)
                }

                Text(goFeedback).font(.title.bold()).foregroundColor(goFeedbackColor)
                    .opacity(goFeedbackOpacity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // =========================================================================
    // MARK: - 8. TIMING GATE
    // =========================================================================
    func initTimingGate() {
        gateNeedle = 0; gateDirection = 1; gateSpeed = 0.5; gateZone = 0.28; gateHits = 0
    }

    func updateTimingGate() {
        gateNeedle += gateDirection * gateSpeed * 0.05
        if gateNeedle > 1 { gateNeedle = 1; gateDirection = -1 }
        if gateNeedle < -1 { gateNeedle = -1; gateDirection = 1 }
    }

    func tapTimingGate() {
        guard !gateCooldown else { return }
        gateCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.gateCooldown = false }
        let dist = abs(gateNeedle)
        if dist <= gateZone {
            let precision = 1.0 - (dist / gateZone)
            let pts = Int(15 + precision * 35)
            score += pts; combo += 1; gateHits += 1
            gateHitFlash = true
            HapticManager.shared.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self.gateHitFlash = false }
            if gateHits % 5 == 0 {
                gateZone = max(0.09, gateZone - 0.03); gateSpeed = min(1.5, gateSpeed + 0.08); level += 1
                SoundManager.shared.playLevelUp()
            }
        } else {
            score = max(0, score - 10); combo = 0
            gateMissFlash = true; HapticManager.shared.error()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self.gateMissFlash = false }
        }
    }

    var timingGateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("TAP WHEN THE BALL IS IN THE ZONE")
                .font(.caption.weight(.bold)).foregroundColor(.gray)
            // Horizontal track
            GeometryReader { geo in
                let w = geo.size.width; let h: CGFloat = 60
                let cx = w / 2
                let ballX = cx + CGFloat(gateNeedle) * (w / 2 - 20)
                let zoneW = CGFloat(gateZone * 2) * (w / 2 - 20)
                ZStack {
                    // Track
                    RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.08))
                        .frame(width: w, height: 24)
                    // Zone
                    RoundedRectangle(cornerRadius: 6)
                        .fill(gateHitFlash ? Color.green.opacity(0.7) : Color.yellow.opacity(0.35))
                        .frame(width: zoneW * 2, height: 24)
                        .position(x: cx, y: h/2)
                    // Zone borders
                    Rectangle().fill(Color.yellow.opacity(0.8)).frame(width: 3, height: 32)
                        .position(x: cx - zoneW, y: h/2)
                    Rectangle().fill(Color.yellow.opacity(0.8)).frame(width: 3, height: 32)
                        .position(x: cx + zoneW, y: h/2)
                    // Ball
                    Circle()
                        .fill(gateMissFlash ? Color.red : gateHitFlash ? Color.green : Color.white)
                        .frame(width: 36, height: 36)
                        .shadow(color: .white, radius: 8)
                        .position(x: ballX, y: h/2)
                }
                .frame(width: w, height: h)
            }
            .frame(height: 60).padding(.horizontal, 16)

            HStack {
                Text("Zone: \(Int(gateZone * 100))%").font(.caption).foregroundColor(.gray)
                Spacer()
                Text("Hits: \(gateHits)").font(.caption).foregroundColor(.gray)
            }.padding(.horizontal, 32)

            Button(action: tapTimingGate) {
                ZStack {
                    Circle().fill(gateHitFlash ? Color.green : gateMissFlash ? Color.red : challenge.color)
                        .frame(width: 110, height: 110)
                        .shadow(color: challenge.color.opacity(0.6), radius: 16)
                    Text("TAP").font(.system(size: 24, weight: .heavy)).foregroundColor(.white)
                }
            }
            .disabled(gateCooldown)
            Spacer()
        }
    }

    // =========================================================================
    // MARK: - 9. FLASH MATCH
    // =========================================================================
    let matchSymbols = ["circle.fill","square.fill","triangle.fill","star.fill","diamond.fill","heart.fill"]
    let matchColorOptions: [Color] = [.red, .blue, .green, .orange, .purple, .pink]

    func initFlashMatch() {
        matchPhase = .showingA; matchUserAnswered = false
        advanceMatchPhase()
    }

    func advanceMatchPhase() {
        matchPhaseTimer?.invalidate()
        switch matchPhase {
        case .showingA:
            let sym = matchSymbols.randomElement()!
            let col = matchColorOptions.randomElement()!
            matchCardA = MatchCard(symbol: sym, color: col)
            matchPhaseTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
                Task { @MainActor in self.matchPhase = .showingB; self.advanceMatchPhase() }
            }
        case .showingB:
            // 50% chance of matching
            let isMatch = Double.random(in: 0...1) < 0.5
            if isMatch {
                matchCardB = MatchCard(symbol: matchCardA.symbol, color: matchCardA.color, matches: true)
            } else {
                var sym = matchSymbols.randomElement()!; var col = matchColorOptions.randomElement()!
                // Ensure at least one attribute differs
                while sym == matchCardA.symbol && col == matchCardA.color {
                    sym = matchSymbols.randomElement()!; col = matchColorOptions.randomElement()!
                }
                matchCardB = MatchCard(symbol: sym, color: col, matches: false)
            }
            matchIsMatch = isMatch; matchUserAnswered = false
            matchPhase = .deciding
            matchPhaseTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
                Task { @MainActor in
                    if !self.matchUserAnswered { self.resolveMatch(userSaidMatch: false) }
                }
            }
        case .deciding, .result:
            break
        }
    }

    func resolveMatch(userSaidMatch: Bool) {
        guard !matchUserAnswered else { return }
        matchUserAnswered = true; matchPhaseTimer?.invalidate()
        let correct = userSaidMatch == matchIsMatch
        if correct {
            let pts = userSaidMatch ? 30 : 15
            score += pts; combo += 1
            matchFeedback = correct ? (userSaidMatch ? "MATCH +\(pts)" : "DIFFERENT +\(pts)") : "WRONG"
            matchFeedbackColor = .green
            HapticManager.shared.success()
        } else {
            score = max(0, score - 20); combo = 0
            matchFeedback = matchIsMatch ? "IT WAS A MATCH!" : "THEY WERE DIFFERENT!"
            matchFeedbackColor = .red
            HapticManager.shared.error(); SoundManager.shared.playFail()
        }
        matchFeedbackOpacity = 1; matchPhase = .result
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) { matchFeedbackOpacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.matchPhase = .showingA; self.advanceMatchPhase()
        }
    }

    var flashMatchView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("SAME SYMBOL & COLOR = TAP MATCH")
                .font(.caption.weight(.bold)).foregroundColor(.gray)
            HStack(spacing: 20) {
                // Card A
                matchCardDisplay(matchCardA, visible: true,
                                 label: "First")
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 32)).foregroundColor(.gray)
                // Card B
                matchCardDisplay(matchCardB, visible: matchPhase == .deciding || matchPhase == .result,
                                 label: "Second")
            }

            Text(matchFeedback).font(.title2.bold()).foregroundColor(matchFeedbackColor)
                .opacity(matchFeedbackOpacity)

            // Buttons
            if matchPhase == .deciding {
                HStack(spacing: 16) {
                    Button(action: { resolveMatch(userSaidMatch: true) }) {
                        Label("MATCH", systemImage: "checkmark.circle.fill")
                            .font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.green).cornerRadius(14)
                    }
                    Button(action: { resolveMatch(userSaidMatch: false) }) {
                        Label("DIFFERENT", systemImage: "xmark.circle.fill")
                            .font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.red).cornerRadius(14)
                    }
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }

    @ViewBuilder
    func matchCardDisplay(_ card: MatchCard, visible: Bool, label: String) -> some View {
        VStack(spacing: 8) {
            Text(label).font(.caption).foregroundColor(.gray)
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(visible ? card.color.opacity(0.25) : Color.white.opacity(0.05))
                    .frame(width: 110, height: 110)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(visible ? card.color.opacity(0.6) : Color.gray.opacity(0.2), lineWidth: 2))
                if visible {
                    Image(systemName: card.symbol).font(.system(size: 44)).foregroundColor(card.color)
                } else {
                    Image(systemName: "questionmark").font(.system(size: 36)).foregroundColor(.gray.opacity(0.4))
                }
            }
        }
        .animation(.easeIn(duration: 0.2), value: visible)
    }

    // =========================================================================
    // MARK: - 10. BREATH BALLOON
    // =========================================================================
    func initBreathBalloon() {
        balloonPhase = .inhale; balloonPhaseTime = 0; balloonIsPressed = false
        balloonSize = 0.35; balloonSyncScore = 0
    }

    func updateBreathBalloon() {
        let inhaleDur = 4.0; let exhaleDur = 4.0
        balloonPhaseTime += 0.05
        // Animate balloon
        let t = balloonPhaseTime / (balloonPhase == .inhale ? inhaleDur : exhaleDur)
        if balloonPhase == .inhale {
            balloonSize = 0.35 + min(t, 1.0) * 0.55
        } else {
            balloonSize = 0.9 - min(t, 1.0) * 0.55
        }
        // Score sync
        let wantsPress = (balloonPhase == .inhale)
        if wantsPress == balloonIsPressed {
            score += 1; balloonSyncScore = min(balloonSyncScore + 0.05, 100)
        }
        // Advance phase
        let dur = balloonPhase == .inhale ? inhaleDur : exhaleDur
        if balloonPhaseTime >= dur {
            balloonPhaseTime = 0
            balloonPhase = balloonPhase == .inhale ? .exhale : .inhale
            HapticManager.shared.lightTap()
        }
    }

    var breathBalloonView: some View {
        VStack(spacing: 0) {
            Spacer()
            Text(balloonPhase == .inhale ? "BREATHE IN" : "BREATHE OUT")
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(balloonPhase == .inhale ? .cyan : .green)
            Text(balloonPhase == .inhale ? "Hold the screen" : "Release the screen")
                .font(.subheadline).foregroundColor(.gray).padding(.top, 4)
            Spacer()
            // Balloon
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: balloonPhase == .inhale ? [.cyan.opacity(0.6), .blue.opacity(0.4)] : [.green.opacity(0.6), .teal.opacity(0.4)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80 + CGFloat(balloonSize) * 200, height: 80 + CGFloat(balloonSize) * 200)
                    .shadow(color: balloonPhase == .inhale ? .cyan.opacity(0.5) : .green.opacity(0.5), radius: 24)
                Text(balloonPhase == .inhale ? "IN" : "OUT")
                    .font(.system(size: 22, weight: .bold)).foregroundColor(.white.opacity(0.8))
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in balloonIsPressed = true }
                .onEnded   { _ in balloonIsPressed = false })
            Spacer()
            // Sync bar
            VStack(spacing: 6) {
                Text("Sync: \(Int(balloonSyncScore))%").font(.caption).foregroundColor(.gray)
                ProgressView(value: balloonSyncScore / 100).tint(.cyan).frame(maxWidth: 220)
            }
            .padding(.bottom, 24)
        }
    }

    // =========================================================================
    // MARK: - 11. BOX MASTER
    // =========================================================================
    func initBoxMaster() {
        boxPhase = .inhale; boxPhaseTime = 0; boxDotProgress = 0
        boxCompletedCycles = 0; boxNearCorner = false; boxCornerTapped = false
    }

    func updateBoxMaster() {
        let dur = boxPhaseDurations[boxPhase.rawValue]
        boxPhaseTime += 0.05
        // Dot progress: each phase occupies 0.25 of the path
        let phaseStart = Double(boxPhase.rawValue) * 0.25
        boxDotProgress = phaseStart + (boxPhaseTime / dur) * 0.25
        // Near corner at phase end
        let progress = boxPhaseTime / dur
        boxNearCorner = progress > 0.85
        // Advance phase
        if boxPhaseTime >= dur {
            boxPhaseTime = 0; boxCornerTapped = false
            let next = BoxBreathPhase(rawValue: (boxPhase.rawValue + 1) % 4) ?? .inhale
            if next == .inhale { boxCompletedCycles += 1; score += 80; SoundManager.shared.playLevelUp() }
            boxPhase = next
            HapticManager.shared.lightTap()
        }
    }

    func tapBoxCorner() {
        guard boxNearCorner && !boxCornerTapped else { return }
        boxCornerTapped = true
        let timing = boxPhaseTime / boxPhaseDurations[boxPhase.rawValue]
        let precision = 1.0 - abs(timing - 1.0)
        let pts = Int(25 * max(0, precision))
        score += pts; combo += 1
        HapticManager.shared.success()
    }

    var boxMasterView: some View {
        VStack(spacing: 12) {
            Spacer()
            Text(boxPhase.label).font(.system(size: 32, weight: .heavy))
                .foregroundColor(boxPhase.color)
            Text("Tap when dot reaches each corner")
                .font(.caption).foregroundColor(.gray)
            Text("Cycles: \(boxCompletedCycles)").font(.subheadline).foregroundColor(.white)

            // Box with dot
            GeometryReader { geo in
                let side: CGFloat = min(geo.size.width, geo.size.height) * 0.78
                let ox = (geo.size.width - side) / 2
                let oy = (geo.size.height - side) / 2
                // Dot position: 0=top-left, 0.25=top-right, 0.5=bottom-right, 0.75=bottom-left
                let dot = dotPosition(progress: boxDotProgress, ox: ox, oy: oy, side: side)
                ZStack {
                    // Box
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.15), lineWidth: 3)
                        .frame(width: side, height: side)
                        .position(x: geo.size.width/2, y: geo.size.height/2)
                    // Phase color fill on sides
                    Path { path in
                        let corners = [
                            CGPoint(x: ox, y: oy),
                            CGPoint(x: ox+side, y: oy),
                            CGPoint(x: ox+side, y: oy+side),
                            CGPoint(x: ox, y: oy+side)
                        ]
                        let p = boxPhase.rawValue
                        path.move(to: corners[p])
                        path.addLine(to: corners[(p+1)%4])
                    }
                    .stroke(boxPhase.color, lineWidth: 5)
                    // Corner circles
                    ForEach(0..<4, id: \.self) { ci in
                        let corners = [CGPoint(x:ox,y:oy),CGPoint(x:ox+side,y:oy),CGPoint(x:ox+side,y:oy+side),CGPoint(x:ox,y:oy+side)]
                        Circle().fill(ci == boxPhase.rawValue && boxNearCorner ? boxPhase.color : Color.white.opacity(0.2))
                            .frame(width: 18, height: 18).position(corners[ci])
                    }
                    // Phase labels on sides
                    let phaseLabels = ["Inhale","Hold","Exhale","Hold"]
                    let labelPos = [CGPoint(x:geo.size.width/2,y:oy-20),CGPoint(x:ox+side+28,y:geo.size.height/2),
                                    CGPoint(x:geo.size.width/2,y:oy+side+20),CGPoint(x:ox-28,y:geo.size.height/2)]
                    ForEach(0..<4, id: \.self) { pi in
                        Text(phaseLabels[pi]).font(.caption2).foregroundColor(pi == boxPhase.rawValue ? boxPhase.color : .gray.opacity(0.5))
                            .position(labelPos[pi])
                    }
                    // Moving dot
                    Circle().fill(boxPhase.color).frame(width: 24, height: 24)
                        .shadow(color: boxPhase.color, radius: 8).position(dot)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(height: 280)

            Button(action: tapBoxCorner) {
                Text(boxNearCorner ? "TAP! Confirm Turn" : "Wait for corner...")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(boxNearCorner ? boxPhase.color : Color.white.opacity(0.08))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24).disabled(!boxNearCorner || boxCornerTapped)
            Spacer()
        }
    }

    func dotPosition(progress: Double, ox: CGFloat, oy: CGFloat, side: CGFloat) -> CGPoint {
        let p = progress.truncatingRemainder(dividingBy: 1.0)
        let t = p * 4  // 0-4
        if t < 1 { return CGPoint(x: ox + CGFloat(t) * side, y: oy) }             // top: left→right
        if t < 2 { return CGPoint(x: ox + side, y: oy + CGFloat(t-1) * side) }   // right: top→bottom
        if t < 3 { return CGPoint(x: ox + side - CGFloat(t-2) * side, y: oy + side) } // bottom: right→left
        return CGPoint(x: ox, y: oy + side - CGFloat(t-3) * side)                // left: bottom→top
    }

    // =========================================================================
    // MARK: - 12. RELAX & RELEASE (4-7-8)
    // =========================================================================
    func initRelaxRelease() {
        rlxPhase = 0; rlxPhaseTime = 0; rlxCycles = 0
        rlxNeedsConfirm = false; rlxRingProgress = 0
    }

    func updateRelaxRelease() {
        let dur = rlxPhaseDurations[rlxPhase]
        rlxPhaseTime += 0.05
        rlxRingProgress = rlxPhaseTime / dur
        if rlxPhaseTime >= dur {
            rlxNeedsConfirm = true
        }
    }

    func confirmRlxPhase() {
        guard rlxNeedsConfirm else { return }
        let lateness = max(0, rlxPhaseTime - rlxPhaseDurations[rlxPhase])
        let pts = max(5, 30 - Int(lateness * 8))
        score += pts; combo += 1
        rlxNeedsConfirm = false; rlxPhaseTime = 0; rlxRingProgress = 0
        rlxConfirmFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.rlxConfirmFlash = false }
        let nextPhase = (rlxPhase + 1) % 3
        if nextPhase == 0 {
            rlxCycles += 1
            if rlxCycles >= 3 { score += 200; endChallenge(); return }
            SoundManager.shared.playLevelUp()
        }
        rlxPhase = nextPhase
        HapticManager.shared.lightTap()
    }

    var relaxReleaseView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("4-7-8 BREATHING").font(.caption.weight(.bold)).foregroundColor(.gray)
            Text(rlxPhaseNames[rlxPhase]).font(.system(size: 34, weight: .heavy))
                .foregroundColor(rlxPhaseColors[rlxPhase])
            Text("\(Int(rlxPhaseDurations[rlxPhase]))s phase")
                .font(.subheadline).foregroundColor(.gray)

            // Ring
            ZStack {
                Circle().stroke(Color.white.opacity(0.1), lineWidth: 16).frame(width: 200, height: 200)
                Circle().trim(from: 0, to: CGFloat(min(rlxRingProgress, 1.0)))
                    .stroke(rlxPhaseColors[rlxPhase], style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 200, height: 200).rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.05), value: rlxRingProgress)
                VStack(spacing: 4) {
                    Text("\(max(0, Int(rlxPhaseDurations[rlxPhase] - rlxPhaseTime) + 1))")
                        .font(.system(size: 52, weight: .heavy)).foregroundColor(.white)
                    Text("seconds").font(.caption).foregroundColor(.gray)
                }
            }

            Text("Cycles: \(rlxCycles) / 3").font(.subheadline).foregroundColor(.white)

            Button(action: confirmRlxPhase) {
                Text(rlxNeedsConfirm ? "CONFIRM →" : "Waiting…")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(rlxNeedsConfirm ? rlxPhaseColors[rlxPhase] : Color.white.opacity(0.08))
                    .cornerRadius(14).scaleEffect(rlxConfirmFlash ? 1.05 : 1.0)
            }
            .padding(.horizontal, 24).disabled(!rlxNeedsConfirm)
            .animation(.spring(response: 0.2), value: rlxConfirmFlash)
            Spacer()
        }
    }

    // =========================================================================
    // MARK: - 13. NOTIFICATION WALL
    // =========================================================================
    let wallFakeTitles = [
        ("Instagram", "New reel just for you!"),
        ("Twitter", "Trending in your area"),
        ("TikTok", "You have 47 new followers"),
        ("Email", "URGENT: Claim your reward"),
        ("News", "Breaking: You won't believe this"),
        ("YouTube", "New video from someone you follow"),
        ("Facebook", "12 people reacted to your post"),
        ("Reddit", "Hot thread: Check it out"),
    ]
    let wallRealTitle = ("FocusFlow", "COLLECT YOUR FOCUS REWARD!")

    func initNotificationWall() {
        wallNotifs = []
        wallSpawnTimer = Timer.scheduledTimer(withTimeInterval: wallSpawnInterval, repeats: true) { _ in
            Task { @MainActor in self.spawnWallNotif() }
        }
    }

    func spawnWallNotif() {
        guard isActive else { return }
        // Every ~6th notification is real
        let isReal = Int.random(in: 0...5) == 0
        let notif: WallNotif
        if isReal {
            notif = WallNotif(title: wallRealTitle.0, subtitle: wallRealTitle.1, isReal: true)
        } else {
            let t = wallFakeTitles.randomElement()!
            notif = WallNotif(title: t.0, subtitle: t.1, isReal: false)
        }
        wallNotifs.append(notif)
        // Auto-expire after 4s
        let notifId = notif.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            if let i = self.wallNotifs.firstIndex(where: { $0.id == notifId && !$0.dismissed }) {
                if self.wallNotifs[i].isReal {
                    // Missed real target
                    self.score = max(0, self.score - 20)
                }
                self.wallNotifs.remove(at: i)
            }
        }
        // Keep max 4 on screen
        if wallNotifs.count > 4 { wallNotifs.removeFirst() }
    }

    func dismissWallNotif(id: UUID, tapContent: Bool) {
        guard let i = wallNotifs.firstIndex(where: { $0.id == id }) else { return }
        let notif = wallNotifs[i]
        wallNotifs[i].dismissed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.wallNotifs.removeAll { $0.id == id }
        }
        if notif.isReal {
            if tapContent {
                score += 50; combo += 1
                HapticManager.shared.success(); SoundManager.shared.playSuccess()
            } else {
                // Dismissed real one
                score = max(0, score - 10)
                HapticManager.shared.error()
            }
        } else {
            if tapContent {
                // Fell for fake
                score = max(0, score - 20); combo = 0; lives -= 1
                HapticManager.shared.error(); SoundManager.shared.playFail()
            } else {
                // Correctly dismissed fake
                score += 10; combo += 1
                HapticManager.shared.lightTap()
            }
        }
    }

    var notificationWallView: some View {
        VStack(spacing: 0) {
            Text("DISMISS FAKES (✕) • TAP REAL ONES (green)")
                .font(.caption.weight(.bold)).foregroundColor(.gray)
                .padding(.top, 8)
            Spacer()
            VStack(spacing: 10) {
                ForEach(wallNotifs) { notif in
                    wallNotifBanner(notif)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35), value: wallNotifs.map(\.id))
            Spacer()
            Text("Lives lost tapping fake content").font(.caption2).foregroundColor(.gray.opacity(0.5))
                .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    func wallNotifBanner(_ notif: WallNotif) -> some View {
        HStack(spacing: 12) {
            // App icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(notif.isReal ? Color.green.opacity(0.3) : Color.white.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: notif.isReal ? "star.fill" : "app.fill")
                    .font(.system(size: 20))
                    .foregroundColor(notif.isReal ? .green : .gray)
            }
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(notif.title).font(.caption.weight(.bold))
                    .foregroundColor(notif.isReal ? .green : .white)
                Text(notif.subtitle).font(.caption2).foregroundColor(.gray).lineLimit(1)
            }
            Spacer()
            // Dismiss X
            Button(action: { dismissWallNotif(id: notif.id, tapContent: false) }) {
                Image(systemName: "xmark.circle.fill").font(.system(size: 22)).foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "1E293B"))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .stroke(notif.isReal ? Color.green.opacity(0.7) : Color.white.opacity(0.07), lineWidth: notif.isReal ? 2 : 1))
        )
        .contentShape(Rectangle())
        .onTapGesture { dismissWallNotif(id: notif.id, tapContent: true) }
        .padding(.horizontal, 16)
        .opacity(notif.dismissed ? 0 : 1)
    }

    // =========================================================================
    // MARK: - 14. GREEN LIGHT ONLY
    // =========================================================================
    func initGreenLightOnly() {
        glCircles = []; glLastGreenPos = CGPoint(x: 200, y: 350)
        glSpawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in self.spawnGLCircle() }
        }
    }

    func updateGreenLightOnly() {
        // Spawn/fade handled by spawnGLCircle dispatch timers
    }

    func spawnGLCircle() {
        guard isActive else { return }
        // Remove old faded circles
        glCircles.removeAll { $0.tapped }

        let isGreen = Double.random(in: 0...1) < 0.6
        var pos: CGPoint
        if !isGreen {
            // Red spawns near last green pos (to tempt)
            let jitter = CGFloat.random(in: -40...40)
            pos = CGPoint(x: glLastGreenPos.x + jitter, y: glLastGreenPos.y + jitter)
            pos.x = max(50, min(330, pos.x)); pos.y = max(140, min(600, pos.y))
        } else {
            pos = CGPoint(x: CGFloat.random(in: 50...330), y: CGFloat.random(in: 140...600))
        }

        let circle = GLCircle(isGreen: isGreen, position: pos)
        glCircles.append(circle)
        let cid = circle.id
        if isGreen { glLastGreenPos = pos }

        // Animate in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let i = self.glCircles.firstIndex(where: { $0.id == cid }) {
                self.glCircles[i].scale = 1; self.glCircles[i].opacity = 1
            }
        }

        // Auto-expire after 1.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let i = self.glCircles.firstIndex(where: { $0.id == cid && !$0.tapped }) {
                if self.glCircles[i].isGreen {
                    self.score = max(0, self.score - 5)
                }
                withAnimation(.easeOut(duration: 0.2)) { self.glCircles[i].opacity = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.glCircles.removeAll { $0.id == cid }
                }
            }
        }
    }

    func tapGLCircle(id: UUID) {
        guard let i = glCircles.firstIndex(where: { $0.id == id }), !glCircles[i].tapped else { return }
        glCircles[i].tapped = true
        let isGreen = glCircles[i].isGreen
        withAnimation(.easeOut(duration: 0.25)) { glCircles[i].scale = 1.4; glCircles[i].opacity = 0 }
        if isGreen {
            score += 20 + combo * 3; combo += 1
            HapticManager.shared.success()
        } else {
            score = max(0, score - 15); combo = 0; lives -= 1
            HapticManager.shared.error(); SoundManager.shared.playFail()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.glCircles.removeAll { $0.id == id }
        }
    }

    var greenLightOnlyView: some View {
        GeometryReader { geo in
            ZStack {
                Text("TAP GREEN  |  AVOID RED")
                    .font(.caption.weight(.bold)).foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top, 8)

                ForEach(glCircles) { c in
                    ZStack {
                        Circle().fill(c.isGreen ? Color.green.opacity(0.85) : Color.red.opacity(0.85))
                            .frame(width: 80, height: 80)
                            .shadow(color: c.isGreen ? .green : .red, radius: 14)
                        Image(systemName: c.isGreen ? "checkmark" : "xmark")
                            .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                    }
                    .scaleEffect(c.scale).opacity(c.opacity)
                    .position(c.position)
                    .onTapGesture { tapGLCircle(id: c.id) }
                    .animation(.spring(response: 0.2), value: c.scale)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // =========================================================================
    // MARK: - 15. IMPULSE FORTRESS
    // =========================================================================
    func initImpulseFortress() {
        fortressSafeButtons = []; fortressBigScale = 1; fortressBigTaps = 0
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            fortressBigPulse = true
        }
        fortressSpawnTimer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { _ in
            Task { @MainActor in self.spawnFortressSafeButton() }
        }
    }

    func spawnFortressSafeButton() {
        guard isActive else { return }
        // Place safe button around the edge of screen
        let angle = Double.random(in: 0...360) * .pi / 180
        let radius: CGFloat = 155
        let cx: CGFloat = 200; let cy: CGFloat = 380
        let pos = CGPoint(x: cx + cos(angle) * radius, y: cy + sin(angle) * radius)
        let btn = SafeButton(position: pos)
        fortressSafeButtons.append(btn)
        let bid = btn.id
        // Animate in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let i = self.fortressSafeButtons.firstIndex(where: { $0.id == bid }) {
                self.fortressSafeButtons[i].opacity = 1
            }
        }
        // Auto-expire after 1.8s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.fortressSafeButtons.removeAll { $0.id == bid }
        }
    }

    func tapFortressSafe(id: UUID) {
        guard let i = fortressSafeButtons.firstIndex(where: { $0.id == id }) else { return }
        fortressSafeButtons[i].visible = false
        score += 30; combo += 1
        HapticManager.shared.success(); SoundManager.shared.playSuccess()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.fortressSafeButtons.removeAll { $0.id == id }
        }
    }

    func tapFortressBigButton() {
        fortressBigTaps += 1; combo = 0
        score = max(0, score - 50); lives -= 1
        HapticManager.shared.heavyTap(); SoundManager.shared.playFail()
        // Shake animation
        withAnimation(.interpolatingSpring(stiffness: 800, damping: 10)) { fortressBigScale = 0.85 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring()) { self.fortressBigScale = 1.0 }
        }
    }

    var impulseFortressView: some View {
        GeometryReader { geo in
            ZStack {
                // Big DON'T TAP button
                Button(action: tapFortressBigButton) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.red.opacity(0.8), .red.opacity(0.4)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: fortressBigPulse ? 230 : 210, height: fortressBigPulse ? 230 : 210)
                            .shadow(color: .red.opacity(0.6), radius: fortressBigPulse ? 28 : 16)
                        VStack(spacing: 8) {
                            Image(systemName: "hand.raised.slash.fill")
                                .font(.system(size: 36)).foregroundColor(.white.opacity(0.8))
                            Text("DO NOT TAP").font(.system(size: 16, weight: .heavy))
                                .foregroundColor(.white.opacity(0.9))
                            Text("-50 PTS").font(.caption2).foregroundColor(.red.opacity(0.8))
                        }
                    }
                }
                .scaleEffect(fortressBigScale)
                .position(x: geo.size.width/2, y: geo.size.height/2)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: fortressBigPulse)

                // Safe buttons
                ForEach(fortressSafeButtons) { btn in
                    Button(action: { tapFortressSafe(id: btn.id) }) {
                        ZStack {
                            Circle().fill(Color.green.opacity(0.9))
                                .frame(width: 62, height: 62)
                                .shadow(color: .green, radius: 10)
                            VStack(spacing: 1) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18)).foregroundColor(.white)
                                Text("+30").font(.caption2.weight(.bold)).foregroundColor(.white)
                            }
                        }
                    }
                    .opacity(btn.opacity)
                    .position(btn.position)
                    .animation(.easeIn(duration: 0.2), value: btn.opacity)
                }

                // Instructions top
                VStack(spacing: 4) {
                    Text("TAP THE GREEN BUTTONS").font(.caption.weight(.bold)).foregroundColor(.green)
                    Text("Resist the big button!").font(.caption2).foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top, 8)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // =========================================================================
    // MARK: - 16. PERIPHERAL SCAN
    // =========================================================================
    func initPeripheralScan() {
        scanTarget = HuntShapeType.allCases.randomElement()!
        scanItems = []
        scanTargetAge = 0
        scanSpawnTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            Task { @MainActor in self.spawnScanItem() }
        }
    }

    func spawnScanItem() {
        guard isActive else { return }
        // Spawn 2-3 items: 1 target (sometimes) + distractors at edge positions
        let edgePositions: [CGPoint] = [
            CGPoint(x: 40, y: Double.random(in: 120...600)),
            CGPoint(x: 340, y: Double.random(in: 120...600)),
            CGPoint(x: Double.random(in: 60...320), y: 130),
            CGPoint(x: Double.random(in: 60...320), y: 620)
        ]
        let spawnCount = Int.random(in: 2...3)
        var hasTarget = Bool.random()
        for i in 0..<min(spawnCount, edgePositions.count) {
            let isTarget = hasTarget && i == 0
            let type = isTarget ? scanTarget : HuntShapeType.allCases.filter { $0 != scanTarget }.randomElement()!
            scanItems.append(ScanItem(type: type, position: edgePositions[i], isTarget: isTarget))
            if isTarget { hasTarget = false }
        }
        // Age out old items
        for i in scanItems.indices.reversed() {
            if scanItems[i].age > 1.2 { scanItems.remove(at: i) }
        }
    }

    func updatePeripheralScan() {
        scanTargetAge += 0.05
        if scanTargetAge > 10 {
            scanTarget = HuntShapeType.allCases.randomElement()!
            scanTargetAge = 0
        }
        for i in scanItems.indices {
            scanItems[i].age += 0.05
            if scanItems[i].age > 1.0 {
                scanItems[i].opacity = max(0, 1.0 - (scanItems[i].age - 1.0) * 5)
            }
        }
        scanItems.removeAll { $0.age > 1.4 }
    }

    func tapScanItem(_ item: ScanItem) {
        guard isActive else { return }
        if item.isTarget || item.type == scanTarget {
            score += 30 + combo * 5; combo += 1
            SoundManager.shared.playSuccess(); HapticManager.shared.success()
        } else {
            lives = max(0, lives - 1); combo = 0
            SoundManager.shared.playFail(); HapticManager.shared.error()
        }
        scanItems.removeAll { $0.id == item.id }
    }

    var peripheralScanView: some View {
        ZStack {
            // Center: target display
            VStack(spacing: 8) {
                Text("TAP THE TARGET").font(.caption.weight(.bold)).foregroundColor(.gray)
                Image(systemName: scanTarget.sfSymbol)
                    .font(.system(size: 56))
                    .foregroundColor(scanTarget.color)
                    .background(Circle().fill(Color.white.opacity(0.08)).frame(width: 90, height: 90))
                Text(String(describing: scanTarget).capitalized)
                    .font(.caption).foregroundColor(.white.opacity(0.6))
            }

            // Edge items
            ForEach(scanItems) { item in
                Button { tapScanItem(item) } label: {
                    Image(systemName: item.type.sfSymbol)
                        .font(.system(size: 36))
                        .foregroundColor(item.type.color)
                        .scaleEffect(CGFloat(1.0 - item.age * 0.3))
                        .opacity(item.opacity)
                }
                .position(item.position)
                .animation(.easeOut(duration: 0.15), value: item.age)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // =========================================================================
    // MARK: - 17. SEQUENCE ECHO
    // =========================================================================
    func initSequenceEcho() {
        echoRound = 1
        echoSequence = []
        echoInput = []
        echoPhase = .showing
        echoFlashIndex = -1
        startEchoRound()
    }

    func startEchoRound() {
        echoSequence.append(Int.random(in: 0..<6))
        echoInput = []
        echoPhase = .showing
        playEchoSequence()
    }

    func playEchoSequence() {
        echoFlashIndex = -1
        var delay = 0.5
        for i in echoSequence.indices {
            let idx = echoSequence[i]
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.echoFlashIndex = idx
            }
            delay += 0.6
            DispatchQueue.main.asyncAfter(deadline: .now() + delay - 0.15) {
                self.echoFlashIndex = -1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.1) {
            self.echoPhase = .inputting
        }
    }

    func tapEchoPad(_ index: Int) {
        guard echoPhase == .inputting, isActive else { return }
        HapticManager.shared.lightTap()
        echoFlashIndex = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.echoFlashIndex = -1 }
        echoInput.append(index)
        let pos = echoInput.count - 1
        if echoInput[pos] != echoSequence[pos] {
            // Wrong
            lives = max(0, lives - 1); combo = 0
            SoundManager.shared.playFail(); HapticManager.shared.error()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.echoInput = []
                self.echoPhase = .showing
                self.playEchoSequence()
            }
            return
        }
        if echoInput.count == echoSequence.count {
            // Complete round
            let pts = echoSequence.count * 20
            score += pts; combo += 1
            SoundManager.shared.playLevelUp(); HapticManager.shared.success()
            echoRound += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.startEchoRound()
            }
        }
    }

    var sequenceEchoView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(echoPhase == .showing ? "WATCH THE SEQUENCE" : "REPEAT THE SEQUENCE")
                .font(.caption.weight(.bold))
                .foregroundColor(echoPhase == .showing ? .yellow : .green)
            Text("Round \(echoRound) • Length \(echoSequence.count)")
                .font(.subheadline).foregroundColor(.white.opacity(0.7))

            // 2×3 grid of pads
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(0..<6, id: \.self) { i in
                    Button { tapEchoPad(i) } label: {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(echoPadColors[i].opacity(echoFlashIndex == i ? 1.0 : 0.25))
                            .frame(height: 80)
                            .overlay(
                                Image(systemName: ["circle.fill","square.fill","triangle.fill","star.fill","diamond.fill","heart.fill"][i])
                                    .font(.title2).foregroundColor(.white)
                            )
                            .scaleEffect(echoFlashIndex == i ? 1.08 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: echoFlashIndex)
                    }
                    .disabled(echoPhase == .showing)
                }
            }
            .padding(.horizontal, 8)
            Spacer()
        }
    }

    // =========================================================================
    // MARK: - 18. REFLEX TAP
    // =========================================================================
    func initReflexTap() {
        reflexTargets = []
        reflexHits = 0
        reflexInterval = 1.8
        spawnReflexTarget()
        reflexSpawnTimer = Timer.scheduledTimer(withTimeInterval: reflexInterval, repeats: true) { _ in
            Task { @MainActor in
                self.reflexInterval = max(0.8, self.reflexInterval - 0.04)
                self.spawnReflexTarget()
            }
        }
    }

    func spawnReflexTarget() {
        guard isActive else { return }
        let target = ReflexTarget(
            position: CGPoint(x: Double.random(in: 60...320), y: Double.random(in: 120...560))
        )
        reflexTargets.append(target)
        // Animate in
        if let idx = reflexTargets.indices.last {
            withAnimation(.spring(response: 0.25)) {
                reflexTargets[idx].opacity = 1
                reflexTargets[idx].scale = 1.0
            }
        }
    }

    func updateReflexTap() {
        for i in reflexTargets.indices.reversed() {
            reflexTargets[i].age += 0.05
            if reflexTargets[i].age > 1.2 {
                // Miss
                lives = max(0, lives - 1); combo = 0
                HapticManager.shared.error()
                reflexTargets.remove(at: i)
            }
        }
    }

    func tapReflexTarget(_ target: ReflexTarget) {
        guard isActive else { return }
        guard let idx = reflexTargets.firstIndex(where: { $0.id == target.id }) else { return }
        let speedBonus = max(0, Int((1.2 - target.age) * 30))
        score += 25 + speedBonus; combo += 1; reflexHits += 1
        SoundManager.shared.playSuccess(); HapticManager.shared.success()
        reflexTargets.remove(at: idx)
    }

    var reflexTapView: some View {
        ZStack {
            VStack {
                Text("TAP FAST!").font(.caption.weight(.bold)).foregroundColor(.orange)
                Text("Hits: \(reflexHits)").font(.subheadline).foregroundColor(.white.opacity(0.7))
                Spacer()
            }
            .padding(.top, 8)

            ForEach(reflexTargets) { target in
                Button { tapReflexTarget(target) } label: {
                    ZStack {
                        Circle().fill(Color.orange.opacity(0.2)).frame(width: 72, height: 72)
                        Circle().stroke(Color.orange, lineWidth: 3).frame(width: 72, height: 72)
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 28)).foregroundColor(.orange)
                    }
                    .scaleEffect(target.scale)
                    .opacity(target.age > 0.9 ? max(0, 1.0 - (target.age - 0.9) * 5) : target.opacity)
                }
                .position(target.position)
                .animation(.spring(response: 0.25), value: target.scale)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // =========================================================================
    // MARK: - 19. 4-7-8 MASTER
    // =========================================================================
    func initFourSevenEight() {
        fsbPhase = .inhale; fsbPhaseTime = 0; fsbCycles = 0
        fsbRingProgress = 0; fsbNeedsConfirm = false; fsbConfirmFlash = false
    }

    func updateFourSevenEight() {
        let dur = fsbPhase.duration
        fsbPhaseTime += 0.05
        fsbRingProgress = fsbPhaseTime / dur
        if fsbPhaseTime >= dur { fsbNeedsConfirm = true }
    }

    func confirmFsbPhase() {
        guard fsbNeedsConfirm else { return }
        let lateness = max(0, fsbPhaseTime - fsbPhase.duration)
        let pts = max(5, 35 - Int(lateness * 8))
        score += pts; combo += 1
        SoundManager.shared.playSuccess(); HapticManager.shared.lightTap()
        fsbNeedsConfirm = false; fsbPhaseTime = 0; fsbRingProgress = 0
        fsbConfirmFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.fsbConfirmFlash = false }
        let nextRaw = (fsbPhase.rawValue + 1) % 3
        if nextRaw == 0 {
            fsbCycles += 1
            if fsbCycles >= 3 { score += 150; endChallenge(); return }
            SoundManager.shared.playLevelUp()
        }
        fsbPhase = FourSevenEightPhase(rawValue: nextRaw)!
    }

    var fourSevenEightView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("4-7-8 BREATHING").font(.caption.weight(.bold)).foregroundColor(.gray)
            Text(fsbPhase.label).font(.system(size: 34, weight: .heavy)).foregroundColor(fsbPhase.color)
            Text("\(Int(fsbPhase.duration))s").font(.subheadline).foregroundColor(.gray)

            ZStack {
                Circle().stroke(Color.white.opacity(0.1), lineWidth: 16).frame(width: 200, height: 200)
                Circle().trim(from: 0, to: CGFloat(min(fsbRingProgress, 1.0)))
                    .stroke(fsbPhase.color, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 200, height: 200).rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.05), value: fsbRingProgress)
                VStack(spacing: 4) {
                    Text("\(max(0, Int(fsbPhase.duration - fsbPhaseTime) + 1))")
                        .font(.system(size: 48, weight: .heavy)).foregroundColor(.white)
                    Text("seconds").font(.caption).foregroundColor(.gray)
                }
            }

            Text("Cycle \(fsbCycles + 1) of 3").font(.subheadline).foregroundColor(.white)

            Button(action: confirmFsbPhase) {
                Text(fsbNeedsConfirm ? "CONFIRM →" : "Waiting…")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(fsbNeedsConfirm ? fsbPhase.color : Color.white.opacity(0.08))
                    .cornerRadius(14).scaleEffect(fsbConfirmFlash ? 1.05 : 1.0)
            }
            .padding(.horizontal, 24).disabled(!fsbNeedsConfirm)
            .animation(.spring(response: 0.2), value: fsbConfirmFlash)
            Spacer()
        }
    }

    // =========================================================================
    // MARK: - 20. TAP DELAY
    // =========================================================================
    func initTapDelay() {
        tdPhase = .waiting; tdBarProgress = 0; tdRound = 0
        tdBarDuration = Double.random(in: 2.5...4.5)
        tdLastScore = ""; tdReactionStart = nil
    }

    func updateTapDelay() {
        switch tdPhase {
        case .waiting:
            tdBarProgress += 0.05 / tdBarDuration
            if tdBarProgress >= 1.0 {
                tdPhase = .ready
                tdReactionStart = Date()
                HapticManager.shared.lightTap()
            }
        case .ready:
            // Count how long since ready - auto-timeout after 2s
            if let start = tdReactionStart, Date().timeIntervalSince(start) > 2.0 {
                tdLastScore = "Too slow! 0 pts"
                nextTapDelayRound()
            }
        case .tapped: break
        }
    }

    func tapDelayButton() {
        guard isActive else { return }
        if tdPhase == .waiting {
            // Early tap - penalize
            lives = max(0, lives - 1); combo = 0
            tdLastScore = "Too early! -1 life"
            SoundManager.shared.playFail(); HapticManager.shared.error()
            nextTapDelayRound()
        } else if tdPhase == .ready {
            guard let start = tdReactionStart else { return }
            let reaction = Date().timeIntervalSince(start)
            let pts = max(10, 100 - Int(reaction * 60))
            score += pts; combo += 1
            tdLastScore = "+\(pts) pts (\(Int(reaction * 1000))ms)"
            SoundManager.shared.playSuccess(); HapticManager.shared.success()
            tdPhase = .tapped
            nextTapDelayRound()
        }
    }

    func nextTapDelayRound() {
        tdRound += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.tdPhase = .waiting
            self.tdBarProgress = 0
            self.tdBarDuration = Double.random(in: 2.5...4.5)
            self.tdReactionStart = nil
        }
    }

    var tapDelayView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("WAIT FOR GREEN").font(.caption.weight(.bold)).foregroundColor(.gray)
            Text("Then tap as fast as possible")
                .font(.subheadline).foregroundColor(.white.opacity(0.6))

            // Bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1))
                    .frame(height: 24)
                RoundedRectangle(cornerRadius: 12)
                    .fill(tdPhase == .ready ? Color.green : Color.red)
                    .frame(width: max(8, UIScreen.main.bounds.width - 64) * CGFloat(min(tdBarProgress, 1.0)), height: 24)
                    .animation(.linear(duration: 0.05), value: tdBarProgress)
            }
            .frame(maxWidth: .infinity).padding(.horizontal, 16)

            if !tdLastScore.isEmpty {
                Text(tdLastScore).font(.subheadline.weight(.semibold))
                    .foregroundColor(tdLastScore.contains("early") ? .red : .green)
            }

            Button(action: tapDelayButton) {
                ZStack {
                    Circle()
                        .fill(tdPhase == .ready ? Color.green : Color.red.opacity(0.3))
                        .frame(width: 140, height: 140)
                    Image(systemName: tdPhase == .ready ? "hand.tap.fill" : "xmark")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .scaleEffect(tdPhase == .ready ? 1.1 : 1.0)
                .animation(.spring(response: 0.3), value: tdPhase == .ready)
            }
            .shadow(color: tdPhase == .ready ? .green : .clear, radius: 20)

            Text("Round \(tdRound + 1)").font(.caption).foregroundColor(.gray)
            Spacer()
        }
    }


    // =========================================================================
    // MARK: - MATH BLITZ
    // =========================================================================
    func initMathBlitz() {
        mbStreak = 0
        nextMathQuestion()
    }

    func nextMathQuestion() {
        let streak = mbStreak
        let ops: [(Int, Int, String, Int)] = generateMathQuestion(streak: streak)
        let (a, b, op, ans) = ops.randomElement() ?? (3, 4, "×", 12)
        mbQuestion = "\(a) \(op) \(b) = ?"
        mbAnswer = ans
        var wrongs = Set<Int>()
        while wrongs.count < 3 {
            let wrong = ans + Int.random(in: -10...10)
            if wrong != ans { wrongs.insert(wrong) }
        }
        mbChoices = (Array(wrongs) + [ans]).shuffled()
        mbPhase = .showing
        mbFlashTimer?.invalidate()
        mbFlashTimer = Timer.scheduledTimer(withTimeInterval: 1.5 - min(Double(streak) * 0.05, 0.8), repeats: false) { _ in
            Task { @MainActor in self.mbPhase = .choosing }
        }
    }

    func generateMathQuestion(streak: Int) -> [(Int, Int, String, Int)] {
        if streak < 4 {
            let a = Int.random(in: 2...9), b = Int.random(in: 2...9)
            return [(a, b, "+", a + b)]
        } else if streak < 8 {
            let a = Int.random(in: 3...12), b = Int.random(in: 3...12)
            return [(a, b, "×", a * b)]
        } else {
            let a = Int.random(in: 5...20), b = Int.random(in: 2...9)
            return [(a, b, "×", a * b)]
        }
    }

    func answerMath(_ choice: Int) {
        guard mbPhase == .choosing else { return }
        if choice == mbAnswer {
            mbStreak += 1
            let pts = 10 + mbStreak * 5
            score += pts
            mbFeedback = "+\(pts)"; mbFeedbackColor = .green
            HapticManager.shared.success(); SoundManager.shared.playSuccess()
        } else {
            mbStreak = 0
            lives -= 1
            mbFeedback = "✗ \(mbAnswer)"; mbFeedbackColor = .red
            HapticManager.shared.error(); SoundManager.shared.playFail()
        }
        withAnimation { mbFeedbackOpacity = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { withAnimation { self.mbFeedbackOpacity = 0 } }
        mbPhase = .feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.nextMathQuestion() }
    }

    func updateMathBlitz() {}

    var mathBlitzView: some View {
        VStack(spacing: 28) {
            Spacer()
            // Streak indicator
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill").foregroundColor(.yellow).font(.system(size: 14))
                Text("Streak: \(mbStreak)").font(.system(size: 14, weight: .bold)).foregroundColor(.yellow)
            }
            // Question card
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(mbPhase == .showing ? 0.12 : 0.06))
                    .frame(height: 140)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.blue.opacity(0.35), lineWidth: 1.5))
                if mbPhase == .showing {
                    Text(mbQuestion)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                } else if mbPhase == .choosing {
                    Text("?").font(.system(size: 40, weight: .bold)).foregroundColor(.white.opacity(0.4))
                } else {
                    Text(mbFeedback).font(.system(size: 32, weight: .bold)).foregroundColor(mbFeedbackColor)
                }
            }
            // Answer choices
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(mbChoices, id: \.self) { choice in
                    Button { answerMath(choice) } label: {
                        Text("\(choice)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(RoundedRectangle(cornerRadius: 18).fill(Color.blue.opacity(mbPhase == .choosing ? 0.25 : 0.08)))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.blue.opacity(mbPhase == .choosing ? 0.5 : 0.15), lineWidth: 1.5))
                    }
                    .disabled(mbPhase != .choosing)
                }
            }
            Spacer()
        }
    }

    // =========================================================================
    // MARK: - COLOR SURGE
    // =========================================================================
    func initColorSurge() {
        spawnNextColor()
    }

    func spawnNextColor() {
        let pair = csColors.randomElement()!
        csCurrentColor = pair.0
        csColorName = pair.1
        csPhase = .filling
        csFillProgress = 0
    }

    func updateColorSurge() {
        guard csPhase == .filling else { return }
        let needsTarget = csColorName == csTargetName
        csFillProgress += 0.05 / 1.5  // fills in ~1.5s
        if csFillProgress >= 1.0 {
            if needsTarget {
                // Missed – should have tapped
                csFeedback = "TOO SLOW"; csFeedbackColor = .red
                score = max(0, score - 5)
                HapticManager.shared.error()
            } else {
                // Correct ignore
                score += 5
            }
            csPhase = .waiting
            csFillProgress = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.spawnNextColor() }
        }
    }

    var csTargetName: String {
        // Target is always GREEN for simplicity (player knows to tap green)
        return "GREEN"
    }

    func tapColorSurge() {
        guard csPhase == .filling else { return }
        if csColorName == csTargetName {
            let reactionBonus = Int((1.0 - csFillProgress) * 30)
            score += 15 + reactionBonus
            csFeedback = "+\(15 + reactionBonus)"; csFeedbackColor = .green
            HapticManager.shared.success(); SoundManager.shared.playSuccess()
        } else {
            lives -= 1
            csFeedback = "WRONG COLOR"; csFeedbackColor = .red
            HapticManager.shared.error(); SoundManager.shared.playFail()
        }
        withAnimation { csFeedbackOpacity = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { self.csFeedbackOpacity = 0 } }
        csPhase = .waiting
        csFillProgress = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.spawnNextColor() }
    }

    var colorSurgeView: some View {
        VStack(spacing: 20) {
            // Target reminder
            HStack(spacing: 8) {
                Text("TAP WHEN:").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.5))
                Text("GREEN").font(.system(size: 14, weight: .black)).foregroundColor(.green)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Color.green.opacity(0.2)))
            }
            Spacer()
            // Color fill area
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 280)
                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(csCurrentColor.opacity(0.3), lineWidth: 2))
                // Fill wave
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer()
                        RoundedRectangle(cornerRadius: 28)
                            .fill(csCurrentColor.opacity(0.7))
                            .frame(height: geo.size.height * CGFloat(csFillProgress))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .frame(height: 280)
                .animation(.linear(duration: 0.05), value: csFillProgress)

                VStack(spacing: 8) {
                    Text(csColorName)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: csCurrentColor, radius: 12)
                    if csFeedbackOpacity > 0 {
                        Text(csFeedback)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(csFeedbackColor)
                            .opacity(csFeedbackOpacity)
                    }
                }
            }
            .onTapGesture { tapColorSurge() }
            .padding(.horizontal)

            Text("Tap the screen when you see GREEN")
                .font(.system(size: 13)).foregroundColor(.white.opacity(0.35))
            Spacer()
        }
    }

    // =========================================================================
    // MARK: - RHYTHM BREATH
    // =========================================================================
    func initRhythmBreath() {
        rbPhase = .inhale
        rbCycles = 0
        rbProgress = 0
    }

    func updateRhythmBreath() {
        let duration = rbPhase == .inhale ? rbInhale : rbExhale
        rbProgress += 0.05 / duration
        if rbProgress >= 1.0 {
            rbProgress = 0
            if rbPhase == .inhale {
                rbPhase = .exhale
            } else {
                rbPhase = .inhale
                rbCycles += 1
                score += 40
                if rbCycles >= 5 {
                    endChallenge()
                }
            }
        }
    }

    var rhythmBreathView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(rbPhase == .inhale ? "BREATHE IN" : "BREATHE OUT")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(rbPhase == .inhale ? .cyan : .green)
                .animation(.easeInOut(duration: 0.3), value: rbPhase)

            // Animated ring
            ZStack {
                Circle().stroke(Color.white.opacity(0.08), lineWidth: 18).frame(width: 220, height: 220)
                Circle()
                    .trim(from: 0, to: rbProgress)
                    .stroke(
                        rbPhase == .inhale ? Color.cyan : Color.green,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.05), value: rbProgress)

                // Breathing circle
                Circle()
                    .fill((rbPhase == .inhale ? Color.cyan : Color.green).opacity(0.15))
                    .frame(width: 120 + CGFloat(rbProgress) * 60, height: 120 + CGFloat(rbProgress) * 60)
                    .animation(.linear(duration: 0.05), value: rbProgress)

                VStack(spacing: 4) {
                    Text("\(rbCycles)/5").font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                    Text("cycles").font(.system(size: 13)).foregroundColor(.white.opacity(0.4))
                }
            }
            Text(rbPhase == .inhale ? "\(String(format: "%.0f", rbInhale))s inhale" : "\(String(format: "%.0f", rbExhale))s exhale")
                .font(.system(size: 15)).foregroundColor(.white.opacity(0.45))
            Spacer()
        }
    }

    // =========================================================================
    // MARK: - SILENT COUNTER
    // =========================================================================
    func initSilentCounter() {
        startSilentRound()
    }

    func startSilentRound() {
        scPhase = .counting
        scHiddenCount = Int.random(in: 7...14)
        scUserGuess = 0
        scFeedback = ""
        scTickTimer?.invalidate()
        // Ticker runs silently – no display
        scTickTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            Task { @MainActor in
                // Nothing visible happens – silence is the challenge
            }
        }
    }

    func submitSilentGuess(_ guess: Int) {
        guard scPhase == .counting else { return }
        scTickTimer?.invalidate()
        scUserGuess = guess
        scPhase = .revealed
        let delta = abs(guess - scHiddenCount)
        scResultDelta = delta
        let pts: Int
        switch delta {
        case 0:     pts = 100; scFeedback = "PERFECT 🎯"
        case 1:     pts = 70;  scFeedback = "SO CLOSE (+1/-1)"
        case 2:     pts = 40;  scFeedback = "GOOD (±2)"
        case 3:     pts = 20;  scFeedback = "OKAY (±3)"
        default:    pts = 0;   scFeedback = "Off by \(delta)"
        }
        score += pts
        HapticManager.shared.mediumTap()
        scRound += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if self.scRound < 5 { self.startSilentRound() }
        }
    }

    var silentCounterView: some View {
        VStack(spacing: 24) {
            Spacer()
            if scPhase == .counting {
                VStack(spacing: 20) {
                    Text("Round \(scRound + 1) of 5")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(.white.opacity(0.45))
                    ZStack {
                        Circle().fill(Color.red.opacity(0.1)).frame(width: 180, height: 180)
                            .overlay(Circle().stroke(Color.red.opacity(0.3), lineWidth: 2))
                        VStack(spacing: 8) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 52)).foregroundColor(.red)
                            Text("COUNTING...").font(.system(size: 14, weight: .bold)).foregroundColor(.white.opacity(0.4))
                        }
                    }
                    Text("A hidden number is being counted.\nPress STOP when you think it hits 10.")
                        .font(.system(size: 14)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center).padding(.horizontal, 32)

                    Button { submitSilentGuess(10) } label: {
                        Text("STOP at 10")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.black)
                            .frame(width: 200, height: 64)
                            .background(Color.red)
                            .cornerRadius(18)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Text("The number was…").font(.system(size: 16)).foregroundColor(.white.opacity(0.5))
                    Text("\(scHiddenCount)")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundColor(scResultDelta == 0 ? .green : scResultDelta <= 2 ? .yellow : .red)
                    Text(scFeedback)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(scResultDelta == 0 ? .green : scResultDelta <= 2 ? .yellow : .red)
                    Text("You pressed at 10").font(.system(size: 13)).foregroundColor(.white.opacity(0.35))
                }
            }
            Spacer()
        }
    }

    // =========================================================================
    // MARK: - DUAL TASK
    // =========================================================================
    func initDualTask() {
        dtTargetPos = 0.5
        dtTargetDir = 1
        generateDualMath()
    }

    func generateDualMath() {
        let a = Int.random(in: 2...9), b = Int.random(in: 2...9)
        dtCorrectNum = a + b
        var wrongs = Set<Int>()
        while wrongs.count < 3 {
            let w = dtCorrectNum + Int.random(in: -5...5)
            if w != dtCorrectNum && w > 0 { wrongs.insert(w) }
        }
        dtChoices = (Array(wrongs) + [dtCorrectNum]).shuffled()
        dtNumbers = [a, b]
        dtTapped = false
    }

    func updateDualTask() {
        // Move target across screen
        let speed: CGFloat = 0.25 + CGFloat(score / 100) * 0.05
        dtTargetPos += dtTargetDir * CGFloat(0.05) * speed
        if dtTargetPos > 0.92 { dtTargetDir = -1 }
        if dtTargetPos < 0.08 { dtTargetDir = 1 }
    }

    func tapDualTask(index: Int) {
        if dtChoices[index] == dtCorrectNum {
            score += 20
            dtMathScore += 1
            HapticManager.shared.success(); SoundManager.shared.playSuccess()
        } else {
            lives -= 1
            HapticManager.shared.error(); SoundManager.shared.playFail()
        }
        generateDualMath()
    }

    func tapDualTarget() {
        score += 10
        dtTrackScore += 1
        HapticManager.shared.lightTap()
        dtTapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.dtTapped = false }
    }

    var dualTaskView: some View {
        VStack(spacing: 0) {
            // TOP: tracking task
            GeometryReader { geo in
                ZStack {
                    Text("TAP THE BALL").font(.system(size: 11, weight: .bold)).foregroundColor(.white.opacity(0.3))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)

                    Circle()
                        .fill(dtTapped ? Color.green : Color.purple)
                        .frame(width: 56, height: 56)
                        .shadow(color: (dtTapped ? Color.green : Color.purple).opacity(0.6), radius: 10)
                        .position(x: geo.size.width * dtTargetPos, y: geo.size.height / 2)
                        .onTapGesture { tapDualTarget() }
                        .animation(.linear(duration: 0.05), value: dtTargetPos)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(16)
            }
            .frame(height: 140)
            .padding(.horizontal)
            .padding(.bottom, 10)

            // Divider
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.horizontal)

            VStack(spacing: 12) {
                // Math equation
                HStack(spacing: 10) {
                    ForEach(dtNumbers, id: \.self) { n in
                        Text("\(n)").font(.system(size: 36, weight: .bold, design: .rounded)).foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
                Text("= ?").font(.system(size: 18, weight: .bold)).foregroundColor(.white.opacity(0.4))

                // Choices
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(Array(dtChoices.enumerated()), id: \.offset) { i, choice in
                        Button { tapDualTask(index: i) } label: {
                            Text("\(choice)")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.blue.opacity(0.2)))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue.opacity(0.4), lineWidth: 1))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
    }

} // end UniversalChallengeView

// Color(hex:) is defined in ContentView.swift

// MARK: - Preview
#Preview {
    UniversalChallengeView(challenge: .targetHunt)
        .environmentObject(AppState())
}
