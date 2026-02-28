import SwiftUI

import SwiftUI

// MARK: - Breathing Circle Challenge
// Breathe in sync with the expanding circle for calm and focus
struct BreathingCircleChallenge: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var score: Int = 0
    @State private var isActive: Bool = false
    @State private var timeRemaining: Double = 90
    @State private var showResults: Bool = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathProgress: Double = 0
    @State private var cycleCount: Int = 0
    @State private var perfectCycles: Int = 0
    @State private var calmScore: Int = 100
    @State private var heartRate: Double = 72
    @State private var showPhaseTransition: Bool = false
    @State private var particles: [Particle] = []
    
    enum BreathPhase {
        case inhale, hold, exhale, rest
        
        var name: String {
            switch self {
            case .inhale: return "Breathe In"
            case .hold: return "Hold"
            case .exhale: return "Breathe Out"
            case .rest: return "Rest"
            }
        }
        
        var duration: Double {
            switch self {
            case .inhale: return 4.0
            case .hold: return 3.0
            case .exhale: return 5.0
            case .rest: return 2.0
            }
        }
        
        var icon: String {
            switch self {
            case .inhale: return "arrow.up.circle.fill"
            case .hold: return "pause.circle.fill"
            case .exhale: return "arrow.down.circle.fill"
            case .rest: return "moon.circle.fill"
            }
        }
    }
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var alpha: Double
        var size: CGFloat
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
                colors: breathGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 2.0), value: breathPhase)
            
            // Animated particles
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white.opacity(particle.alpha))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .blur(radius: 1)
            }
        }
        .ignoresSafeArea()
    }
    
    var breathGradientColors: [Color] {
        switch breathPhase {
        case .inhale:
            return [Color(red: 0.2, green: 0.4, blue: 0.8), Color(red: 0.4, green: 0.2, blue: 0.6)]
        case .hold:
            return [Color(red: 0.3, green: 0.3, blue: 0.7), Color(red: 0.5, green: 0.3, blue: 0.7)]
        case .exhale:
            return [Color(red: 0.2, green: 0.6, blue: 0.5), Color(red: 0.3, green: 0.5, blue: 0.4)]
        case .rest:
            return [Color(red: 0.15, green: 0.3, blue: 0.4), Color(red: 0.2, green: 0.3, blue: 0.5)]
        }
    }
    
    // MARK: - Preview
    var previewView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 120, height: 120)
                Image(systemName: "circle.dotted")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            
            Text("Breathing Circle")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Breathe in sync with the expanding circle")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                HStack(spacing: 32) {
                    VStack {
                        Text("90s")
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
                
                Text("🧘 Difficulty: Easy")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.cyan)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "wind")
                            .foregroundColor(.cyan)
                        Text("Follow the breathing pattern")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Reduce stress and anxiety")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.purple)
                        Text("Improve focus and calm")
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
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Active Challenge
    var activeChallengeView: some View {
        VStack(spacing: 20) {
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
                        .foregroundColor(.white)
                    ProgressView(value: timeRemaining, total: 90)
                        .tint(.green)
                        .frame(width: 120)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                        Text("\(calmScore)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.green)
                    }
                    Text("Calm")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            
            Spacer()
            
            // Cycle counter
            VStack(spacing: 8) {
                Text("Cycle \(cycleCount + 1)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    Label("\(cycleCount)", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("\(perfectCycles)", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                }
                .font(.system(size: 14))
            }
            
            Spacer()
            
            // Main breathing circle
            ZStack {
                // Outer guide rings
                ForEach([1.0, 0.8, 0.6], id: \.self) { scale in
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .frame(width: 300 * scale, height: 300 * scale)
                }
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: breathProgress)
                    .stroke(
                        LinearGradient(
                            colors: [phaseColor, phaseColor.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 320, height: 320)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: phaseColor, radius: 10)
                
                // Main breathing circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                phaseColor.opacity(0.8),
                                phaseColor.opacity(0.4),
                                phaseColor.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: breathScale * 150
                        )
                    )
                    .frame(width: breathScale * 200, height: breathScale * 200)
                    .shadow(color: phaseColor, radius: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            .frame(width: breathScale * 200, height: breathScale * 200)
                    )
                
                // Center icon
                Image(systemName: breathPhase.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .shadow(color: phaseColor, radius: 10)
                
                // Ripple effect during transitions
                if showPhaseTransition {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(phaseColor.opacity(0.5), lineWidth: 3)
                            .frame(width: 200, height: 200)
                            .scaleEffect(1 + Double(i) * 0.3)
                            .opacity(1 - Double(i) * 0.3)
                    }
                }
            }
            
            Spacer()
            
            // Phase indicator
            VStack(spacing: 16) {
                Text(breathPhase.name.uppercased())
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: phaseColor, radius: 10)
                
                Text(phaseInstruction)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Stats
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(Int(heartRate))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.red)
                    }
                    Text("Heart Rate")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text("\(cycleCount)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.cyan)
                    Text("Cycles")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text("\(perfectCycles)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("Perfect")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.3)))
            .padding()
        }
    }
    
    var phaseColor: Color {
        switch breathPhase {
        case .inhale: return Color.blue
        case .hold: return Color.purple
        case .exhale: return Color.green
        case .rest: return Color.cyan
        }
    }
    
    var breathScale: CGFloat {
        switch breathPhase {
        case .inhale: return CGFloat(0.6 + breathProgress * 0.8) // 0.6 -> 1.4
        case .hold: return 1.4
        case .exhale: return CGFloat(1.4 - breathProgress * 0.8) // 1.4 -> 0.6
        case .rest: return 0.6
        }
    }
    
    var phaseInstruction: String {
        switch breathPhase {
        case .inhale: return "Breathe in slowly through your nose"
        case .hold: return "Hold your breath gently"
        case .exhale: return "Release slowly through your mouth"
        case .rest: return "Relax and prepare for the next cycle"
        }
    }
    
    // MARK: - Results
    var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(calmScore >= 80 ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: calmScore >= 80 ? "leaf.fill" : "wind")
                    .font(.system(size: 60))
                    .foregroundColor(calmScore >= 80 ? .green : .gray)
            }
            
            Text("Breathing Session Complete!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                HStack(spacing: 24) {
                    StatBox(title: "Calm Score", value: "\(calmScore)", color: .green)
                    StatBox(title: "Cycles", value: "\(cycleCount)", color: .cyan)
                }
                
                HStack(spacing: 24) {
                    StatBox(title: "Perfect", value: "\(perfectCycles)", color: .yellow)
                    StatBox(title: "Heart Rate", value: "\(Int(heartRate)) BPM", color: .red)
                }
            }
            .padding(.horizontal, 32)
            
            // Wellness insights
            VStack(spacing: 12) {
                Text("Wellness Benefits")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    BenefitRow(icon: "brain.head.profile", text: "Improved focus and clarity", color: .purple)
                    BenefitRow(icon: "heart.fill", text: "Reduced heart rate", color: .red)
                    BenefitRow(icon: "bolt.fill", text: "Lowered stress levels", color: .orange)
                    BenefitRow(icon: "moon.fill", text: "Enhanced relaxation", color: .blue)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
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
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    var performanceMessage: String {
        if calmScore >= 90 { return "🧘 Perfect Mindfulness!" }
        if calmScore >= 80 { return "⭐️ Excellent Breathing!" }
        if calmScore >= 70 { return "💪 Great Progress!" }
        return "Keep practicing for better calm!"
    }
    
    // MARK: - Game Logic
    func startChallenge() {
        isActive = true
        score = 0
        cycleCount = 0
        perfectCycles = 0
        calmScore = 100
        heartRate = 72
        timeRemaining = 90
        breathPhase = .inhale
        breathProgress = 0
        particles = generateParticles()
        
        HapticManager.shared.prepare()
        
        // Main timer
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.timeRemaining > 0 && self.isActive {
                self.timeRemaining -= 0.1
                self.updateBreathing()
                self.updateParticles()
                self.updateHeartRate()
            } else {
                timer.invalidate()
                self.showResults = true
                if self.calmScore >= 80 {
                    HapticManager.shared.success()
                    SoundManager.shared.playLevelUp()
                }
            }
        }
    }
    
    func updateBreathing() {
        let phaseDuration = breathPhase.duration
        breathProgress += 0.1 / phaseDuration
        
        if breathProgress >= 1.0 {
            // Move to next phase
            breathProgress = 0
            transitionToNextPhase()
        }
    }
    
    func transitionToNextPhase() {
        showPhaseTransition = true
        
        switch breathPhase {
        case .inhale:
            breathPhase = .hold
            HapticManager.shared.lightTap()
        case .hold:
            breathPhase = .exhale
            HapticManager.shared.lightTap()
        case .exhale:
            breathPhase = .rest
            perfectCycles += 1
            calmScore = min(100, calmScore + 2)
            score += 20
            HapticManager.shared.mediumTap()
            SoundManager.shared.playSuccess()
        case .rest:
            breathPhase = .inhale
            cycleCount += 1
            HapticManager.shared.lightTap()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showPhaseTransition = false
        }
    }
    
    func updateHeartRate() {
        // Simulate heart rate reduction over time
        let targetRate = 60.0
        let currentProgress = (90.0 - timeRemaining) / 90.0
        heartRate = 72 - (12 * currentProgress) // 72 -> 60 BPM
    }
    
    func generateParticles() -> [Particle] {
        var newParticles: [Particle] = []
        let screenBounds = UIScreen.main.bounds
        
        for _ in 0..<30 {
            let particle = Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenBounds.width),
                    y: CGFloat.random(in: 0...screenBounds.height)
                ),
                velocity: CGPoint(
                    x: CGFloat.random(in: -0.5...0.5),
                    y: CGFloat.random(in: -1...0)
                ),
                alpha: Double.random(in: 0.1...0.3),
                size: CGFloat.random(in: 2...6)
            )
            newParticles.append(particle)
        }
        
        return newParticles
    }
    
    func updateParticles() {
        let screenBounds = UIScreen.main.bounds
        
        for i in 0..<particles.count {
            particles[i].position.x += particles[i].velocity.x
            particles[i].position.y += particles[i].velocity.y
            
            // Wrap around screen
            if particles[i].position.y < 0 {
                particles[i].position.y = screenBounds.height
            }
            if particles[i].position.x < 0 {
                particles[i].position.x = screenBounds.width
            } else if particles[i].position.x > screenBounds.width {
                particles[i].position.x = 0
            }
        }
    }
    
    func endChallenge() {
        isActive = false
        showResults = true
    }
}

// MARK: - Supporting Views
struct BenefitRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

#Preview {
    BreathingCircleChallenge()
        .environmentObject(AppState())
}
