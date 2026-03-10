import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var store = AchievementStore()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCategory: Achievement.AchievementCategory?
    @State private var showUnlocked: Bool = false
    @State private var recentlyUnlocked: Achievement?
    @State private var showShareSheet: Bool = false
    @State private var achievementToShare: Achievement?
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Progress summary
                progressHeader
                
                // Quick stats
                quickStats
                
                // Category tabs
                categoryTabs
                
                // Achievements grid
                achievementsGrid
            }
        }
        .onAppear {
            if let progress = appState.progress {
                store.checkAndUnlock(progress: progress)
            }
        }
        .sheet(isPresented: $showUnlocked) {
            if let achievement = recentlyUnlocked {
                AchievementUnlockSheet(achievement: achievement) {
                    showUnlocked = false
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let achievement = achievementToShare {
                ShareAchievementSheet(achievement: achievement) {
                    showShareSheet = false
                    achievementToShare = nil
                }
            }
        }
    }
    
    var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 18)).foregroundColor(.white).frame(width: 44, height: 44)
            }
            Spacer()
            VStack(spacing: 2) {
                Text("Achievements").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                Text("\(store.unlockedCount()) of \(store.achievements.count) unlocked")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button {
                // Show all achievements
            } label: {
                Image(systemName: "list.bullet").font(.system(size: 18)).foregroundColor(.purple)
            }
            .frame(width: 44, height: 44)
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
    }
    
    var progressHeader: some View {
        VStack(spacing: 12) {
            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: store.progressPercentage())
                    .stroke(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                    Text("\(store.unlockedCount())")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Text(": 18,Achievement Progress")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 16)
    }
    
    var quickStats: some View {
        HStack(spacing: 12) {
            AchievementStatBox(icon: "flame.fill", value: "\(appState.progress?.streakDays ?? 0)", label: "Day Streak", color: .orange)
            AchievementStatBox(icon: "star.fill", value: "\(appState.progress?.totalXP ?? 0)", label: "Total XP", color: .yellow)
            AchievementStatBox(icon: "checkmark.circle.fill", value: "\(appState.progress?.completedChallenges.count ?? 0)", label: "Completed", color: .green)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All button
                CategoryTabButton(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                    CategoryTabButton(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
    }
    
    var achievementsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(filteredAchievements) { achievement in
                    AchievementCard(achievement: achievement) {
                        // Show detail
                    } onShare: {
                        achievementToShare = achievement
                        showShareSheet = true
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return store.achievements.filter { $0.category == category }
        }
        return store.achievements
    }
}

// MARK: - Supporting Views
struct AchievementStatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
            Text(value).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CategoryTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var color: Color = .purple
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.5) : Color.white.opacity(0.05))
            )
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let action: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // Icon with glow
                ZStack {
                    if achievement.isUnlocked {
                        Circle()
                            .fill(achievement.category.color.opacity(0.2))
                            .frame(width: 60, height: 60)
                        Circle()
                            .fill(achievement.category.color.opacity(0.3))
                            .frame(width: 50, height: 50)
                    }
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 24))
                        .foregroundColor(achievement.isUnlocked ? achievement.category.color : .gray)
                }
                
                // Title
                Text(achievement.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                    .lineLimit(1)
                
                // Rarity badge
                if achievement.isUnlocked {
                    HStack(spacing: 4) {
                        Text(achievement.rarity.rawValue)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(achievement.rarity.color)
                        Button(action: onShare) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 10))
                                .foregroundColor(achievement.rarity.color)
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(achievement.rarity.color.opacity(0.2))
                    .cornerRadius(4)
                } else {
                    // Progress indicator
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("\(achievement.requirement)")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(achievement.isUnlocked ? Color.white.opacity(0.1) : Color.white.opacity(0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(achievement.isUnlocked ? achievement.category.color.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct AchievementUnlockSheet: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    @State private var showAnimation: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Celebration icon
                ZStack {
                    Circle()
                        .fill(achievement.category.color.opacity(0.2))
                        .frame(width: 150, height: 150)
                        .scaleEffect(showAnimation ? 1.2 : 1.0)
                    
                    Circle()
                        .fill(achievement.category.color.opacity(0.4))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                // Achievement unlocked text
                Text("Achievement Unlocked!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                // Title
                Text(achievement.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                // Description
                Text(achievement.description)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Category badge
                HStack(spacing: 8) {
                    Image(systemName: achievement.category.icon)
                    Text(achievement.category.rawValue)
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(achievement.category.color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(achievement.category.color.opacity(0.2))
                .cornerRadius(20)
                
                Spacer()
                
                // XP reward
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                    Text("+\(achievement.xpReward) XP")
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.yellow)
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.2))
                )
                
                Button(action: onDismiss) {
                    Text("Awesome!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showAnimation = true
            }
        }
    }
}

// MARK: - Share Achievement Sheet
struct ShareAchievementSheet: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Preview card
                VStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(achievement.category.color.opacity(0.2))
                            .frame(width: 80, height: 80)
                        Image(systemName: achievement.icon)
                            .font(.system(size: 36))
                            .foregroundColor(achievement.category.color)
                    }
                    
                    // Title
                    Text(achievement.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Description
                    Text(achievement.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Category & Rarity
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: achievement.category.icon)
                            Text(achievement.category.rawValue)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(achievement.category.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(achievement.category.color.opacity(0.2))
                        .cornerRadius(12)
                        
                        Text(achievement.rarity.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(achievement.rarity.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(achievement.rarity.color.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "1E293B"))
                )
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Share buttons
                VStack(spacing: 12) {
                    // Share button
                    ShareLink(item: shareText) {
                        Label("Share Achievement", systemImage: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: onDismiss) {
                        Text("Done")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
            }
            .background(Color(hex: "0A0F1C").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Share Achievement")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color(hex: "0A0F1C"), for: .navigationBar)
        }
    }
    
    var shareText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = achievement.unlockedAt.map { dateFormatter.string(from: $0) } ?? "today"
        
        return "🎉 I just unlocked the \"\(achievement.title)\" achievement in FocusFlow! \(achievement.description) #FocusFlow #Achievement"
    }
}

// MARK: - Achievement Category Extension
extension Achievement.AchievementCategory {
    var icon: String {
        switch self {
        case .progress: return "chart.line.uptrend.xyaxis"
        case .streak: return "flame.fill"
        case .speed: return "bolt.fill"
        case .social: return "person.2.fill"
        case .mastery: return "crown.fill"
        case .special: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .progress: return .green
        case .streak: return .orange
        case .speed: return .yellow
        case .social: return .blue
        case .mastery: return .purple
        case .special: return .pink
        }
    }
}

#Preview {
    AchievementsView().environmentObject(AppState())
}
