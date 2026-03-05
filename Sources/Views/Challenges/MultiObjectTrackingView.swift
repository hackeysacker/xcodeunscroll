import SwiftUI

// MARK: - Multi-Object Tracking Challenge
// Track multiple objects as they move across the screen
// Difficulty increases: more objects, faster movement, longer tracking time

struct MultiObjectTrackingView: View {
    @Environment(\.dismiss) var dismiss
    
    // Game State
    @State private var score: Int = 0
    @State private var round: Int = 1
    @State private var lives: Int = 3
    @State private var timeRemaining: Double = 45
    @State private var isGameOver: Bool = false
    @State private var showResults: Bool = false
    @State private var gamePhase: GamePhase = .ready
    
    // Objects
    @State private var trackingObjects: [TrackingObject] = []
    @State private var selectedObjects: Set<UUID> = []
    @State private var correctSelections: Set<UUID> = []
    @State private var wrongSelection: UUID?
    
    // Audio/Haptics
    @State private var audioManager = AppAudioManager.shared
    
    // Configuration
    let maxRounds = 10
    let objectCount: Int = 3
    let trackingDuration: Double = 3.0
    
    enum GamePhase {
        case ready
        case tracking
        case selecting
        case result
    }
    
    struct TrackingObject: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var targetX: CGFloat
        var targetY: CGFloat        var shape: String
        var color: Color
        var isSelected: Bool = false
        var wasCorrect: Bool = false
    }
    
    let shapes = ["circle.fill", "square.fill", "triangle.fill", "star.fill", "heart.fill", "diamond.fill"]
    let objectColors: [Color] = [.purple, .blue, .pink, .orange, .green, .yellow]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color("0A0F1C"), Color("1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                Spacer()
                
                // Game Area
                gameArea
                
                Spacer()
                
                // Instructions
                instructionText
                    .padding(.bottom, 40)
            }
            
            // Results Overlay
            if showResults {
                resultsOverlay
            }
        }
        .onAppear {
            startRound()
        }
    }
    
    // MARK: - Header
    var header: some View {
        HStack(spacing: 24) {
            // Round
            VStack(spacing: 2) {
                Text("Round \(round)/\(maxRounds)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text("LEVEL \(round)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Score
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.yellow)
                Text("SCORE")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            // Lives
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(i < lives ? .red : .gray)
                }
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
            
            // Tracking Objects
            ForEach(trackingObjects) { object in
                TrackingBubble(
                    object: object,
                    isSelected: selectedObjects.contains(object.id),
                    isWrong: wrongSelection == object.id,
                    isCorrect: correctSelections.contains(object.id),
                    isSelectable: gamePhase == .selecting
                ) {
                    handleObjectTap(object)
                }
                .position(x: object.x, y: object.y)
            }
            
            // Countdown overlay during tracking
            if gamePhase == .tracking {
                VStack {
                    Text("TRACK THE OBJECTS")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(Int(trackingDuration))")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Instruction Text
    @ViewBuilder
    var instructionText: some View {
        switch gamePhase {
        case .ready:
            Text("GET READY")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.yellow)
        case .tracking:
            Text("MEMORIZE THE POSITIONS")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.purple)
        case .selecting:
            Text("TAP THE SAME POSITIONS")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.green)
        case .result:
            Text(correctSelections.count == objectCount ? "CORRECT!" : "MISSED!")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(correctSelections.count == objectCount ? .green : .red)
        }
    }
    
    // MARK: - Results Overlay
    var resultsOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("\(score)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("POINTS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(2)
                
                Text(round >= maxRounds ? "COMPLETED!" : "GAME OVER")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(round >= maxRounds ? .green : .red)
                
                VStack(spacing: 8) {
                    Text("You reached round \(round)")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    Text("Objects tracked: \(objectCount)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                
                VStack(spacing: 12) {
                    Button {
                        restart()
                    } label: {
                        Text("Play Again")
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
    
    // MARK: - Game Logic
    func startRound() {
        // Reset round state
        trackingObjects = []
        selectedObjects = []
        correctSelections = []
        wrongSelection = nil
        gamePhase = .ready
        
        // Calculate number of objects based on round
        let objCount = min(objectCount + (round / 3), 6)
        
        // Generate objects
        let padding: CGFloat = 100
        let screenWidth = UIScreen.main.bounds.width - (padding * 2)
        let screenHeight = UIScreen.main.bounds.height - 400
        
        for i in 0..<objCount {
            let startX = CGFloat.random(in: padding...(UIScreen.main.bounds.width - padding))
            let startY = CGFloat.random(in: 200...(200 + screenHeight))
            
            let endX = CGFloat.random(in: padding...(UIScreen.main.bounds.width - padding))
            let endY = CGFloat.random(in: 200...(200 + screenHeight))
            
            let shape = shapes[i % shapes.count]
            let color = objectColors[i % objectColors.count]
            
            trackingObjects.append(TrackingObject(
                x: startX,
                y: startY,
                targetX: endX,
                targetY: endY,
                shape: shape,
                color: color
            ))
        }
        
        // Start tracking phase after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: trackingDuration)) {
                gamePhase = .tracking
                for i in 0..<trackingObjects.count {
                    trackingObjects[i].x = trackingObjects[i].targetX
                    trackingObjects[i].y = trackingObjects[i].targetY
                }
            }
            
            audioManager.playChallengeStart()
            
            // After tracking duration, hide objects and show selecting phase
            DispatchQueue.main.asyncAfter(deadline: .now() + trackingDuration + 0.5) {
                gamePhase = .selecting
                // Randomize positions for selection
                withAnimation(.spring(response: 0.4)) {
                    for i in 0..<trackingObjects.count {
                        trackingObjects[i].x = CGFloat.random(in: padding...(UIScreen.main.bounds.width - padding))
                        trackingObjects[i].y = CGFloat.random(in: 200...(200 + screenHeight))
                    }
                }
            }
        }
    }
    
    func handleObjectTap(_ object: TrackingObject) {
        guard gamePhase == .selecting else { return }
        guard !selectedObjects.contains(object.id) else { return }
        
        selectedObjects.insert(object.id)
        audioManager.lightImpact()
        
        // Check if this was one of the original positions
        // In this simplified version, we track by shape+color combination
        let originalIndex = round % trackingObjects.count
        
        // For simplicity: first N objects are the ones to track
        if selectedObjects.count <= trackingObjects.count {
            correctSelections.insert(object.id)
            audioManager.success()
        } else {
            wrongSelection = object.id
            lives -= 1
            audioManager.playError()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                wrongSelection = nil
            }
        }
        
        // Check round completion
        if selectedObjects.count >= trackingObjects.count || lives <= 0 {
            gamePhase = .result
            
            // Calculate score
            if lives > 0 {
                let roundScore = round * 20 + (trackingObjects.count * 10)
                score += roundScore
                audioManager.playReward()
            } else {
                audioManager.playError()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if round < maxRounds && lives > 0 {
                    round += 1
                    startRound()
                } else {
                    showResults = true
                }
            }
        }
    }
    
    func restart() {
        round = 1
        score = 0
        lives = 3
        showResults = false
        startRound()
    }
}

// MARK: - Tracking Bubble
struct TrackingBubble: View {
    let object: MultiObjectTrackingView.TrackingObject
    let isSelected: Bool
    let isWrong: Bool
    let isCorrect: Bool
    let isSelectable: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [fillColor, fillColor.opacity(0.5)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: object.color.opacity(0.6), radius: isSelected ? 25 : 15, x: 0, y: 5)
                
                // Border
                Circle()
                    .stroke(borderColor, lineWidth: isSelected ? 4 : 2)
                    .frame(width: 70, height: 70)
                
                // Shape icon
                Image(systemName: object.shape)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .disabled(!isSelectable)
        .scaleEffect(isSelected ? 0.9 : 1)
        .animation(.spring(response: 0.2), value: isSelected)
    }
    
    var fillColor: Color {
        if isWrong { return .red }
        if isCorrect { return .green }
        if isSelected { return object.color }
        return object.color.opacity(0.7)
    }
    
    var borderColor: Color {
        if isWrong { return .red }
        if isCorrect { return .green }
        if isSelected { return .white }
        return object.color
    }
}

#Preview {
    MultiObjectTrackingView()
}
