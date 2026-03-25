import SwiftUI

import SwiftUI

// MARK: - Multi-Target Challenge
// Track and tap multiple moving targets simultaneously
struct MultiTargetChallenge: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var score: Int = 0
    @State private var isActive: Bool = false
    @State private var timeRemaining: Double = 45
    @State private var showResults: Bool = false
    @State private var targets: [MovingTarget] = []
    @State private var level: Int = 1
    @State private var targetsHit: Int = 0
    @State private var targetsMissed: Int = 0
    @State private var simultaneousTaps: Int = 0
    @State private var maxSimultaneous: Int = 0
    @State private var activeTargetCount: Int = 3
    @State private var trailEffects: [TrailEffect] = []
    
    struct MovingTarget: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        let color: Color
        let size: CGFloat
        let spawnTime: Date
        var isMarked: Bool = false
    }
    
    struct TrailEffect: Identifiable {
        let id = UUID()
        let startPos: CGPoint
        let endPos: CGPoint
        let color: Color
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            if showResults {
                resultsView
            } else if isActive {
                activeChallengeView
            } else {
                previewView
            }
        }
    }
    
    var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.1, blue: 0.15), Color(red: 0.1, green: 0.2, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Grid pattern
            Path { path in
                let spacing: CGFloat = 40
                let width = UIScreen.main.bounds.width
                let height = UIScreen.main.bounds.height
                
                for x in stride(from: 0, to: width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                for y in stride(from: 0, to: height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(Color.cyan.opacity(0.05), lineWidth: 0.5)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Preview
    var previewView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 120, height: 120)
                Image(systemName: "circle.grid.3x3.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
            }
            
            Text("Multi-Target")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Track and tap multiple moving targets simultaneously")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                HStack(spacing: 32) {
                    VStack {
                        Text("45s")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Duration")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    VStack {
                        Text("30")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("XP Reward")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Text("🎯 Difficulty: Medium")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.cyan)
                        Text("Tap multiple targets at once")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.cyan)
                        Text("Targets move and bounce")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.orange)
                        Text("Difficulty increases over time")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
            }
            
            Spacer()
            
            Button(action: { startChallenge() }) {
                Text("Start Challenge")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Active Challenge
    var activeChallengeView: some View {
        GeometryReader { geometry in
            ZStack {
                // Trail effects
                ForEach(trailEffects) { trail in
                    Path { path in
                        path.move(to: trail.startPos)
                        path.addLine(to: trail.endPos)
                    }
                    .stroke(trail.color.opacity(0.5), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                }
                
                VStack(spacing: 0) {
                    // Top HUD
                    HStack {
                        Button(action: { endChallenge() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("\(Int(timeRemaining))s")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(timeRemaining < 10 ? .red : .white)
                            ProgressView(value: timeRemaining, total: 45)
                                .tint(timeRemaining < 10 ? .red : .cyan)
                                .frame(width: 120)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(score)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.yellow)
                            }
                            Text("Level \(level)")
                                .font(.system(size: 12))
                                .foregroundColor(.cyan)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    
                    // Targets display area
                    ZStack {
                        ForEach(targets) { target in
                            TargetView(target: target)
                                .position(target.position)
                                .onTapGesture {
                                    handleTargetTap(target)
                                }
                        }
                        
                        // Level up animation
                        if simultaneousTaps > 1 {
                            VStack {
                                Text("\(simultaneousTaps)x HIT!")
                                    .font(.system(size: 48, weight: .black))
                                    .foregroundColor(.cyan)
                                    .shadow(color: .cyan, radius: 20)
                                
                                Text("+\(simultaneousTaps * 25)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.yellow)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Stats bar
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text("\(activeTargetCount)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.cyan)
                            Text("Active")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(targetsHit)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.green)
                            Text("Hit")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(maxSimultaneous)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.purple)
                            Text("Max Combo")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(targetsMissed)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.red)
                            Text("Missed")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                }
            }
        }
    }
    
    // MARK: - Results
    var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(accuracy >= 80 ? Color.purple.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: accuracy >= 80 ? "target" : "circle.grid.3x3.fill")
                    .font(.system(size: 60))
                    .foregroundColor(accuracy >= 80 ? .purple : .gray)
            }
            
            Text("Multi-Tasking Complete!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                HStack(spacing: 24) {
                    StatBox(title: "Score", value: "\(score)", color: .yellow)
                    StatBox(title: "Accuracy", value: "\(accuracy)%", color: .green)
                }
                
                HStack(spacing: 24) {
                    StatBox(title: "Hit", value: "\(targetsHit)", color: .cyan)
                    StatBox(title: "Max Combo", value: "\(maxSimultaneous)x", color: .purple)
                }
                
                HStack(spacing: 24) {
                    StatBox(title: "Level", value: "\(level)", color: .orange)
                    StatBox(title: "Missed", value: "\(targetsMissed)", color: .red)
                }
            }
            .padding(.horizontal, 32)
            
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.cyan)
                Text("+30 XP")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.cyan)
            }
            .padding()
            .background(Capsule().fill(Color.cyan.opacity(0.2)))
            
            Text(performanceMessage)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    var accuracy: Int {
        let total = targetsHit + targetsMissed
        guard total > 0 else { return 0 }
        return (targetsHit * 100) / total
    }
    
    var performanceMessage: String {
        if maxSimultaneous >= 5 { return "🎯 Multi-Tasking Master!" }
        if accuracy >= 85 { return "⭐️ Excellent Tracking!" }
        if accuracy >= 70 { return "💪 Great Focus!" }
        return "Keep improving your multi-tasking!"
    }
    
    // MARK: - Game Logic
    func startChallenge() {
        isActive = true
        score = 0
        level = 1
        targetsHit = 0
        targetsMissed = 0
        simultaneousTaps = 0
        maxSimultaneous = 0
        activeTargetCount = 3
        targets = []
        timeRemaining = 45
        
        HapticManager.shared.prepare()
        
        // Spawn initial targets
        for _ in 0..<activeTargetCount {
            spawnTarget()
        }
        
        // Main timer
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            if self.timeRemaining > 0 && self.isActive {
                self.timeRemaining -= 0.016
                self.updateTargets()
                self.cleanupTrails()
            } else {
                timer.invalidate()
                self.showResults = true
                if self.accuracy >= 80 {
                    HapticManager.shared.success()
                    SoundManager.shared.playLevelUp()
                }
            }
        }
        
        // Level progression
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { timer in
            if self.isActive && self.timeRemaining > 0 {
                self.levelUp()
            } else {
                timer.invalidate()
            }
        }
    }
    
    func spawnTarget() {
        let screenBounds = UIScreen.main.bounds
        let padding: CGFloat = 100
        
        let colors: [Color] = [.cyan, .purple, .blue, .pink, .green]
        let target = MovingTarget(
            position: CGPoint(
                x: CGFloat.random(in: padding...(screenBounds.width - padding)),
                y: CGFloat.random(in: (150 + padding)...(screenBounds.height - padding - 150))
            ),
            velocity: CGPoint(
                x: CGFloat.random(in: -3...3),
                y: CGFloat.random(in: -3...3)
            ),
            color: colors.randomElement()!,
            size: CGFloat.random(in: 50...70),
            spawnTime: Date()
        )
        
        targets.append(target)
    }
    
    func updateTargets() {
        let screenBounds = UIScreen.main.bounds
        let padding: CGFloat = 100
        
        for i in 0..<targets.count {
            // Update position
            targets[i].position.x += targets[i].velocity.x
            targets[i].position.y += targets[i].velocity.y
            
            // Bounce off walls
            if targets[i].position.x < padding || targets[i].position.x > screenBounds.width - padding {
                targets[i].velocity.x *= -1
            }
            if targets[i].position.y < 150 + padding || targets[i].position.y > screenBounds.height - padding - 100 {
                targets[i].velocity.y *= -1
            }
            
            // Check if target is too old (expired)
            let age = Date().timeIntervalSince(targets[i].spawnTime)
            if age > 5.0 && !targets[i].isMarked {
                targets[i].isMarked = true
                targetsMissed += 1
                
                // Respawn
                targets.remove(at: i)
                spawnTarget()
            }
        }
    }
    
    func handleTargetTap(_ target: MovingTarget) {
        guard let index = targets.firstIndex(where: { $0.id == target.id }) else { return }
        
        let hitPosition = targets[index].position
        targets.remove(at: index)
        
        targetsHit += 1
        simultaneousTaps += 1
        
        // Add trail effect
        let trail = TrailEffect(
            startPos: hitPosition,
            endPos: CGPoint(x: UIScreen.main.bounds.midX, y: 100),
            color: target.color
        )
        trailEffects.append(trail)
        
        // Score based on speed
        let age = Date().timeIntervalSince(target.spawnTime)
        let speedBonus = max(0, Int((3.0 - age) * 5))
        score += 20 + speedBonus + (simultaneousTaps * 5)
        
        HapticManager.shared.mediumTap()
        SoundManager.shared.playTap()
        
        // Reset simultaneous counter
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.maxSimultaneous = max(self.maxSimultaneous, self.simultaneousTaps)
            
            if self.simultaneousTaps > 1 {
                HapticManager.shared.success()
                SoundManager.shared.playLevelUp()
            }
            
            self.simultaneousTaps = 0
        }
        
        // Spawn new target
        spawnTarget()
    }
    
    func levelUp() {
        level += 1
        if activeTargetCount < 7 {
            activeTargetCount += 1
            spawnTarget()
        }
        
        // Increase velocity slightly
        for i in 0..<targets.count {
            targets[i].velocity.x *= 1.1
            targets[i].velocity.y *= 1.1
        }
        
        HapticManager.shared.success()
        SoundManager.shared.playLevelUp()
    }
    
    func cleanupTrails() {
        if trailEffects.count > 20 {
            trailEffects.removeFirst()
        }
    }
    
    func endChallenge() {
        isActive = false
        showResults = true
    }
}

// MARK: - Target View
struct TargetView: View {
    let target: MultiTargetChallenge.MovingTarget
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(target.color.opacity(0.5), lineWidth: 3)
                .frame(width: target.size + 15, height: target.size + 15)
            
            // Main circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white, target.color, target.color.opacity(0.6)],
                        center: .center,
                        startRadius: 0,
                        endRadius: target.size / 2
                    )
                )
                .frame(width: target.size, height: target.size)
                .shadow(color: target.color, radius: 10)
            
            // Center icon
            Image(systemName: "scope")
                .font(.system(size: target.size * 0.4))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    MultiTargetChallenge()
        .environmentObject(AppState())
}
