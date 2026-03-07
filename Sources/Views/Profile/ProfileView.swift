import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings     = false
    @State private var showAchievements = false
    @State private var showLeaderboard  = false
    @State private var showEditProfile  = false
    @State private var editingName      = ""
    @State private var editingEmoji     = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "06060F"), Color(hex: "0A0F1C"), Color(hex: "0D1526")],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroCard
                    statsGrid
                    skillsSection
                    menuSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
        .sheet(isPresented: $showAchievements) { AchievementsView().environmentObject(appState) }
        .sheet(isPresented: $showLeaderboard)  { LeaderboardView().environmentObject(appState) }
        .sheet(isPresented: $showSettings)     { SettingsView().environmentObject(appState) }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(
                name: $editingName, emoji: $editingEmoji,
                isPresented: $showEditProfile
            ) {
                appState.currentUser?.displayName = editingName
                appState.currentUser?.avatarEmoji = editingEmoji
                appState.saveData()
            }
        }
    }

    // MARK: - Hero Card
    var heroCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.5), Color.indigo.opacity(0.2), Color.clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ), lineWidth: 1.5
                        )
                )

            Circle()
                .fill(Color.purple.opacity(0.15))
                .frame(width: 160, height: 160)
                .offset(y: -20).blur(radius: 40)

            VStack(spacing: 20) {
                // Avatar with level ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 5)
                        .frame(width: 104, height: 104)
                    Circle()
                        .trim(from: 0, to: CGFloat(levelProgress))
                        .stroke(
                            LinearGradient(colors: [.purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 104, height: 104)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6), value: levelProgress)

                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 90, height: 90)
                    Text(appState.currentUser?.avatarEmoji ?? "🦞").font(.system(size: 42))

                    Button {
                        editingName  = appState.currentUser?.displayName ?? ""
                        editingEmoji = appState.currentUser?.avatarEmoji ?? "🦞"
                        showEditProfile = true
                    } label: {
                        ZStack {
                            Circle().fill(Color(hex: "1C1C42")).frame(width: 26, height: 26)
                            Image(systemName: "pencil").font(.system(size: 11, weight: .semibold)).foregroundColor(.white)
                        }
                    }
                    .offset(x: 32, y: 32)
                }

                VStack(spacing: 6) {
                    Text(appState.currentUser?.displayName ?? "Focus Warrior")
                        .font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                    Text(levelTitle)
                        .font(.system(size: 13, weight: .medium)).foregroundColor(Color(hex: "A78BFA"))

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.yellow)
                        Text("Level \(appState.progress?.level ?? 1)")
                            .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                        Text("·").foregroundColor(.white.opacity(0.3))
                        Text("\(appState.progress?.totalXP ?? 0) XP")
                            .font(.system(size: 13)).foregroundColor(.yellow.opacity(0.8))
                    }
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(Capsule().fill(Color.yellow.opacity(0.1)).overlay(Capsule().stroke(Color.yellow.opacity(0.2), lineWidth: 1)))
                }

                HStack(spacing: 12) {
                    profileActionButton(icon: "trophy.fill",   label: "Leaderboard", color: .yellow) { showLeaderboard  = true }
                    profileActionButton(icon: "star.fill",     label: "Achievements", color: .purple) { showAchievements = true }
                    profileActionButton(icon: "gearshape.fill",label: "Settings",     color: .gray)   { showSettings     = true }
                }
            }
            .padding(.vertical, 28)
        }
        .padding(.top, 60)
    }

    func profileActionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle().fill(color.opacity(0.15)).frame(width: 46, height: 46)
                    Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
                }
                Text(label).font(.system(size: 10, weight: .medium)).foregroundColor(.white.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
        }
    }

    var levelProgress: Double {
        guard let p = appState.progress else { return 0 }
        return min(Double(p.currentLevelXP) / Double(max(p.xpForNextLevel, 1)), 1.0)
    }

    var levelTitle: String {
        switch appState.progress?.level ?? 1 {
        case 1...3:   return "Awakening Mind"
        case 4...7:   return "Focus Seeker"
        case 8...14:  return "Attention Adept"
        case 15...24: return "Clarity Hunter"
        case 25...39: return "Mind Architect"
        case 40...59: return "Focus Virtuoso"
        case 60...79: return "Neural Sage"
        default:      return "Flow Master"
        }
    }

    // MARK: - Stats Grid
    var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(icon: "flame.fill",            value: "\(appState.progress?.streakDays ?? 0)",                     label: "Day Streak",      color: .orange)
            statCard(icon: "diamond.fill",          value: "\(appState.progress?.gems ?? 0)",                           label: "Gems",            color: .cyan)
            statCard(icon: "checkmark.circle.fill", value: "\(appState.progress?.completedChallenges.count ?? 0)",      label: "Completed",       color: .green)
            statCard(icon: "heart.fill",            value: "\(appState.progress?.hearts ?? 5)/5",                       label: "Hearts",          color: .red)
        }
    }

    func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(color.opacity(0.2), lineWidth: 1))
            VStack(spacing: 10) {
                ZStack {
                    Circle().fill(color.opacity(0.15)).frame(width: 44, height: 44)
                    Image(systemName: icon).font(.system(size: 20)).foregroundColor(color)
                }
                Text(value).font(.system(size: 24, weight: .bold)).foregroundColor(.white)
                Text(label).font(.system(size: 11)).foregroundColor(.white.opacity(0.4))
            }
            .padding(.vertical, 20)
        }
    }

    // MARK: - Skills Section
    var skillsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Skills").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            ForEach(SkillType.allCases) { skill in
                let sp = appState.progress?.getSkill(skill)
                skillRow(skill: skill, level: sp?.level ?? 1, progress: sp?.progressToNextLevel ?? 0)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.07), lineWidth: 1))
        )
    }

    func skillRow(skill: SkillType, level: Int, progress: Double) -> some View {
        let color = Color(hex: skill.color)
        return HStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 36, height: 36)
                Image(systemName: skill.icon).font(.system(size: 15)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(skill.rawValue).font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                    Spacer()
                    Text("Lv.\(level)").font(.system(size: 11, weight: .bold)).foregroundColor(color)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.07))
                        RoundedRectangle(cornerRadius: 3).fill(color)
                            .frame(width: geo.size.width * CGFloat(progress))
                            .animation(.spring(response: 0.5), value: progress)
                    }
                }.frame(height: 5)
            }
        }
    }

    // MARK: - Menu Section
    var menuSection: some View {
        VStack(spacing: 0) {
            menuRow(icon: "person.fill",                  label: "Edit Profile",         color: .blue)   { editingName = appState.currentUser?.displayName ?? ""; editingEmoji = appState.currentUser?.avatarEmoji ?? "🦞"; showEditProfile = true }
            menuDivider
            menuRow(icon: "bell.fill",                    label: "Notifications",        color: .orange) {}
            menuDivider
            menuRow(icon: "lock.fill",                    label: "Privacy & Security",   color: .purple) {}
            menuDivider
            menuRow(icon: "arrow.triangle.2.circlepath",  label: "Reset Progress",       color: .red)    { appState.resetOnboarding() }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.07), lineWidth: 1))
        )
    }

    var menuDivider: some View {
        Rectangle().fill(Color.white.opacity(0.05)).frame(height: 1).padding(.horizontal, 16)
    }

    func menuRow(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.15)).frame(width: 38, height: 38)
                    Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
                }
                Text(label).font(.system(size: 15, weight: .medium)).foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.white.opacity(0.25))
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
        }
    }
}

// MARK: - Shared Profile Components
struct ProfileStatBox: View {
    let title: String; let value: String; let icon: String; let color: Color
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(color)
            Text(value).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Text(title).font(.system(size: 10)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(Color.white.opacity(0.05)).cornerRadius(14)
    }
}

struct ProfileRowButton: View {
    let icon: String; let title: String; let color: Color
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(color).frame(width: 28)
            Text(title).font(.system(size: 15)).foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.gray)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

struct ProfileRowToggle: View {
    let icon: String; let title: String; let color: Color
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(color).frame(width: 28)
            Text(title).font(.system(size: 15)).foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn).tint(.purple).labelsHidden()
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

struct EditProfileSheet: View {
    @Binding var name: String
    @Binding var emoji: String
    @Binding var isPresented: Bool
    let onSave: () -> Void

    let emojiOptions = ["🦞","🦁","🐉","🦊","🦅","🐺","🦋","🐬","🐻","🦄","⚡","🔥","🌙","⭐","🎯"]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "06060F"), Color(hex: "0A0F1C")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                VStack(spacing: 24) {
                    Text(emoji).font(.system(size: 80)).padding(.top, 20)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojiOptions, id: \.self) { e in
                                Button { emoji = e } label: {
                                    Text(e).font(.system(size: 32)).frame(width: 56, height: 56)
                                        .background(Circle().fill(emoji == e ? Color.purple.opacity(0.35) : Color.white.opacity(0.06)))
                                }
                            }
                        }.padding(.horizontal)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name").font(.system(size: 13, weight: .semibold)).foregroundColor(.gray)
                        TextField("Your name", text: $name)
                            .foregroundColor(.white).font(.system(size: 17))
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)))
                    }.padding(.horizontal)
                    Spacer()
                }
            }
            .navigationTitle("Edit Profile").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }.foregroundColor(.gray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { onSave(); isPresented = false }.foregroundColor(.purple).fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ProfileView().environmentObject(AppState())
}
