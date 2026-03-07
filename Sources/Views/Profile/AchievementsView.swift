import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var store = AchievementStore()
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    @State private var showUnlockSheet = false
    @State private var recentlyUnlocked: Achievement?
    @State private var progressAnim: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "06060F"), Color(hex: "0A0F1C"), Color(hex: "0D1526")],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        overviewCard
                        statsRow
                        categoryFilter
                        achievementsList
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            if let progress = appState.progress {
                store.checkAndUnlock(progress: progress)
            }
            withAnimation(.easeOut(duration: 1.2)) { progressAnim = store.progressPercentage() }
        }
        .sheet(isPresented: $showUnlockSheet) {
            if let a = recentlyUnlocked {
                AchievementUnlockSheet(achievement: a) { showUnlockSheet = false }
            }
        }
    }

    // MARK: - Nav Bar
    var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.07))
                    .clipShape(Circle())
            }
            Spacer()
            Text("Achievements")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            // Spacer button for alignment
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Overview Card
    var overviewCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 20) {
                // Circular progress ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 9)
                        .frame(width: 90, height: 90)
                    Circle()
                        .trim(from: 0, to: progressAnim)
                        .stroke(
                            LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round)
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 1) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                        Text("\(store.unlockedCount())")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Achievement Progress")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text("\(store.unlockedCount()) of \(store.achievements.count) unlocked")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    // Overall bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.08)).frame(height: 7)
                            Capsule()
                                .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * progressAnim, height: 7)
                        }
                    }
                    .frame(height: 7)
                    Text("\(Int(store.progressPercentage() * 100))% complete")
                        .font(.system(size: 11))
                        .foregroundColor(.yellow.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.yellow.opacity(0.15), lineWidth: 1))
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Stats Row
    var statsRow: some View {
        HStack(spacing: 10) {
            miniStat(icon: "flame.fill",            value: "\(appState.progress?.streakDays ?? 0)d",  label: "Streak",    color: .orange)
            miniStat(icon: "star.fill",              value: "\(appState.progress?.totalXP ?? 0)",      label: "Total XP",  color: .yellow)
            miniStat(icon: "checkmark.circle.fill",  value: "\(appState.progress?.completedChallenges.count ?? 0)", label: "Done", color: .green)
            miniStat(icon: "diamond.fill",           value: "\(appState.progress?.gems ?? 0)",         label: "Gems",      color: .cyan)
        }
        .padding(.horizontal, 20)
    }

    func miniStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            Text(value).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 9)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background(Color.white.opacity(0.04))
        .cornerRadius(12)
    }

    // MARK: - Category Filter
    var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "All", icon: "square.grid.2x2", color: .purple, selected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(Achievement.AchievementCategory.allCases, id: \.self) { cat in
                    filterChip(title: cat.rawValue, icon: cat.icon, color: cat.color, selected: selectedCategory == cat) {
                        selectedCategory = cat
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    func filterChip(title: String, icon: String, color: Color, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 11, weight: .semibold))
                Text(title).font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(selected ? .white : .gray)
            .padding(.horizontal, 13).padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(selected ? color.opacity(0.4) : Color.white.opacity(0.05))
                    .overlay(Capsule().stroke(selected ? color.opacity(0.6) : Color.clear, lineWidth: 1))
            )
        }
    }

    // MARK: - Achievements List
    var achievementsList: some View {
        let filtered = selectedCategory == nil ? store.achievements : store.achievements.filter { $0.category == selectedCategory }
        let unlocked = filtered.filter { $0.isUnlocked }
        let locked   = filtered.filter { !$0.isUnlocked }

        return LazyVStack(spacing: 10) {
            if !unlocked.isEmpty {
                sectionHeader(title: "Unlocked", count: unlocked.count, color: .yellow)
                ForEach(unlocked) { a in
                    AchievementRow(achievement: a)
                }
            }
            if !locked.isEmpty {
                sectionHeader(title: "Locked", count: locked.count, color: .gray)
                ForEach(locked) { a in
                    AchievementRow(achievement: a)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    func sectionHeader(title: String, count: Int, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
            Text("(\(count))")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.top, 4)
    }
}

// MARK: - Achievement Row
struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                        ? achievement.category.color.opacity(0.2)
                        : Color.white.opacity(0.04))
                    .frame(width: 52, height: 52)
                if achievement.isUnlocked {
                    Circle()
                        .fill(achievement.category.color.opacity(0.12))
                        .frame(width: 42, height: 42)
                        .blur(radius: 4)
                }
                Image(systemName: achievement.icon)
                    .font(.system(size: 20))
                    .foregroundColor(achievement.isUnlocked ? achievement.category.color : .gray.opacity(0.4))
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(achievement.isUnlocked ? .white : .gray)
                    Spacer()
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13))
                            .foregroundColor(achievement.category.color)
                    }
                }

                Text(achievement.description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray.opacity(0.7))
                    .lineLimit(2)

                if achievement.isUnlocked {
                    // Rewards
                    HStack(spacing: 10) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill").font(.system(size: 9)).foregroundColor(.yellow)
                            Text("+\(achievement.xpReward) XP").font(.system(size: 10, weight: .medium)).foregroundColor(.yellow.opacity(0.9))
                        }
                        if achievement.gemReward > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "diamond.fill").font(.system(size: 9)).foregroundColor(.cyan)
                                Text("+\(achievement.gemReward)").font(.system(size: 10, weight: .medium)).foregroundColor(.cyan.opacity(0.9))
                            }
                        }
                        Spacer()
                        Text(achievement.rarity.rawValue)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(achievement.rarity.color)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(achievement.rarity.color.opacity(0.15))
                            .cornerRadius(4)
                    }
                } else {
                    // Progress bar
                    VStack(alignment: .leading, spacing: 3) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.06)).frame(height: 5)
                                Capsule()
                                    .fill(achievement.category.color.opacity(0.6))
                                    .frame(width: geo.size.width * achievement.progress, height: 5)
                            }
                        }
                        .frame(height: 5)
                        HStack {
                            Text("\(Int(achievement.progress * 100))% progress")
                                .font(.system(size: 9))
                                .foregroundColor(.gray.opacity(0.6))
                            Spacer()
                            // Show rewards to aim for
                            HStack(spacing: 6) {
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill").font(.system(size: 8)).foregroundColor(.yellow.opacity(0.5))
                                    Text("+\(achievement.xpReward)").font(.system(size: 9)).foregroundColor(.yellow.opacity(0.5))
                                }
                                if achievement.gemReward > 0 {
                                    HStack(spacing: 2) {
                                        Image(systemName: "diamond.fill").font(.system(size: 8)).foregroundColor(.cyan.opacity(0.5))
                                        Text("+\(achievement.gemReward)").font(.system(size: 9)).foregroundColor(.cyan.opacity(0.5))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(achievement.isUnlocked ? Color.white.opacity(0.07) : Color.white.opacity(0.025))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(achievement.isUnlocked ? achievement.category.color.opacity(0.25) : Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

// MARK: - Unlock Sheet
struct AchievementUnlockSheet: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            Color(hex: "06060F").ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(achievement.category.color.opacity(0.25))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .opacity(glowOpacity)

            VStack(spacing: 24) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(achievement.category.color.opacity(0.15))
                        .frame(width: 140, height: 140)
                    Circle()
                        .fill(achievement.category.color.opacity(0.25))
                        .frame(width: 100, height: 100)
                    Image(systemName: achievement.icon)
                        .font(.system(size: 46))
                        .foregroundColor(achievement.category.color)
                }
                .scaleEffect(scale)

                VStack(spacing: 8) {
                    Text("Achievement Unlocked!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    Text(achievement.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text(achievement.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Category pill
                HStack(spacing: 6) {
                    Image(systemName: achievement.category.icon).font(.system(size: 12))
                    Text(achievement.category.rawValue).font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(achievement.category.color)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(achievement.category.color.opacity(0.15))
                .clipShape(Capsule())

                // Rewards
                HStack(spacing: 16) {
                    rewardBadge(icon: "star.fill", text: "+\(achievement.xpReward) XP", color: .yellow)
                    if achievement.gemReward > 0 {
                        rewardBadge(icon: "diamond.fill", text: "+\(achievement.gemReward) Gems", color: .cyan)
                    }
                }

                Spacer()

                Button(action: onDismiss) {
                    Text("Awesome!")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            LinearGradient(colors: [achievement.category.color, achievement.category.color.opacity(0.7)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 44)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { scale = 1 }
            withAnimation(.easeOut(duration: 0.8)) { glowOpacity = 1 }
        }
    }

    func rewardBadge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            Text(text).font(.system(size: 15, weight: .bold)).foregroundColor(color)
        }
        .padding(.horizontal, 18).padding(.vertical, 10)
        .background(color.opacity(0.12))
        .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
        .clipShape(Capsule())
    }
}

#Preview {
    AchievementsView().environmentObject(AppState())
}
