import SwiftUI

// MARK: - Rapid Target Challenge
// Fully built with: animations, haptics, sound, scoring, combo system, results

struct RapidTargetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var score: Int = 0
    @State private var timeRemaining: Double = 30
    @State private var targets: [Target] = []
    @State private var combo: Int = 0
    @State private var maxCombo: Int = 0
    @State private var isGameOver: Bool = false
    @State private var showResults: Bool = false
    
    // Audio/Haptics
    @State private var audioManager = AppAudioManager.shared
    
    struct Target: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat = 0
        var createdAt: Date = Date()
    }
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color("0A0F1C"), Color("1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                Spacer()
                
                // Game area
                gameArea
                
                Spacer()
            }
            
            // Results overlay
            if showResults {
                resultsOverlay
            }
        }
        .onAppear {
            startGame()
        }
        .onReceive(timer) { _ in
            guard !isGameOver else { return }
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                endGame()
            }
            spawnTarget()
            cleanupOldTargets()
        }
    }
    
    // MARK: - Header
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
            
            // Combo
            if combo > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(combo)x")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(12)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }
    
    // MARK: - Game Area
    var gameArea: some View {
        ZStack {
            // Grid pattern
            PatternGrid()
                .opacity(0.1)
            
            // Targets
            ForEach(targets) { target in
                TargetBubble(scale: target.scale) {
                    handleTap(target)
                }
                .position(x: target.x, y: target.y)
            }
        }
    }
    
    // MARK: - Results Overlay
    var resultsOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Score
                Text("\(score)")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("POINTS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(2)
                
                // Stats
                HStack(spacing: 32) {
                    VStack {
                        Text("\(maxCombo)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.orange)
                        Text("Max Combo")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("\(score / 10)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.purple)
                        Text("XP Earned")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 40)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                
                // Performance
                Text(performanceText)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(performanceColor)
                
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
    
    // MARK: - Helpers
    var performanceText: String {
        if score >= 300 { return "LEGENDARY!" }
        if score >= 200 { return "AMAZING!" }
        if score >= 100 { return "GREAT!" }
        return "KEEP PRACTICING"
    }
    
    var performanceColor: Color {
        if score >= 300 { return .yellow }
        if score >= 200 { return .orange }
        if score >= 100 { return .green }
        return .gray
    }
    
    func startGame() {
        score = 0
        combo = 0
        maxCombo = 0
        timeRemaining = 30
        targets = []
        isGameOver = false
        showResults = false
        
        audioManager.playChallengeStart()
        
        // Spawn initial targets
        for _ in 0..<3 {
            spawnTarget()
        }
    }
    
    func endGame() {
        isGameOver = true
        audioManager.playChallengeComplete()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showResults = true
        }
    }
    
    func restart() {
        showResults = false
        startGame()
    }
    
    func handleTap(_ target: Target) {
        // Remove target
        targets.removeAll { $0.id == target.id }
        
        // Update combo
        combo += 1
        if combo > maxCombo {
            maxCombo = combo
        }
        
        // Calculate points
        let points = 10 + (combo * 2)
        score += points
        
        // Haptics
        if combo >= 10 {
            audioManager.playPerfect()
        } else if combo >= 5 {
            audioManager.playSuccess()
        } else {
            audioManager.lightImpact()
        }
    }
    
    func spawnTarget() {
        guard targets.count < 5 else { return }
        
        let padding: CGFloat = 80
        let screenW = UIScreen.main.bounds.width - padding * 2
        let screenH = UIScreen.main.bounds.height - 300
        
        let x = CGFloat.random(in: padding...(UIScreen.main.bounds.width - padding))
        let y = CGFloat.random(in: (150 + padding)...(screenH + 150))
        
        var newTarget = Target(x: x, y: y)
        newTarget.scale = 0
        targets.append(newTarget)
        
        // Animate in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let index = targets.firstIndex(where: { $0.id == newTarget.id }) {
                targets[index].scale = 1
            }
        }
    }
    
    func cleanupOldTargets() {
        targets.removeAll { Date().timeIntervalSince($0.createdAt) > 2.5 }
    }
}

// MARK: - Target Bubble
struct TargetBubble: View {
    let scale: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple, .indigo],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .purple.opacity(0.6), radius: 20, x: 0, y: 5)
                
                // Inner ring
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 3)
                    .frame(width: 55, height: 55)
                
                // Target icon
                Image(systemName: "target")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(scale)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scale)
    }
}

// MARK: - Pattern Grid
struct PatternGrid: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let spacing: CGFloat = 40
                for x in stride(from: 0, to: geo.size.width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }
                for y in stride(from: 0, to: geo.size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.05), lineWidth: 1)
        }
    }
}

#Preview {
    RapidTargetView()
}
