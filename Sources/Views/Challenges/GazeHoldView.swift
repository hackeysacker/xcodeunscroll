import SwiftUI

// MARK: - Gaze Hold Challenge View
// Train your ability to maintain focus on a single point

struct GazeHoldView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var gameState = GazeHoldGameState()
    
    let onComplete: ((Int) -> Void)?
    
    init(onComplete: ((Int) -> Void)? = nil) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                Spacer()
                
                // Game area
                gameArea
                
                Spacer()
                
                // Instructions
                instructions
            }
            .padding()
        }
        .onChange(of: gameState.gamePhase) { _, newPhase in
            if newPhase == .completed {
                let score = gameState.score
                onComplete?(score)
                gameState.showResults = true
            }
        }
        .sheet(isPresented: $gameState.showResults) {
            ResultsView(
                score: gameState.score,
                maxScore: gameState.maxScore,
                xpEarned: gameState.xpEarned,
                message: gameState.resultMessage,
                onDismiss: {
                    gameState.showResults = false
                    dismiss()
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("GAZE HOLD")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Hold your focus")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Score display
            Text("\(gameState.score)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(gameState.scoreColor)
                .frame(width: 60)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    var gameArea: some View {
        ZStack {
            // Outer ring (stability zone)
            Circle()
                .stroke(gameState.isInZone ? Color.green.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 4)
                .frame(width: 200, height: 200)
            
            // Middle ring
            Circle()
                .stroke(gameState.isInZone ? Color.green.opacity(0.5) : Color.white.opacity(0.15), lineWidth: 3)
                .frame(width: 140, height: 140)
            
            // Inner target circle
            Circle()
                .fill(gameState.isInZone ? Color.green.opacity(0.4) : Color.white.opacity(0.1))
                .frame(width: 80, height: 80)
            
            // Center dot
            Circle()
                .fill(gameState.isInZone ? Color.green : Color.white.opacity(0.5))
                .frame(width: 20, height: 20)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(gameState.stabilityTime) / CGFloat(gameState.requiredStability))
                .stroke(
                    gameState.isInZone ? Color.green : Color.orange,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: gameState.stabilityTime)
            
            // Hold indicator
            if gameState.gamePhase == .playing && gameState.isHolding {
                VStack {
                    Text("HOLDING")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                    Text("\(gameState.requiredStability - gameState.stabilityTime)/\(gameState.requiredStability)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    gameState.handleTouch(true)
                }
                .onEnded { _ in
                    gameState.handleTouch(false)
                }
        )
        .scaleEffect(gameState.isHolding ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: gameState.isHolding)
    }
    
    var instructions: some View {
        VStack(spacing: 8) {
            switch gameState.gamePhase {
            case .ready:
                Text("Touch and hold the circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                Text("Keep your finger steady to build stability")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                
                Button(action: { gameState.startGame() }) {
                    Text("START")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(25)
                }
                .padding(.top, 20)
                
            case .playing:
                if gameState.isInZone {
                    Text("Perfect! Hold steady...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.green)
                } else {
                    Text("Stay inside the circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.orange)
                }
                
            case .completed:
                EmptyView()
            }
        }
        .padding()
    }
}

// MARK: - Game State
@MainActor
class GazeHoldGameState: ObservableObject {
    @Published var gamePhase: GamePhase = .ready
    @Published var score: Int = 0
    @Published var maxScore: Int = 100
    @Published var xpEarned: Int = 30
    @Published var stabilityTime: Int = 0
    @Published var requiredStability: Int = 60 // frames (about 1 second at 60fps)
    @Published var isHolding: Bool = false
    @Published var isInZone: Bool = false
    @Published var showResults: Bool = false
    @Published var resultMessage: String = ""
    
    private var gameTimer: Timer?
    private var stabilityCheckTimer: Timer?
    
    var scoreColor: Color {
        let percentage = Double(score) / Double(maxScore)
        if percentage >= 0.8 { return .green }
        if percentage >= 0.5 { return .yellow }
        return .orange
    }
    
    func startGame() {
        gamePhase = .playing
        score = 0
        stabilityTime = 0
        isHolding = false
        isInZone = false
        
        // Start stability check timer
        stabilityCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkStability()
            }
        }
    }
    
    func handleTouch(_ touching: Bool) {
        guard gamePhase == .playing else { return }
        isHolding = touching
    }
    
    private func checkStability() {
        guard isHolding else {
            // Lost stability - reset
            if stabilityTime > 0 {
                stabilityTime = max(0, stabilityTime - 2)
            }
            isInZone = false
            return
        }
        
        // Simulate micro-movements (simulates real finger unsteadiness)
        let drift = Int.random(in: -3...3)
        
        if abs(drift) <= 2 {
            // Stable - increase progress
            stabilityTime += 1
            isInZone = true
            score = min(maxScore, (stabilityTime * 100) / requiredStability)
            
            if stabilityTime >= requiredStability {
                completeGame()
            }
        } else {
            // Unstable - lose progress
            stabilityTime = max(0, stabilityTime - 1)
            isInZone = false
        }
    }
    
    private func completeGame() {
        stabilityCheckTimer?.invalidate()
        stabilityCheckTimer = nil
        
        gamePhase = .completed
        
        // Calculate final score and XP
        let percentage = Double(score) / Double(maxScore)
        xpEarned = Int(30 * percentage)
        
        if percentage >= 0.9 {
            resultMessage = "Outstanding focus! 🌟"
        } else if percentage >= 0.7 {
            resultMessage = "Great stability! 💪"
        } else if percentage >= 0.5 {
            resultMessage = "Good effort! 👍"
        } else {
            resultMessage = "Keep practicing! 🎯"
        }
    }
}

enum GamePhase {
    case ready
    case playing
    case completed
}

// MARK: - Results View
struct ResultsView: View {
    let score: Int
    let maxScore: Int
    let xpEarned: Int
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Score circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / CGFloat(maxScore))
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("/\(maxScore)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Message
            Text(message)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            // XP earned
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("+\(xpEarned) XP")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(20)
            
            Spacer()
            
            // Done button
            Button(action: onDismiss) {
                Text("DONE")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.green)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "1a1a2e"))
    }
    
    var scoreColor: Color {
        let percentage = Double(score) / Double(maxScore)
        if percentage >= 0.8 { return .green }
        if percentage >= 0.5 { return .yellow }
        return .orange
    }
}

// MARK: - Preview
#Preview {
    GazeHoldView()
}
