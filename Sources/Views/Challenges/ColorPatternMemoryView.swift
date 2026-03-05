import SwiftUI

// MARK: - Color Pattern Memory Challenge
// Remember and reproduce color sequences
// Difficulty increases with sequence length

struct ColorPatternMemoryView: View {
    @Environment(\.dismiss) var dismiss
    
    // Game State
    @State private var score: Int = 0
    @State private var round: Int = 1
    @State private var lives: Int = 3
    @State private var sequence: [ColorTile] = []
    @State private var userSequence: [Int] = []
    @State private var showingSequence: Bool = false
    @State private var canTap: Bool = false
    @State private var isGameOver: Bool = false
    @State private var showResults: Bool = false
    @State private var selectedTile: Int?
    @State private var correctTiles: Set<Int> = []
    @State private var wrongTile: Int?
    @State private var audioManager = AppAudioManager.shared
    
    // Configuration
    let maxRounds = 12
    let tileColors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    let tileEmojis: [String] = ["🔴", "🔵", "🟢", "🟡", "🟣", "🟠"]
    
    struct ColorTile: Identifiable {
        let id = Int
        let color: Color
        let emoji: String
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color("0A0F1C"), Color("1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                Spacer()
                
                // Game Content
                if showResults {
                    resultsOverlay
                } else {
                    gameContent
                }
                
                Spacer()
                
                // Instructions
                if showingSequence {
                    Text("MEMORIZE THE PATTERN")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(.bottom, 40)
                } else if canTap {
                    Text("REPEAT THE PATTERN")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.bottom, 40)
                }
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
                Text("SEQUENCE: \(sequence.count)")
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
    
    // MARK: - Game Content
    var gameContent: some View {
        VStack(spacing: 40) {
            // Sequence display area (shows when memorizing)
            if showingSequence {
                HStack(spacing: 16) {
                    ForEach(sequence.indices, id: \.self) { index in
                        Circle()
                            .fill(sequence[index].color)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            )
                            .scaleEffect(showingSequence ? 1 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                                value: showingSequence
                            )
                    }
                }
                .padding(.top, 40)
            }
            
            // Tap tiles
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(0..<6, id: \.self) { index in
                    ColorTileButton(
                        index: index,
                        emoji: tileEmojis[index],
                        color: tileColors[index],
                        isShowing: showingSequence && sequence.contains(where: { $0.id == index }),
                        isCorrect: correctTiles.contains(index),
                        isWrong: wrongTile == index,
                        canTap: canTap
                    ) {
                        handleTap(index)
                    }
                }
            }
            .padding(.horizontal, 40)
            
            // Progress indicator
            if canTap {
                HStack(spacing: 8) {
                    ForEach(0..<sequence.count, id: \.self) { index in
                        Circle()
                            .fill(index < userSequence.count ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                }
            }
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
                    Text("Longest sequence: \(sequence.count)")
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
                            .background(Color.blue)
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
        sequence = []
        userSequence = []
        showingSequence = false
        canTap = false
        selectedTile = nil
        correctTiles = []
        wrongTile = nil
        
        // Generate sequence - starts at 3, increases every 2 rounds
        let sequenceLength = 3 + (round / 2)
        
        for _ in 0..<sequenceLength {
            let randomIndex = Int.random(in: 0..<6)
            sequence.append(ColorTile(id: randomIndex, color: tileColors[randomIndex], emoji: tileEmojis[randomIndex]))
        }
        
        // Show sequence
        showingSequence = true
        audioManager.playChallengeStart()
        
        // Hide sequence after delay
        let displayTime = Double(sequenceLength) * 0.8 + 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + displayTime) {
            showingSequence = false
            canTap = true
        }
    }
    
    func handleTap(_ index: Int) {
        guard canTap else { return }
        
        selectedTile = index
        audioManager.lightImpact()
        
        let expectedIndex = sequence[userSequence.count].id
        
        if index == expectedIndex {
            // Correct
            correctTiles.insert(index)
            userSequence.append(index)
            audioManager.success()
            
            // Check if sequence complete
            if userSequence.count == sequence.count {
                canTap = false
                score += round * 15 + (sequence.count * 5)
                audioManager.playReward()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if round < maxRounds {
                        round += 1
                        startRound()
                    } else {
                        showResults = true
                    }
                }
            }
        } else {
            // Wrong
            wrongTile = index
            lives -= 1
            audioManager.playError()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                wrongTile = nil
                selectedTile = nil
                
                if lives <= 0 {
                    canTap = false
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

// MARK: - Color Tile Button
struct ColorTileButton: View {
    let index: Int
    let emoji: String
    let color: Color
    let isShowing: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let canTap: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(tileColor)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColor, lineWidth: 3)
                    )
                    .shadow(color: color.opacity(0.4), radius: isShowing ? 15 : 5, x: 0, y: 5)
                
                Text(emoji)
                    .font(.system(size: 36))
            }
        }
        .disabled(!canTap)
        .scaleEffect(isWrong ? 0.95 : 1)
        .animation(.spring(response: 0.2), value: isWrong)
    }
    
    var tileColor: Color {
        if isWrong { return .red.opacity(0.7) }
        if isCorrect { return .green.opacity(0.7) }
        if isShowing { return color.opacity(0.9) }
        return color.opacity(0.6)
    }
    
    var borderColor: Color {
        if isWrong { return .red }
        if isCorrect { return .green }
        if isShowing { return .white }
        return color
    }
}

#Preview {
    ColorPatternMemoryView()
}
