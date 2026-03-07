import SwiftUI

struct ProgressPathView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedRealm: Int = 1
    @State private var selectedLevel: Int = 1
    @State private var showLevelDetail: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: realmTheme.primary), Color(hex: realmTheme.secondary)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Realm selector
                realmSelector
                
                // Level grid
                levelGrid
                
                // Stats bar
                statsBar
            }
        }
        .sheet(isPresented: $showLevelDetail) {
            LevelDetailView(level: selectedLevel, realm: GameRealm.allRealms[selectedRealm - 1])
                .environmentObject(appState)
        }
    }
    
    // MARK: - Header
    var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: { }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
                VStack {
                    Text(realm.name)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text(realm.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                Spacer()
                Button(action: { }) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .padding()
                }
            }
            .padding(.horizontal)
            
            // Realm progress
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: geo.size.width * realmProgress, height: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)
            
            Text("Level \(appState.progress?.level ?? 1) • \(appState.progress?.totalXP ?? 0) XP")
                .font(.caption.bold())
                .foregroundColor(.white)
        }
        .padding(.top, 50)
    }
    
    // MARK: - Realm Selector
    var realmSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(1...10, id: \.self) { realmId in
                        Button(action: { withAnimation { selectedRealm = realmId } }) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(selectedRealm == realmId ? Color.white : Color.white.opacity(0.2))
                                        .frame(width: 44, height: 44)
                                    
                                    if completedRealms.contains(realmId) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color(hex: GameRealm.allRealms[realmId - 1].color))
                                    } else {
                                        Text("\(realmId)")
                                            .font(.headline.bold())
                                            .foregroundColor(selectedRealm == realmId ? Color(hex: GameRealm.allRealms[realmId - 1].color) : .white)
                                    }
                                }
                                
                                Text(GameRealm.allRealms[realmId - 1].name.prefix(8))
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .id(realmId)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                proxy.scrollTo(selectedRealm, anchor: .center)
            }
        }
        .frame(height: 70)
        .padding(.vertical)
    }
    
    // MARK: - Level Grid
    var levelGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(realm.levels, id: \.self) { level in
                    LevelNode(
                        level: level,
                        isUnlocked: isLevelUnlocked(level),
                        isCompleted: isLevelCompleted(level),
                        stars: getStars(level),
                        isSelected: selectedLevel == level
                    )
                    .onTapGesture {
                        if isLevelUnlocked(level) {
                            selectedLevel = level
                            showLevelDetail = true
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Stats Bar
    var statsBar: some View {
        HStack(spacing: 24) {
            StatItem(icon: "star.fill", value: "\(totalStars)", label: "Stars")
            StatItem(icon: "flame.fill", value: "\(appState.progress?.streakDays ?? 0)", label: "Streak")
            StatItem(icon: "gem.fill", value: "\(appState.progress?.gems ?? 0)", label: "Gems")
        }
        .padding()
        .background(Color.black.opacity(0.2))
    }
    
    // MARK: - Helpers
    var realm: GameRealm {
        GameRealm.allRealms[selectedRealm - 1]
    }
    
    var realmTheme: GameRealm.RealmTheme {
        realm.theme
    }
    
    var realmProgress: Double {
        let levelsInRealm = realm.levels
        let completedInRealm = levelsInRealm.filter { isLevelCompleted($0) }.count
        return Double(completedInRealm) / Double(levelsInRealm.count)
    }
    
    var completedRealms: [Int] {
        // Would come from user progress
        []
    }
    
    var totalStars: Int {
        // Would come from user progress
        var stars = 0
        for level in 1...(appState.progress?.level ?? 1) {
            stars += getStars(level)
        }
        return stars
    }
    
    func isLevelUnlocked(_ level: Int) -> Bool {
        if level == 1 { return true }
        return (appState.progress?.level ?? 1) >= level - 1
    }
    
    func isLevelCompleted(_ level: Int) -> Bool {
        // Would check user progress
        return (appState.progress?.level ?? 1) > level
    }
    
    func getStars(_ level: Int) -> Int {
        // Would come from user progress - random for demo
        if isLevelCompleted(level) {
            return Int.random(in: 1...3)
        }
        return 0
    }
}

// MARK: - Level Node
struct LevelNode: View {
    let level: Int
    let isUnlocked: Bool
    let isCompleted: Bool
    let stars: Int
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? (isCompleted ? Color.yellow.opacity(0.3) : Color.white.opacity(0.2)) : Color.white.opacity(0.05))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                    )
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.headline)
                } else if isUnlocked {
                    Text("\(level)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            // Stars
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < stars ? "star.fill" : "star")
                        .font(.system(size: 8))
                        .foregroundColor(i < stars ? .yellow : .gray)
                }
            }
        }
    }
}

// MARK: - Level Detail Sheet
struct LevelDetailView: View {
    let level: Int
    let realm: GameRealm
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: realm.theme.primary), Color(hex: realm.theme.secondary)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button("Close") { dismiss() }
                        .foregroundColor(.white)
                    Spacer()
                    Text("Level \(level)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
                
                // Level circle
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    VStack {
                        Text("\(level)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        Text("of 250")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Challenge info
                VStack(spacing: 12) {
                    Text(challengeForLevel.type.rawValue)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    Text("Score \(challengeForLevel.requiredScore) to complete")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Stars needed
                    HStack {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: "star.fill")
                                .foregroundColor(i < 2 ? .yellow : .gray)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Rewards
                HStack(spacing: 32) {
                    RewardItem(icon: "gem.fill", value: "\(level * 2)", label: "Gems")
                    RewardItem(icon: "star.fill", value: "\(level * 10)", label: "XP")
                    RewardItem(icon: "crown.fill", value: level % 25 == 0 ? "1" : "-", label: "Realm")
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
                
                // Start button
                Button(action: {
                    // Start challenge
                    dismiss()
                }) {
                    Text("Start Challenge")
                        .font(.headline)
                        .foregroundColor(Color(hex: realm.theme.primary))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
    
    var challengeForLevel: GameRealm.RealmChallenge {
        let idx = (level - 1) % realm.challenges.count
        return realm.challenges[idx]
    }
}

// MARK: - Supporting Views
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct RewardItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.green)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    ProgressPathView()
        .environmentObject(AppState())
}
