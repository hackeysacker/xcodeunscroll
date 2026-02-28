import SwiftUI

// MARK: - Memory Grid Challenge
// Fully built with: pattern reveal, memory sequence, haptics, scoring

struct MemoryGridView: View {
    @Environment(\.dismiss) var dismiss
    @State private var gridSize: Int = 3
    @State private var pattern: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var showingPattern: Bool = false
    @State private var canTap: Bool = false
    @State private var round: Int = 1
    @State private var score: Int = 0
    @State private var lives: Int = 3
    @State private var isGameOver: Bool = false
    @State private var showResults: Bool = false
    @State private var selectedTile: Int?
    @State private var correctTiles: Set<Int> = []
    @State private var wrongTile: Int?
    @State private var audioManager = AppAudioManager.shared
    
    let maxRounds = 10
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color("0A0F1C"), Color("1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                Spacer()
                
                // Grid
                if showResults {
                    resultsOverlay
                } else {
                    gameContent
                }
                
                Spacer()
                
                // Instructions
                if showingPattern {
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
    
    var header: some View {
        HStack(spacing: 24) {
            // Round
            VStack(spacing: 2) {
                Text("Round \(round)/\(maxRounds)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text("LEVEL \(gridSize - 2)")
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
    
    var gameContent: some View {
        VStack(spacing: 24) {
            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: gridSize), spacing: 12) {
                ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                    MemoryTile(
                        index: index,
                        isShowing: showingPattern && pattern.contains(index),
                        isCorrect: correctTiles.contains(index),
                        isWrong: wrongTile == index,
                        isSelected: selectedTile == index,
                        canTap: canTap
                    ) {
                        handleTap(index)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    var resultsOverlay: some View {
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
                Text("Grid size: \(gridSize)x\(gridSize)")
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
    
    func startRound() {
        // Reset state
        pattern = []
        userSequence = []
        showingPattern = false
        canTap = false
        selectedTile = nil
        correctTiles = []
        wrongTile = nil
        
        // Generate new pattern
        let tileCount = gridSize * gridSize
        let patternLength = min(round + 2, tileCount - 1)
        
        var availableTiles = Array(0..<tileCount)
        for _ in 0..<patternLength {
            if let index = availableTiles.randomElement() {
                pattern.append(index)
                availableTiles.removeAll { $0 == index }
            }
        }
        
        // Show pattern
        showingPattern = true
        audioManager.playChallengeStart()
        
        // Hide pattern after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(pattern.count) * 0.8 + 1) {
            showingPattern = false
            canTap = true
        }
    }
    
    func handleTap(_ index: Int) {
        guard canTap else { return }
        
        selectedTile = index
        audioManager.lightImpact()
        
        if pattern.contains(index) && !userSequence.contains(index) {
            // Correct
            correctTiles.insert(index)
            userSequence.append(index)
            audioManager.success()
            
            // Check if round complete
            if userSequence.count == pattern.count {
                canTap = false
                score += round * 10 + (gridSize * 5)
                audioManager.playReward()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if round < maxRounds {
                        round += 1
                        if round % 3 == 0 && gridSize < 5 {
                            gridSize += 1
                        }
                        startRound()
                    } else {
                        showResults = true
                    }
                }
            }
        } else if userSequence.contains(index) {
            // Already tapped
            audioManager.warning()
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
        gridSize = 3
        showResults = false
        startRound()
    }
}

// MARK: - Memory Tile
struct MemoryTile: View {
    let index: Int
    let isShowing: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isSelected: Bool
    let canTap: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 12)
                .fill(tileColor)
                .frame(height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 2)
                )
        }
        .disabled(!canTap)
        .scaleEffect(isSelected ? 0.95 : 1)
        .animation(.spring(response: 0.2), value: isSelected)
    }
    
    var tileColor: Color {
        if isWrong { return .red.opacity(0.5) }
        if isCorrect || isShowing { return .purple.opacity(0.8) }
        return Color.white.opacity(0.1)
    }
    
    var borderColor: Color {
        if isWrong { return .red }
        if isCorrect || isShowing { return .purple }
        return Color.white.opacity(0.2)
    }
}

#Preview {
    MemoryGridView()
}
