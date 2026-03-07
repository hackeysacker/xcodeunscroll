import SwiftUI
import AVFoundation
import AudioToolbox
import UIKit

// NOTE: HapticManager, SoundManager, Difficulty, GlassCard, and GlassProgressBar 
// are defined in UniversalChallengeView.swift and GlassComponents.swift
// They are shared across the entire app target and do not need to be redefined here.

// MARK: - Custom Shapes
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct StarShape: Shape {
    let points: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius / 2.5
        let angle = Double.pi / Double(points)
        
        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let currentAngle = angle * Double(i) - Double.pi / 2
            let point = CGPoint(
                x: center.x + cos(currentAngle) * radius,
                y: center.y + sin(currentAngle) * radius
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let angle = Double.pi / 3 // 60 degrees
        
        for i in 0..<6 {
            let currentAngle = angle * Double(i) - Double.pi / 2
            let point = CGPoint(
                x: center.x + cos(currentAngle) * radius,
                y: center.y + sin(currentAngle) * radius
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Target Types for Attention Challenge
enum TargetType: String, CaseIterable {
    case circle = "Circle"
    case square = "Square"
    case triangle = "Triangle"
    case star = "Star"
    case diamond = "Diamond"
    case hexagon = "Hexagon"
    
    // Number variants (1-9)
    case number1 = "1"
    case number2 = "2"
    case number3 = "3"
    case number4 = "4"
    case number5 = "5"
    case number6 = "6"
    case number7 = "7"
    case number8 = "8"
    case number9 = "9"
    
    // Letter variants (A-E for difficulty)
    case letterA = "A"
    case letterB = "B"
    case letterC = "C"
    case letterD = "D"
    case letterE = "E"
    
    var isShape: Bool {
        switch self {
        case .circle, .square, .triangle, .star, .diamond, .hexagon:
            return true
        default:
            return false
        }
    }
    
    var isNumber: Bool {
        switch self {
        case .number1, .number2, .number3, .number4, .number5, .number6, .number7, .number8, .number9:
            return true
        default:
            return false
        }
    }
    
    var isLetter: Bool {
        switch self {
        case .letterA, .letterB, .letterC, .letterD, .letterE:
            return true
        default:
            return false
        }
    }
    
    // Get color based on type
    var color: Color {
        switch self {
        case .circle, .number1, .letterA:
            return .purple
        case .square, .number2, .letterB:
            return .blue
        case .triangle, .number3, .letterC:
            return .green
        case .star, .number4, .letterD:
            return .yellow
        case .diamond, .number5, .letterE:
            return .orange
        case .hexagon:
            return .pink
        case .number6:
            return .cyan
        case .number7:
            return .indigo
        case .number8:
            return .teal
        case .number9:
            return .mint
        }
    }
}

// MARK: - Attention Challenge (Follow the target)
struct AttentionChallengeView: View {
    @Binding var score: Int
    let isActive: Bool
    var difficulty: Int = 1 // 1-3: shapes, 4-6: numbers, 7+: letters
    
    @State private var targetPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var targetOpacity: Double = 1.0
    @State private var moveTimer: Timer?
    @State private var currentTarget: TargetType = .circle
    @State private var targetIndex: Int = 0
    
    // Targets based on difficulty
    private var availableTargets: [TargetType] {
        if difficulty <= 3 {
            // Shapes only
            return [.circle, .square, .triangle, .star, .diamond, .hexagon]
        } else if difficulty <= 6 {
            // Numbers
            return [.number1, .number2, .number3, .number4, .number5, .number6, .number7, .number8, .number9]
        } else {
            // Letters (hardest)
            return [.letterA, .letterB, .letterC, .letterD, .letterE, .number1, .number2, .number3, .number4, .number5]
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background grid
                ForEach(0..<5, id: \.self) { row in
                    ForEach(0..<3, id: \.self) { col in
                        Rectangle()
                            .fill(Color.white.opacity(0.02))
                            .frame(width: geometry.size.width / 3, height: geometry.size.width / 3)
                            .position(
                                x: geometry.size.width / 6 + CGFloat(col) * geometry.size.width / 3,
                                y: geometry.size.width / 6 + CGFloat(row) * geometry.size.width / 3
                            )
                    }
                }
                
                // Target (with variety)
                targetView
                    .position(targetPosition)
                    .opacity(targetOpacity)
                
                // Score indicator
                VStack {
                    HStack {
                        Spacer()
                        GlassCard(intensity: 10, tint: .yellow, cornerRadius: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                Text("\(score)")
                            }
                            .foregroundColor(.yellow)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startMoving(in: geometry.size)
                } else {
                    stopMoving()
                }
            }
        }
    }
    
    @ViewBuilder
    private var targetView: some View {
        let size: CGFloat = currentTarget.isLetter ? 60 : 80
        
        Group {
            if currentTarget.isShape {
                shapeView(size: size)
            } else if currentTarget.isNumber || currentTarget.isLetter {
                textView(size: size)
            } else {
                Circle()
                    .fill(RadialGradient(colors: [.purple, .purple.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 50))
                    .frame(width: size, height: size)
                    .shadow(color: .purple.opacity(0.5), radius: 20)
            }
        }
    }
    
    @ViewBuilder
    private func shapeView(size: CGFloat) -> some View {
        let color = currentTarget.color
        
        switch currentTarget {
        case .circle:
            Circle()
                .fill(RadialGradient(colors: [color, color.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 50))
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.5), radius: 20)
        case .square:
            RoundedRectangle(cornerRadius: 8)
                .fill(RadialGradient(colors: [color, color.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 50))
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.5), radius: 20)
        case .triangle:
            Triangle()
                .fill(RadialGradient(colors: [color, color.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 50))
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.5), radius: 20)
        case .star:
            StarShape(points: 5)
                .fill(RadialGradient(colors: [color, color.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 50))
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.5), radius: 20)
        case .diamond:
            Diamond()
                .fill(RadialGradient(colors: [color, color.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 50))
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.5), radius: 20)
        case .hexagon:
            Hexagon()
                .fill(RadialGradient(colors: [color, color.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 50))
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.5), radius: 20)
        default:
            Circle()
                .fill(RadialGradient(colors: [color, color.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 50))
                .frame(width: size, height: size)
        }
    }
    
    @ViewBuilder
    private func textView(size: CGFloat) -> some View {
        let color = currentTarget.color
        let text = currentTarget.rawValue
        
        Text(text)
            .font(.system(size: size * 0.6, weight: .bold))
            .foregroundColor(color)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: size, height: size)
            )
            .shadow(color: color.opacity(0.5), radius: 15)
    }
    
    func startMoving(in size: CGSize) {
        // Speed increases with difficulty
        let interval = max(0.3, 0.8 - Double(difficulty) * 0.1)
        
        moveTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            withAnimation(.easeInOut(duration: interval * 0.8)) {
                targetPosition = CGPoint(
                    x: CGFloat.random(in: 0.2...0.8) * size.width,
                    y: CGFloat.random(in: 0.2...0.6) * size.height
                )
                // Change target type periodically
                targetIndex = (targetIndex + 1) % availableTargets.count
                currentTarget = availableTargets[targetIndex]
                score += 10 * difficulty // More points for harder targets
            }
        }
    }
    
    func stopMoving() {
        moveTimer?.invalidate()
        moveTimer = nil
    }
}

// Shapes are defined above at the top of the file

// MARK: - Memory Challenge (Pattern matching)
struct MemoryChallengeView: View {
    @Binding var score: Int
    @Binding var isActive: Bool
    
    @State private var grid: [Int] = Array(repeating: 0, count: 9)
    @State private var showingPattern: Bool = true
    @State private var playerTurn: Bool = false
    @State private var pattern: [Int] = []
    @State private var playerIndex: Int = 0
    @State private var level: Int = 1
    @State private var soundEnabled: Bool = true
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Sound frequencies for each grid position (musical notes)
    private var noteFrequencies: [Int: Int] {
        return [
            0: 262, // C4
            1: 294, // D4
            2: 330, // E4
            3: 349, // F4
            4: 392, // G4
            5: 440, // A4
            6: 494, // B4
            7: 523, // C5
            8: 587  // D5
        ]
    }
    
    // System sound IDs for different notes
    private var soundIDs: [Int: UInt32] {
        return [
            262: 1103,  // C4
            294: 1104,  // D4
            330: 1105,  // E4
            349: 1106,  // F4
            392: 1107,  // G4
            440: 1108,  // A4
            494: 1109,  // B4
            523: 1110,  // C5
            587: 1111   // D5
        ]
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Level indicator
            HStack {
                Text("Level \(level)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Sound toggle
                Button {
                    soundEnabled.toggle()
                } label: {
                    Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .foregroundColor(soundEnabled ? .purple : .gray)
                }
            }
            .padding(.horizontal, 24)
            
            Text(playerTurn ? "Your turn! Repeat the pattern" : "Watch the pattern!")
                .font(.system(size: 16))
                .foregroundColor(playerTurn ? .green : .purple)
            
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<pattern.count, id: \.self) { index in
                    Circle()
                        .fill(index < playerIndex ? Color.green : (index == playerIndex && playerTurn ? Color.yellow : Color.gray))
                        .frame(width: 12, height: 12)
                }
            }
            
            // Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<9, id: \.self) { index in
                    Button {
                        handleTap(index)
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(buttonColor(for: index))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: grid[index] == 1 ? .purple.opacity(0.5) : .clear, radius: 10)
                    }
                    .disabled(!playerTurn || showingPattern)
                }
            }
            .padding(.horizontal, 24)
            
            // Score
            Text("Score: \(score)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.yellow)
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startLevel()
            }
        }
    }
    
    func buttonColor(for index: Int) -> Color {
        if grid[index] == 1 {
            return .purple
        }
        return Color.white.opacity(0.1)
    }
    
    func handleTap(_ index: Int) {
        guard playerTurn else { return }
        
        // Play sound on tap
        if soundEnabled, let frequency = noteFrequencies[index] {
            playTone(frequency: frequency)
        }
        
        // Flash the button
        grid[index] = 1
        HapticManager.shared.lightTap()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            grid[index] = 0
        }
        
        // Check if correct
        if index == pattern[playerIndex] {
            playerIndex += 1
            if playerIndex >= pattern.count {
                // Level complete
                score += level * 10
                level += 1
                HapticManager.shared.success()
                SoundManager.shared.playLevelUp()
                startLevel()
            }
        } else {
            // Wrong - game over
            playerTurn = false
            HapticManager.shared.error()
            SoundManager.shared.playFail()
        }
    }
    
    func startLevel() {
        pattern = (0..<(2 + min(level, 5))).map { _ in Int.random(in: 0...8) } // Cap pattern length
        playerIndex = 0
        showingPattern = true
        playerTurn = false
        
        // Show pattern with sound
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            clearGrid()
            showingPattern = false
            playerTurn = true
            showPattern()
        }
    }
    
    func showPattern() {
        guard playerTurn else { return }
        
        for (i, index) in pattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6) {
                guard self.playerTurn else { return }
                grid[index] = 1
                if soundEnabled, let frequency = noteFrequencies[index] {
                    playTone(frequency: frequency)
                }
                HapticManager.shared.selectionChanged()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    grid[index] = 0
                }
            }
        }
    }
    
    func clearGrid() {
        grid = Array(repeating: 0, count: 9)
    }
    
    // Play a tone using system sound
    func playTone(frequency: Int) {
        if let soundID = soundIDs[frequency] {
            AudioServicesPlaySystemSound(soundID)
        } else {
            AudioServicesPlaySystemSound(1104)
        }
    }
}

// MARK: - Reaction Challenge
struct ReactionChallengeView: View {
    @Binding var score: Int
    let isActive: Bool
    var difficulty: Difficulty = .medium // New difficulty parameter
    
    @State private var gameState: ReactionState = .waiting
    @State private var startTime: Date?
    @State private var reactionTime: Double = 0
    @State private var reactionTimes: [Double] = [] // Track all reaction times
    @State private var bestTime: Double = 999 // Personal best
    @State private var averageTime: Double = 0
    @State private var roundCount: Int = 0
    @State private var falseStarts: Int = 0
    
    enum ReactionState {
        case waiting, ready, go, tooEarly
    }
    
    // Difficulty settings
    private var waitTimeRange: ClosedRange<Double> {
        switch difficulty {
        case .easy: return 3...6
        case .medium: return 2...5
        case .hard: return 1.5...4
        case .extreme: return 1...3
        }
    }
    
    private var goDelayRange: ClosedRange<Double> {
        switch difficulty {
        case .easy: return 1.0...2.0
        case .medium: return 0.5...1.5
        case .hard: return 0.3...1.0
        case .extreme: return 0.2...0.5
        }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Stats header
            HStack(spacing: 20) {
                StatBadge(title: "Best", value: bestTime < 999 ? "\(Int(bestTime * 1000))ms" : "-", color: .green)
                StatBadge(title: "Avg", value: averageTime > 0 ? "\(Int(averageTime * 1000))ms" : "-", color: .blue)
                StatBadge(title: "Rounds", value: "\(roundCount)", color: .purple)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Main circle
            ZStack {
                Circle()
                    .fill(circleColor.opacity(0.3))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .stroke(circleColor, lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                Text(circleText)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            .onTapGesture {
                handleTap()
            }
            
            // Current reaction time
            if reactionTime > 0 {
                VStack(spacing: 4) {
                    Text("\(Int(reactionTime * 1000)) ms")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(reactionColor)
                    
                    if reactionTime == bestTime && roundCount > 0 {
                        Text("New Best!")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            } else if falseStarts > 0 {
                Text("False starts: \(falseStarts)")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            // Instructions
            HStack {
                Image(systemName: "bolt.fill")
                Text("Tap when green!")
            }
            .font(.system(size: 16))
            .foregroundColor(.gray)
            
            // Difficulty indicator
            Text("Difficulty: \(difficulty.rawValue.capitalized)")
                .font(.system(size: 12))
                .foregroundColor(difficultyColor)
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                resetGame()
            }
        }
    }
    
    var circleColor: Color {
        switch gameState {
        case .waiting: return .red
        case .ready: return .yellow
        case .go: return .green
        case .tooEarly: return .orange
        }
    }
    
    var circleText: String {
        switch gameState {
        case .waiting: return "Wait..."
        case .ready: return "Wait..."
        case .go: return "TAP!"
        case .tooEarly: return "Too Early!"
        }
    }
    
    var reactionColor: Color {
        if reactionTime < 0.2 { return .green }
        if reactionTime < 0.3 { return .yellow }
        return .orange
    }
    
    var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .extreme: return .red
        }
    }
    
    func handleTap() {
        switch gameState {
        case .waiting:
            gameState = .tooEarly
            falseStarts += 1
            HapticManager.shared.error()
            resetAfterDelay()
        case .ready:
            gameState = .tooEarly
            falseStarts += 1
            HapticManager.shared.error()
            resetAfterDelay()
        case .go:
            let thisReaction = Date().timeIntervalSince(startTime!)
            reactionTime = thisReaction
            roundCount += 1
            
            // Update stats
            reactionTimes.append(thisReaction)
            averageTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
            
            if thisReaction < bestTime {
                bestTime = thisReaction
                HapticManager.shared.success()
                SoundManager.shared.playSuccess()
            } else {
                HapticManager.shared.lightTap()
            }
            
            // Score based on reaction time and difficulty
            let baseScore = max(0, Int((0.5 - thisReaction) * 200))
            let difficultyBonus = Int(Double(baseScore) * difficulty.xpMultiplier)
            score += difficultyBonus
            
            resetAfterDelay()
        case .tooEarly:
            break
        }
    }
    
    func resetGame() {
        gameState = .waiting
        reactionTime = 0
        reactionTimes = []
        bestTime = 999
        averageTime = 0
        roundCount = 0
        falseStarts = 0
        
        startNextRound()
    }
    
    func startNextRound() {
        // Random delay before showing ready
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: waitTimeRange)) {
            guard isActive else { return }
            gameState = .ready
            startTime = Date()
            
            // Random delay before green
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: goDelayRange)) {
                guard isActive else { return }
                gameState = .go
                startTime = Date()
                HapticManager.shared.warning()
            }
        }
    }
    
    func resetAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if isActive {
                gameState = .waiting
                startNextRound()
            }
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}

// MARK: - Focus Challenge (Hold focus)
struct FocusChallengeView: View {
    @Binding var score: Int
    let isActive: Bool
    
    @State private var focusLevel: Double = 0.5
    @State private var isHolding: Bool = false
    @State private var holdTimer: Timer?
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Hold your focus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Keep your finger on the circle")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            // Focus circle
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: focusLevel)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .yellow, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                // Inner circle
                Circle()
                    .fill(isHolding ? Color.green.opacity(0.3) : Color.white.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "eye.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isHolding ? .green : .gray)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isHolding {
                            isHolding = true
                            startHolding()
                        }
                    }
                    .onEnded { _ in
                        isHolding = false
                        stopHolding()
                    }
            )
            
            // Score
            HStack {
                Image(systemName: "star.fill")
                Text("\(score)")
            }
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.yellow)
        }
    }
    
    func startHolding() {
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if isHolding {
                focusLevel = min(1.0, focusLevel + 0.02)
                score += 1
            }
        }
    }
    
    func stopHolding() {
        holdTimer?.invalidate()
        holdTimer = nil
    }
}

// MARK: - Discipline Challenge (Impulse control)
struct DisciplineChallengeView: View {
    @Binding var score: Int
    let isActive: Bool
    
    @State private var showTarget: Bool = false
    @State private var targetTimer: Timer?
    @State private var distractionTimer: Timer?
    @State private var temptationLevel: Double = 0
    
    // Response time tracking
    @State private var responseTimes: [Double] = []
    @State private var currentResponseTime: Double = 0
    @State private var bestResponseTime: Double = 999
    @State private var averageResponseTime: Double = 0
    @State private var responseStartTime: Date?
    
    // Distraction tracking
    @State private var distractionCount: Int = 0
    @State private var distractionsResisted: Int = 0
    @State private var roundNumber: Int = 0
    
    // Fake notifications
    @State private var activeNotifications: [FakeNotification] = []
    @State private var notificationId: Int = 0
    
    // Current distraction scenario
    @State private var currentDistraction: DistractionScenario?
    
    var body: some View {
        VStack(spacing: 16) {
            // Stats header
            HStack(spacing: 16) {
                StatBadge(title: "Best", value: bestResponseTime < 999 ? "\(Int(bestResponseTime * 1000))ms" : "-", color: .green)
                StatBadge(title: "Avg", value: averageResponseTime > 0 ? "\(Int(averageResponseTime * 1000))ms" : "-", color: .blue)
                StatBadge(title: "Round", value: "\(roundNumber)", color: .purple)
            }
            .padding(.horizontal)
            
            // Temptation indicator
            VStack(spacing: 8) {
                Text("Temptation Level")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                GlassProgressBar(
                    progress: temptationLevel,
                    height: 8,
                    gradientColors: [.green, .yellow, .red]
                )
            }
            .padding(.horizontal, 40)
            
            // Distraction counter
            HStack {
                Image(systemName: "bell.slash.fill")
                    .foregroundColor(.orange)
                Text("\(distractionsResisted) distractions resisted")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            // Active notifications overlay
            ZStack {
                // Main button
                Button {
                    handleTap()
                } label: {
                    Circle()
                        .fill(buttonColor)
                        .frame(width: 150, height: 150)
                        .shadow(color: buttonColor.opacity(0.5), radius: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                }
                
                // Fake notifications
                ForEach(activeNotifications) { notification in
                    FakeNotificationView(notification: notification)
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                }
            }
            
            Spacer()
            
            // Instructions
            VStack(spacing: 8) {
                Text("Don't tap until you see green!")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                if let distraction = currentDistraction {
                    HStack(spacing: 4) {
                        Image(systemName: distraction.icon)
                        Text(distraction.message)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(20)
                }
            }
            
            // Score
            HStack {
                Image(systemName: "hand.raised.fill")
                Text("\(score) points")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.purple)
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startGame()
            } else {
                stopGame()
            }
        }
    }
    
    var buttonColor: Color {
        if showTarget {
            return .green
        }
        return temptationLevel > 0.7 ? .red : .orange
    }
    
    func handleTap() {
        if showTarget {
            // Good tap - record response time
            if let startTime = responseStartTime {
                currentResponseTime = Date().timeIntervalSince(startTime)
                responseTimes.append(currentResponseTime)
                
                if currentResponseTime < bestResponseTime {
                    bestResponseTime = currentResponseTime
                }
                averageResponseTime = responseTimes.reduce(0, +) / Double(responseTimes.count)
            }
            
            // Score based on response time and temptation level
            let baseScore = Int(50 * (1 - temptationLevel))
            let speedBonus = max(0, Int((0.5 - currentResponseTime) * 100))
            score += baseScore + speedBonus
            
            showTarget = false
            HapticManager.shared.success()
            startNextRound()
        } else {
            // Bad tap - temptation too high
            score = max(0, score - 10)
            temptationLevel = min(1.0, temptationLevel + 0.2)
            HapticManager.shared.error()
            
            // Failed to resist - remove the distraction but increase temptation
            if let distraction = currentDistraction {
                distractionsResisted += 1
                currentDistraction = nil
            }
        }
    }
    
    func startGame() {
        roundNumber = 0
        distractionsResisted = 0
        responseTimes = []
        bestResponseTime = 999
        averageResponseTime = 0
        temptationLevel = 0
        startNextRound()
    }
    
    func startNextRound() {
        roundNumber += 1
        responseStartTime = Date()
        currentDistraction = nil
        activeNotifications = []
        
        // Base temptation increases with round number (up to max 0.9)
        let baseTemptation = min(0.7, Double(roundNumber) * 0.08)
        temptationLevel = baseTemptation
        
        // Show target randomly - earlier rounds have more time
        let minDelay = max(1.5, 4.0 - Double(roundNumber) * 0.3)
        let maxDelay = max(2.5, 6.0 - Double(roundNumber) * 0.3)
        
        // Show distraction
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showDistraction()
        }
        
        // Show target
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: minDelay...maxDelay)) {
            showTarget = true
            currentDistraction = nil
            // Clear notifications when target appears
            withAnimation {
                activeNotifications = []
            }
        }
    }
    
    func showDistraction() {
        guard isActive && !showTarget else { return }
        
        let scenario = DistractionScenario.random()
        currentDistraction = scenario
        distractionCount += 1
        
        // Show fake notification
        let notification = FakeNotification(
            id: notificationId,
            appName: scenario.appName,
            message: scenario.message,
            icon: scenario.icon,
            notificationType: scenario.notificationType
        )
        notificationId += 1
        
        withAnimation(.spring(response: 0.3)) {
            activeNotifications.append(notification)
        }
        
        // Haptic feedback based on urgency
        switch scenario.notificationType {
        case .critical:
            HapticManager.shared.warning()
        case .normal:
            HapticManager.shared.lightTap()
        case .subtle:
            break
        }
        
        // Auto-dismiss notification after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.5...3.0)) {
            withAnimation {
                activeNotifications.removeAll { $0.id == notification.id }
            }
            if currentDistraction?.id == scenario.id {
                currentDistraction = nil
                distractionsResisted += 1
            }
        }
        
        // Schedule next distraction (frequency increases with rounds)
        let nextDistractionDelay = max(0.8, 2.5 - Double(roundNumber) * 0.15)
        distractionTimer = Timer.scheduledTimer(withTimeInterval: nextDistractionDelay, repeats: false) { _ in
            if !showTarget && isActive {
                showDistraction()
            }
        }
    }
    
    func stopGame() {
        targetTimer?.invalidate()
        targetTimer = nil
        distractionTimer?.invalidate()
        distractionTimer = nil
    }
}

// MARK: - Distraction Scenarios
struct DistractionScenario: Identifiable {
    let id = UUID()
    let appName: String
    let message: String
    let icon: String
    let notificationType: NotificationType
    
    enum NotificationType {
        case critical  // Red, urgent
        case normal    // Blue, standard
        case subtle    // Gray, minor
    }
    
    static let scenarios: [DistractionScenario] = [
        // Social media
        DistractionScenario(appName: "Messages", message: "New message from Alex", icon: "message.fill", notificationType: .normal),
        DistractionScenario(appName: "Instagram", message: "Sarah liked your photo", icon: "heart.fill", notificationType: .normal),
        DistractionScenario(appName: "TikTok", message: "New trending video available", icon: "play.rectangle.fill", notificationType: .normal),
        DistractionScenario(appName: "Twitter", message: "50 new mentions", icon: "at", notificationType: .normal),
        DistractionScenario(appName: "Snapchat", message: "New snap from Jordan", icon: "bolt.fill", notificationType: .normal),
        
        // Communication
        DistractionScenario(appName: "Mail", message: "Important email received", icon: "envelope.fill", notificationType: .critical),
        DistractionScenario(appName: "Slack", message: "New message in #general", icon: "number.circle.fill", notificationType: .normal),
        DistractionScenario(appName: "Discord", message: "New DM from server", icon: "bubble.left.fill", notificationType: .normal),
        
        // Shopping & Entertainment
        DistractionScenario(appName: "Amazon", message: "Your order has shipped!", icon: "shippingbox.fill", notificationType: .subtle),
        DistractionScenario(appName: "Netflix", message: "Continue watching?", icon: "play.tv.fill", notificationType: .normal),
        DistractionScenario(appName: "YouTube", message: "New video uploaded", icon: "play.circle.fill", notificationType: .normal),
        DistractionScenario(appName: "Spotify", message: "New podcast episode", icon: "headphones", notificationType: .subtle),
        
        // Productivity
        DistractionScenario(appName: "Calendar", message: "Meeting in 5 minutes", icon: "calendar.badge.clock", notificationType: .critical),
        DistractionScenario(appName: "Reminders", message: "Task due today", icon: "checklist", notificationType: .normal),
        DistractionScenario(appName: "Notes", message: "Note synced from iPad", icon: "note.text", notificationType: .subtle),
        
        // Gaming
        DistractionScenario(appName: "Games", message: "Your daily reward is ready!", icon: "star.fill", notificationType: .normal),
        DistractionScenario(appName: "Roblox", message: "Friend is online", icon: "person.2.fill", notificationType: .normal),
    ]
    
    static func random() -> DistractionScenario {
        scenarios.randomElement()!
    }
}

// MARK: - Fake Notification
struct FakeNotification: Identifiable {
    let id: Int
    let appName: String
    let message: String
    let icon: String
    let notificationType: DistractionScenario.NotificationType
    
    var backgroundColor: Color {
        switch notificationType {
        case .critical: return .red.opacity(0.9)
        case .normal: return .blue.opacity(0.9)
        case .subtle: return .gray.opacity(0.9)
        }
    }
}

// MARK: - Fake Notification View
struct FakeNotificationView: View {
    let notification: FakeNotification
    
    var body: some View {
        HStack(spacing: 12) {
            // App icon placeholder
            Image(systemName: notification.icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(notification.backgroundColor.opacity(0.3))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.appName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(notification.message)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text("now")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.85))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(notification.backgroundColor.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .offset(y: -120) // Position above the button
    }
}

// MARK: - Breathing Exercise Patterns
enum BreathingPattern: String, CaseIterable {
    case boxBreathing = "Box Breathing"
    case fourSevenEight = "4-7-8 Relaxing"
    case calmBreathing = "Calm Breathing"
    case energizing = "Energizing"
    
    var inhaleSeconds: Int {
        switch self {
        case .boxBreathing: return 4
        case .fourSevenEight: return 4
        case .calmBreathing: return 4
        case .energizing: return 2
        }
    }
    
    var holdAfterInhaleSeconds: Int {
        switch self {
        case .boxBreathing: return 4
        case .fourSevenEight: return 7
        case .calmBreathing: return 2
        case .energizing: return 0
        }
    }
    
    var exhaleSeconds: Int {
        switch self {
        case .boxBreathing: return 4
        case .fourSevenEight: return 8
        case .calmBreathing: return 6
        case .energizing: return 2
        }
    }
    
    var holdAfterExhaleSeconds: Int {
        switch self {
        case .boxBreathing: return 4
        case .fourSevenEight: return 0
        case .calmBreathing: return 2
        case .energizing: return 0
        }
    }
    
    var description: String {
        switch self {
        case .boxBreathing:
            return "Equal parts: inhale, hold, exhale, hold. Great for focus and calm."
        case .fourSevenEight:
            return "Relaxing breath pattern. Longer exhale calms the nervous system."
        case .calmBreathing:
            return "Gentle breathing to reduce stress and anxiety."
        case .energizing:
            return "Quick breaths to increase alertness and energy."
        }
    }
    
    var totalCycleSeconds: Int {
        inhaleSeconds + holdAfterInhaleSeconds + exhaleSeconds + holdAfterExhaleSeconds
    }
}

// MARK: - Mood Types for tracking
enum MoodType: String, CaseIterable, Identifiable {
    case anxious = "Anxious"
    case stressed = "Stressed"
    case tired = "Tired"
    case calm = "Calm"
    case focused = "Focused"
    case energized = "Energized"
    
    var id: Self { self }
    
    var emoji: String {
        switch self {
        case .anxious: return "😰"
        case .stressed: return "😫"
        case .tired: return "😴"
        case .calm: return "😌"
        case .focused: return "🎯"
        case .energized: return "⚡"
        }
    }
    
    var color: Color {
        switch self {
        case .anxious: return .orange
        case .stressed: return .red
        case .tired: return .purple
        case .calm: return .green
        case .focused: return .blue
        case .energized: return .yellow
        }
    }
}

// MARK: - Breathing Exercise View
struct BreathingExerciseView: View {
    @Binding var score: Int
    @Binding var isActive: Bool
    
    @State private var selectedPattern: BreathingPattern = .boxBreathing
    @State private var phase: BreathingPhase = .ready
    @State private var progress: Double = 0
    @State private var cycleCount: Int = 0
    @State private var sessionDuration: Int = 0 // in seconds
    @State private var totalCycles: Int = 4 // default
    @State private var showPatternPicker: Bool = false
    @State private var showDurationPicker: Bool = false
    
    // Mood tracking
    @State private var showMoodPicker: Bool = true
    @State private var preSessionMood: MoodType?
    @State private var postSessionMood: MoodType?
    @State private var showPostSessionMood: Bool = false
    
    // Duration options in cycles
    private let durationOptions = [2, 4, 6, 8, 10]
    
    @State private var timer: Timer?
    @State private var sessionTimer: Timer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var isGuidedAudioEnabled: Bool = true
    
    // MARK: - Speech Helper
    private func speak(_ text: String) {
        guard isGuidedAudioEnabled else { return }
        speechSynthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        utterance.pitchMultiplier = 0.9
        utterance.volume = 0.6
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
    
    enum BreathingPhase: String {
        case ready = "Ready"
        case inhale = "Breathe In"
        case holdInhale = "Hold (In)"
        case exhale = "Breathe Out"
        case holdExhale = "Hold (Out)"
        case complete = "Complete!"
        
        var instruction: String {
            switch self {
            case .ready: return "Tap to begin"
            case .inhale: return "Slowly breathe in"
            case .holdInhale: return "Hold your breath"
            case .exhale: return "Slowly breathe out"
            case .holdExhale: return "Hold empty"
            case .complete: return "Great job!"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Mood selector (before session)
            if phase == .ready && showMoodPicker && preSessionMood == nil {
                preMoodSelector
            }
            
            // Pattern selector
            if phase == .ready && preSessionMood != nil {
                patternSelector
                durationSelector
                
                // Guided audio toggle
                HStack {
                    Image(systemName: isGuidedAudioEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .foregroundColor(isGuidedAudioEnabled ? .green : .gray)
                    Text("Guided Audio")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $isGuidedAudioEnabled)
                        .labelsHidden()
                        .tint(.green)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            // Phase indicator
            Text(phase.rawValue)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(phaseColor)
            
            // Main breathing circle
            ZStack {
                // Outer ring (progress)
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 220, height: 220)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(colors: [phaseColor, phaseColor.opacity(0.5)], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: progress)
                
                // Inner circle
                Circle()
                    .fill(phaseColor.opacity(0.2))
                    .frame(width: breathingCircleSize, height: breathingCircleSize)
                
                // Icon
                Image(systemName: phaseIcon)
                    .font(.system(size: 50))
                    .foregroundColor(phaseColor)
            }
            .onTapGesture {
                if phase == .ready {
                    startBreathing()
                }
            }
            
            // Instructions
            Text(phase.instruction)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            // Stats row
            HStack(spacing: 24) {
                VStack {
                    Text("\(cycleCount)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("Cycles")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                VStack {
                    Text(formattedDuration)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("Duration")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                VStack {
                    Text("\(score)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("Score")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            // Pattern info
            if phase != .ready && phase != .complete {
                VStack(spacing: 4) {
                    Text("\(selectedPattern.inhaleSeconds)s in • \(selectedPattern.holdAfterInhaleSeconds)s hold • \(selectedPattern.exhaleSeconds)s out")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            // Post-session mood picker
            if showPostSessionMood && postSessionMood == nil {
                postMoodSelector
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                phase = .ready
                cycleCount = 0
                sessionDuration = 0
                score = 0
                preSessionMood = nil
                postSessionMood = nil
                showMoodPicker = true
                showPostSessionMood = false
            } else {
                stopBreathing()
            }
        }
    }
    
    var patternSelector: some View {
        VStack(spacing: 16) {
            Text("Choose a pattern")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                Button {
                    selectedPattern = pattern
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pattern.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Text(pattern.description)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        if selectedPattern == pattern {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedPattern == pattern ? Color.green.opacity(0.15) : Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedPattern == pattern ? Color.green : Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Pre-Session Mood Selector
    var preMoodSelector: some View {
        VStack(spacing: 20) {
            Text("How are you feeling?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("Select your current mood")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            // Mood grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(MoodType.allCases) { mood in
                    Button {
                        preSessionMood = mood
                    } label: {
                        VStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.system(size: 32))
                            Text(mood.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(mood.color.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Post-Session Mood Selector
    var postMoodSelector: some View {
        VStack(spacing: 20) {
            Text("How do you feel now?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            if let preMood = preSessionMood {
                HStack(spacing: 8) {
                    Text("Was: \(preMood.emoji)")
                    Image(systemName: "arrow.right")
                    Text("Now:")
                }
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
            
            // Mood grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(MoodType.allCases) { mood in
                    Button {
                        postSessionMood = mood
                        // Save mood data (could sync to Supabase here)
                        saveMoodTracking()
                        showPostSessionMood = false
                    } label: {
                        VStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.system(size: 32))
                            Text(mood.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(mood.color.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Button {
                showPostSessionMood = false
            } label: {
                Text("Skip")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Save mood tracking
    func saveMoodTracking() {
        guard let pre = preSessionMood, let post = postSessionMood else { return }
        
        // Log mood improvement
        let moodImproved = moodScore(pre) < moodScore(post)
        let improvement = abs(moodScore(pre) - moodScore(post))
        
        print("Mood tracking: \(pre.rawValue) -> \(post.rawValue), improved: \(moodImproved), change: \(improvement)")
        
        // Additional XP for mood improvement
        if moodImproved {
            score += 25
        }
    }
    
    func moodScore(_ mood: MoodType) -> Int {
        switch mood {
        case .anxious: return 1
        case .stressed: return 2
        case .tired: return 3
        case .calm: return 4
        case .focused: return 5
        case .energized: return 6
        }
    }
    
    // MARK: - Duration Selector
    var durationSelector: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Session Length")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button {
                    showDurationPicker.toggle()
                } label: {
                    Text("\(totalCycles) cycles")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.cyan.opacity(0.15))
                        )
                }
            }
            
            if showDurationPicker {
                HStack(spacing: 8) {
                    ForEach(durationOptions, id: \.self) { cycles in
                        Button {
                            totalCycles = cycles
                            showDurationPicker = false
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(cycles)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(totalCycles == cycles ? .black : .white)
                                Text("cycles")
                                    .font(.system(size: 10))
                                    .foregroundColor(totalCycles == cycles ? .black.opacity(0.7) : .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(totalCycles == cycles ? Color.cyan : Color.white.opacity(0.1))
                            )
                        }
                    }
                }
                
                // Show estimated time
                let estimatedMinutes = (totalCycles * selectedPattern.totalCycleSeconds) / 60
                Text("~ \(estimatedMinutes) minute session")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    var phaseColor: Color {
        switch phase {
        case .ready: return .blue
        case .inhale: return .cyan
        case .holdInhale: return .purple
        case .exhale: return .green
        case .holdExhale: return .orange
        case .complete: return .yellow
        }
    }
    
    var phaseIcon: String {
        switch phase {
        case .ready: return "wind"
        case .inhale: return "arrow.up"
        case .holdInhale: return "pause.circle"
        case .exhale: return "arrow.down"
        case .holdExhale: return "pause.circle"
        case .complete: return "star.fill"
        }
    }
    
    var breathingCircleSize: CGFloat {
        switch phase {
        case .inhale: return 280
        case .holdInhale: return 280
        case .exhale, .holdExhale: return 150
        case .ready, .complete: return 200
        }
    }
    
    var formattedDuration: String {
        let minutes = sessionDuration / 60
        let seconds = sessionDuration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func startBreathing() {
        phase = .inhale
        progress = 0
        cycleCount = 0
        
        // Speak initial guidance
        speak("Starting. Get comfortable. Follow my voice.")
        
        // Start session timer
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            sessionDuration += 1
        }
        
        runBreathingCycle()
    }
    
    func runBreathingCycle() {
        let pattern = selectedPattern
        
        // Inhale phase
        phase = .inhale
        speak("Breathe in")
        animateProgress(duration: Double(pattern.inhaleSeconds)) {
            // Hold after inhale
            if pattern.holdAfterInhaleSeconds > 0 {
                phase = .holdInhale
                speak("Hold")
                animateProgress(duration: Double(pattern.holdAfterInhaleSeconds)) {
                    doExhale(pattern: pattern)
                }
            } else {
                doExhale(pattern: pattern)
            }
        }
    }
    
    func doExhale(pattern: BreathingPattern) {
        phase = .exhale
        speak("Breathe out")
        animateProgress(duration: Double(pattern.exhaleSeconds)) {
            // Hold after exhale
            if pattern.holdAfterExhaleSeconds > 0 {
                phase = .holdExhale
                speak("Hold")
                animateProgress(duration: Double(pattern.holdAfterExhaleSeconds)) {
                    completeCycle()
                }
            } else {
                completeCycle()
            }
        }
    }
    
    func completeCycle() {
        cycleCount += 1
        score += 50 // Score per complete cycle
        
        // Continue to next cycle
        if cycleCount < totalCycles {
            runBreathingCycle()
        } else {
            finishSession()
        }
    }
    
    func finishSession() {
        phase = .complete
        score += 100 // Bonus for completing
        speak("Well done. Session complete.")
        HapticManager.shared.success()
        SoundManager.shared.playLevelUp()
        
        // Show post-session mood after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showPostSessionMood = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if postSessionMood == nil {
                isActive = false
            }
        }
    }
    
    func animateProgress(duration: Double, completion: @escaping () -> Void) {
        let steps = Int(duration * 10)
        let stepDuration = duration / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                self.progress = Double(i) / Double(steps)
                if i == steps {
                    completion()
                }
            }
        }
    }
    
    func stopBreathing() {
        timer?.invalidate()
        timer = nil
        sessionTimer?.invalidate()
        sessionTimer = nil
    }
}

#Preview("Attention") {
    AttentionChallengeView(score: Binding.constant(0), isActive: true)
        .background(Color.black)
}

#Preview("Memory") {
    MemoryChallengeView(score: Binding.constant(0), isActive: Binding.constant(true))
        .background(Color.black)
}

#Preview("Reaction") {
    ReactionChallengeView(score: Binding.constant(0), isActive: true)
        .background(Color.black)
}

#Preview("Focus") {
    FocusChallengeView(score: Binding.constant(0), isActive: true)
        .background(Color.black)
}

#Preview("Discipline") {
    DisciplineChallengeView(score: Binding.constant(0), isActive: true)
        .background(Color.black)
}
