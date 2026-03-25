import SwiftUI

import SwiftUI

// MARK: - Color Blitz Challenge
// React to rapid color changes instantly - lightning reflexes required
struct ColorBlitzChallenge: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var score: Int = 0
    @State private var isActive: Bool = false
    @State private var timeRemaining: Double = 30
    @State private var showResults: Bool = false
    @State private var targetColor: Color = .red
    @State private var displayedColors: [ColorOption] = []
    @State private var correctTaps: Int = 0
    @State private var incorrectTaps: Int = 0
    @State private var missedTargets: Int = 0
    @State private var streak: Int = 0
    @State private var maxStreak: Int = 0
    @State private var reactionTimes: [Double] = []
    @State private var currentTargetSpawnTime: Date = Date()
    @State private var colorFlashEffect: Bool = false
    @State private var difficultyMultiplier: Double = 1.0
    
    struct ColorOption: Identifiable {
        let id = UUID()
        let color: Color
        let name: String
        let position: CGPoint
        let isTarget: Bool
        let spawnTime: Date
    }
    
    let gameColors: [(Color, String)] = [
        (.red, "RED"),
        (.blue, "BLUE"),
        (.green, "GREEN"),
        (.yellow, "YELLOW"),
        (.purple, "PURPLE"),
        (.orange, "ORANGE")
    ]
    
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
                colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Color flash effect
            if colorFlashEffect {
                targetColor.opacity(0.3)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: colorFlashEffect)
        .ignoresSafeArea()
    }
    
    // MARK: - Preview
    var previewView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 120, height: 120)
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
            }
            
            Text("Color Blitz")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("React to rapid color changes instantly")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                HStack(spacing: 32) {
                    VStack {
                        Text("30s")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Duration")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    VStack {
                        Text("20")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("XP Reward")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Text("⚡️ Difficulty: Easy")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.cyan)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.cyan)
                        Text("Watch for the target color")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.cyan)
                        Text("Tap matching colors instantly")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.orange)
                        Text("Speed increases over time")
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
                    .background(Color.orange)
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
                            ProgressView(value: timeRemaining, total: 30)
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
                            if streak > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.orange)
                                    Text("\(streak)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    
                    // Target color display
                    VStack(spacing: 16) {
                        Text("TAP THIS COLOR:")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(targetColor)
                                .frame(width: 180, height: 100)
                                .shadow(color: targetColor, radius: 20)
                            
                            Text(targetColorName)
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2)
                        }
                        
                        if streak > 2 {
                            HStack(spacing: 8) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("\(streak)x STREAK!")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.3)))
                    .padding()
                    
                    // Color options grid
                    ZStack {
                        ForEach(displayedColors) { option in
                            ColorOptionView(option: option, currentTime: Date())
                                .position(option.position)
                                .onTapGesture {
                                    handleColorTap(option)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Stats bar
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("\(correctTaps)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.green)
                            Text("Correct")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(incorrectTaps)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.red)
                            Text("Wrong")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(maxStreak)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.orange)
                            Text("Best Streak")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 4) {
                            Text(averageReactionTime)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.cyan)
                            Text("Avg Time")
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
    
    var targetColorName: String {
        gameColors.first(where: { $0.0 == targetColor })?.1 ?? "COLOR"
    }
    
    var averageReactionTime: String {
        guard !reactionTimes.isEmpty else { return "-" }
        let avg = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        return "\(Int(avg * 1000))ms"
    }
    
    // MARK: - Results
    var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(accuracy >= 80 ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: accuracy >= 80 ? "bolt.fill" : "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(accuracy >= 80 ? .orange : .gray)
            }
            
            Text("Color Blitz Complete!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                HStack(spacing: 24) {
                    StatBox(title: "Score", value: "\(score)", color: .yellow)
                    StatBox(title: "Accuracy", value: "\(accuracy)%", color: .green)
                }
                
                HStack(spacing: 24) {
                    StatBox(title: "Best Streak", value: "\(maxStreak)x", color: .orange)
                    StatBox(title: "Correct", value: "\(correctTaps)", color: .cyan)
                }
                
                HStack(spacing: 24) {
                    StatBox(title: "Wrong", value: "\(incorrectTaps)", color: .red)
                    StatBox(title: "Avg Time", value: averageReactionTime, color: .purple)
                }
            }
            .padding(.horizontal, 32)
            
            // Reaction time distribution
            if !reactionTimes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reaction Times")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(alignment: .bottom, spacing: 3) {
                        ForEach(Array(reactionTimes.prefix(20).enumerated()), id: \.offset) { _, time in
                            Rectangle()
                                .fill(reactionTimeColor(time))
                                .frame(width: 12, height: CGFloat(min(time * 300, 80)))
                        }
                    }
                    .frame(height: 80)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                .padding(.horizontal, 32)
            }
            
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.cyan)
                Text("+20 XP")
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
                    .background(Color.orange)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    var accuracy: Int {
        let total = correctTaps + incorrectTaps
        guard total > 0 else { return 0 }
        return (correctTaps * 100) / total
    }
    
    func reactionTimeColor(_ time: Double) -> Color {
        if time < 0.3 { return .green }
        if time < 0.5 { return .yellow }
        return .orange
    }
    
    var performanceMessage: String {
        if maxStreak >= 20 { return "⚡️ Lightning Reflexes!" }
        if accuracy >= 90 { return "⭐️ Color Master!" }
        if accuracy >= 75 { return "💪 Great Reactions!" }
        return "Keep practicing your reflexes!"
    }
    
    // MARK: - Game Logic
    func startChallenge() {
        isActive = true
        score = 0
        correctTaps = 0
        incorrectTaps = 0
        missedTargets = 0
        streak = 0
        maxStreak = 0
        reactionTimes = []
        timeRemaining = 30
        difficultyMultiplier = 1.0
        displayedColors = []
        
        HapticManager.shared.prepare()
        selectNewTargetColor()
        
        // Main timer
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.timeRemaining > 0 && self.isActive {
                self.timeRemaining -= 0.1
                self.updateDifficulty()
                self.cleanupExpiredColors()
            } else {
                timer.invalidate()
                self.showResults = true
                if self.accuracy >= 80 {
                    HapticManager.shared.success()
                    SoundManager.shared.playLevelUp()
                }
            }
        }
        
        // Color spawner
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
            if self.isActive && self.timeRemaining > 0 {
                self.spawnColorOptions()
            } else {
                timer.invalidate()
            }
        }
    }
    
    func selectNewTargetColor() {
        let previousColor = targetColor
        repeat {
            targetColor = gameColors.randomElement()!.0
        } while targetColor == previousColor
        
        currentTargetSpawnTime = Date()
        
        colorFlashEffect = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.colorFlashEffect = false
        }
        
        HapticManager.shared.mediumTap()
        SoundManager.shared.playTap()
    }
    
    func spawnColorOptions() {
        let screenBounds = UIScreen.main.bounds
        let padding: CGFloat = 80
        
        // Spawn 2-4 colors (one correct, others wrong)
        let colorCount = Int.random(in: 2...4)
        var colorsToSpawn = gameColors.filter { $0.0 != targetColor }.shuffled()
        
        // Insert target color at random position
        let targetIndex = Int.random(in: 0..<colorCount)
        colorsToSpawn.insert((targetColor, targetColorName), at: targetIndex)
        
        for i in 0..<colorCount {
            let colorData = colorsToSpawn[i]
            let option = ColorOption(
                color: colorData.0,
                name: colorData.1,
                position: CGPoint(
                    x: CGFloat.random(in: padding...(screenBounds.width - padding)),
                    y: CGFloat.random(in: (200 + padding)...(screenBounds.height - padding - 150))
                ),
                isTarget: colorData.0 == targetColor,
                spawnTime: Date()
            )
            displayedColors.append(option)
        }
    }
    
    func cleanupExpiredColors() {
        let maxLifetime = max(0.5, 2.0 - (difficultyMultiplier - 1) * 0.5)
        
        displayedColors.removeAll { option in
            let age = Date().timeIntervalSince(option.spawnTime)
            if age > maxLifetime {
                if option.isTarget {
                    missedTargets += 1
                    streak = 0
                }
                return true
            }
            return false
        }
    }
    
    func handleColorTap(_ option: ColorOption) {
        // Remove the tapped color
        displayedColors.removeAll { $0.id == option.id }
        
        if option.isTarget {
            // Correct!
            correctTaps += 1
            streak += 1
            maxStreak = max(maxStreak, streak)
            
            // Calculate reaction time
            let reactionTime = Date().timeIntervalSince(currentTargetSpawnTime)
            reactionTimes.append(reactionTime)
            
            // Score based on speed and streak
            let speedBonus = max(0, Int((1.0 - reactionTime) * 20))
            let streakBonus = min(streak, 15) * 2
            score += 15 + speedBonus + streakBonus
            
            HapticManager.shared.success()
            SoundManager.shared.playSuccess()
            
            if streak % 5 == 0 {
                SoundManager.shared.playLevelUp()
            }
            
            // New target color
            selectNewTargetColor()
            
        } else {
            // Wrong color!
            incorrectTaps += 1
            streak = 0
            score = max(0, score - 10)
            
            HapticManager.shared.error()
            SoundManager.shared.playFail()
        }
    }
    
    func updateDifficulty() {
        let progress = 1.0 - (timeRemaining / 30.0)
        difficultyMultiplier = 1.0 + progress * 1.5
    }
    
    func endChallenge() {
        isActive = false
        showResults = true
    }
}

// MARK: - Color Option View
struct ColorOptionView: View {
    let option: ColorBlitzChallenge.ColorOption
    let currentTime: Date
    
    var age: TimeInterval {
        currentTime.timeIntervalSince(option.spawnTime)
    }
    
    var opacity: Double {
        let maxAge = 2.0
        return max(0.3, 1.0 - (age / maxAge))
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            option.color,
                            option.color.opacity(0.6)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: 90, height: 90)
                .shadow(color: option.color, radius: 15)
            
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 3)
                .frame(width: 90, height: 90)
            
            if option.isTarget {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .opacity(opacity)
        .scaleEffect(age < 0.2 ? age * 5 : 1.0)
    }
}

#Preview {
    ColorBlitzChallenge()
        .environmentObject(AppState())
}
