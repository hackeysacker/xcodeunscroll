import SwiftUI

// MARK: - Duolingo-Style Learning Path

struct DuolingoPathView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentLevel: Int = 1
    @State private var selectedLevel: Int? = nil
    @State private var showLevelDetail: Bool = false
    
    // Section colors (app theme)
    let sectionColors: [Color] = [
        Color("8B5CF6"), // Purple - Basics
        Color("3B82F6"), // Blue - Attention
        Color("8B5CF6"), // Purple - Memory
        Color("EF4444"), // Red - Impulse
        Color("10B981"), // Green - Calm
        Color("F59E0B"), // Orange - Discipline
        Color("EC4899"), // Pink - Endurance
        Color("06B6D4"), // Cyan - Mastery
        Color("FBBF24"), // Gold - Wisdom
        Color("EF4444"), // Red - Legend
    ]
    
    var sectionNames: [String] {
        [
            "Focus Basics",
            "Attention",
            "Memory",
            "Impulse",
            "Calm",
            "Discipline",
            "Endurance",
            "Mastery",
            "Wisdom",
            "Legend"
        ]
    }
    
    var body: some View {
        ZStack {
            // App's dark gradient background
            LinearGradient(colors: [Color("0A0F1C"), Color("1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        headerView
                        
                        // Path
                        pathView
                    }
                    .padding(.bottom, 120)
                }
            }
            
            // Floating continue button
            VStack {
                Spacer()
                continueButton
            }
        }
        .sheet(isPresented: $showLevelDetail) {
            if let level = selectedLevel {
                DuolingoLevelDetail(
                    level: level,
                    section: getSection(for: level),
                    color: sectionColors[getSection(for: level) % sectionColors.count]
                )
                .environmentObject(appState)
            }
        }
    }
    
    // MARK: - Header
    var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                // Hearts
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(appState.progress?.hearts ?? 5)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.2))
                .cornerRadius(20)
                
                Spacer()
                
                // Gems
                HStack(spacing: 4) {
                    Image(systemName: "diamond.fill")
                        .foregroundColor(.cyan)
                    Text("\(appState.progress?.gems ?? 0)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.cyan.opacity(0.2))
                .cornerRadius(20)
            }
            
            // Streak banner
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(appState.progress?.streakDays ?? 0) day streak")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(appState.progress?.totalXP ?? 0) XP")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.3), Color.purple.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
    
    // MARK: - Path View (Duolingo-style winding path)
    var pathView: some View {
        VStack(spacing: 0) {
            // Starting path segment
            ForEach(0..<sections.count, id: \.self) { sectionIndex in
                PathSectionView(
                    sectionIndex: sectionIndex,
                    section: sections[sectionIndex],
                    levels: sectionLevels(sectionIndex),
                    sectionColor: sectionColors[sectionIndex % sectionColors.count],
                    currentLevel: currentLevel,
                    completedLevel: getHighestCompleted(),
                    onLevelTap: { level in
                        if isLevelUnlocked(level) {
                            selectedLevel = level
                            showLevelDetail = true
                        }
                    }
                )
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Continue Button
    var continueButton: some View {
        Button {
            selectedLevel = currentLevel
            showLevelDetail = true
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Continue")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color("8B5CF6"), Color("6366F1")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color("8B5CF6").opacity(0.5), radius: 0, y: 4)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - Helpers
    func getSection(for level: Int) -> Int {
        return (level - 1) / 10
    }
    
    func getHighestCompleted() -> Int {
        return appState.progress?.level ?? 1
    }
    
    func isLevelUnlocked(_ level: Int) -> Bool {
        return level <= getHighestCompleted() + 1
    }
    
    func sectionLevels(_ section: Int) -> [Int] {
        let start = section * 10 + 1
        return Array(start...min(start + 9, 100))
    }
    
    var sections: [String] {
        [
            "Focus Basics",
            "Attention",
            "Memory",
            "Impulse",
            "Calm",
            "Discipline",
            "Endurance",
            "Mastery",
            "Wisdom",
            "Legend"
        ]
    }
}

// MARK: - Path Section
struct PathSectionView: View {
    let sectionIndex: Int
    let section: String
    let levels: [Int]
    let sectionColor: Color
    let currentLevel: Int
    let completedLevel: Int
    let onLevelTap: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Section header - glassmorphism style
            HStack {
                Text(section.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(sectionColor)
                    .tracking(1)
                Spacer()
                Text("\(completedInSection)/\(levels.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(sectionColor.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Winding path
            ZStack(alignment: .top) {
                // Path line
                PathLine(isLeft: sectionIndex % 2 == 0)
                    .stroke(
                        LinearGradient(
                            colors: [sectionColor.opacity(0.3), sectionColor],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                    )
                    .frame(height: CGFloat(levels.count) * 80)
                
                // Level bubbles
                ForEach(levels, id: \.self) { level in
                    LevelBubble(
                        level: level,
                        isCompleted: level <= completedLevel,
                        isCurrent: level == currentLevel,
                        isUnlocked: level <= completedLevel + 1,
                        sectionColor: sectionColor,
                        position: getPosition(for: level),
                        isLeft: sectionIndex % 2 == 0
                    )
                    .onTapGesture {
                        onLevelTap(level)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    var completedInSection: Int {
        levels.filter { $0 <= completedLevel }.count
    }
    
    func getPosition(for level: Int) -> Int {
        return (level - 1) % 10
    }
}

// MARK: - Path Line
struct PathLine: Shape {
    let isLeft: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let midX = rect.midX
        let height = rect.height
        let segmentHeight: CGFloat = 60
        
        path.move(to: CGPoint(x: midX, y: 0))
        
        // Winding S-curve
        let segments = Int(height / segmentHeight)
        for i in 0..<max(1, segments) {
            let y = CGFloat(i) * segmentHeight
            let offset: CGFloat = isLeft ? -40 : 40
            
            if i % 2 == 0 {
                path.addLine(to: CGPoint(x: midX + offset, y: min(y + segmentHeight / 2, height)))
            } else {
                path.addLine(to: CGPoint(x: midX - offset, y: min(y + segmentHeight / 2, height)))
            }
        }
        
        path.addLine(to: CGPoint(x: midX, y: height))
        
        return path
    }
}

// MARK: - Level Bubble
struct LevelBubble: View {
    let level: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let isUnlocked: Bool
    let sectionColor: Color
    let position: Int
    let isLeft: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Outer glow for current
                if isCurrent {
                    Circle()
                        .fill(sectionColor.opacity(0.4))
                        .frame(width: 72, height: 72)
                        .blur(radius: 8)
                }
                
                // Main bubble
                Circle()
                    .fill(bubbleColor)
                    .frame(width: isCurrent ? 64 : 56, height: isCurrent ? 64 : 56)
                    .overlay(
                        Circle()
                            .stroke(isCurrent ? sectionColor : Color.white.opacity(0.3), 
                                   lineWidth: isCurrent ? 4 : 2)
                    )
                    .shadow(color: isCurrent ? sectionColor.opacity(0.6) : .clear, 
                           radius: isCurrent ? 12 : 0, y: 0)
                
                // Content
                if isCompleted {
                    // Checkmark for completed
                    Image(systemName: "checkmark")
                        .font(.system(size: isCurrent ? 24 : 20, weight: .bold))
                        .foregroundColor(.white)
                } else if isUnlocked {
                    // Level number
                    Text("\(level % 10)")
                        .font(.system(size: isCurrent ? 22 : 18, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    // Lock icon
                    Image(systemName: "lock.fill")
                        .font(.system(size: isCurrent ? 20 : 16))
                        .foregroundColor(.gray)
                }
            }
            
            // Crowns/stars
            if isCompleted {
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < getCrowns() ? "crown.fill" : "crown")
                            .font(.system(size: 8))
                            .foregroundColor(i < getCrowns() ? .yellow : .gray.opacity(0.3))
                    }
                }
            }
        }
        .offset(x: offsetX, y: offsetY)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isCurrent)
    }
    
    var bubbleColor: Color {
        if isCompleted {
            return sectionColor
        } else if isCurrent {
            return sectionColor.opacity(0.8)
        } else if isUnlocked {
            return Color.white.opacity(0.2)
        } else {
            return Color.white.opacity(0.1)
        }
    }
    
    var offsetX: CGFloat {
        let baseX: CGFloat = isLeft ? -40 : 40
        if position % 2 == 0 {
            return baseX
        } else {
            return -baseX
        }
    }
    
    var offsetY: CGFloat {
        return CGFloat(position) * 76
    }
    
    func getCrowns() -> Int {
        // 1-3 crowns based on performance
        return min(3, max(1, level / 5))
    }
}

// MARK: - Level Detail Sheet
struct DuolingoLevelDetail: View {
    let level: Int
    let section: Int
    let color: Color
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showChallenge = false
    
    var body: some View {
        ZStack {
            // App's dark gradient background
            LinearGradient(colors: [Color("0A0F1C"), Color("1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Crowns earned
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < crowns ? "crown.fill" : "crown")
                                .font(.system(size: 16))
                                .foregroundColor(i < crowns ? .yellow : .gray.opacity(0.3))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer()
                
                // Level number (big)
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 180, height: 180)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 140, height: 140)
                    
                    VStack {
                        Text("LEVEL")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(level)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Challenge name
                Text(challengeName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(challengeDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Rewards
                HStack(spacing: 24) {
                    rewardItem(icon: "diamond.fill", value: "\(level * 2)", label: "Gems", color: .cyan)
                    rewardItem(icon: "bolt.fill", value: "\(level * 10)", label: "XP", color: .yellow)
                    rewardItem(icon: "crown.fill", value: "\(crowns)", label: "Crowns", color: .purple)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Start button
                Button {
                    showChallenge = true
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("START")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color("8B5CF6"), Color("6366F1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showChallenge) {
            ChallengeView(challenge: challengeType)
                .environmentObject(appState)
        }
    }
    
    var crowns: Int {
        return min(3, max(1, level / 5))
    }
    
    var challengeName: String {
        let challenges = ["Focus Tap", "Memory Match", "Quick Reaction", "Breath Control", "Impulse Test", "Gaze Hold", "Number Chain", "Pattern Recall", "Color Match", "Zone Focus"]
        return challenges[level % challenges.count]
    }
    
    var challengeDescription: String {
        "Complete this challenge to earn XP and crowns. Perfect scores earn bonus crowns!"
    }
    
    var challengeType: AllChallengeType {
        let types: [AllChallengeType] = [.movingTarget, .memoryFlash, .reactionInhibition, .focusHold, .gazeHold, .numberSequence, .patternMatching, .rhythmTap, .multiObjectTracking, .spatialPuzzle]
        return types[level % types.count]
    }
    
    func rewardItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    DuolingoPathView()
        .environmentObject(AppState())
}
