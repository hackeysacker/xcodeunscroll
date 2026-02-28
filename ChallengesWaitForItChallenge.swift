import SwiftUI

import SwiftUI

// MARK: - Wait For It Challenge
// Wait for the perfect moment to tap - ultimate patience test
struct WaitForItChallenge: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var score: Int = 0
    @State private var isActive: Bool = false
    @State private var timeRemaining: Double = 60
    @State private var showResults: Bool = false
    @State private var waitState: WaitState = .waiting
    @State private var targetWaitTime: Double = 3.0
    @State private var currentWaitTime: Double = 0
    @State private var round: Int = 0
    @State private var perfectWaits: Int = 0
    @State private var earlyTaps: Int = 0
    @State private var totalAttempts: Int = 0
    @State private var temptationLevel: Double = 0
    @State private var patienceScore: Int = 100
    @State private var showTemptation: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    
    enum WaitState {
        case waiting, ready, perfect, tooEarly, tooLate
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
                colors: stateGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 0.5), value: waitState)
            
            // Temptation pulses
            if showTemptation && waitState == .waiting {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                        .scaleEffect(1 + Double(i) * 0.5)
                        .opacity(1 - Double(i) * 0.3)
                        .frame(width: 300, height: 300)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    var stateGradient: [Color] {
        switch waitState {
        case .waiting:
            return [Color(red: 0.15, green: 0.05, blue: 0.1), Color(red: 0.25, green: 0.1, blue: 0.15)]
        case .ready:
            return [Color(red: 0.2, green: 0.2, blue: 0.05), Color(red: 0.3, green: 0.3, blue: 0.1)]
        case .perfect:
            return [Color(red: 0.05, green: 0.2, blue: 0.1), Color(red: 0.1, green: 0.3, blue: 0.2)]
        case .tooEarly:
            return [Color(red: 0.3, green: 0.05, blue: 0.05), Color(red: 0.4, green: 0.1, blue: 0.1)]
        case .tooLate:
            return [Color(red: 0.15, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.15, blue: 0.3)]
        }
    }
    
    // MARK: - Preview
    var previewView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 120, height: 120)
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
            }
            
            Text("Wait For It")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Wait for the perfect moment to tap")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                HStack(spacing: 32) {
                    VStack {
                        Text("60s")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Duration")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    VStack {
                        Text("25")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("XP Reward")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Text("⏰ Difficulty: Easy")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.cyan)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.cyan)
                        Text("Resist the urge to tap early")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.cyan)
                        Text("Wait for the perfect moment")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.purple)
                        Text("Train your patience & impulse control")
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
                    .background(Color.red)
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
                            ProgressView(value: timeRemaining, total: 60)
                                .tint(timeRemaining < 10 ? .red : .orange)
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
                            Text("Round \(round)")
                                .font(.system(size: 12))
                                .foregroundColor(.cyan)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    
                    Spacer()
                    
                    // Main waiting area
                    VStack(spacing: 32) {
                        // State message
                        Text(stateMessage)
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .shadow(color: stateColor, radius: 20)
                            .multilineTextAlignment(.center)
                        
                        // Central circle
                        ZStack {
                            // Progress ring
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 12)
                                .frame(width: 250, height: 250)
                            
                            if waitState == .waiting {
                                Circle()
                                    .trim(from: 0, to: currentWaitTime / targetWaitTime)
                                    .stroke(
                                        AngularGradient(
                                            colors: progressGradient,
                                            center: .center
                                        ),
                                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                    )
                                    .frame(width: 250, height: 250)
                                    .rotationEffect(.degrees(-90))
                            }
                            
                            // Main circle
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            stateColor.opacity(0.8),
                                            stateColor.opacity(0.4),
                                            stateColor.opacity(0.1)
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 200, height: 200)
                                .shadow(color: stateColor, radius: 30)
                                .scaleEffect(pulseScale)
                            
                            // Icon
                            Image(systemName: stateIcon)
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                                .shadow(color: stateColor, radius: 10)
                            
                            // Timer display when waiting
                            if waitState == .waiting {
                                VStack {
                                    Spacer()
                                    Text(String(format: "%.1f", currentWaitTime))
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(.bottom, 40)
                                }
                                .frame(width: 200, height: 200)
                            }
                        }
                        
                        // Instruction
                        Text(instructionText)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                    
                    // Patience meter
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.purple)
                            Text("Patience Level")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(patienceScore)%")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(patienceColor)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 16)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [.red, .orange, .yellow, .green],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * CGFloat(patienceScore) / 100, height: 16)
                            }
                        }
                        .frame(height: 16)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.5)))
                    .padding()
                    
                    // Stats
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text("\(perfectWaits)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.green)
                            Text("Perfect")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(earlyTaps)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.red)
                            Text("Too Early")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(accuracy)%")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.orange)
                            Text("Success Rate")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                handleTap()
            }
        }
    }
    
    var stateMessage: String {
        switch waitState {
        case .waiting: return "WAIT..."
        case .ready: return "ALMOST..."
        case .perfect: return "PERFECT!"
        case .tooEarly: return "TOO EARLY!"
        case .tooLate: return "TOO LATE!"
        }
    }
    
    var stateIcon: String {
        switch waitState {
        case .waiting: return "hourglass"
        case .ready: return "exclamationmark.triangle.fill"
        case .perfect: return "checkmark.circle.fill"
        case .tooEarly: return "xmark.circle.fill"
        case .tooLate: return "clock.badge.xmark"
        }
    }
    
    var stateColor: Color {
        switch waitState {
        case .waiting: return .red
        case .ready: return .yellow
        case .perfect: return .green
        case .tooEarly: return .red
        case .tooLate: return .orange
        }
    }
    
    var instructionText: String {
        switch waitState {
        case .waiting:
            let remaining = targetWaitTime - currentWaitTime
            if remaining > 2 {
                return "Don't tap yet! Keep waiting..."
            } else {
                return "Get ready... almost time..."
            }
        case .ready: return "TAP NOW!"
        case .perfect: return "Excellent patience! +\(Int((currentWaitTime / targetWaitTime) * 50)) points"
        case .tooEarly: return "You tapped too soon! Control your impulse."
        case .tooLate: return "You missed the window! Be quicker next time."
        }
    }
    
    var progressGradient: [Color] {
        let progress = currentWaitTime / targetWaitTime
        if progress < 0.33 {
            return [.red, .red]
        } else if progress < 0.66 {
            return [.red, .orange, .yellow]
        } else if progress < 0.9 {
            return [.orange, .yellow, .yellow]
        } else {
            return [.yellow, .green]
        }
    }
    
    var patienceColor: Color {
        if patienceScore >= 80 { return .green }
        if patienceScore >= 60 { return .yellow }
        if patienceScore >= 40 { return .orange }
        return .red
    }
    
    var accuracy: Int {
        guard totalAttempts > 0 else { return 100 }
        return (perfectWaits * 100) / totalAttempts
    }
    
    // MARK: - Results
    var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(accuracy >= 70 ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: accuracy >= 70 ? "hourglass.badge.plus" : "clock.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundColor(accuracy >= 70 ? .green : .gray)
            }
            
            Text("Patience Training Complete!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                HStack(spacing: 24) {
                    StatBox(title: "Score", value: "\(score)", color: .yellow)
                    StatBox(title: "Patience", value: "\(patienceScore)%", color: .green)
                }
                
                HStack(spacing: 24) {
                    StatBox(title: "Perfect", value: "\(perfectWaits)", color: .cyan)
                    StatBox(title: "Success", value: "\(accuracy)%", color: .purple)
                }
                
                HStack(spacing: 24) {
                    StatBox(title: "Too Early", value: "\(earlyTaps)", color: .red)
                    StatBox(title: "Total", value: "\(totalAttempts)", color: .orange)
                }
            }
            .padding(.horizontal, 32)
            
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.cyan)
                Text("+25 XP")
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
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    var performanceMessage: String {
        if accuracy >= 90 && earlyTaps == 0 { return "🏆 Perfect Patience!" }
        if accuracy >= 80 { return "⭐️ Excellent Self-Control!" }
        if accuracy >= 65 { return "💪 Good Impulse Control!" }
        return "Keep practicing patience!"
    }
    
    // MARK: - Game Logic
    func startChallenge() {
        isActive = true
        score = 0
        round = 0
        perfectWaits = 0
        earlyTaps = 0
        totalAttempts = 0
        patienceScore = 100
        timeRemaining = 60
        
        HapticManager.shared.prepare()
        startNewRound()
        
        // Main timer
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.timeRemaining > 0 && self.isActive {
                self.timeRemaining -= 0.1
                self.updateWaitTimer()
                self.updatePulse()
                self.updateTemptation()
            } else {
                timer.invalidate()
                self.showResults = true
                if self.accuracy >= 70 {
                    HapticManager.shared.success()
                    SoundManager.shared.playLevelUp()
                }
            }
        }
    }
    
    func startNewRound() {
        guard timeRemaining > 5 else {
            showResults = true
            return
        }
        
        round += 1
        waitState = .waiting
        currentWaitTime = 0
        
        // Random wait time between 2-5 seconds
        targetWaitTime = Double.random(in: 2.5...5.0)
        
        HapticManager.shared.lightTap()
    }
    
    func updateWaitTimer() {
        guard waitState == .waiting else { return }
        
        currentWaitTime += 0.1
        
        // Check if reached target time
        if currentWaitTime >= targetWaitTime {
            waitState = .ready
            HapticManager.shared.mediumTap()
            SoundManager.shared.playSuccess()
            
            // Auto timeout after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if self.waitState == .ready {
                    self.handleTimeout()
                }
            }
        }
        
        // Progressive haptics as we get close
        if currentWaitTime > targetWaitTime - 1.0 && Int(currentWaitTime * 10) % 3 == 0 {
            HapticManager.shared.lightTap()
        }
    }
    
    func handleTap() {
        totalAttempts += 1
        
        switch waitState {
        case .waiting:
            // Tapped too early!
            waitState = .tooEarly
            earlyTaps += 1
            score = max(0, score - 10)
            patienceScore = max(0, patienceScore - 10)
            
            HapticManager.shared.error()
            SoundManager.shared.playFail()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.startNewRound()
            }
            
        case .ready:
            // Perfect timing!
            waitState = .perfect
            perfectWaits += 1
            
            let accuracyBonus = Int((currentWaitTime / targetWaitTime) * 50)
            score += 30 + accuracyBonus
            patienceScore = min(100, patienceScore + 5)
            
            HapticManager.shared.success()
            SoundManager.shared.playLevelUp()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.startNewRound()
            }
            
        default:
            break
        }
    }
    
    func handleTimeout() {
        waitState = .tooLate
        totalAttempts += 1
        patienceScore = max(0, patienceScore - 5)
        
        HapticManager.shared.warning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.startNewRound()
        }
    }
    
    func updatePulse() {
        if waitState == .waiting {
            let progress = currentWaitTime / targetWaitTime
            pulseScale = 1.0 + (sin(Date().timeIntervalSinceReferenceDate * (1 + progress * 3)) * 0.05)
        } else {
            pulseScale = 1.0
        }
    }
    
    func updateTemptation() {
        if waitState == .waiting {
            let progress = currentWaitTime / targetWaitTime
            showTemptation = progress > 0.6
        } else {
            showTemptation = false
        }
    }
    
    func endChallenge() {
        isActive = false
        showResults = true
    }
}

#Preview {
    WaitForItChallenge()
        .environmentObject(AppState())
}
