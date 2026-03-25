import SwiftUI

// MARK: - Attention Challenge (Follow the target)
struct AttentionChallengeView: View {
    @Binding var score: Int
    let isActive: Bool
    
    @State private var targetPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var targetOpacity: Double = 1.0
    @State private var moveTimer: Timer?
    
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
                
                // Target
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple, .purple.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)
                    .position(targetPosition)
                    .opacity(targetOpacity)
                    .shadow(color: .purple.opacity(0.5), radius: 20)
                
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
    
    func startMoving(in size: CGSize) {
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                targetPosition = CGPoint(
                    x: CGFloat.random(in: 0.2...0.8) * size.width,
                    y: CGFloat.random(in: 0.2...0.6) * size.height
                )
                score += 10
            }
        }
    }
    
    func stopMoving() {
        moveTimer?.invalidate()
        moveTimer = nil
    }
}

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
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Level indicator
            Text("Level \(level)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(playerTurn ? "Your turn!" : "Watch the pattern!")
                .font(.system(size: 16))
                .foregroundColor(playerTurn ? .green : .purple)
            
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
        
        // Flash the button
        grid[index] = 1
        
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
                startLevel()
            }
        } else {
            // Wrong - game over
            playerTurn = false
        }
    }
    
    func startLevel() {
        pattern = (0..<(2 + level)).map { _ in Int.random(in: 0...8) }
        playerIndex = 0
        showingPattern = true
        playerTurn = false
        
        // Show pattern
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(level) * 0.8) {
            clearGrid()
            showingPattern = false
            playerTurn = true
            showPattern()
        }
    }
    
    func showPattern() {
        guard playerTurn else { return }
        
        for (i, index) in pattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                grid[index] = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    grid[index] = 0
                }
            }
        }
    }
    
    func clearGrid() {
        grid = Array(repeating: 0, count: 9)
    }
}

// MARK: - Reaction Challenge
struct ReactionChallengeView: View {
    @Binding var score: Int
    let isActive: Bool
    
    @State private var gameState: ReactionState = .waiting
    @State private var startTime: Date?
    @State private var reactionTime: Double = 0
    
    enum ReactionState {
        case waiting, ready, go, tooEarly
    }
    
    var body: some View {
        VStack(spacing: 32) {
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
            
            if reactionTime > 0 {
                Text("\(Int(reactionTime * 1000)) ms")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(reactionColor)
            }
            
            Spacer()
            
            // Best time
            HStack {
                Image(systemName: "bolt.fill")
                Text("Tap when green!")
            }
            .font(.system(size: 16))
            .foregroundColor(.gray)
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
    
    func handleTap() {
        switch gameState {
        case .waiting:
            gameState = .tooEarly
            resetAfterDelay()
        case .ready:
            gameState = .tooEarly
            resetAfterDelay()
        case .go:
            reactionTime = Date().timeIntervalSince(startTime!)
            score = max(0, Int((0.5 - reactionTime) * 200))
            resetAfterDelay()
        case .tooEarly:
            break
        }
    }
    
    func resetGame() {
        gameState = .waiting
        reactionTime = 0
        
        // Random delay before green
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2...5)) {
            gameState = .ready
            startTime = Date()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...1.5)) {
                gameState = .go
            }
        }
    }
    
    func resetAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if isActive {
                resetGame()
            }
        }
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
    @State private var temptationLevel: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Resist the urge")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Don't tap until you see green!")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            // Temptation indicator
            VStack(spacing: 8) {
                Text("Temptation")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                GlassProgressBar(
                    progress: temptationLevel,
                    height: 8,
                    gradientColors: [.green, .yellow, .red]
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
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
            
            Spacer()
            
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
            // Good tap
            score += Int(50 * (1 - temptationLevel))
            showTarget = false
            startNextRound()
        } else {
            // Bad tap - temptation too high
            score = max(0, score - 10)
            temptationLevel = min(1.0, temptationLevel + 0.2)
        }
    }
    
    func startGame() {
        startNextRound()
    }
    
    func startNextRound() {
        // Increase temptation over time
        targetTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if temptationLevel < 1.0 {
                temptationLevel += 0.05
            }
        }
        
        // Show target randomly
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2...5)) {
            showTarget = true
            targetTimer?.invalidate()
        }
    }
    
    func stopGame() {
        targetTimer?.invalidate()
        targetTimer = nil
    }
}

#Preview("Attention") {
    AttentionChallengeView(score: .constant(0), isActive: true)
        .background(Color.black)
}

#Preview("Memory") {
    MemoryChallengeView(score: .constant(0), isActive: .constant(true))
        .background(Color.black)
}

#Preview("Reaction") {
    ReactionChallengeView(score: .constant(0), isActive: true)
        .background(Color.black)
}

#Preview("Focus") {
    FocusChallengeView(score: .constant(0), isActive: true)
        .background(Color.black)
}

#Preview("Discipline") {
    DisciplineChallengeView(score: .constant(0), isActive: true)
        .background(Color.black)
}
