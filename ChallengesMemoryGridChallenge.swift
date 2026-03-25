import SwiftUI

import SwiftUI

// MARK: - Memory Grid Challenge
// Remember and recreate the pattern shown
struct MemoryGridChallenge: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var score: Int = 0
    @State private var isActive: Bool = false
    @State private var timeRemaining: Double = 45
    @State private var showResults: Bool = false
    @State private var level: Int = 1
    @State private var phase: GamePhase = .memorize
    @State private var pattern: Set<Int> = []
    @State private var userPattern: Set<Int> = []
    @State private var gridSize: Int = 3
    @State private var memorizeTime: Double = 3.0
    @State private var phaseTimer: Double = 0
    @State private var perfectRounds: Int = 0
    @State private var totalAttempts: Int = 0
    @State private var flashingCells: Set<Int> = []
    
    enum GamePhase {
        case memorize, recall, feedback
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
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.08, blue: 0.15), Color(red: 0.1, green: 0.15, blue: 0.25)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Preview
    var previewView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 120, height: 120)
                Image(systemName: "square.grid.4x3.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            
            Text("Memory Grid")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Remember and recreate the pattern shown")
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
                        Text("25")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("XP Reward")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Text("⭐️ Difficulty: Easy")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.cyan)
            }
            
            Spacer()
            
            Button(action: { startChallenge() }) {
                Text("Start Challenge")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
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
                        .foregroundColor(timeRemaining < 10 ? .red : .white)
                    ProgressView(value: timeRemaining, total: 45)
                        .tint(timeRemaining < 10 ? .red : .blue)
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
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.cyan)
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            
            Spacer()
            
            // Phase indicator
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    PhaseIndicator(phase: .memorize, currentPhase: phase, icon: "eye.fill")
                    PhaseIndicator(phase: .recall, currentPhase: phase, icon: "hand.tap.fill")
                    PhaseIndicator(phase: .feedback, currentPhase: phase, icon: "checkmark.circle.fill")
                }
                
                Text(phaseText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(phaseColor)
                
                if phase == .memorize {
                    Text("Time: \(Int(phaseTimer))s")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Grid
            VStack(spacing: 8) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            let index = row * gridSize + col
                            GridCell(
                                index: index,
                                isActive: pattern.contains(index),
                                isUserSelected: userPattern.contains(index),
                                isFlashing: flashingCells.contains(index),
                                phase: phase,
                                size: cellSize
                            )
                            .onTapGesture {
                                handleCellTap(index)
                            }
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
            
            // Stats bar
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(perfectRounds)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                    Text("Perfect")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text("\(pattern.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Cells")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text("\(accuracy)%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.orange)
                    Text("Accuracy")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.3)))
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var cellSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 56
        let spacing: CGFloat = 8 * CGFloat(gridSize - 1)
        return (screenWidth - padding - spacing) / CGFloat(gridSize)
    }
    
    var phaseText: String {
        switch phase {
        case .memorize: return "MEMORIZE THE PATTERN"
        case .recall: return "TAP TO RECREATE"
        case .feedback: return userPattern == pattern ? "✓ PERFECT!" : "✗ INCORRECT"
        }
    }
    
    var phaseColor: Color {
        switch phase {
        case .memorize: return .cyan
        case .recall: return .blue
        case .feedback: return userPattern == pattern ? .green : .red
        }
    }
    
    var accuracy: Int {
        guard totalAttempts > 0 else { return 100 }
        return (perfectRounds * 100) / totalAttempts
    }
    
    // MARK: - Results
    var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(score >= 150 ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: score >= 150 ? "brain.head.profile" : "square.grid.4x3.fill")
                    .font(.system(size: 60))
                    .foregroundColor(score >= 150 ? .yellow : .gray)
            }
            
            Text("Memory Training Complete!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                HStack(spacing: 24) {
                    StatBox(title: "Score", value: "\(score)", color: .yellow)
                    StatBox(title: "Level", value: "\(level)", color: .cyan)
                }
                
                HStack(spacing: 24) {
                    StatBox(title: "Perfect", value: "\(perfectRounds)", color: .green)
                    StatBox(title: "Accuracy", value: "\(accuracy)%", color: .orange)
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
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    var performanceMessage: String {
        if perfectRounds >= 8 { return "🧠 Memory Master!" }
        if perfectRounds >= 5 { return "⭐️ Excellent Memory!" }
        if perfectRounds >= 3 { return "💪 Good Recall!" }
        return "Keep training your memory!"
    }
    
    // MARK: - Game Logic
    func startChallenge() {
        isActive = true
        score = 0
        level = 1
        gridSize = 3
        perfectRounds = 0
        totalAttempts = 0
        timeRemaining = 45
        
        HapticManager.shared.prepare()
        startNewRound()
        
        // Main timer
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.timeRemaining > 0 && self.isActive {
                self.timeRemaining -= 0.1
                self.updatePhase()
            } else {
                timer.invalidate()
                self.showResults = true
                if self.score >= 150 {
                    HapticManager.shared.success()
                    SoundManager.shared.playLevelUp()
                }
            }
        }
    }
    
    func startNewRound() {
        phase = .memorize
        userPattern = []
        flashingCells = []
        
        // Generate pattern based on level
        let patternSize = min(2 + level, (gridSize * gridSize) - 2)
        pattern = []
        while pattern.count < patternSize {
            pattern.insert(Int.random(in: 0..<(gridSize * gridSize)), into: pattern)
        }
        
        // Adjust memorize time based on difficulty
        memorizeTime = max(1.5, 3.0 - Double(level) * 0.2)
        phaseTimer = memorizeTime
        
        HapticManager.shared.mediumTap()
    }
    
    func updatePhase() {
        switch phase {
        case .memorize:
            phaseTimer -= 0.1
            if phaseTimer <= 0 {
                phase = .recall
                phaseTimer = 0
                HapticManager.shared.selectionChanged()
            }
            
        case .recall:
            // Waiting for user input
            break
            
        case .feedback:
            phaseTimer += 0.1
            if phaseTimer >= 1.5 {
                // Move to next round
                if timeRemaining > 0 {
                    startNewRound()
                }
            }
        }
    }
    
    func handleCellTap(_ index: Int) {
        guard phase == .recall else { return }
        
        if userPattern.contains(index) {
            userPattern.remove(index)
            HapticManager.shared.lightTap()
        } else {
            userPattern.insert(index)
            HapticManager.shared.lightTap()
            SoundManager.shared.playTap()
        }
        
        // Auto-submit when user has selected the right number of cells
        if userPattern.count == pattern.count {
            submitPattern()
        }
    }
    
    func submitPattern() {
        totalAttempts += 1
        phase = .feedback
        phaseTimer = 0
        
        if userPattern == pattern {
            // Perfect match!
            perfectRounds += 1
            let points = 20 * level + (pattern.count * 5)
            score += points
            
            // Level up
            level += 1
            if level % 3 == 0 && gridSize < 5 {
                gridSize += 1 // Increase grid size every 3 levels
            }
            
            HapticManager.shared.success()
            SoundManager.shared.playLevelUp()
            
            // Flash all correct cells
            flashingCells = pattern
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                flashingCells = []
            }
        } else {
            // Incorrect
            let correctCells = userPattern.intersection(pattern)
            score += correctCells.count * 2 // Partial credit
            
            HapticManager.shared.error()
            SoundManager.shared.playFail()
            
            // Flash incorrect cells
            flashingCells = userPattern.subtracting(pattern)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                flashingCells = []
            }
        }
    }
    
    func endChallenge() {
        isActive = false
        showResults = true
    }
}

// MARK: - Supporting Views
struct GridCell: View {
    let index: Int
    let isActive: Bool
    let isUserSelected: Bool
    let isFlashing: Bool
    let phase: MemoryGridChallenge.GamePhase
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
            
            if showContent {
                Circle()
                    .fill(contentColor)
                    .frame(width: size * 0.3, height: size * 0.3)
            }
            
            if isFlashing {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.5))
            }
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .animation(.easeInOut(duration: 0.2), value: isUserSelected)
    }
    
    var backgroundColor: Color {
        if phase == .memorize && isActive {
            return Color.blue.opacity(0.6)
        } else if phase == .recall && isUserSelected {
            return Color.cyan.opacity(0.4)
        } else if phase == .feedback {
            if isActive && isUserSelected {
                return Color.green.opacity(0.6)
            } else if isUserSelected {
                return Color.red.opacity(0.4)
            }
        }
        return Color.white.opacity(0.05)
    }
    
    var borderColor: Color {
        if phase == .recall && isUserSelected {
            return Color.cyan
        }
        return Color.white.opacity(0.2)
    }
    
    var borderWidth: CGFloat {
        isUserSelected ? 3 : 1
    }
    
    var showContent: Bool {
        (phase == .memorize && isActive) || (phase == .recall && isUserSelected)
    }
    
    var contentColor: Color {
        if phase == .memorize {
            return Color.white
        } else {
            return Color.cyan
        }
    }
}

struct PhaseIndicator: View {
    let phase: MemoryGridChallenge.GamePhase
    let currentPhase: MemoryGridChallenge.GamePhase
    let icon: String
    
    var isActive: Bool {
        phase == currentPhase
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isActive ? .cyan : .gray)
            
            Circle()
                .fill(isActive ? Color.cyan : Color.white.opacity(0.2))
                .frame(width: 8, height: 8)
        }
    }
}

#Preview {
    MemoryGridChallenge()
        .environmentObject(AppState())
}
