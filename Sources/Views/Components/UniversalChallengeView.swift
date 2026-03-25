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

// Bubble Burst
struct BubbleItem: Identifiable {
    let id = UUID()
    let number: Int
    var position: CGPoint
    var opacity: Double = 1.0
    var popped: Bool = false
    var scale: CGFloat = 1.0
}

// Digit Storm
enum DigitStormPhase { case flashing, entering, result }

// Pattern Clone
enum PatternClonePhase { case showing, recalling, result }

// Color Blitz
enum ColorBlitzPhase { case waiting, flashing, feedback }

// Word Zen
struct FloatingWord: Identifiable {
    let id = UUID()
    let text: String
    let isZen: Bool
    var posX: CGFloat
    var posY: CGFloat
    var opacity: Double = 1.0
    var tapped: Bool = false
    var speed: CGFloat = 1.0
}

// Calm Scroll
struct ScrollPost: Identifiable {
    let id = UUID()
    let app: String
    let content: String
    let isFocus: Bool
    var tapped: Bool = false
}

// Shape Drop
struct DroppingShape: Identifiable {
    let id = UUID()
    var type: HuntShapeType
    var posX: CGFloat
    var posY: CGFloat
    var speed: CGFloat
    var tapped: Bool = false
    var opacity: Double = 1.0
}

// Memory Maze
enum MazePhase { case showing, recalling, result }

// Sync Beat
enum SyncBeatPhase { case waiting, active }

// Pulse Lock
enum PulseLockPhase { case inhale, exhale }

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

    // ── Bubble Burst ────────────────────────────────────────────────────────
    @State private var bbBubbles: [BubbleItem] = []
    @State private var bbNextTap: Int = 1
    @State private var bbWave: Int = 1
    @State private var bbSpawnTimer: Timer? = nil
    @State private var bbMoveTimer: Timer? = nil

    // ── Digit Storm ──────────────────────────────────────────────────────────
    @State private var dsDigits: [Int] = []
    @State private var dsFlashIndex: Int = -1
    @State private var dsFlashTimer: Timer? = nil
    @State private var dsPhase: DigitStormPhase = .flashing
    @State private var dsUserInput: [Int] = []
    @State private var dsCorrectSum: Int = 0
    @State private var dsCurrentDigit: Int = 0
    @State private var dsRound: Int = 1

    // ── Pattern Clone ────────────────────────────────────────────────────────
    @State private var pcTargetPattern: [Color] = Array(repeating: .clear, count: 9)
    @State private var pcUserPattern: [Color] = Array(repeating: .clear, count: 9)
    @State private var pcPhase: PatternClonePhase = .showing
    @State private var pcShowTimer: Timer? = nil
    @State private var pcRound: Int = 1
    @State private var pcColorPalette: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .cyan, .pink]
    @State private var pcSelectedColor: Color = .red
    @State private var pcResultOK: Bool = false

    // ── Color Blitz ──────────────────────────────────────────────────────────
    @State private var cbTargetColor: Color = .red
    @State private var cbTargetName: String = "RED"
    @State private var cbPhase: ColorBlitzPhase = .waiting
    @State private var cbQuadrantColors: [Color] = [.red, .blue, .green, .yellow]
    @State private var cbFeedback: String = ""
    @State private var cbFeedbackColor: Color = .green
    @State private var cbFeedbackOpacity: Double = 0
    @State private var cbSpawnTimer: Timer? = nil
    @State private var cbTimeLeft: Double = 0
    let cbAllColors: [(Color, String)] = [(.red,"RED"),(.blue,"BLUE"),(.green,"GREEN"),(.yellow,"YELLOW"),(.orange,"ORANGE"),(.cyan,"CYAN"),(.pink,"PINK"),(.purple,"PURPLE")]

    // ── Sync Beat ────────────────────────────────────────────────────────────
    @State private var sbBPM: Double = 60
    @State private var sbBeatTime: Double = 0      // time since last beat
    @State private var sbBeatInterval: Double = 1.0 // seconds per beat
    @State private var sbBeatFlash: Bool = false
    @State private var sbLastTapBeat: Double = 0
    @State private var sbBeatsCompleted: Int = 0
    @State private var sbTotalBeats: Int = 0
    @State private var sbAccumTime: Double = 0

    // ── Pulse Lock ───────────────────────────────────────────────────────────
    @State private var plPhase: PulseLockPhase = .inhale
    @State private var plPhaseTime: Double = 0
    @State private var plIsPressed: Bool = false
    @State private var plCycles: Int = 0
    @State private var plSyncScore: Double = 0
    @State private var plOrbScale: Double = 0.6
    @State private var plInhaleDur: Double = 4.0
    @State private var plExhaleDur: Double = 6.0

    // ── Word Zen ─────────────────────────────────────────────────────────────
    @State private var wzWords: [FloatingWord] = []
    @State private var wzSpawnTimer: Timer? = nil
    @State private var wzMoveTimer: Timer? = nil
    @State private var wzZenTapped: Int = 0
    @State private var wzFalseAlerts: Int = 0
    let wzZenWords = ["Breathe", "Peace", "Calm", "Still", "Serene", "Quiet", "Flow", "Ease"]
    let wzNoiseWords = ["TRENDING", "VIRAL", "LIKE", "SHARE", "FOLLOW", "REPOST", "HOT", "🔥", "NEW", "ALERT", "NOTIFY", "PING", "NOW", "LIVE"]

    // ── Calm Scroll ───────────────────────────────────────────────────────────
    @State private var csPosts: [ScrollPost] = []
    @State private var csScrollOffset: CGFloat = 0
    @State private var csScrollTimer: Timer? = nil
    @State private var csFocusTapped: Int = 0
    @State private var csWrongTaps: Int = 0

    // ── Shape Drop ────────────────────────────────────────────────────────────
    @State private var sdShapes: [DroppingShape] = []
    @State private var sdTarget: HuntShapeType = .circle
    @State private var sdSpawnTimer: Timer? = nil
    @State private var sdMoveTimer: Timer? = nil
    @State private var sdLevel: Int = 1

    // ── Memory Maze ───────────────────────────────────────────────────────────
    @State private var mmPath: [Int] = []             // cell indices in path order
    @State private var mmUserPath: [Int] = []
    @State private var mmPhase: MazePhase = .showing
    @State private var mmFlashIndex: Int = -1
    @State private var mmFlashTimer: Timer? = nil
    @State private var mmRound: Int = 1
    @State private var mmNextExpected: Int = 0

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
        ZStack {
            // Ambient color glow in background
            challenge.color.opacity(0.12)
                .blur(radius: 80)
                .frame(width: 400, height: 400)
                .offset(y: -60)
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Close button row
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                        Spacer()
                        GlassBadge(text: challenge.category.rawValue.uppercased(), color: challenge.color)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    Spacer().frame(height: 36)

                    // Animated icon
                    ChallengePreviewIcon(color: challenge.color, icon: challenge.icon)

                    Spacer().frame(height: 28)

                    // Challenge name
                    Text(challenge.rawValue)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, challenge.color.opacity(0.85)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 12)

                    // Description glass card
                    Text(challenge.description)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(challenge.color.opacity(0.07))
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(challenge.color.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 24)

                    // Stats row — duration, XP, gems, lives
                    HStack(spacing: 10) {
                        PreviewStatPill(icon: "timer", value: "\(challenge.duration)s", label: "Duration", color: .white.opacity(0.8))
                        PreviewStatPill(icon: "bolt.fill", value: "\(challenge.xpReward) XP", label: "Reward", color: .yellow)
                        PreviewStatPill(icon: "diamond.fill", value: "+\(challenge.gemReward)", label: "Gems", color: .cyan)
                        PreviewStatPill(icon: "heart.fill", value: "3", label: "Lives", color: .pink)
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 32)

                    // Start button — full liquid glass
                    Button(action: startChallenge) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("Start Challenge")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [challenge.color.opacity(0.8), challenge.color.opacity(0.5)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    )
                                // Specular shine
                                VStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(LinearGradient(colors: [Color.white.opacity(0.25), Color.clear], startPoint: .top, endPoint: .bottom))
                                        .frame(height: 28)
                                    Spacer(minLength: 0)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(LinearGradient(colors: [Color.white.opacity(0.35), challenge.color.opacity(0.5)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                        )
                        .shadow(color: challenge.color.opacity(0.5), radius: 16, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
        }
    }

    // MARK: - Active View
    var activeChallengeView: some View {
        VStack(spacing: 0) {
            // ── Header ─────────────────────────────────────────────────────
            VStack(spacing: 6) {
                HStack(alignment: .center, spacing: 12) {
                    // Exit button
                    Button(action: endChallenge) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(Circle().fill(Color.white.opacity(0.08)))
                            )
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }

                    Spacer()

                    // Timer — changes color when low
                    HStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.12), lineWidth: 2.5)
                                .frame(width: 32, height: 32)
                            Circle()
                                .trim(from: 0, to: timeRemaining / Double(challenge.duration))
                                .stroke(timeRemaining < 10 ? Color.red : challenge.color,
                                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                                .frame(width: 32, height: 32)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 0.05), value: timeRemaining)
                        }
                        Text("\(Int(ceil(timeRemaining)))")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(timeRemaining < 10 ? .red : .white)
                            .contentTransition(.numericText())
                            .animation(.linear(duration: 0.05), value: Int(timeRemaining))
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(
                        Capsule().fill(.ultraThinMaterial)
                            .overlay(Capsule().fill(timeRemaining < 10 ? Color.red.opacity(0.1) : Color.white.opacity(0.05)))
                    )
                    .overlay(Capsule().stroke(timeRemaining < 10 ? Color.red.opacity(0.5) : Color.white.opacity(0.12), lineWidth: 1))

                    Spacer()

                    // Score pill
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("\(score)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.3), value: score)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(
                        Capsule().fill(.ultraThinMaterial)
                            .overlay(Capsule().fill(Color.yellow.opacity(0.1)))
                    )
                    .overlay(Capsule().stroke(Color.yellow.opacity(0.3), lineWidth: 1))
                    .shadow(color: .yellow.opacity(0.2), radius: 6)
                }
                .padding(.horizontal, 16)

                // Lives + Combo row
                HStack(spacing: 8) {
                    // Hearts
                    HStack(spacing: 5) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < lives ? "heart.fill" : "heart")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(i < lives ? .pink : .gray.opacity(0.3))
                                .scaleEffect(i < lives ? 1.0 : 0.85)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: lives)
                        }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Capsule().fill(Color.pink.opacity(0.12)))
                    .overlay(Capsule().stroke(Color.pink.opacity(0.25), lineWidth: 1))

                    Spacer()

                    // Level indicator
                    if level > 1 {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.up.2")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(challenge.color)
                            Text("LVL \(level)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(challenge.color)
                        }
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Capsule().fill(challenge.color.opacity(0.15)))
                        .overlay(Capsule().stroke(challenge.color.opacity(0.4), lineWidth: 1))
                        .transition(.scale.combined(with: .opacity))
                    }

                    // Combo badge
                    if combo > 1 {
                        HStack(spacing: 3) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.yellow)
                            Text("\(combo)×")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [Color.yellow.opacity(0.25), Color.orange.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .overlay(Capsule().stroke(Color.yellow.opacity(0.5), lineWidth: 1))
                        .shadow(color: .yellow.opacity(0.35), radius: 6)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: combo)
                    }
                }
                .padding(.horizontal, 16)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: level)
            }
            .padding(.top, 12)
            .padding(.bottom, 6)

            // ── Time progress bar ───────────────────────────────────────────
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.white.opacity(0.07)).frame(height: 3)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: timeRemaining < 10
                                    ? [.red, .orange]
                                    : [challenge.color, challenge.color.opacity(0.6)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: g.size.width * max(0, timeRemaining / Double(challenge.duration)), height: 3)
                        .shadow(color: timeRemaining < 10 ? .red.opacity(0.6) : challenge.color.opacity(0.4), radius: 3)
                        .animation(.linear(duration: 0.05), value: timeRemaining)
                }
            }
            .frame(height: 3)

            // ── Challenge content ───────────────────────────────────────────
            challengeContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 16)
        }
        .background(
            // Subtle color wash based on challenge
            LinearGradient(
                colors: [challenge.color.opacity(0.05), Color.clear],
                startPoint: .top, endPoint: .center
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Results
    var resultsView: some View {
        let gemsEarned = challenge.gemReward
        let grade: String = score >= 200 ? "S" : score >= 120 ? "A" : score >= 60 ? "B" : "C"
        let gradeColor: Color = score >= 200 ? .yellow : score >= 120 ? .green : score >= 60 ? .cyan : .gray
        let starCount: Int = score >= 200 ? 3 : score >= 80 ? 2 : 1
        return ZStack {
            // Background glow
            challenge.color.opacity(0.18).blur(radius: 80)
                .frame(width: 500, height: 500)
                .allowsHitTesting(false)

            // Confetti particles
            ForEach(0..<min(gemsEarned, 8), id: \.self) { i in
                FloatingGemParticle(delay: Double(i) * 0.12)
            }

            // Extra color confetti for high scores
            if score >= 120 {
                ForEach(0..<12, id: \.self) { i in
                    ResultsConfettiPiece(
                        color: [challenge.color, .yellow, .cyan, .pink, .green].randomElement()!,
                        delay: Double(i) * 0.08
                    )
                }
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    // Grade badge
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [gradeColor.opacity(0.3), gradeColor.opacity(0.05)],
                                    center: .center, startRadius: 0, endRadius: 90
                                )
                            )
                            .frame(width: 140, height: 140)
                            .blur(radius: 12)

                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 110, height: 110)
                            .overlay(
                                Circle()
                                    .fill(LinearGradient(colors: [gradeColor.opacity(0.3), gradeColor.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .overlay(
                                Circle()
                                    .stroke(LinearGradient(colors: [Color.white.opacity(0.3), gradeColor.opacity(0.5)], startPoint: .top, endPoint: .bottom), lineWidth: 2)
                            )
                            .shadow(color: gradeColor.opacity(0.5), radius: 20)

                        Text(grade)
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [gradeColor, gradeColor.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                            )
                    }
                    .scaleEffect(showResults ? 1 : 0.4)
                    .opacity(showResults ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.65), value: showResults)

                    Spacer().frame(height: 16)

                    // Stars
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < starCount ? "star.fill" : "star")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(i < starCount ? .yellow : .gray.opacity(0.3))
                                .scaleEffect(showResults ? 1 : 0.3)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(i) * 0.1 + 0.2), value: showResults)
                        }
                    }

                    Spacer().frame(height: 16)

                    // Challenge name
                    Text("Challenge Complete!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    Text(challenge.rawValue)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Spacer().frame(height: 24)

                    // Score display
                    VStack(spacing: 4) {
                        Text("\(score)")
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: .yellow.opacity(0.4), radius: 12)
                            .contentTransition(.numericText())
                        Text("POINTS")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(2)
                    }

                    Spacer().frame(height: 28)

                    // Rewards glass card
                    HStack(spacing: 0) {
                        ResultRewardItem(icon: "bolt.fill", value: "+\(challenge.xpReward)", label: "XP", color: .green)
                        ResultDivider()
                        ResultRewardItem(icon: "diamond.fill", value: "+\(gemsEarned)", label: "Gems", color: .cyan)
                        ResultDivider()
                        ResultRewardItem(icon: "chart.bar.fill", value: grade, label: "Grade", color: gradeColor)
                    }
                    .padding(.vertical, 18)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.04))
                            VStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(colors: [Color.white.opacity(0.12), Color.clear], startPoint: .top, endPoint: .bottom))
                                    .frame(height: 24)
                                Spacer(minLength: 0)
                            }.clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    )
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.15), lineWidth: 1))
                    .shadow(color: .black.opacity(0.25), radius: 16, y: 6)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 36)

                    // Continue button
                    Button(action: { dismiss() }) {
                        HStack(spacing: 10) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(LinearGradient(colors: [challenge.color.opacity(0.8), challenge.color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                VStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(LinearGradient(colors: [Color.white.opacity(0.25), Color.clear], startPoint: .top, endPoint: .bottom))
                                        .frame(height: 28)
                                    Spacer(minLength: 0)
                                }.clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                        )
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(LinearGradient(colors: [Color.white.opacity(0.35), challenge.color.opacity(0.5)], startPoint: .top, endPoint: .bottom), lineWidth: 1))
                        .shadow(color: challenge.color.opacity(0.45), radius: 16, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
        }
        .onAppear {
            HapticManager.shared.success()
            SoundManager.shared.playSuccess()
        }
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
        bbSpawnTimer?.invalidate(); bbSpawnTimer = nil
        bbMoveTimer?.invalidate(); bbMoveTimer = nil
        dsFlashTimer?.invalidate(); dsFlashTimer = nil
        pcShowTimer?.invalidate(); pcShowTimer = nil
        cbSpawnTimer?.invalidate(); cbSpawnTimer = nil
        wzSpawnTimer?.invalidate(); wzSpawnTimer = nil
        wzMoveTimer?.invalidate(); wzMoveTimer = nil
        csScrollTimer?.invalidate(); csScrollTimer = nil
        sdSpawnTimer?.invalidate(); sdSpawnTimer = nil
        sdMoveTimer?.invalidate(); sdMoveTimer = nil
        mmFlashTimer?.invalidate(); mmFlashTimer = nil
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
        case .bubbleBurst:      initBubbleBurst()
        case .digitStorm:       initDigitStorm()
        case .patternClone:     initPatternClone()
        case .colorBlitz:       initColorBlitz()
        case .syncBeat:         initSyncBeat()
        case .pulseLock:        initPulseLock()
        case .wordZen:          initWordZen()
        case .calmScroll:       initCalmScroll()
        case .shapeDrop:        initShapeDrop()
        case .memoryMaze:       initMemoryMaze()
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
        case .bubbleBurst:      updateBubbleBurst()
        case .digitStorm:       break
        case .patternClone:     break
        case .colorBlitz:       updateColorBlitz()
        case .syncBeat:         updateSyncBeat()
        case .pulseLock:        updatePulseLock()
        case .wordZen:          break
        case .calmScroll:       break
        case .shapeDrop:        updateShapeDrop()
        case .memoryMaze:       break
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
        case .bubbleBurst:      bubbleBurstView
        case .digitStorm:       digitStormView
        case .patternClone:     patternCloneView
        case .colorBlitz:       colorBlitzView
        case .syncBeat:         syncBeatView
        case .pulseLock:        pulseLockView
        case .wordZen:          wordZenView
        case .calmScroll:       calmScrollView
        case .shapeDrop:        shapeDropView
        case .memoryMaze:       memoryMazeView
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
                // Find target indicator — glass card
                HStack(spacing: 14) {
                    Text("FIND")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.45))
                        .tracking(1.5)
                    ZStack {
                        Circle()
                            .fill(huntTarget.color.opacity(0.25))
                            .frame(width: 48, height: 48)
                            .shadow(color: huntTarget.color.opacity(0.7), radius: 10)
                        Image(systemName: huntTarget.sfSymbol)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(huntTarget.color)
                    }
                    Text(String(describing: huntTarget).capitalized)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20).padding(.vertical, 10)
                .background(
                    ZStack {
                        Capsule().fill(.ultraThinMaterial)
                        Capsule().fill(huntTarget.color.opacity(0.08))
                    }
                )
                .overlay(Capsule().stroke(huntTarget.color.opacity(0.4), lineWidth: 1))
                .shadow(color: huntTarget.color.opacity(0.25), radius: 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 8)

                // Floating shapes
                ForEach(huntShapes.indices, id: \.self) { i in
                    let shape = huntShapes[i]
                    let isTarget = shape.type == huntTarget
                    ZStack {
                        if isTarget {
                            Circle()
                                .stroke(shape.type.color.opacity(0.35), lineWidth: 2)
                                .frame(width: 58, height: 58)
                                .blur(radius: 1)
                        }
                        Image(systemName: shape.type.sfSymbol)
                            .font(.system(size: 40))
                            .foregroundColor(shape.isWrong ? .red : shape.type.color)
                            .scaleEffect(shape.isWrong ? 1.4 : 1.0)
                            .shadow(color: (shape.isWrong ? Color.red : shape.type.color).opacity(shape.isWrong ? 0.9 : 0.6), radius: shape.isWrong ? 14 : 8)
                    }
                    .position(shape.position)
                    .onTapGesture { tapHuntShape(index: i) }
                    .animation(.spring(response: 0.15, dampingFraction: 0.5), value: shape.isWrong)
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
        let cols = 4
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
                // Next number glass pill
                HStack(spacing: 10) {
                    Text("NEXT").font(.system(size: 11, weight: .bold)).foregroundColor(.white.opacity(0.45)).tracking(1.5)
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.4))
                            .frame(width: 40, height: 40)
                            .shadow(color: .purple.opacity(0.8), radius: 10)
                        Text("\(rushNext)")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 18).padding(.vertical, 8)
                .background(ZStack {
                    Capsule().fill(.ultraThinMaterial)
                    Capsule().fill(Color.purple.opacity(0.1))
                })
                .overlay(Capsule().stroke(Color.purple.opacity(0.5), lineWidth: 1))
                .shadow(color: .purple.opacity(0.3), radius: 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top, 4)

                ForEach(rushNumbers.indices, id: \.self) { i in
                    let n = rushNumbers[i]
                    let isNext = n.value == rushNext && !n.tapped
                    ZStack {
                        // Outer glow for next number
                        if isNext {
                            Circle()
                                .stroke(Color.purple.opacity(0.5), lineWidth: 2)
                                .frame(width: 66, height: 66)
                                .blur(radius: 2)
                        }
                        Circle()
                            .fill(
                                n.tapped ? Color.gray.opacity(0.1) :
                                isNext ? Color.purple.opacity(0.5) : Color.purple.opacity(0.15)
                            )
                            .frame(width: 58, height: 58)
                            .shadow(color: isNext ? Color.purple.opacity(0.7) : .clear, radius: 12)
                        // Shine on active
                        if isNext {
                            Circle()
                                .fill(LinearGradient(colors: [Color.white.opacity(0.25), Color.clear], startPoint: .topLeading, endPoint: .center))
                                .frame(width: 58, height: 58)
                        }
                        Text("\(n.value)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(n.tapped ? .gray.opacity(0.25) : .white)
                    }
                    .offset(x: n.shake ? 5 : 0)
                    .scaleEffect(isNext ? 1.08 : 1.0)
                    .position(n.position)
                    .onTapGesture { if !n.tapped { tapRushNumber(index: i) } }
                    .animation(.spring(response: 0.15, dampingFraction: 0.5), value: n.shake)
                    .animation(.spring(response: 0.3), value: isNext)
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

            // Stats pills row
            HStack(spacing: 12) {
                HStack(spacing: 5) {
                    Image(systemName: "scope").font(.system(size: 11)).foregroundColor(.yellow)
                    Text("Zone \(Int(lockZone * 100))%").font(.system(size: 12, weight: .semibold)).foregroundColor(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(Color.yellow.opacity(0.12)))
                .overlay(Capsule().stroke(Color.yellow.opacity(0.3), lineWidth: 1))

                HStack(spacing: 5) {
                    Image(systemName: "gauge.with.needle.fill").font(.system(size: 11)).foregroundColor(.orange)
                    Text("Speed \(String(format: "%.1f", lockSpeed))×").font(.system(size: 12, weight: .semibold)).foregroundColor(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(Color.orange.opacity(0.12)))
                .overlay(Capsule().stroke(Color.orange.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 32)

            // Tap button — glass orb style
            Button(action: tapLaserLock) {
                ZStack {
                    // Glow aura
                    Circle()
                        .fill((lockHitFlash ? Color.green : lockMissFlash ? Color.red : challenge.color).opacity(0.35))
                        .frame(width: 130, height: 130)
                        .blur(radius: 14)
                    // Glass body
                    Circle().fill(.ultraThinMaterial).frame(width: 110, height: 110)
                    Circle().fill(LinearGradient(
                        colors: lockHitFlash ? [.green.opacity(0.8), .green.opacity(0.5)] :
                                lockMissFlash ? [.red.opacity(0.8), .red.opacity(0.5)] :
                                [challenge.color.opacity(0.8), challenge.color.opacity(0.5)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )).frame(width: 110, height: 110)
                    // Specular
                    VStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                            .frame(width: 110, height: 55)
                        Spacer(minLength: 0)
                    }.clipShape(Circle().scale(1.0)).frame(width: 110, height: 110)

                    Text("TAP")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                }
            }
            .overlay(
                Circle()
                    .stroke(LinearGradient(colors: [Color.white.opacity(0.3), (lockHitFlash ? Color.green : challenge.color).opacity(0.6)], startPoint: .top, endPoint: .bottom), lineWidth: 1.5)
                    .frame(width: 110, height: 110)
            )
            .scaleEffect(lockCooldown ? 0.96 : 1.0)
            .animation(.spring(response: 0.2), value: lockCooldown)
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
            // Display area — glass card
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .frame(height: 110)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.08))
                    )
                    .overlay(
                        VStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(colors: [Color.white.opacity(0.12), Color.clear], startPoint: .top, endPoint: .bottom))
                                .frame(height: 22)
                            Spacer(minLength: 0)
                        }.clipShape(RoundedRectangle(cornerRadius: 20))
                    )
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                    .shadow(color: .blue.opacity(0.15), radius: 12)

                if vaultPhase == .showing {
                    VStack(spacing: 8) {
                        Text("MEMORIZE").font(.system(size: 11, weight: .bold)).foregroundColor(.gray).tracking(1.5)
                        HStack(spacing: 10) {
                            ForEach(vaultSequence.indices, id: \.self) { i in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.35))
                                        .frame(width: 38, height: 48)
                                        .shadow(color: .blue.opacity(0.6), radius: 6)
                                    Text("\(vaultSequence[i])")
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        let showDuration = max(1.8, 3.0 - Double(level) * 0.15)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(width: 160, height: 4)
                            RoundedRectangle(cornerRadius: 4).fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                                .frame(width: 160 * CGFloat(vaultShowProgress / showDuration), height: 4)
                                .animation(.linear(duration: 0.05), value: vaultShowProgress)
                        }
                    }
                } else if vaultPhase == .entering {
                    VStack(spacing: 8) {
                        Text("ENTER THE NUMBER").font(.system(size: 11, weight: .bold)).foregroundColor(.gray).tracking(1.5)
                        HStack(spacing: 10) {
                            ForEach(0..<vaultSequence.count, id: \.self) { i in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(i < vaultInput.count ? Color.blue.opacity(0.4) : Color.white.opacity(0.06))
                                        .frame(width: 38, height: 48)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue.opacity(i < vaultInput.count ? 0.7 : 0.2), lineWidth: 1.5))
                                        .shadow(color: i < vaultInput.count ? .blue.opacity(0.5) : .clear, radius: 6)
                                    if i < vaultInput.count {
                                        Text("\(vaultInput[i])").font(.system(size: 28, weight: .black, design: .rounded)).foregroundColor(.white)
                                    } else {
                                        Rectangle().fill(Color.blue.opacity(0.5)).frame(width: 18, height: 2).offset(y: 14)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: vaultPhase == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(vaultPhase == .correct ? .green : .red)
                        Text(vaultResultMessage)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(vaultPhase == .correct ? .green : .red)
                            .multilineTextAlignment(.center).padding(.horizontal, 12)
                    }
                }
            }
            .padding(.horizontal, 24)

            // Numpad — glass style
            if vaultPhase == .entering {
                VStack(spacing: 10) {
                    ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.self) { digit in
                                Button(action: { tapVaultDigit(digit) }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                                        RoundedRectangle(cornerRadius: 14).fill(Color.blue.opacity(0.1))
                                        VStack {
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(LinearGradient(colors: [Color.white.opacity(0.15), Color.clear], startPoint: .top, endPoint: .bottom))
                                                .frame(height: 20)
                                            Spacer(minLength: 0)
                                        }.clipShape(RoundedRectangle(cornerRadius: 14))
                                        Text("\(digit)").font(.system(size: 28, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 76, height: 64)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 1))
                                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                                }
                            }
                        }
                    }
                    HStack(spacing: 12) {
                        Button(action: deleteVaultDigit) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 14).fill(Color.orange.opacity(0.12))
                                Image(systemName: "delete.left.fill").font(.system(size: 22))
                                    .foregroundColor(.orange)
                            }
                            .frame(width: 76, height: 64)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.25), lineWidth: 1))
                        }
                        Button(action: { tapVaultDigit(0) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 14).fill(Color.blue.opacity(0.1))
                                Text("0").font(.system(size: 28, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 76, height: 64)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 1))
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
        let indices = Array(0..<16).shuffled()
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
            // Phase indicator pill
            HStack(spacing: 8) {
                Image(systemName: recallPhase == .showing ? "eye.fill" :
                      recallPhase == .recalling ? "hand.tap.fill" : (recallResultOK ? "checkmark.circle.fill" : "xmark.circle.fill"))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(recallPhase == .result ? (recallResultOK ? .green : .red) :
                                     recallPhase == .showing ? .yellow : .cyan)
                Text(recallPhase == .showing ? "MEMORIZE THE PATTERN" :
                     recallPhase == .recalling ? "RECREATE IT — \(recallCellCount) CELLS" :
                     recallResultOK ? "CORRECT!" : "WRONG!")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(recallPhase == .result ? (recallResultOK ? .green : .red) :
                                     recallPhase == .showing ? .yellow : .cyan)
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().stroke(
                (recallPhase == .result ? (recallResultOK ? Color.green : Color.red) :
                 recallPhase == .showing ? Color.yellow : Color.cyan).opacity(0.4),
                lineWidth: 1))

            // 4x4 Grid
            VStack(spacing: 7) {
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 7) {
                        ForEach(0..<4, id: \.self) { col in
                            let idx = row * 4 + col
                            let isLit: Bool = {
                                if recallPhase == .showing { return recallGrid[idx] }
                                if recallPhase == .result { return recallGrid[idx] }
                                return recallUserGrid[idx]
                            }()
                            let isCorrectCell = recallPhase == .result && recallGrid[idx] && recallUserGrid[idx]
                            let isWrongCell = recallPhase == .result && !recallGrid[idx] && recallUserGrid[idx]
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        isWrongCell ? Color.red.opacity(0.75) :
                                        isCorrectCell ? Color.green.opacity(0.75) :
                                        isLit ? Color.blue.opacity(0.85) :
                                        Color.white.opacity(0.06)
                                    )
                                    .frame(width: 70, height: 70)
                                    .shadow(color: isWrongCell ? .red.opacity(0.7) : isCorrectCell ? .green.opacity(0.7) : isLit ? .blue.opacity(0.8) : .clear,
                                            radius: isLit || isCorrectCell || isWrongCell ? 12 : 0)
                                // Specular shine on lit cells
                                if isLit || isCorrectCell {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(colors: [Color.white.opacity(0.2), Color.clear], startPoint: .topLeading, endPoint: .center))
                                        .frame(width: 70, height: 70)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isLit || isCorrectCell || isWrongCell ? Color.white.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
                            )
                            .onTapGesture { tapRecallCell(index: idx) }
                            .animation(.spring(response: 0.2), value: isLit)
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
        VStack(spacing: 20) {
            Spacer()
            // Phase pill
            HStack(spacing: 8) {
                Image(systemName: chainPhase == .showing ? "eye.fill" : "hand.tap.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(chainPhase == .showing ? .yellow : .cyan)
                Text(chainPhase == .showing ? "WATCH THE SEQUENCE" : "REPEAT THE SEQUENCE")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(chainPhase == .showing ? .yellow : .cyan)
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().stroke((chainPhase == .showing ? Color.yellow : Color.cyan).opacity(0.4), lineWidth: 1))

            Text("Round \(chainSequence.count)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))

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
            ZStack {
                // Base glass
                RoundedRectangle(cornerRadius: 22)
                    .fill(.ultraThinMaterial)
                    .frame(width: 144, height: 144)
                // Color fill — dim or bright
                RoundedRectangle(cornerRadius: 22)
                    .fill(chainColors[idx].opacity(isFlashing ? 1.0 : 0.25))
                    .frame(width: 144, height: 144)
                // Specular when flashing
                if isFlashing {
                    VStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                            .frame(width: 144, height: 40)
                        Spacer(minLength: 0)
                    }.clipShape(RoundedRectangle(cornerRadius: 22)).frame(width: 144, height: 144)
                }
                // Icon
                Image(systemName: chainColorSymbols[idx])
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundColor(isFlashing ? .white : chainColors[idx].opacity(0.7))
                    .shadow(color: isFlashing ? .white.opacity(0.4) : .clear, radius: 6)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(chainColors[idx].opacity(isFlashing ? 0.9 : 0.35), lineWidth: isFlashing ? 2.5 : 1.5)
            )
            .shadow(color: isFlashing ? chainColors[idx] : .black.opacity(0.2), radius: isFlashing ? 22 : 6, y: isFlashing ? 0 : 3)
            .scaleEffect(isFlashing ? 1.06 : 1.0)
        }
        .animation(.easeInOut(duration: 0.1), value: isFlashing)
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
                // Instruction pills
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Text("TAP").font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.green.opacity(0.12)))
                    .overlay(Capsule().stroke(Color.green.opacity(0.3), lineWidth: 1))

                    HStack(spacing: 5) {
                        Circle().fill(Color.red).frame(width: 10, height: 10)
                        Text("HOLD").font(.system(size: 12, weight: .bold)).foregroundColor(.red)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.red.opacity(0.12)))
                    .overlay(Capsule().stroke(Color.red.opacity(0.3), lineWidth: 1))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top, 8)

                ForEach(goCircles.indices, id: \.self) { i in
                    let c = goCircles[i]
                    ZStack {
                        // Outer glow ring
                        Circle()
                            .stroke((c.isGo ? Color.green : Color.red).opacity(0.4), lineWidth: 3)
                            .frame(width: 124, height: 124)
                            .blur(radius: 4)
                        // Glass body
                        Circle().fill(.ultraThinMaterial).frame(width: 110, height: 110)
                        Circle().fill((c.isGo ? Color.green : Color.red).opacity(0.85)).frame(width: 110, height: 110)
                        // Specular shine
                        Circle()
                            .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .topLeading, endPoint: .center))
                            .frame(width: 110, height: 110)
                        VStack(spacing: 4) {
                            Image(systemName: c.isGo ? "hand.tap.fill" : "hand.raised.fill")
                                .font(.system(size: 30, weight: .semibold)).foregroundColor(.white)
                            Text(c.isGo ? "TAP!" : "WAIT!")
                                .font(.system(size: 14, weight: .black)).foregroundColor(.white)
                        }
                    }
                    .shadow(color: (c.isGo ? Color.green : Color.red).opacity(0.7), radius: 20)
                    .scaleEffect(c.scale).opacity(c.opacity)
                    .position(c.position)
                    .onTapGesture { tapGoCircle(index: i) }
                    .animation(.spring(response: 0.2), value: c.scale)
                }

                // Feedback glass overlay
                if goFeedbackOpacity > 0 {
                    Text(goFeedback)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(goFeedbackColor)
                        .padding(.horizontal, 24).padding(.vertical, 12)
                        .background(Capsule().fill(.ultraThinMaterial))
                        .overlay(Capsule().stroke(goFeedbackColor.opacity(0.5), lineWidth: 1.5))
                        .shadow(color: goFeedbackColor.opacity(0.4), radius: 12)
                        .opacity(goFeedbackOpacity)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
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

            // Stats pills
            HStack(spacing: 12) {
                HStack(spacing: 5) {
                    Image(systemName: "scope").font(.system(size: 11)).foregroundColor(.yellow)
                    Text("Zone \(Int(gateZone * 100))%").font(.system(size: 12, weight: .semibold)).foregroundColor(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(Color.yellow.opacity(0.12)))
                .overlay(Capsule().stroke(Color.yellow.opacity(0.3), lineWidth: 1))

                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 11)).foregroundColor(.green)
                    Text("Hits \(gateHits)").font(.system(size: 12, weight: .semibold)).foregroundColor(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(Color.green.opacity(0.12)))
                .overlay(Capsule().stroke(Color.green.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 32)

            // Glass TAP button
            Button(action: tapTimingGate) {
                ZStack {
                    Circle()
                        .fill((gateHitFlash ? Color.green : gateMissFlash ? Color.red : challenge.color).opacity(0.4))
                        .frame(width: 132, height: 132)
                        .blur(radius: 14)
                    Circle().fill(.ultraThinMaterial).frame(width: 110, height: 110)
                    Circle().fill(LinearGradient(
                        colors: gateHitFlash ? [.green.opacity(0.85), .green.opacity(0.55)] :
                                gateMissFlash ? [.red.opacity(0.85), .red.opacity(0.55)] :
                                [challenge.color.opacity(0.85), challenge.color.opacity(0.55)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )).frame(width: 110, height: 110)
                    Circle()
                        .fill(LinearGradient(colors: [Color.white.opacity(0.28), Color.clear], startPoint: .topLeading, endPoint: .center))
                        .frame(width: 110, height: 110)
                    Text("TAP").font(.system(size: 22, weight: .black, design: .rounded)).foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                }
                .overlay(Circle().stroke(LinearGradient(colors: [Color.white.opacity(0.3), (gateHitFlash ? Color.green : challenge.color).opacity(0.6)], startPoint: .top, endPoint: .bottom), lineWidth: 1.5).frame(width: 110, height: 110))
            }
            .scaleEffect(gateCooldown ? 0.96 : 1.0)
            .animation(.spring(response: 0.2), value: gateCooldown)
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

            // Glass MATCH / DIFFERENT buttons
            if matchPhase == .deciding {
                HStack(spacing: 14) {
                    Button(action: { resolveMatch(userSaidMatch: true) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 16).fill(Color.green.opacity(0.75))
                            VStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                                    .frame(height: 20)
                                Spacer(minLength: 0)
                            }.clipShape(RoundedRectangle(cornerRadius: 16))
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 16, weight: .bold))
                                Text("MATCH").font(.system(size: 16, weight: .black))
                            }.foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.6), lineWidth: 1.5))
                        .shadow(color: .green.opacity(0.45), radius: 12)
                    }
                    Button(action: { resolveMatch(userSaidMatch: false) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 16).fill(Color.red.opacity(0.75))
                            VStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                                    .frame(height: 20)
                                Spacer(minLength: 0)
                            }.clipShape(RoundedRectangle(cornerRadius: 16))
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill").font(.system(size: 16, weight: .bold))
                                Text("DIFFERENT").font(.system(size: 16, weight: .black))
                            }.foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.6), lineWidth: 1.5))
                        .shadow(color: .red.opacity(0.45), radius: 12)
                    }
                }
                .padding(.horizontal, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
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
            // Phase label
            VStack(spacing: 6) {
                Text(balloonPhase == .inhale ? "BREATHE IN" : "BREATHE OUT")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(balloonPhase == .inhale ? .cyan : .green)
                    .animation(.easeInOut(duration: 0.3), value: balloonPhase)
                Text(balloonPhase == .inhale ? "Hold the screen" : "Release the screen")
                    .font(.system(size: 14, weight: .medium)).foregroundColor(.gray)
            }
            Spacer()
            // Balloon — glass orb with shine
            ZStack {
                // Outer glow
                Circle()
                    .fill((balloonPhase == .inhale ? Color.cyan : Color.green).opacity(0.3))
                    .frame(width: 90 + CGFloat(balloonSize) * 220, height: 90 + CGFloat(balloonSize) * 220)
                    .blur(radius: 20)
                // Main balloon
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80 + CGFloat(balloonSize) * 200, height: 80 + CGFloat(balloonSize) * 200)
                Circle()
                    .fill(LinearGradient(
                        colors: balloonPhase == .inhale ? [.cyan.opacity(0.75), .blue.opacity(0.55)] : [.green.opacity(0.75), .teal.opacity(0.55)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 80 + CGFloat(balloonSize) * 200, height: 80 + CGFloat(balloonSize) * 200)
                // Specular
                Circle()
                    .fill(LinearGradient(colors: [Color.white.opacity(0.35), Color.clear], startPoint: .topLeading, endPoint: .center))
                    .frame(width: 80 + CGFloat(balloonSize) * 200, height: 80 + CGFloat(balloonSize) * 200)
                Text(balloonPhase == .inhale ? "IN" : "OUT")
                    .font(.system(size: 24, weight: .black, design: .rounded)).foregroundColor(.white.opacity(0.9))
            }
            .shadow(color: (balloonPhase == .inhale ? Color.cyan : Color.green).opacity(0.55), radius: 28)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in balloonIsPressed = true }
                .onEnded   { _ in balloonIsPressed = false })
            Spacer()
            // Sync glass pill
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "waveform").font(.system(size: 12)).foregroundColor(.cyan)
                    Text("Sync: \(Int(balloonSyncScore))%").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                }
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(width: 200, height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 200 * CGFloat(balloonSyncScore / 100), height: 6)
                        .animation(.linear(duration: 0.1), value: balloonSyncScore)
                }
            }
            .padding(.horizontal, 24).padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.cyan.opacity(0.2), lineWidth: 1))
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

            // Glass corner confirm button
            Button(action: tapBoxCorner) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(boxNearCorner ? boxPhase.color.opacity(0.75) : Color.white.opacity(0.06))
                    VStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(colors: [Color.white.opacity(boxNearCorner ? 0.25 : 0.08), Color.clear], startPoint: .top, endPoint: .bottom))
                            .frame(height: 20)
                        Spacer(minLength: 0)
                    }.clipShape(RoundedRectangle(cornerRadius: 16))
                    HStack(spacing: 8) {
                        Image(systemName: boxNearCorner ? "hand.tap.fill" : "clock.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(boxNearCorner ? .white : .gray)
                        Text(boxNearCorner ? "TAP! Confirm Turn" : "Wait for corner…")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(boxNearCorner ? .white : .gray)
                    }
                }
                .frame(maxWidth: .infinity).frame(height: 54)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(boxNearCorner ? boxPhase.color.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1.5))
                .shadow(color: boxNearCorner ? boxPhase.color.opacity(0.45) : .clear, radius: 14)
                .scaleEffect(boxNearCorner ? 1.02 : 1.0)
                .animation(.spring(response: 0.3), value: boxNearCorner)
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

            // Glass CONFIRM button
            Button(action: confirmRlxPhase) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(rlxNeedsConfirm ? rlxPhaseColors[rlxPhase].opacity(0.75) : Color.white.opacity(0.05))
                    VStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(colors: [Color.white.opacity(rlxNeedsConfirm ? 0.25 : 0.08), Color.clear], startPoint: .top, endPoint: .bottom))
                            .frame(height: 22)
                        Spacer(minLength: 0)
                    }.clipShape(RoundedRectangle(cornerRadius: 16))
                    HStack(spacing: 8) {
                        Image(systemName: rlxNeedsConfirm ? "checkmark.circle.fill" : "ellipsis.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(rlxNeedsConfirm ? .white : .gray)
                        Text(rlxNeedsConfirm ? "CONFIRM" : "Waiting…")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(rlxNeedsConfirm ? .white : .gray)
                        if rlxNeedsConfirm {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity).frame(height: 58)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(rlxNeedsConfirm ? rlxPhaseColors[rlxPhase].opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1.5))
                .shadow(color: rlxNeedsConfirm ? rlxPhaseColors[rlxPhase].opacity(0.4) : .clear, radius: 16)
                .scaleEffect(rlxConfirmFlash ? 1.04 : (rlxNeedsConfirm ? 1.02 : 1.0))
            }
            .padding(.horizontal, 24).disabled(!rlxNeedsConfirm)
            .animation(.spring(response: 0.2), value: rlxConfirmFlash)
            .animation(.spring(response: 0.3), value: rlxNeedsConfirm)
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
    let wallRealTitle = ("Unscroll", "COLLECT YOUR FOCUS REWARD!")

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
        let appIcons: [String: (String, Color)] = [
            "Instagram": ("camera.fill", .pink),
            "Twitter": ("bird.fill", .cyan),
            "TikTok": ("music.note", .white),
            "Email": ("envelope.fill", .blue),
            "News": ("newspaper.fill", .orange),
            "YouTube": ("play.rectangle.fill", .red),
            "Facebook": ("person.2.fill", .blue),
            "Reddit": ("bubble.left.and.bubble.right.fill", .orange),
            "Unscroll": ("star.fill", .green),
        ]
        let iconInfo = appIcons[notif.title] ?? ("app.fill", .gray)

        HStack(spacing: 12) {
            // App icon — glass rounded rect
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(notif.isReal ? Color.green.opacity(0.25) : iconInfo.1.opacity(0.18))
                    .frame(width: 46, height: 46)
                    .overlay(RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [Color.white.opacity(0.18), Color.clear], startPoint: .topLeading, endPoint: .center)))
                RoundedRectangle(cornerRadius: 12).stroke(
                    notif.isReal ? Color.green.opacity(0.6) : iconInfo.1.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 46, height: 46)
                Image(systemName: notif.isReal ? "star.fill" : iconInfo.0)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(notif.isReal ? .green : iconInfo.1)
            }
            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(notif.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(notif.isReal ? .green : .white)
                Text(notif.subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Spacer()
            // Dismiss X
            Button(action: { dismissWallNotif(id: notif.id, tapContent: false) }) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.1)).frame(width: 30, height: 30)
                    Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 16).fill(notif.isReal ? Color.green.opacity(0.08) : Color(hex: "1E293B").opacity(0.85))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(notif.isReal ? Color.green.opacity(0.7) : Color.white.opacity(0.08), lineWidth: notif.isReal ? 2 : 1)
        )
        .shadow(color: notif.isReal ? .green.opacity(0.25) : .black.opacity(0.2), radius: notif.isReal ? 12 : 4)
        .contentShape(Rectangle())
        .onTapGesture { dismissWallNotif(id: notif.id, tapContent: true) }
        .padding(.horizontal, 16)
        .opacity(notif.dismissed ? 0 : 1)
        .animation(.easeOut(duration: 0.2), value: notif.dismissed)
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
                // Instruction pills
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Text("TAP GREEN").font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.green.opacity(0.12)))
                    .overlay(Capsule().stroke(Color.green.opacity(0.3), lineWidth: 1))

                    HStack(spacing: 5) {
                        Circle().fill(Color.red).frame(width: 10, height: 10)
                        Text("AVOID RED").font(.system(size: 12, weight: .bold)).foregroundColor(.red)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.red.opacity(0.12)))
                    .overlay(Capsule().stroke(Color.red.opacity(0.3), lineWidth: 1))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top, 8)

                ForEach(glCircles) { c in
                    ZStack {
                        // Outer pulse ring
                        Circle()
                            .stroke((c.isGreen ? Color.green : Color.red).opacity(0.4), lineWidth: 3)
                            .frame(width: 96, height: 96)
                            .blur(radius: 3)
                        // Glass body
                        Circle().fill(.ultraThinMaterial).frame(width: 82, height: 82)
                        Circle().fill((c.isGreen ? Color.green : Color.red).opacity(0.85)).frame(width: 82, height: 82)
                        Circle()
                            .fill(LinearGradient(colors: [Color.white.opacity(0.28), Color.clear], startPoint: .topLeading, endPoint: .center))
                            .frame(width: 82, height: 82)
                        Image(systemName: c.isGreen ? "checkmark" : "xmark")
                            .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                    }
                    .shadow(color: (c.isGreen ? Color.green : Color.red).opacity(0.7), radius: 18)
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

                // Safe buttons — glass style
                ForEach(fortressSafeButtons) { btn in
                    Button(action: { tapFortressSafe(id: btn.id) }) {
                        ZStack {
                            // Glow
                            Circle().fill(Color.green.opacity(0.35)).frame(width: 74, height: 74).blur(radius: 8)
                            // Glass body
                            Circle().fill(.ultraThinMaterial).frame(width: 62, height: 62)
                            Circle().fill(LinearGradient(colors: [.green.opacity(0.9), .green.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 62, height: 62)
                            Circle().fill(LinearGradient(colors: [Color.white.opacity(0.28), Color.clear], startPoint: .topLeading, endPoint: .center)).frame(width: 62, height: 62)
                            VStack(spacing: 2) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                                Text("+30").font(.system(size: 11, weight: .black)).foregroundColor(.white)
                            }
                        }
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1.5).frame(width: 62, height: 62))
                        .shadow(color: .green.opacity(0.7), radius: 12)
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
            // Center: target display — glass card
            VStack(spacing: 10) {
                Text("TAP THE TARGET").font(.system(size: 11, weight: .bold)).foregroundColor(.gray).tracking(1.5)
                ZStack {
                    Circle()
                        .fill(scanTarget.color.opacity(0.25))
                        .frame(width: 100, height: 100)
                        .shadow(color: scanTarget.color.opacity(0.6), radius: 18)
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 88, height: 88)
                        .overlay(Circle().fill(LinearGradient(colors: [Color.white.opacity(0.2), Color.clear], startPoint: .topLeading, endPoint: .center)))
                    Image(systemName: scanTarget.sfSymbol)
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(scanTarget.color)
                        .shadow(color: scanTarget.color.opacity(0.5), radius: 8)
                }
                Text(String(describing: scanTarget).capitalized)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 24).padding(.vertical, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 22).fill(scanTarget.color.opacity(0.06))
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(scanTarget.color.opacity(0.4), lineWidth: 1.5))
            .shadow(color: scanTarget.color.opacity(0.2), radius: 16)

            // Edge items — larger, with glow
            ForEach(scanItems) { item in
                Button { tapScanItem(item) } label: {
                    ZStack {
                        Circle()
                            .fill(item.type.color.opacity(0.2))
                            .frame(width: 54, height: 54)
                            .shadow(color: item.type.color.opacity(0.7), radius: 10)
                        Image(systemName: item.type.sfSymbol)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(item.type.color)
                    }
                    .scaleEffect(CGFloat(max(0.5, 1.0 - item.age * 0.2)))
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
        VStack(spacing: 16) {
            Spacer()
            // Phase pill
            HStack(spacing: 8) {
                Image(systemName: echoPhase == .showing ? "eye.fill" : "hand.tap.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(echoPhase == .showing ? .yellow : .green)
                Text(echoPhase == .showing ? "WATCH THE SEQUENCE" : "REPEAT THE SEQUENCE")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(echoPhase == .showing ? .yellow : .green)
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().stroke((echoPhase == .showing ? Color.yellow : Color.green).opacity(0.4), lineWidth: 1))

            Text("Round \(echoRound) • Length \(echoSequence.count)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))

            // 2×3 grid of pads
            let symbols = ["circle.fill","square.fill","triangle.fill","star.fill","diamond.fill","heart.fill"]
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(0..<6, id: \.self) { i in
                    let isFlashing = echoFlashIndex == i
                    Button { tapEchoPad(i) } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 16)
                                .fill(echoPadColors[i].opacity(isFlashing ? 1.0 : 0.2))
                            if isFlashing {
                                VStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                                        .frame(height: 24)
                                    Spacer(minLength: 0)
                                }.clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            Image(systemName: symbols[i])
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(isFlashing ? .white : echoPadColors[i].opacity(0.8))
                                .shadow(color: isFlashing ? .white.opacity(0.5) : .clear, radius: 6)
                        }
                        .frame(height: 82)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(echoPadColors[i].opacity(isFlashing ? 0.9 : 0.3), lineWidth: isFlashing ? 2.5 : 1))
                        .shadow(color: isFlashing ? echoPadColors[i] : .black.opacity(0.2), radius: isFlashing ? 18 : 4)
                        .scaleEffect(isFlashing ? 1.06 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isFlashing)
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
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Image(systemName: "hand.tap.fill").font(.system(size: 12, weight: .bold)).foregroundColor(.orange)
                        Text("TAP FAST").font(.system(size: 12, weight: .bold)).foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.orange.opacity(0.12)))
                    .overlay(Capsule().stroke(Color.orange.opacity(0.4), lineWidth: 1))

                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 12)).foregroundColor(.green)
                        Text("\(reflexHits)").font(.system(size: 14, weight: .black)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.green.opacity(0.12)))
                    .overlay(Capsule().stroke(Color.green.opacity(0.3), lineWidth: 1))
                }
                Spacer()
            }
            .padding(.top, 8)

            ForEach(reflexTargets) { target in
                let timeLeft = max(0, 1.2 - target.age)
                let ringProgress = CGFloat(target.age / 1.2)
                Button { tapReflexTarget(target) } label: {
                    ZStack {
                        // Timer ring (shrinks as time runs out)
                        Circle()
                            .stroke(Color.orange.opacity(0.15), lineWidth: 4)
                            .frame(width: 84, height: 84)
                        Circle()
                            .trim(from: 0, to: 1.0 - ringProgress)
                            .stroke(Color.orange.opacity(0.7), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 84, height: 84)
                            .rotationEffect(.degrees(-90))
                        // Glow orb
                        Circle()
                            .fill(Color.orange.opacity(0.25))
                            .frame(width: 66, height: 66)
                            .shadow(color: .orange.opacity(0.7), radius: 12)
                        Circle().fill(.ultraThinMaterial).frame(width: 66, height: 66)
                        Circle().fill(LinearGradient(colors: [.orange.opacity(0.85), .orange.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 66, height: 66)
                        Circle()
                            .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .topLeading, endPoint: .center))
                            .frame(width: 66, height: 66)
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 24, weight: .semibold)).foregroundColor(.white)
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

            // Glass CONFIRM button
            Button(action: confirmFsbPhase) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(fsbNeedsConfirm ? fsbPhase.color.opacity(0.75) : Color.white.opacity(0.05))
                    VStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(colors: [Color.white.opacity(fsbNeedsConfirm ? 0.25 : 0.08), Color.clear], startPoint: .top, endPoint: .bottom))
                            .frame(height: 22)
                        Spacer(minLength: 0)
                    }.clipShape(RoundedRectangle(cornerRadius: 16))
                    HStack(spacing: 8) {
                        Image(systemName: fsbNeedsConfirm ? "checkmark.circle.fill" : "ellipsis.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(fsbNeedsConfirm ? .white : .gray)
                        Text(fsbNeedsConfirm ? "CONFIRM" : "Waiting…")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(fsbNeedsConfirm ? .white : .gray)
                        if fsbNeedsConfirm {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity).frame(height: 58)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(fsbNeedsConfirm ? fsbPhase.color.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1.5))
                .shadow(color: fsbNeedsConfirm ? fsbPhase.color.opacity(0.4) : .clear, radius: 16)
                .scaleEffect(fsbConfirmFlash ? 1.04 : (fsbNeedsConfirm ? 1.02 : 1.0))
            }
            .padding(.horizontal, 24).disabled(!fsbNeedsConfirm)
            .animation(.spring(response: 0.2), value: fsbConfirmFlash)
            .animation(.spring(response: 0.3), value: fsbNeedsConfirm)
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
        VStack(spacing: 20) {
            Spacer()
            // Instructions glass pill
            HStack(spacing: 8) {
                Image(systemName: "hourglass").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.5))
                Text("WAIT FOR GREEN, THEN TAP FAST").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.5)).tracking(0.5)
            }
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))

            // Loading bar — glass styled
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .frame(height: 28)
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 28)
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(
                        colors: tdPhase == .ready ? [.green, .green.opacity(0.7)] : [.red.opacity(0.7), .orange.opacity(0.5)],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(width: max(8, UIScreen.main.bounds.width - 64) * CGFloat(min(tdBarProgress, 1.0)), height: 28)
                    .animation(.linear(duration: 0.05), value: tdBarProgress)
                // Bar shine
                VStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(colors: [Color.white.opacity(0.25), Color.clear], startPoint: .top, endPoint: .bottom))
                        .frame(height: 10)
                    Spacer(minLength: 0)
                }.clipShape(RoundedRectangle(cornerRadius: 14)).frame(height: 28)
            }
            .frame(maxWidth: .infinity).padding(.horizontal, 16)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1).padding(.horizontal, 16))

            // Last score glass badge
            if !tdLastScore.isEmpty {
                let isGood = !tdLastScore.contains("early") && !tdLastScore.contains("slow")
                Text(tdLastScore)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(isGood ? .green : .red)
                    .padding(.horizontal, 18).padding(.vertical, 8)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .overlay(Capsule().stroke((isGood ? Color.green : Color.red).opacity(0.4), lineWidth: 1))
            }

            // TAP button — glass orb
            Button(action: tapDelayButton) {
                ZStack {
                    // Aura
                    Circle()
                        .fill((tdPhase == .ready ? Color.green : Color.red.opacity(0.5)).opacity(0.4))
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                    Circle().fill(.ultraThinMaterial).frame(width: 136, height: 136)
                    Circle().fill(LinearGradient(
                        colors: tdPhase == .ready ? [.green.opacity(0.9), .green.opacity(0.6)] : [.red.opacity(0.35), .red.opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )).frame(width: 136, height: 136)
                    Circle()
                        .fill(LinearGradient(colors: [Color.white.opacity(0.28), Color.clear], startPoint: .topLeading, endPoint: .center))
                        .frame(width: 136, height: 136)
                    VStack(spacing: 4) {
                        Image(systemName: tdPhase == .ready ? "hand.tap.fill" : "xmark.circle.fill")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundColor(tdPhase == .ready ? .white : .white.opacity(0.3))
                        if tdPhase == .ready {
                            Text("NOW!").font(.system(size: 14, weight: .black)).foregroundColor(.white)
                        }
                    }
                }
                .overlay(Circle().stroke(
                    LinearGradient(colors: [Color.white.opacity(0.3), (tdPhase == .ready ? Color.green : Color.red.opacity(0.4)).opacity(0.6)], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1.5).frame(width: 136, height: 136))
                .scaleEffect(tdPhase == .ready ? 1.08 : 1.0)
                .shadow(color: tdPhase == .ready ? .green.opacity(0.6) : .clear, radius: 24)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.65), value: tdPhase == .ready)

            Text("Round \(tdRound + 1)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
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
        VStack(spacing: 20) {
            Spacer()
            // Streak glass pill
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill").foregroundColor(.yellow).font(.system(size: 13, weight: .bold))
                Text("Streak \(mbStreak)").font(.system(size: 14, weight: .black)).foregroundColor(.yellow)
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Capsule().fill(Color.yellow.opacity(0.12)))
            .overlay(Capsule().stroke(Color.yellow.opacity(0.4), lineWidth: 1))
            .shadow(color: .yellow.opacity(mbStreak > 0 ? 0.3 : 0), radius: 8)

            // Question card — glass
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial).frame(height: 130)
                RoundedRectangle(cornerRadius: 24).fill(Color.blue.opacity(0.1)).frame(height: 130)
                VStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [Color.white.opacity(0.15), Color.clear], startPoint: .top, endPoint: .bottom))
                        .frame(height: 30)
                    Spacer(minLength: 0)
                }.clipShape(RoundedRectangle(cornerRadius: 24)).frame(height: 130)
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.blue.opacity(mbPhase == .showing ? 0.5 : 0.2), lineWidth: 1.5)
                    .frame(height: 130)
                    .shadow(color: .blue.opacity(mbPhase == .showing ? 0.3 : 0), radius: 10)

                if mbPhase == .showing {
                    Text(mbQuestion)
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .blue.opacity(0.4), radius: 8)
                        .transition(.scale.combined(with: .opacity))
                } else if mbPhase == .choosing {
                    Text("?").font(.system(size: 42, weight: .black, design: .rounded)).foregroundColor(.white.opacity(0.3))
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: mbFeedbackColor == .green ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 26)).foregroundColor(mbFeedbackColor)
                        Text(mbFeedback).font(.system(size: 28, weight: .bold, design: .rounded)).foregroundColor(mbFeedbackColor)
                    }
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 12, y: 4)

            // Answer choices — glass
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(mbChoices, id: \.self) { choice in
                    Button { answerMath(choice) } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 18).fill(Color.blue.opacity(mbPhase == .choosing ? 0.2 : 0.05))
                            VStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(LinearGradient(colors: [Color.white.opacity(0.15), Color.clear], startPoint: .top, endPoint: .bottom))
                                    .frame(height: 20)
                                Spacer(minLength: 0)
                            }.clipShape(RoundedRectangle(cornerRadius: 18))
                            Text("\(choice)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(mbPhase == .choosing ? .white : .white.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity).frame(height: 70)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.blue.opacity(mbPhase == .choosing ? 0.5 : 0.12), lineWidth: 1.5))
                        .shadow(color: mbPhase == .choosing ? .blue.opacity(0.2) : .clear, radius: 8)
                    }
                    .disabled(mbPhase != .choosing)
                    .opacity(mbPhase == .choosing ? 1.0 : 0.5)
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
        VStack(spacing: 16) {
            // Target reminder — prominent glass pill
            HStack(spacing: 10) {
                Text("TAP WHEN YOU SEE").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.5))
                ZStack {
                    Capsule().fill(Color.green.opacity(0.3)).frame(height: 32)
                    Capsule().stroke(Color.green.opacity(0.6), lineWidth: 1.5).frame(height: 32)
                    Text("GREEN").font(.system(size: 14, weight: .black)).foregroundColor(.green)
                        .padding(.horizontal, 14)
                }
                .shadow(color: .green.opacity(0.3), radius: 8)
                .fixedSize()
            }
            Spacer()
            // Color fill area — glass styled
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .frame(height: 280)
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white.opacity(0.02))
                    .frame(height: 280)
                RoundedRectangle(cornerRadius: 32)
                    .stroke(csCurrentColor.opacity(0.45), lineWidth: 2)
                    .frame(height: 280)
                    .shadow(color: csCurrentColor.opacity(0.4), radius: 10)
                // Fill wave
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer()
                        RoundedRectangle(cornerRadius: 28)
                            .fill(LinearGradient(colors: [csCurrentColor.opacity(0.8), csCurrentColor.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                            .frame(height: geo.size.height * CGFloat(csFillProgress))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .frame(height: 280)
                .animation(.linear(duration: 0.05), value: csFillProgress)

                VStack(spacing: 10) {
                    Text(csColorName)
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: csCurrentColor, radius: 14)
                    if csFeedbackOpacity > 0 {
                        Text(csFeedback)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(csFeedbackColor)
                            .padding(.horizontal, 20).padding(.vertical, 8)
                            .background(Capsule().fill(.ultraThinMaterial))
                            .overlay(Capsule().stroke(csFeedbackColor.opacity(0.5), lineWidth: 1))
                            .opacity(csFeedbackOpacity)
                    }
                }
            }
            .onTapGesture { tapColorSurge() }
            .padding(.horizontal)
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
        scTickTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in }
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
                    // Round indicator
                    HStack(spacing: 6) {
                        ForEach(0..<5, id: \.self) { i in
                            Circle()
                                .fill(i < scRound ? Color.red : Color.white.opacity(0.15))
                                .frame(width: 10, height: 10)
                        }
                    }

                    // Pulsing orb
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 190, height: 190)
                            .blur(radius: 15)
                        Circle().fill(.ultraThinMaterial).frame(width: 170, height: 170)
                        Circle().fill(LinearGradient(colors: [.red.opacity(0.25), .red.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 170, height: 170)
                        Circle()
                            .fill(LinearGradient(colors: [Color.white.opacity(0.15), Color.clear], startPoint: .topLeading, endPoint: .center))
                            .frame(width: 170, height: 170)
                        VStack(spacing: 8) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 44)).foregroundColor(.red.opacity(0.8))
                            Text("COUNTING…").font(.system(size: 13, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.5)
                        }
                    }
                    .overlay(Circle().stroke(Color.red.opacity(0.3), lineWidth: 1.5).frame(width: 170, height: 170))
                    .shadow(color: .red.opacity(0.25), radius: 20)

                    Text("A hidden number is being counted.\nPress STOP when you think it hits 10.")
                        .font(.system(size: 14)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center).padding(.horizontal, 32)

                    // Glass STOP button
                    Button { submitSilentGuess(10) } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 20).fill(Color.red.opacity(0.8))
                            VStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                                    .frame(height: 24)
                                Spacer(minLength: 0)
                            }.clipShape(RoundedRectangle(cornerRadius: 20))
                            Text("STOP at 10")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(width: 220, height: 64)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red.opacity(0.6), lineWidth: 1.5))
                        .shadow(color: .red.opacity(0.5), radius: 16)
                    }
                }
            } else {
                VStack(spacing: 14) {
                    Text("The number was…").font(.system(size: 16, weight: .medium)).foregroundColor(.white.opacity(0.5))
                    let resultColor: Color = scResultDelta == 0 ? .green : scResultDelta <= 2 ? .yellow : .red
                    Text("\(scHiddenCount)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(resultColor)
                        .shadow(color: resultColor.opacity(0.5), radius: 16)
                    Text(scFeedback)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(resultColor)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Capsule().fill(.ultraThinMaterial))
                        .overlay(Capsule().stroke(resultColor.opacity(0.5), lineWidth: 1.5))
                    Text("You stopped at 10").font(.system(size: 13)).foregroundColor(.white.opacity(0.35))
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
            // TOP: tracking task — glass container
            GeometryReader { geo in
                ZStack {
                    Text("TAP THE BALL").font(.system(size: 11, weight: .bold)).foregroundColor(.white.opacity(0.3))
                        .tracking(1.5)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)

                    ZStack {
                        // Glow aura
                        Circle()
                            .fill((dtTapped ? Color.green : Color.purple).opacity(0.4))
                            .frame(width: 70, height: 70)
                            .blur(radius: 10)
                        // Ball
                        Circle().fill(.ultraThinMaterial).frame(width: 58, height: 58)
                        Circle().fill(LinearGradient(
                            colors: dtTapped ? [.green.opacity(0.9), .green.opacity(0.6)] : [.purple.opacity(0.9), .purple.opacity(0.6)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )).frame(width: 58, height: 58)
                        Circle()
                            .fill(LinearGradient(colors: [Color.white.opacity(0.25), Color.clear], startPoint: .topLeading, endPoint: .center))
                            .frame(width: 58, height: 58)
                    }
                    .shadow(color: (dtTapped ? Color.green : Color.purple).opacity(0.7), radius: 14)
                    .position(x: geo.size.width * dtTargetPos, y: geo.size.height / 2)
                    .onTapGesture { tapDualTarget() }
                    .animation(.linear(duration: 0.05), value: dtTargetPos)
                    .scaleEffect(dtTapped ? 1.15 : 1.0)
                    .animation(.spring(response: 0.2), value: dtTapped)
                }
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 16).fill(Color.purple.opacity(0.05))
                    }
                )
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.2), lineWidth: 1))
            }
            .frame(height: 140)
            .padding(.horizontal)
            .padding(.bottom, 12)

            // Glass divider
            Rectangle()
                .fill(LinearGradient(colors: [Color.clear, Color.white.opacity(0.12), Color.clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1).padding(.horizontal)

            VStack(spacing: 14) {
                // Math equation
                HStack(spacing: 8) {
                    ForEach(dtNumbers, id: \.self) { n in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.2)).frame(width: 52, height: 52)
                            Text("\(n)").font(.system(size: 28, weight: .black, design: .rounded)).foregroundColor(.white)
                        }
                    }
                    Text("+").font(.system(size: 22, weight: .bold)).foregroundColor(.white.opacity(0.5))
                    Text("= ?").font(.system(size: 20, weight: .bold)).foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .center)

                // Choices — glass style
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(Array(dtChoices.enumerated()), id: \.offset) { i, choice in
                        Button { tapDualTask(index: i) } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 14).fill(Color.purple.opacity(0.15))
                                VStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(LinearGradient(colors: [Color.white.opacity(0.12), Color.clear], startPoint: .top, endPoint: .bottom))
                                        .frame(height: 16)
                                    Spacer(minLength: 0)
                                }.clipShape(RoundedRectangle(cornerRadius: 14))
                                Text("\(choice)")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity).frame(height: 58)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.purple.opacity(0.4), lineWidth: 1))
                            .shadow(color: .purple.opacity(0.15), radius: 6)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 14)
        }
    }


    // =========================================================================
    // MARK: - 26. BUBBLE BURST
    // =========================================================================
    func initBubbleBurst() {
        bbNextTap = 1; bbWave = 1; bbBubbles = []
        spawnBubbleWave()
    }

    func spawnBubbleWave() {
        let count = min(bbWave + 3, 9)
        bbBubbles = []
        bbNextTap = 1
        for i in 1...count {
            bbBubbles.append(BubbleItem(
                number: i,
                position: CGPoint(
                    x: Double.random(in: 60...320),
                    y: Double.random(in: 400...680)
                ),
                opacity: 1.0
            ))
        }
    }

    func updateBubbleBurst() {
        let speed = CGFloat(30 + bbWave * 5)
        for i in bbBubbles.indices {
            if !bbBubbles[i].popped {
                bbBubbles[i].position.y -= speed * 0.05
                if bbBubbles[i].position.y < 80 {
                    // Escaped bubble — lose a life
                    bbBubbles[i].popped = true
                    bbBubbles[i].opacity = 0
                    lives -= 1
                    HapticManager.shared.error()
                    if bbNextTap == bbBubbles[i].number {
                        bbNextTap += 1
                    }
                }
            }
        }
        // Check if wave complete
        if bbBubbles.allSatisfy({ $0.popped }) {
            bbWave += 1
            score += 15 * bbWave
            level = bbWave
            HapticManager.shared.success()
            SoundManager.shared.playLevelUp()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.spawnBubbleWave()
            }
        }
    }

    func tapBubble(id: UUID) {
        guard let idx = bbBubbles.firstIndex(where: { $0.id == id }),
              !bbBubbles[idx].popped else { return }
        let bubble = bbBubbles[idx]
        if bubble.number == bbNextTap {
            bbBubbles[idx].popped = true
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                bbBubbles[idx].scale = 1.6
                bbBubbles[idx].opacity = 0
            }
            bbNextTap += 1
            score += 10
            HapticManager.shared.mediumTap()
            SoundManager.shared.playTap()
        } else {
            // Wrong order
            lives -= 1
            HapticManager.shared.error()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                bbBubbles[idx].scale = 0.7
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { self.bbBubbles[idx].scale = 1.0 }
            }
        }
    }

    var bubbleBurstView: some View {
        ZStack {
            // Ambient glow
            Circle()
                .fill(Color.purple.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(y: 50)

            VStack(spacing: 8) {
                // Header
                HStack(spacing: 12) {
                    // Next number pill
                    HStack(spacing: 6) {
                        Text("NEXT")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(.purple.opacity(0.8)).tracking(1)
                        Text("\(bbNextTap)")
                            .font(.system(size: 20, weight: .black, design: .rounded)).foregroundColor(.white)
                            .shadow(color: .purple.opacity(0.7), radius: 6)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(ZStack {
                        Capsule().fill(.ultraThinMaterial)
                        Capsule().fill(Color.purple.opacity(0.2))
                    })
                    .overlay(Capsule().stroke(Color.purple.opacity(0.5), lineWidth: 1))

                    Spacer()

                    // Wave pill
                    HStack(spacing: 6) {
                        Image(systemName: "wave.3.right").font(.system(size: 11)).foregroundColor(.cyan)
                        Text("Wave \(bbWave)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(ZStack {
                        Capsule().fill(.ultraThinMaterial)
                        Capsule().fill(Color.cyan.opacity(0.15))
                    })
                    .overlay(Capsule().stroke(Color.cyan.opacity(0.4), lineWidth: 1))
                }
                .padding(.horizontal, 16)

                // Bubble arena
                GeometryReader { geo in
                    ZStack {
                        // Background field
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .overlay(RoundedRectangle(cornerRadius: 24).fill(Color.purple.opacity(0.05)))
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.purple.opacity(0.2), lineWidth: 1))

                        ForEach(bbBubbles) { bubble in
                            if !bubble.popped || bubble.opacity > 0.01 {
                                bubbleView(bubble: bubble, isNext: bubble.number == bbNextTap)
                                    .position(x: bubble.position.x, y: bubble.position.y - 60)
                                    .opacity(bubble.opacity)
                                    .scaleEffect(bubble.scale)
                                    .onTapGesture { tapBubble(id: bubble.id) }
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }

    func bubbleView(bubble: BubbleItem, isNext: Bool) -> some View {
        ZStack {
            // Glow aura
            Circle()
                .fill(isNext ? Color.purple.opacity(0.4) : Color.blue.opacity(0.15))
                .frame(width: 66, height: 66)
                .blur(radius: isNext ? 10 : 4)
            // Glass bubble body
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 52, height: 52)
                .overlay(
                    Circle().fill(LinearGradient(
                        colors: isNext
                            ? [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]
                            : [Color.blue.opacity(0.35), Color.cyan.opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                )
                .overlay(
                    // Specular shine
                    VStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.white.opacity(0.4), Color.clear], startPoint: .top, endPoint: .bottom))
                            .frame(width: 26, height: 26)
                            .offset(y: 2)
                        Spacer(minLength: 0)
                    }.frame(width: 52, height: 52).clipShape(Circle())
                )
                .overlay(Circle().stroke(
                    isNext ? Color.purple.opacity(0.8) : Color.white.opacity(0.2),
                    lineWidth: isNext ? 2 : 1
                ))
                .shadow(color: isNext ? .purple.opacity(0.7) : .blue.opacity(0.3), radius: isNext ? 12 : 5)
            // Number
            Text("\(bubble.number)")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .scaleEffect(isNext ? 1.08 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isNext)
    }

    // =========================================================================
    // MARK: - 27. DIGIT STORM
    // =========================================================================
    func initDigitStorm() {
        dsRound = 1
        dsPhase = .flashing
        dsDigits = []
        dsUserInput = []
        startDigitStormRound()
    }

    func startDigitStormRound() {
        let count = min(2 + dsRound, 7)
        dsDigits = (0..<count).map { _ in Int.random(in: 1...9) }
        dsCorrectSum = dsDigits.reduce(0, +)
        dsUserInput = []
        dsFlashIndex = -1
        dsPhase = .flashing
        flashNextDigit()
    }

    func flashNextDigit() {
        let nextIndex = dsFlashIndex + 1
        guard nextIndex < dsDigits.count else {
            // Done flashing — switch to entry
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dsPhase = .entering
                self.dsCurrentDigit = 0
            }
            return
        }
        dsFlashIndex = nextIndex
        dsCurrentDigit = dsDigits[nextIndex]
        HapticManager.shared.lightTap()
        dsFlashTimer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { _ in
            Task { @MainActor in
                self.dsFlashIndex = -1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.flashNextDigit()
                }
            }
        }
    }

    func digitStormInput(_ digit: Int) {
        guard dsPhase == .entering else { return }
        dsUserInput.append(digit)
        HapticManager.shared.lightTap()
        if dsUserInput.count == String(dsCorrectSum).count {
            let userSum = Int(dsUserInput.map { String($0) }.joined()) ?? 0
            if userSum == dsCorrectSum {
                score += 20 * dsRound
                HapticManager.shared.success()
                SoundManager.shared.playSuccess()
                dsPhase = .result
                dsRound += 1
                level = dsRound
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.startDigitStormRound()
                }
            } else {
                lives -= 1
                HapticManager.shared.error()
                SoundManager.shared.playFail()
                dsPhase = .result
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.startDigitStormRound()
                }
            }
        }
    }

    func digitStormDelete() {
        guard !dsUserInput.isEmpty else { return }
        dsUserInput.removeLast()
    }

    var digitStormView: some View {
        VStack(spacing: 16) {
            // Round pill
            HStack(spacing: 8) {
                Image(systemName: "bolt.ring.closed").foregroundColor(.blue)
                Text("Round \(dsRound)").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text("\(dsDigits.count) digits").font(.system(size: 13)).foregroundColor(.blue.opacity(0.8))
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(ZStack {
                RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 14).fill(Color.blue.opacity(0.12))
            })
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue.opacity(0.4), lineWidth: 1))
            .padding(.horizontal)

            // Flash display
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 24).fill(Color.blue.opacity(0.08)))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                    .shadow(color: .blue.opacity(0.2), radius: 16)
                    .frame(height: 140)

                if dsPhase == .flashing {
                    VStack(spacing: 6) {
                        Text("Remember!")
                            .font(.system(size: 13, weight: .medium)).foregroundColor(.white.opacity(0.5)).tracking(1)
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(dsFlashIndex >= 0 ? 0.35 : 0.08))
                                .frame(width: 80, height: 80)
                                .blur(radius: dsFlashIndex >= 0 ? 12 : 0)
                            Text(dsFlashIndex >= 0 ? "\(dsCurrentDigit)" : "...")
                                .font(.system(size: dsFlashIndex >= 0 ? 48 : 28, weight: .black, design: .rounded))
                                .foregroundColor(dsFlashIndex >= 0 ? .white : .white.opacity(0.3))
                                .shadow(color: .blue.opacity(dsFlashIndex >= 0 ? 0.7 : 0), radius: 12)
                        }
                        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: dsFlashIndex)
                    }
                } else if dsPhase == .entering {
                    VStack(spacing: 8) {
                        Text("What's the sum?")
                            .font(.system(size: 13, weight: .medium)).foregroundColor(.white.opacity(0.6))
                        HStack(spacing: 6) {
                            ForEach(dsUserInput.indices, id: \.self) { i in
                                Text("\(dsUserInput[i])")
                                    .font(.system(size: 32, weight: .black, design: .rounded)).foregroundColor(.white)
                            }
                            if dsUserInput.isEmpty {
                                Text("?").font(.system(size: 32, weight: .black, design: .rounded)).foregroundColor(.white.opacity(0.3))
                            }
                        }
                        .frame(height: 48)
                    }
                } else {
                    // Result
                    let correct = (Int(dsUserInput.map{String($0)}.joined()) ?? 0) == dsCorrectSum
                    VStack(spacing: 4) {
                        Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(correct ? .green : .red)
                        Text(correct ? "Correct! +\(20 * dsRound)" : "Answer: \(dsCorrectSum)")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    }
                }
            }
            .frame(height: 140)
            .padding(.horizontal)

            // Progress dots for this round's digits
            if dsPhase == .flashing {
                HStack(spacing: 8) {
                    ForEach(dsDigits.indices, id: \.self) { i in
                        Circle()
                            .fill(i < dsFlashIndex ? Color.blue : (i == dsFlashIndex ? Color.white : Color.white.opacity(0.2)))
                            .frame(width: 8, height: 8)
                            .scaleEffect(i == dsFlashIndex ? 1.5 : 1.0)
                            .animation(.spring(response: 0.2), value: dsFlashIndex)
                    }
                }
            }

            Spacer()

            // Numpad
            if dsPhase == .entering {
                digitStormNumpad
            }
        }
        .padding(.top, 8)
    }

    var digitStormNumpad: some View {
        VStack(spacing: 8) {
            ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { digit in
                        Button(action: { digitStormInput(digit) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 14).fill(Color.blue.opacity(0.15))
                                VStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(LinearGradient(colors: [Color.white.opacity(0.12), Color.clear], startPoint: .top, endPoint: .bottom))
                                        .frame(height: 16)
                                    Spacer(minLength: 0)
                                }.clipShape(RoundedRectangle(cornerRadius: 14))
                                Text("\(digit)").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity).frame(height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue.opacity(0.35), lineWidth: 1))
                        }
                    }
                }
            }
            HStack(spacing: 8) {
                Button(action: { digitStormDelete() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 14).fill(Color.orange.opacity(0.2))
                        Image(systemName: "delete.left.fill").font(.system(size: 18)).foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.4), lineWidth: 1))
                }
                Button(action: { digitStormInput(0) }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 14).fill(Color.blue.opacity(0.15))
                        Text("0").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue.opacity(0.35), lineWidth: 1))
                }
                .frame(maxWidth: .infinity * 2)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // =========================================================================
    // MARK: - 28. PATTERN CLONE
    // =========================================================================
    func initPatternClone() {
        pcRound = 1
        pcSelectedColor = pcColorPalette[0]
        startPatternCloneRound()
    }

    func startPatternCloneRound() {
        let filledCount = min(2 + pcRound, 8)
        let indices = Array(0..<9).shuffled().prefix(filledCount)
        pcTargetPattern = Array(repeating: .clear, count: 9)
        for idx in indices {
            pcTargetPattern[idx] = pcColorPalette.randomElement()!
        }
        pcUserPattern = Array(repeating: .clear, count: 9)
        pcPhase = .showing
        // Show for 2 seconds then hide
        pcShowTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.pcPhase = .recalling
                }
            }
        }
    }

    func tapPatternCell(_ idx: Int) {
        guard pcPhase == .recalling else { return }
        HapticManager.shared.lightTap()
        // Cycle through colors or set color
        if pcUserPattern[idx] == pcSelectedColor {
            pcUserPattern[idx] = .clear
        } else {
            pcUserPattern[idx] = pcSelectedColor
        }
    }

    func submitPatternClone() {
        guard pcPhase == .recalling else { return }
        // Check pattern
        var correct = 0
        var total = pcTargetPattern.filter { $0 != .clear }.count
        for i in 0..<9 {
            let target = pcTargetPattern[i]
            let user = pcUserPattern[i]
            if target == .clear && user == .clear { correct += 1 }
            else if target != .clear && user == target { correct += 1 }
        }
        let accuracy = Double(correct) / 9.0
        let points = Int(accuracy * Double(20 * pcRound))
        score += points
        pcResultOK = accuracy >= 0.7
        pcPhase = .result
        if pcResultOK { HapticManager.shared.success(); SoundManager.shared.playSuccess() }
        else { HapticManager.shared.warning() }
        pcRound += 1
        level = pcRound
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.startPatternCloneRound()
        }
    }

    var patternCloneView: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.2x2.fill").font(.system(size: 12)).foregroundColor(.purple)
                    Text("Round \(pcRound)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(ZStack { Capsule().fill(.ultraThinMaterial); Capsule().fill(Color.purple.opacity(0.2)) })
                .overlay(Capsule().stroke(Color.purple.opacity(0.5), lineWidth: 1))

                Spacer()

                Text(pcPhase == .showing ? "Memorize!" : pcPhase == .recalling ? "Recreate!" : (pcResultOK ? "✓ Correct!" : "Try again!"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(pcPhase == .result ? (pcResultOK ? .green : .orange) : .white.opacity(0.7))
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(Capsule().fill(.ultraThinMaterial))
            }
            .padding(.horizontal)

            // 3x3 grid
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 20).fill(Color.purple.opacity(0.06)))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.purple.opacity(0.25), lineWidth: 1))
                    .shadow(color: .purple.opacity(0.2), radius: 16)

                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(0..<3, id: \.self) { col in
                                let idx = row * 3 + col
                                patternCell(
                                    idx: idx,
                                    display: pcPhase == .showing ? pcTargetPattern[idx]
                                           : (pcPhase == .recalling || pcPhase == .result) ? pcUserPattern[idx] : .clear,
                                    isTarget: pcPhase == .result && pcTargetPattern[idx] != .clear
                                )
                                .onTapGesture { tapPatternCell(idx) }
                            }
                        }
                    }
                }
                .padding(18)
            }
            .padding(.horizontal)

            // Color palette (when recalling)
            if pcPhase == .recalling {
                VStack(spacing: 8) {
                    Text("Select color to paint:")
                        .font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 10) {
                        ForEach(pcColorPalette.prefix(6), id: \.self) { c in
                            Button(action: { pcSelectedColor = c; HapticManager.shared.selectionChanged() }) {
                                ZStack {
                                    Circle().fill(c).frame(width: 32, height: 32)
                                        .shadow(color: c.opacity(0.6), radius: pcSelectedColor == c ? 8 : 2)
                                    if pcSelectedColor == c {
                                        Circle().stroke(Color.white, lineWidth: 2).frame(width: 36, height: 36)
                                    }
                                }
                            }
                        }
                        // Clear
                        Button(action: { pcSelectedColor = .clear; HapticManager.shared.selectionChanged() }) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.1)).frame(width: 32, height: 32)
                                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                                Image(systemName: "xmark").font(.system(size: 12)).foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }

                    Button(action: { submitPatternClone() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Submit Pattern")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(ZStack {
                            RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 14).fill(Color.purple.opacity(0.5))
                        })
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.purple.opacity(0.7), lineWidth: 1.5))
                        .shadow(color: .purple.opacity(0.4), radius: 10)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    func patternCell(idx: Int, display: Color, isTarget: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 12).fill(display == .clear ? Color.white.opacity(0.04) : display.opacity(0.75)))
                .overlay(
                    display != .clear ?
                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [Color.white.opacity(0.25), Color.clear], startPoint: .top, endPoint: .bottom))
                            .frame(height: 18)
                        Spacer(minLength: 0)
                    }.clipShape(RoundedRectangle(cornerRadius: 12))
                    : nil
                )
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                    display != .clear ? display.opacity(0.6) : Color.white.opacity(0.1),
                    lineWidth: display != .clear ? 1.5 : 1
                ))
                .shadow(color: display != .clear ? display.opacity(0.4) : .clear, radius: 8)
                .frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: display == .clear)
    }

    // =========================================================================
    // MARK: - 29. COLOR BLITZ
    // =========================================================================
    func initColorBlitz() {
        cbQuadrantColors = [.red, .blue, .green, .yellow]
        cbPhase = .waiting
        shuffleColorBlitz()
    }

    func shuffleColorBlitz() {
        let pick = cbAllColors.shuffled().prefix(4)
        cbQuadrantColors = pick.map { $0.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.spawnColorBlitzTarget()
        }
    }

    func spawnColorBlitzTarget() {
        // Pick a color that exists in one of the quadrants
        let idx = Int.random(in: 0..<4)
        cbTargetColor = cbQuadrantColors[idx]
        cbTargetName = cbAllColors.first(where: { $0.0 == cbTargetColor })?.1 ?? "?"
        cbPhase = .flashing
        cbTimeLeft = 1.8
    }

    func updateColorBlitz() {
        guard cbPhase == .flashing else { return }
        cbTimeLeft -= 0.05
        if cbTimeLeft <= 0 {
            // Timed out — lose a life
            cbPhase = .feedback
            cbFeedback = "Too slow! -1 life"
            cbFeedbackColor = .red
            cbFeedbackOpacity = 1
            lives -= 1
            HapticManager.shared.error()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { self.cbFeedbackOpacity = 0 }
                self.shuffleColorBlitz()
            }
        }
    }

    func tapColorBlitzQuadrant(_ idx: Int) {
        guard cbPhase == .flashing else { return }
        let tapped = cbQuadrantColors[idx]
        if tapped == cbTargetColor {
            let timeBonus = Int(cbTimeLeft * 20)
            score += 15 + timeBonus
            cbPhase = .feedback
            cbFeedback = "+\(15 + timeBonus)"
            cbFeedbackColor = .green
            cbFeedbackOpacity = 1
            HapticManager.shared.success()
            SoundManager.shared.playSuccess()
        } else {
            lives -= 1
            cbPhase = .feedback
            cbFeedback = "Wrong! -1 life"
            cbFeedbackColor = .red
            cbFeedbackOpacity = 1
            HapticManager.shared.error()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation { self.cbFeedbackOpacity = 0 }
            self.shuffleColorBlitz()
        }
    }

    var colorBlitzView: some View {
        VStack(spacing: 0) {
            // Target color display
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 80)
                    .overlay(
                        Rectangle().fill(cbPhase == .flashing ? cbTargetColor.opacity(0.25) : Color.clear)
                            .animation(.easeInOut(duration: 0.3), value: cbPhase == .flashing)
                    )

                if cbPhase == .flashing {
                    HStack(spacing: 16) {
                        Text("TAP").font(.system(size: 16, weight: .heavy)).foregroundColor(.white.opacity(0.6)).tracking(3)
                        ZStack {
                            Circle().fill(cbTargetColor.opacity(0.3)).frame(width: 54, height: 54).blur(radius: 8)
                            Circle().fill(cbTargetColor).frame(width: 42, height: 42)
                                .shadow(color: cbTargetColor.opacity(0.8), radius: 12)
                            VStack {
                                Circle().fill(LinearGradient(colors: [Color.white.opacity(0.4), Color.clear], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 22, height: 22).offset(y: 4)
                                Spacer(minLength: 0)
                            }.frame(width: 42, height: 42).clipShape(Circle())
                        }
                        Text(cbTargetName)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(cbTargetColor)
                            .shadow(color: cbTargetColor.opacity(0.7), radius: 8)
                        // Timer bar
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.1)).frame(height: 6)
                                Capsule()
                                    .fill(cbTargetColor.opacity(0.9))
                                    .frame(width: g.size.width * CGFloat(max(0, cbTimeLeft / 1.8)), height: 6)
                                    .animation(.linear(duration: 0.05), value: cbTimeLeft)
                            }
                        }
                        .frame(width: 60, height: 6)
                    }
                } else {
                    Text("Get ready...")
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(.white.opacity(0.4))
                }
            }

            // Feedback overlay
            if cbFeedbackOpacity > 0.01 {
                Text(cbFeedback)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(cbFeedbackColor)
                    .opacity(cbFeedbackOpacity)
                    .shadow(color: cbFeedbackColor.opacity(0.6), radius: 8)
                    .padding(.vertical, 4)
                    .animation(.easeOut(duration: 0.4), value: cbFeedbackOpacity)
            }

            // 4 colored quadrants
            GeometryReader { geo in
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        colorBlitzQuadrant(idx: 0, geo: geo)
                        colorBlitzQuadrant(idx: 1, geo: geo)
                    }
                    HStack(spacing: 4) {
                        colorBlitzQuadrant(idx: 2, geo: geo)
                        colorBlitzQuadrant(idx: 3, geo: geo)
                    }
                }
                .padding(4)
            }
        }
    }

    func colorBlitzQuadrant(idx: Int, geo: GeometryProxy) -> some View {
        let c = cbQuadrantColors[idx]
        let isTarget = c == cbTargetColor && cbPhase == .flashing
        return Button(action: { tapColorBlitzQuadrant(idx) }) {
            ZStack {
                // Base fill
                RoundedRectangle(cornerRadius: 20)
                    .fill(c.opacity(isTarget ? 0.55 : 0.3))
                // Specular
                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [Color.white.opacity(0.2), Color.clear], startPoint: .top, endPoint: .bottom))
                        .frame(height: 30)
                    Spacer(minLength: 0)
                }.clipShape(RoundedRectangle(cornerRadius: 20))
                // Border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(c.opacity(isTarget ? 0.9 : 0.4), lineWidth: isTarget ? 3 : 1.5)
                // Pulse ring when target
                if isTarget {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(c.opacity(0.5), lineWidth: 2)
                        .scaleEffect(1.04)
                        .blur(radius: 3)
                }
                // Color name label
                Text(cbAllColors.first(where: { $0.0 == c })?.1 ?? "")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(isTarget ? 1.0 : 0.75))
                    .shadow(color: c.opacity(0.7), radius: isTarget ? 10 : 3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .shadow(color: c.opacity(isTarget ? 0.5 : 0.15), radius: isTarget ? 16 : 6)
            .scaleEffect(isTarget ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTarget)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // =========================================================================
    // MARK: - 30. SYNC BEAT
    // =========================================================================
    func initSyncBeat() {
        sbBPM = 60
        sbBeatInterval = 60.0 / sbBPM
        sbBeatTime = 0
        sbBeatsCompleted = 0
        sbTotalBeats = 0
        sbAccumTime = 0
        sbBeatFlash = false
    }

    func updateSyncBeat() {
        sbAccumTime += 0.05
        sbBeatTime += 0.05
        if sbBeatTime >= sbBeatInterval {
            sbBeatTime = 0
            sbTotalBeats += 1
            // Flash beat indicator
            withAnimation(.easeOut(duration: 0.1)) { sbBeatFlash = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeIn(duration: 0.2)) { self.sbBeatFlash = false }
            }
            // Increase BPM over time
            if sbAccumTime > 15 { sbBPM = 80; sbBeatInterval = 60.0/sbBPM }
            if sbAccumTime > 30 { sbBPM = 100; sbBeatInterval = 60.0/sbBPM }
            if sbAccumTime > 45 { sbBPM = 120; sbBeatInterval = 60.0/sbBPM }
        }
    }

    func tapSyncBeat() {
        guard isActive else { return }
        // How close to the nearest beat?
        let nearestBeat = round(sbBeatTime / sbBeatInterval) * sbBeatInterval
        let offset = abs(sbBeatTime - nearestBeat)
        let tolerance = sbBeatInterval
        let accuracy = max(0, 1.0 - (offset / (tolerance * 0.5)))
        let points: Int
        if offset < 0.08 { points = 25; HapticManager.shared.success() }
        else if offset < 0.15 { points = 15; HapticManager.shared.mediumTap() }
        else if offset < 0.25 { points = 8; HapticManager.shared.lightTap() }
        else { points = 2; HapticManager.shared.warning() }
        score += points
        sbBeatsCompleted += 1
        _ = accuracy
    }

    var syncBeatView: some View {
        VStack(spacing: 24) {
            // BPM display
            HStack(spacing: 10) {
                Image(systemName: "metronome.fill").foregroundColor(.orange)
                Text("\(Int(sbBPM)) BPM")
                    .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "hand.tap.fill").font(.system(size: 11)).foregroundColor(.orange.opacity(0.7))
                    Text("\(sbBeatsCompleted) taps").font(.system(size: 13)).foregroundColor(.orange.opacity(0.8))
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(ZStack {
                RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 14).fill(Color.orange.opacity(0.12))
            })
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.4), lineWidth: 1))
            .padding(.horizontal)

            Spacer()

            // Beat visualizer
            ZStack {
                // Outer pulse ring
                Circle()
                    .stroke(Color.orange.opacity(sbBeatFlash ? 0.6 : 0.12), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(sbBeatFlash ? 1.08 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: sbBeatFlash)

                // Beat progress ring
                Circle()
                    .trim(from: 0, to: CGFloat(1.0 - sbBeatTime / sbBeatInterval))
                    .stroke(
                        AngularGradient(colors: [.orange, .yellow, .orange], center: .center),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 175, height: 175)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.05), value: sbBeatTime)

                // Central tap orb
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(sbBeatFlash ? 0.5 : 0.2))
                        .frame(width: 145, height: 145)
                        .blur(radius: sbBeatFlash ? 16 : 6)
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 130, height: 130)
                        .overlay(Circle().fill(LinearGradient(
                            colors: [Color.orange.opacity(sbBeatFlash ? 0.7 : 0.3), Color.yellow.opacity(0.2)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )))
                        .overlay(
                            VStack {
                                Circle().fill(LinearGradient(colors: [Color.white.opacity(0.25), Color.clear], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 65, height: 65).offset(y: 6)
                                Spacer(minLength: 0)
                            }.frame(width: 130, height: 130).clipShape(Circle())
                        )
                        .overlay(Circle().stroke(Color.orange.opacity(sbBeatFlash ? 0.9 : 0.35), lineWidth: sbBeatFlash ? 2.5 : 1.5))
                        .shadow(color: .orange.opacity(sbBeatFlash ? 0.7 : 0.2), radius: sbBeatFlash ? 22 : 8)
                    VStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 28, weight: .semibold))
                        Text("TAP")
                            .font(.system(size: 14, weight: .black)).tracking(3)
                    }
                    .foregroundStyle(LinearGradient(colors: [.white, .orange.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                }
                .scaleEffect(sbBeatFlash ? 0.95 : 1.0)
                .animation(.spring(response: 0.15, dampingFraction: 0.6), value: sbBeatFlash)
                .onTapGesture { tapSyncBeat() }
            }

            Spacer()

            // Rhythm hint dots
            HStack(spacing: 10) {
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(Double(i) / 8.0 < (1.0 - sbBeatTime / sbBeatInterval)
                              ? Color.orange.opacity(0.8) : Color.white.opacity(0.15))
                        .frame(width: 8, height: 8)
                        .animation(.linear(duration: 0.05), value: sbBeatTime)
                }
            }
            .padding(.bottom, 16)
        }
        .padding(.top, 8)
    }

    // =========================================================================
    // MARK: - 31. PULSE LOCK
    // =========================================================================
    func initPulseLock() {
        plPhase = .inhale
        plPhaseTime = 0
        plCycles = 0
        plSyncScore = 0
        plOrbScale = 0.6
        plIsPressed = false
    }

    func updatePulseLock() {
        let dt = 0.05
        plPhaseTime += dt
        let dur = plPhase == .inhale ? plInhaleDur : plExhaleDur
        // Progress of current phase 0→1
        let progress = min(plPhaseTime / dur, 1.0)
        // Orb scale: inhale = 0.6→1.0, exhale = 1.0→0.6
        if plPhase == .inhale {
            plOrbScale = 0.6 + 0.4 * progress
            // Score: press should be held
            if plIsPressed { plSyncScore += dt / dur }
        } else {
            plOrbScale = 1.0 - 0.4 * progress
            // Score: press should be released
            if !plIsPressed { plSyncScore += dt / dur }
        }
        if plPhaseTime >= dur {
            plPhaseTime = 0
            if plPhase == .inhale {
                plPhase = .exhale
            } else {
                plPhase = .inhale
                plCycles += 1
                // Award points per cycle
                let cyclePoints = Int(plSyncScore * 30.0 / Double(max(plCycles, 1)))
                score += cyclePoints
                HapticManager.shared.lightTap()
            }
        }
    }

    var pulseLockView: some View {
        VStack(spacing: 20) {
            // Phase indicator
            HStack(spacing: 12) {
                Image(systemName: plPhase == .inhale ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .foregroundColor(plPhase == .inhale ? .cyan : .green)
                    .font(.system(size: 16))
                Text(plPhase == .inhale ? "Hold — Inhale" : "Release — Exhale")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Text("\(plCycles) cycles")
                    .font(.system(size: 13)).foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(ZStack {
                RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 14).fill((plPhase == .inhale ? Color.cyan : Color.green).opacity(0.15))
            })
            .overlay(RoundedRectangle(cornerRadius: 14).stroke((plPhase == .inhale ? Color.cyan : Color.green).opacity(0.4), lineWidth: 1))
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.4), value: plPhase)

            Spacer()

            // Orb
            let orbColor: Color = plPhase == .inhale ? .cyan : .green
            ZStack {
                // Outer glow
                Circle()
                    .fill(orbColor.opacity(0.2))
                    .frame(width: 220, height: 220)
                    .blur(radius: 28)
                    .scaleEffect(plOrbScale)

                // Main orb
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 180, height: 180)
                    .overlay(Circle().fill(LinearGradient(
                        colors: [orbColor.opacity(plIsPressed ? 0.65 : 0.3), orbColor.opacity(0.1)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )))
                    .overlay(
                        VStack {
                            Circle().fill(LinearGradient(colors: [Color.white.opacity(0.28), Color.clear], startPoint: .top, endPoint: .bottom))
                                .frame(width: 90, height: 90).offset(y: 10)
                            Spacer(minLength: 0)
                        }.frame(width: 180, height: 180).clipShape(Circle())
                    )
                    .overlay(Circle().stroke(orbColor.opacity(plIsPressed ? 0.9 : 0.4), lineWidth: plIsPressed ? 2.5 : 1.5))
                    .shadow(color: orbColor.opacity(plIsPressed ? 0.6 : 0.25), radius: plIsPressed ? 24 : 10)
                    .scaleEffect(plOrbScale)
                    .animation(.easeInOut(duration: 0.1), value: plOrbScale)

                // Inner instruction
                VStack(spacing: 6) {
                    Image(systemName: plPhase == .inhale ? "hand.point.down.fill" : "hand.raised.fill")
                        .font(.system(size: 22))
                    Text(plPhase == .inhale ? "HOLD" : "RELEASE")
                        .font(.system(size: 13, weight: .black)).tracking(2)
                }
                .foregroundColor(.white)
                .scaleEffect(plOrbScale * 0.9 + 0.1)
                .animation(.easeInOut(duration: 0.1), value: plOrbScale)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !plIsPressed { plIsPressed = true; HapticManager.shared.lightTap() }
                    }
                    .onEnded { _ in plIsPressed = false; HapticManager.shared.lightTap() }
            )

            Spacer()

            // Sync progress bar
            VStack(spacing: 6) {
                Text("Sync Accuracy")
                    .font(.system(size: 11, weight: .medium)).foregroundColor(.white.opacity(0.4)).tracking(1)
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.1)).frame(height: 8)
                        Capsule()
                            .fill(LinearGradient(colors: [.cyan, .green], startPoint: .leading, endPoint: .trailing))
                            .frame(width: g.size.width * CGFloat(min(plSyncScore / Double(max(plCycles, 1) * 2), 1.0)), height: 8)
                            .animation(.linear(duration: 0.05), value: plSyncScore)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .padding(.top, 8)
    }

    // =========================================================================
    // MARK: - 32. WORD ZEN
    // =========================================================================
    func initWordZen() {
        wzWords = []
        wzZenTapped = 0
        wzFalseAlerts = 0
        wzSpawnTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            Task { @MainActor in self.spawnWordZen() }
        }
        wzMoveTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in self.moveWordZen() }
        }
    }

    func spawnWordZen() {
        guard isActive else { return }
        let isZen = Double.random(in: 0...1) < 0.3
        let text = isZen ? wzZenWords.randomElement()! : wzNoiseWords.randomElement()!
        wzWords.append(FloatingWord(
            text: text,
            isZen: isZen,
            posX: CGFloat.random(in: 40...340),
            posY: 680,
            opacity: 1.0,
            speed: CGFloat.random(in: 40...70)
        ))
        // Trim old
        wzWords = wzWords.filter { !$0.tapped && $0.opacity > 0.01 }.suffix(20).map { $0 }
    }

    func moveWordZen() {
        guard isActive else { return }
        for i in wzWords.indices {
            wzWords[i].posY -= wzWords[i].speed * 0.05
            if wzWords[i].posY < 80 && !wzWords[i].tapped {
                // Zen word escaped = lose a life
                if wzWords[i].isZen {
                    lives -= 1
                    HapticManager.shared.warning()
                }
                wzWords[i].opacity = 0
                wzWords[i].tapped = true
            }
        }
        wzWords = wzWords.filter { $0.opacity > 0.01 || !$0.tapped }.suffix(20).map { $0 }
    }

    func tapWordZen(id: UUID) {
        guard let idx = wzWords.firstIndex(where: { $0.id == id }),
              !wzWords[idx].tapped else { return }
        if wzWords[idx].isZen {
            score += 20
            wzZenTapped += 1
            HapticManager.shared.success()
            SoundManager.shared.playSuccess()
        } else {
            lives -= 1
            wzFalseAlerts += 1
            HapticManager.shared.error()
        }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            wzWords[idx].opacity = 0
            wzWords[idx].tapped = true
        }
    }

    var wordZenView: some View {
        ZStack {
            // Ambient
            Circle().fill(Color.teal.opacity(0.1)).frame(width: 280, height: 280).blur(radius: 50).offset(y: 50)

            VStack(spacing: 0) {
                // Stats
                HStack(spacing: 12) {
                    HStack(spacing: 5) {
                        Image(systemName: "leaf.fill").font(.system(size: 11)).foregroundColor(.teal)
                        Text("Zen: \(wzZenTapped)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(ZStack { Capsule().fill(.ultraThinMaterial); Capsule().fill(Color.teal.opacity(0.2)) })
                    .overlay(Capsule().stroke(Color.teal.opacity(0.5), lineWidth: 1))

                    Spacer()

                    HStack(spacing: 5) {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 11)).foregroundColor(.red.opacity(0.7))
                        Text("False: \(wzFalseAlerts)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(ZStack { Capsule().fill(.ultraThinMaterial); Capsule().fill(Color.red.opacity(0.12)) })
                    .overlay(Capsule().stroke(Color.red.opacity(0.35), lineWidth: 1))
                }
                .padding(.horizontal, 16).padding(.bottom, 8)

                // Word arena
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 20).fill(Color.teal.opacity(0.04)))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.teal.opacity(0.2), lineWidth: 1))

                    // Guide text
                    Text("Tap only ZEN words")
                        .font(.system(size: 13, weight: .medium)).foregroundColor(.white.opacity(0.2))
                        .tracking(1)

                    ForEach(wzWords) { word in
                        wordZenPill(word: word)
                            .position(x: word.posX, y: word.posY - 100)
                            .opacity(word.opacity)
                            .onTapGesture { tapWordZen(id: word.id) }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 8)

                // Legend
                HStack(spacing: 16) {
                    HStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.teal.opacity(0.5)).frame(width: 12, height: 12)
                        Text("Zen = TAP").font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
                    }
                    HStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.3)).frame(width: 12, height: 12)
                        Text("Noise = IGNORE").font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    func wordZenPill(word: FloatingWord) -> some View {
        Text(word.text)
            .font(.system(size: word.isZen ? 17 : 15, weight: word.isZen ? .bold : .medium))
            .foregroundColor(word.isZen ? .white : .white.opacity(0.5))
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(
                ZStack {
                    Capsule().fill(.ultraThinMaterial)
                    Capsule().fill(word.isZen ? Color.teal.opacity(0.35) : Color.white.opacity(0.04))
                }
            )
            .overlay(Capsule().stroke(word.isZen ? Color.teal.opacity(0.7) : Color.white.opacity(0.12), lineWidth: word.isZen ? 1.5 : 1))
            .shadow(color: word.isZen ? .teal.opacity(0.4) : .clear, radius: 6)
    }

    // =========================================================================
    // MARK: - 33. CALM SCROLL
    // =========================================================================
    func initCalmScroll() {
        let apps = ["Instagram", "Twitter", "TikTok", "Facebook", "Reddit", "YouTube"]
        let noiseContents = [
            "This VIRAL video will SHOCK you 🔥 Like & Share NOW!!",
            "Hot take: everyone needs to see this thread RIGHT NOW",
            "Breaking: you won't believe what just happened 😱",
            "Double tap if you agree! ❤️ Comment your thoughts below",
            "This is blowing up for a reason... join the conversation",
            "NEW DROP just hit — limited time only! Tap to grab yours",
            "Tag someone who NEEDS to see this lol 😂😂",
            "RT this if you've felt this way before 💯",
        ]
        let focusContents = [
            "✅ FOCUS: What's one thing you can do right now?",
            "✅ FOCUS: Take a breath. You've got this.",
            "✅ FOCUS: One task at a time. Stay present.",
        ]
        var posts: [ScrollPost] = []
        for i in 0..<20 {
            let isFocus = (i % 7 == 5)
            posts.append(ScrollPost(
                app: apps.randomElement()!,
                content: isFocus ? focusContents.randomElement()! : noiseContents.randomElement()!,
                isFocus: isFocus
            ))
        }
        csPosts = posts
        csFocusTapped = 0
        csWrongTaps = 0
        csScrollOffset = 0
        // Auto scroll
        csScrollTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in
                if self.isActive {
                    self.csScrollOffset -= 0.8
                }
            }
        }
    }

    func tapScrollPost(id: UUID) {
        guard let idx = csPosts.firstIndex(where: { $0.id == id }),
              !csPosts[idx].tapped else { return }
        csPosts[idx].tapped = true
        if csPosts[idx].isFocus {
            score += 25
            csFocusTapped += 1
            HapticManager.shared.success()
            SoundManager.shared.playSuccess()
        } else {
            lives -= 1
            csWrongTaps += 1
            HapticManager.shared.error()
        }
    }

    var calmScrollView: some View {
        VStack(spacing: 0) {
            // Stats bar
            HStack(spacing: 12) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 11)).foregroundColor(.green)
                    Text("Focus: \(csFocusTapped)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(ZStack { Capsule().fill(.ultraThinMaterial); Capsule().fill(Color.green.opacity(0.2)) })
                .overlay(Capsule().stroke(Color.green.opacity(0.5), lineWidth: 1))

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "hand.raised.fill").font(.system(size: 11)).foregroundColor(.red.opacity(0.7))
                    Text("Resist!").font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Capsule().fill(.ultraThinMaterial))
            }
            .padding(.horizontal, 16).padding(.bottom, 6)

            // Scrolling feed
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))

                // Clip and translate
                VStack(spacing: 0) {
                    ForEach(csPosts) { post in
                        calmScrollPostView(post: post)
                    }
                }
                .offset(y: csScrollOffset)
                .animation(.linear(duration: 0.05), value: csScrollOffset)
                .clipped()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 8)
            .clipped()
        }
    }

    func calmScrollPostView(post: ScrollPost) -> some View {
        let appIcons: [String: (String, Color)] = [
            "Instagram": ("camera.fill", .pink),
            "Twitter": ("bird.fill", .cyan),
            "TikTok": ("music.note", .white),
            "Facebook": ("person.2.fill", .blue),
            "Reddit": ("bubble.left.and.bubble.right.fill", .orange),
            "YouTube": ("play.rectangle.fill", .red),
        ]
        let (icon, iconColor) = appIcons[post.app] ?? ("app.fill", .gray)
        return HStack(alignment: .top, spacing: 10) {
            // App icon
            ZStack {
                Circle().fill(iconColor.opacity(0.2)).frame(width: 34, height: 34)
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(post.app).font(.system(size: 12, weight: .semibold)).foregroundColor(.white.opacity(0.6))
                Text(post.content)
                    .font(.system(size: 14, weight: post.isFocus ? .semibold : .regular))
                    .foregroundColor(post.isFocus ? .white : .white.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                if post.isFocus {
                    Text("TAP TO FOCUS").font(.system(size: 10, weight: .black)).foregroundColor(.green).tracking(1)
                } else {
                    HStack(spacing: 12) {
                        Label("Like", systemImage: "heart").font(.system(size: 11)).foregroundColor(.white.opacity(0.3))
                        Label("Comment", systemImage: "bubble.left").font(.system(size: 11)).foregroundColor(.white.opacity(0.3))
                    }
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(post.isFocus ? Color.green.opacity(post.tapped ? 0.05 : 0.12) : Color.clear)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(post.isFocus ? Color.green.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1))
        )
        .opacity(post.tapped ? 0.4 : 1.0)
        .onTapGesture { tapScrollPost(id: post.id) }
        .animation(.easeInOut(duration: 0.3), value: post.tapped)
    }

    // =========================================================================
    // MARK: - 34. SHAPE DROP
    // =========================================================================
    func initShapeDrop() {
        sdTarget = HuntShapeType.allCases.randomElement()!
        sdShapes = []
        sdLevel = 1
        sdSpawnTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            Task { @MainActor in self.spawnDropShape() }
        }
        sdMoveTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in self.moveDropShapes() }
        }
    }

    func spawnDropShape() {
        guard isActive else { return }
        let isTarget = Double.random(in: 0...1) < 0.4
        let type = isTarget ? sdTarget : HuntShapeType.allCases.filter { $0 != sdTarget }.randomElement()!
        sdShapes.append(DroppingShape(
            type: type,
            posX: CGFloat.random(in: 40...340),
            posY: -40,
            speed: CGFloat(60 + sdLevel * 15)
        ))
        if sdShapes.count > 12 { sdShapes.removeFirst() }
    }

    func moveDropShapes() {
        guard isActive else { return }
        for i in sdShapes.indices {
            if !sdShapes[i].tapped {
                sdShapes[i].posY += sdShapes[i].speed * 0.05
                if sdShapes[i].posY > 720 {
                    if sdShapes[i].type == sdTarget {
                        lives -= 1
                        HapticManager.shared.warning()
                    }
                    sdShapes[i].opacity = 0
                    sdShapes[i].tapped = true
                }
            }
        }
        sdShapes = sdShapes.filter { $0.opacity > 0.01 && !($0.tapped && $0.opacity < 0.1) }.suffix(12).map { $0 }
    }

    func updateShapeDrop() {
        // Level up every 15 points
        sdLevel = max(1, score / 30 + 1)
    }

    func tapDropShape(id: UUID) {
        guard let idx = sdShapes.firstIndex(where: { $0.id == id }),
              !sdShapes[idx].tapped else { return }
        let shape = sdShapes[idx]
        if shape.type == sdTarget {
            score += 15
            HapticManager.shared.mediumTap()
            SoundManager.shared.playSuccess()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                sdShapes[idx].opacity = 0
                sdShapes[idx].tapped = true
            }
        } else {
            lives -= 1
            HapticManager.shared.error()
            withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
                sdShapes[idx].posX += CGFloat.random(in: -20...20)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.sdShapes[idx].tapped = true
                self.sdShapes[idx].opacity = 0
            }
        }
    }

    var shapeDropView: some View {
        ZStack {
            // Background glow
            Circle().fill(Color.red.opacity(0.08)).frame(width: 300, height: 300).blur(radius: 60).offset(y: 50)

            VStack(spacing: 8) {
                // Target indicator
                HStack(spacing: 12) {
                    Text("DROP")
                        .font(.system(size: 11, weight: .bold)).foregroundColor(.red.opacity(0.8)).tracking(1)
                    ZStack {
                        Circle().fill(sdTarget.color.opacity(0.25)).frame(width: 44, height: 44)
                            .shadow(color: sdTarget.color.opacity(0.5), radius: 8)
                        Image(systemName: sdTarget.sfSymbol)
                            .font(.system(size: 20)).foregroundColor(sdTarget.color)
                    }
                    Text(String(describing: sdTarget).capitalized)
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "speedometer").font(.system(size: 11)).foregroundColor(.orange)
                        Text("Lv.\(sdLevel)").font(.system(size: 13, weight: .bold)).foregroundColor(.orange)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Capsule().fill(.ultraThinMaterial))
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(ZStack {
                    Capsule().fill(.ultraThinMaterial)
                    Capsule().fill(sdTarget.color.opacity(0.1))
                })
                .overlay(Capsule().stroke(sdTarget.color.opacity(0.4), lineWidth: 1))
                .padding(.horizontal)

                // Drop arena
                GeometryReader { _ in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(RoundedRectangle(cornerRadius: 20).fill(Color.red.opacity(0.03)))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))

                        ForEach(sdShapes) { shape in
                            if !shape.tapped || shape.opacity > 0.01 {
                                droppingShapeView(shape: shape)
                                    .position(x: shape.posX, y: shape.posY - 60)
                                    .opacity(shape.opacity)
                                    .onTapGesture { tapDropShape(id: shape.id) }
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }

    func droppingShapeView(shape: DroppingShape) -> some View {
        let isTarget = shape.type == sdTarget
        return ZStack {
            Circle()
                .fill(isTarget ? shape.type.color.opacity(0.35) : Color.white.opacity(0.08))
                .frame(width: 56, height: 56)
                .blur(radius: isTarget ? 8 : 2)
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 44, height: 44)
                .overlay(Circle().fill(isTarget ? shape.type.color.opacity(0.5) : shape.type.color.opacity(0.2)))
                .overlay(
                    VStack {
                        Circle().fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                            .frame(width: 22, height: 22).offset(y: 3)
                        Spacer(minLength: 0)
                    }.frame(width: 44, height: 44).clipShape(Circle())
                )
                .overlay(Circle().stroke(isTarget ? shape.type.color.opacity(0.8) : Color.white.opacity(0.15), lineWidth: isTarget ? 1.5 : 1))
                .shadow(color: isTarget ? shape.type.color.opacity(0.5) : .clear, radius: 8)
            Image(systemName: shape.type.sfSymbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isTarget ? .white : shape.type.color.opacity(0.6))
        }
    }

    // =========================================================================
    // MARK: - 35. MEMORY MAZE
    // =========================================================================
    func initMemoryMaze() {
        mmRound = 1
        mmPath = []
        mmUserPath = []
        mmPhase = .showing
        mmNextExpected = 0
        startMazeRound()
    }

    func startMazeRound() {
        let pathLength = min(2 + mmRound, 10)
        var path: [Int] = []
        var last = Int.random(in: 0..<16)
        path.append(last)
        for _ in 1..<pathLength {
            // Pick adjacent cell
            let row = last / 4; let col = last % 4
            var candidates: [Int] = []
            if row > 0 { candidates.append((row-1)*4+col) }
            if row < 3 { candidates.append((row+1)*4+col) }
            if col > 0 { candidates.append(row*4+(col-1)) }
            if col < 3 { candidates.append(row*4+(col+1)) }
            let next = candidates.filter { !path.contains($0) }.randomElement() ?? candidates.randomElement()!
            path.append(next)
            last = next
        }
        mmPath = path
        mmUserPath = []
        mmNextExpected = 0
        mmPhase = .showing
        mmFlashIndex = -1
        flashMazePath()
    }

    func flashMazePath() {
        var delay = 0.0
        for i in mmPath.indices {
            let captured = i
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: 0.2)) { self.mmFlashIndex = self.mmPath[captured] }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.easeOut(duration: 0.2)) { self.mmFlashIndex = -1 }
                }
            }
            delay += 0.65
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.3) {
            self.mmPhase = .recalling
        }
    }

    func tapMazeCell(_ idx: Int) {
        guard mmPhase == .recalling else { return }
        guard !mmUserPath.contains(idx) else { return }
        mmUserPath.append(idx)
        HapticManager.shared.lightTap()

        if mmUserPath.count <= mmPath.count && mmUserPath.last == mmPath[mmUserPath.count - 1] {
            // Correct so far
            mmNextExpected += 1
            if mmUserPath.count == mmPath.count {
                // Completed!
                score += 15 * mmRound
                mmPhase = .result
                mmRound += 1
                level = mmRound
                HapticManager.shared.success()
                SoundManager.shared.playLevelUp()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.startMazeRound()
                }
            }
        } else {
            // Wrong
            lives -= 1
            mmPhase = .result
            HapticManager.shared.error()
            SoundManager.shared.playFail()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.startMazeRound()
            }
        }
    }

    var memoryMazeView: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "map.fill").font(.system(size: 12)).foregroundColor(.purple)
                    Text("Path \(mmRound)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    Text("• \(mmPath.count) steps").font(.system(size: 12)).foregroundColor(.purple.opacity(0.7))
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(ZStack { Capsule().fill(.ultraThinMaterial); Capsule().fill(Color.purple.opacity(0.2)) })
                .overlay(Capsule().stroke(Color.purple.opacity(0.5), lineWidth: 1))

                Spacer()

                Text(mmPhase == .showing ? "Watch!" : mmPhase == .recalling ? "Trace the path!" : (mmUserPath.count == mmPath.count ? "Perfect!" : "Wrong!"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(mmPhase == .result ? (mmUserPath.count == mmPath.count ? .green : .red) : .white.opacity(0.7))
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(Capsule().fill(.ultraThinMaterial))
            }
            .padding(.horizontal)

            // 4x4 grid
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 20).fill(Color.purple.opacity(0.06)))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.purple.opacity(0.25), lineWidth: 1))
                    .shadow(color: .purple.opacity(0.2), radius: 16)

                VStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(0..<4, id: \.self) { col in
                                let idx = row * 4 + col
                                mazeCellView(idx: idx)
                                    .onTapGesture { tapMazeCell(idx) }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .padding(.horizontal)

            // Step progress
            if mmPhase == .recalling {
                HStack(spacing: 6) {
                    ForEach(mmPath.indices, id: \.self) { i in
                        Circle()
                            .fill(i < mmUserPath.count ? Color.purple : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    func mazeCellView(idx: Int) -> some View {
        let isInPath = mmPath.contains(idx)
        let isFlashing = mmFlashIndex == idx
        let userOrder = mmUserPath.firstIndex(of: idx)
        let isUserTapped = userOrder != nil
        let pathOrder = mmPath.firstIndex(of: idx)

        let cellColor: Color = isFlashing ? .purple
            : isUserTapped ? .cyan
            : (mmPhase == .result && isInPath) ? .purple.opacity(0.4)
            : .clear

        return ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 10).fill(cellColor.opacity(isFlashing || isUserTapped ? 0.7 : 0.1)))
                .overlay(
                    (isFlashing || isUserTapped) ?
                    VStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: [Color.white.opacity(0.25), Color.clear], startPoint: .top, endPoint: .bottom))
                            .frame(height: 12)
                        Spacer(minLength: 0)
                    }.clipShape(RoundedRectangle(cornerRadius: 10))
                    : nil
                )
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(
                    isFlashing ? Color.purple.opacity(0.9)
                    : isUserTapped ? Color.cyan.opacity(0.7)
                    : Color.white.opacity(0.08),
                    lineWidth: isFlashing || isUserTapped ? 2 : 1
                ))
                .shadow(color: isFlashing ? .purple.opacity(0.7) : isUserTapped ? .cyan.opacity(0.4) : .clear, radius: isFlashing ? 14 : 6)
                .frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)

            if isUserTapped, let order = userOrder {
                Text("\(order + 1)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            } else if isFlashing, let order = pathOrder {
                Text("\(order + 1)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isFlashing)
        .animation(.spring(response: 0.2, dampingFraction: 0.65), value: isUserTapped)
    }

} // end UniversalChallengeView

// MARK: - Challenge Preview Icon (animated)
struct ChallengePreviewIcon: View {
    let color: Color
    let icon: String
    @State private var pulse = false
    @State private var rotate = false

    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(color.opacity(pulse ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: 170, height: 170)
                .scaleEffect(pulse ? 1.06 : 0.97)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulse)
                .blur(radius: 2)

            // Spinning gradient ring
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.8), color.opacity(0.3), Color.clear],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .animation(.linear(duration: 5).repeatForever(autoreverses: false), value: rotate)

            // Glass orb
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 118, height: 118)
                .overlay(
                    Circle()
                        .fill(LinearGradient(colors: [color.opacity(0.35), color.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .overlay(
                    Circle()
                        .fill(LinearGradient(colors: [Color.white.opacity(0.25), Color.clear], startPoint: .topLeading, endPoint: .center))
                )
                .shadow(color: color.opacity(0.55), radius: 24)

            Image(systemName: icon)
                .font(.system(size: 46, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(colors: [.white, color.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: color.opacity(0.4), radius: 8)
        }
        .onAppear { pulse = true; rotate = true }
    }
}

// MARK: - Preview Stat Pill
struct PreviewStatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 16).fill(color.opacity(0.07))
                VStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: [Color.white.opacity(0.15), Color.clear], startPoint: .top, endPoint: .bottom))
                        .frame(height: 18)
                    Spacer(minLength: 0)
                }.clipShape(RoundedRectangle(cornerRadius: 16))
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.35), lineWidth: 1))
        .shadow(color: color.opacity(0.2), radius: 8)
    }
}

// MARK: - Result Reward Item
struct ResultRewardItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 6)
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ResultDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 1, height: 50)
    }
}

// MARK: - Results Confetti Piece
struct ResultsConfettiPiece: View {
    let color: Color
    let delay: Double
    @State private var position: CGPoint = CGPoint(x: 0, y: 0)
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 8...16))
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                position = CGPoint(x: CGFloat.random(in: 50...350), y: -20)
                withAnimation(.easeIn(duration: Double.random(in: 1.5...3.0)).delay(delay)) {
                    position = CGPoint(x: CGFloat.random(in: 0...400), y: UIScreen.main.bounds.height + 40)
                    rotation = Double.random(in: 180...720)
                }
                withAnimation(.linear(duration: 1.0).delay(delay + 1.2)) {
                    opacity = 0
                }
            }
    }
}

// Color(hex:) is defined in ContentView.swift

// MARK: - Preview
#Preview {
    UniversalChallengeView(challenge: .targetHunt)
        .environmentObject(AppState())
}
