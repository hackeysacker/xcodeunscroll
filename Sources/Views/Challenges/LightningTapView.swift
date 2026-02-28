import SwiftUI

// MARK: - Lightning Tap (Reflex) Challenge
// Fully built with: instant reaction, timing, scoring, perfect/good/miss feedback

struct LightningTapView: View {
    @Environment(\.dismiss) var dismiss
    @State private var score: Int = 0
    @State private var attempts: Int = 0
    @State private var perfectHits: Int = 0
    @State private var goodHits: Int = 0
    @State private var misses: Int = 0
    @State private var timeRemaining: Double = 30
    @State private var currentState: TapState = .waiting
    @State private var showResults: Bool = false
    @State private var lastReactionTime: Double?
    @State private var showFeedback: Bool = false
    @State private var feedbackText: String = ""
    @State private var feedbackColor: Color = .white
    @State private var targetVisible: Bool = false
    @State private var targetAppearTime: Date = Date()
    @State private var audioManager = AppAudioManager.shared
    
    enum TapState {
        case waiting
        case ready
        case tapped
    }
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color("0A0F1C"), Color("1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                Spacer()
                
                // Game area
                gameArea
                
                Spacer()
                
                // Instructions
                instructions
            }
            
            // Results
            if showResults {
                resultsOverlay
            }
            
            // Feedback popup
            if showFeedback {
                feedbackPopup
            }
        }
        .onAppear {
            startGame()
        }
        .onReceive(timer) { _ in
            guard !showResults else { return }
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                endGame()
            }
            scheduleNextTarget()
        }
    }
    
    var header: some View {
        HStack(spacing: 24) {
            // Timer
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .foregroundColor(timeRemaining < 10 ? .red : .purple)
                Text(String(format: "%.1f", timeRemaining))
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
            
            // Score
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.yellow)
                Text("SCORE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }
    
    var gameArea: some View {
        ZStack {
            // Tap zone indicator
            Circle()
                .stroke(
                    LinearGradient(colors: [.purple.opacity(0.3), .indigo.opacity(0.3)], startPoint: .top, endPoint: .bottom),
                    lineWidth: 4
                )
                .frame(width: 200, height: 200)
            
            // Center guide
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 100, height: 100)
            
            // Target button
            if targetVisible {
                Button(action: handleTap) {
                    ZStack {
                        // Glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.yellow, .orange],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: .yellow.opacity(0.8), radius: 30, x: 0, y: 0)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 4)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(targetVisible ? 1 : 0)
                .animation(.spring(response: 0.2), value: targetVisible)
            } else if currentState == .waiting {
                Text("WAIT...")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.gray)
            }
            
            // Miss indicator
            if currentState == .ready && !targetVisible {
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text("MISS")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
    
    var instructions: some View {
        VStack(spacing: 8) {
            if currentState == .waiting {
                Text("Wait for the target...")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            } else if targetVisible {
                Text("TAP NOW!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.yellow)
            }
        }
        .padding(.bottom, 40)
    }
    
    var feedbackPopup: some View {
        Text(feedbackText)
            .font(.system(size: 36, weight: .bold))
            .foregroundColor(feedbackColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
            .transition(.scale.combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showFeedback = false
                }
            }
    }
    
    var resultsOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Score
                Text("\(score)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("POINTS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(2)
                
                // Stats
                VStack(spacing: 16) {
                    statRow(icon: "star.fill", value: "\(perfectHits)", label: "Perfect", color: .yellow)
                    statRow(icon: "hand.thumbsup.fill", value: "\(goodHits)", label: "Good", color: .green)
                    statRow(icon: "xmark.circle.fill", value: "\(misses)", label: "Miss", color: .red)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                
                // Average reaction
                let avgReaction = attempts > 0 ? (Double(score) / Double(attempts) * 100) : 0
                VStack(spacing: 4) {
                    Text(String(format: "%.0f ms", avgReaction))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.cyan)
                    Text("AVG REACTION")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                // Buttons
                VStack(spacing: 12) {
                    Button {
                        restart()
                    } label: {
                        Text("Try Again")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.purple)
                            .cornerRadius(16)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    func statRow(icon: String, value: String, label: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
    
    func startGame() {
        score = 0
        attempts = 0
        perfectHits = 0
        goodHits = 0
        misses = 0
        timeRemaining = 30
        showResults = false
        targetVisible = false
        currentState = .waiting
    }
    
    func scheduleNextTarget() {
        guard currentState == .waiting && !targetVisible else { return }
        
        // Random delay 0.5-2 seconds
        let delay = Double.random(in: 0.5...2.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard !showResults else { return }
            showTarget()
        }
    }
    
    func showTarget() {
        targetVisible = true
        targetAppearTime = Date()
        currentState = .ready
    }
    
    func handleTap() {
        guard currentState == .ready && targetVisible else { return }
        
        let reactionTime = Date().timeIntervalSince(targetAppearTime) * 1000 // ms
        attempts += 1
        targetVisible = false
        currentState = .tapped
        
        if reactionTime < 200 {
            // Perfect
            perfectHits += 1
            score += 50
            feedbackText = "PERFECT!"
            feedbackColor = .yellow
            audioManager.playPerfect()
        } else if reactionTime < 400 {
            // Good
            goodHits += 1
            score += 25
            feedbackText = "GOOD!"
            feedbackColor = .green
            audioManager.success()
        } else {
            // Slow
            score += 10
            feedbackText = "SLOW"
            feedbackColor = .orange
            audioManager.lightImpact()
        }
        
        showFeedback = true
        currentState = .waiting
        
        scheduleNextTarget()
    }
    
    func endGame() {
        showResults = true
        audioManager.playChallengeComplete()
    }
    
    func restart() {
        showResults = false
        startGame()
    }
}

#Preview {
    LightningTapView()
}
