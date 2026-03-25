import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings     = false
    @State private var showAchievements = false
    @State private var showLeaderboard  = false
    @State private var showFriends      = false
    @State private var showEditProfile  = false
    @State private var editingName      = ""
    @State private var editingEmoji     = ""

    var body: some View {
        ZStack {
            // Background gradient with floating orbs
            LinearGradient(
                colors: [Color(hex: "06060F"), Color(hex: "0A0F1C"), Color(hex: "0D1526")],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            // Floating ambient orbs
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -150)
                .blur(radius: 60)

            Circle()
                .fill(Color.indigo.opacity(0.08))
                .frame(width: 250, height: 250)
                .offset(x: 150, y: 400)
                .blur(radius: 60)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroCard
                    statsGrid
                    skillsSection
                    menuSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 58)
                .padding(.bottom, 120)
            }
        }
        .sheet(isPresented: $showAchievements) { AchievementsView().environmentObject(appState) }
        .sheet(isPresented: $showLeaderboard)  { LeaderboardView().environmentObject(appState) }
        .sheet(isPresented: $showFriends)      { FriendsView().environmentObject(appState) }
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
            // Liquid glass background with subtle glow
            VStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)
                    .offset(y: -40)
                Spacer()
            }

            VStack(spacing: 20) {
                // Avatar with glass progress ring
                ZStack {
                    // Outer glass circle with gradient background
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "7C3AED").opacity(0.3), Color(hex: "4F46E5").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                        .blur(radius: 1)

                    // GlassProgressRing component
                    GlassProgressRing(
                        progress: levelProgress,
                        lineWidth: 5,
                        gradientColors: [.purple, .cyan],
                        size: 120
                    )

                    // Avatar circle with gradient
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)

                    Text(appState.currentUser?.avatarEmoji ?? "🦞")
                        .font(.system(size: 48))

                    // Edit button with glass effect
                    Button {
                        editingName  = appState.currentUser?.displayName ?? ""
                        editingEmoji = appState.currentUser?.avatarEmoji ?? "🦞"
                        showEditProfile = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "1C1C42"))
                                .frame(width: 32, height: 32)

                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color.purple.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    .offset(x: 36, y: 36)
                }

                VStack(spacing: 8) {
                    Text(appState.currentUser?.displayName ?? "Focus Warrior")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text(levelTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "C4B5FD"))

                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        Text("Level \(appState.progress?.level ?? 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("·")
                            .foregroundColor(.white.opacity(0.3))
                        Text("\(appState.progress?.totalXP ?? 0) XP")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow.opacity(0.9))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.12))
                            .overlay(
                                Capsule().stroke(Color.yellow.opacity(0.25), lineWidth: 1.5)
                            )
                    )
                }

                // Action buttons in a glass grid
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        profileActionButton(icon: "trophy.fill", label: "Leaderboard", color: .yellow) { showLeaderboard = true }
                        profileActionButton(icon: "star.fill", label: "Achievements", color: .purple) { showAchievements = true }
                    }
                    HStack(spacing: 10) {
                        profileActionButton(icon: "person.2.fill", label: "Friends", color: .cyan) { showFriends = true }
                        profileActionButton(icon: "gearshape.fill", label: "Settings", color: .gray) { showSettings = true }
                    }
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 20)
        }
        .liquidGlass(tint: .purple, cornerRadius: 28)
    }

    func profileActionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.25))
                        .frame(width: 52, height: 52)
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
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
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            statCard(icon: "flame.fill", value: "\(appState.progress?.streakDays ?? 0)", label: "Day Streak", color: .orange, glowColor: Color.orange.opacity(0.4))
            statCard(icon: "diamond.fill", value: "\(appState.progress?.gems ?? 0)", label: "Gems", color: .cyan, glowColor: Color.cyan.opacity(0.4))
            statCard(icon: "checkmark.circle.fill", value: "\(appState.progress?.completedChallenges.count ?? 0)", label: "Completed", color: .green, glowColor: Color.green.opacity(0.4))
            statCard(icon: "heart.fill", value: "\(appState.progress?.hearts ?? 5)/5", label: "Hearts", color: .red, glowColor: Color.red.opacity(0.4))
        }
    }

    func statCard(icon: String, value: String, label: String, color: Color, glowColor: Color) -> some View {
        ZStack {
            // Subtle glow from bottom
            VStack {
                Spacer()
                Circle()
                    .fill(glowColor)
                    .frame(height: 60)
                    .blur(radius: 20)
                    .offset(y: 30)
            }

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.22))
                        .frame(width: 50, height: 50)
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
        }
        .liquidGlass(tint: color, cornerRadius: 20)
    }

    // MARK: - Skills Section
    var skillsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skills")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 4)

            ForEach(SkillType.allCases) { skill in
                let sp = appState.progress?.getSkill(skill)
                skillRow(skill: skill, level: sp?.level ?? 1, progress: sp?.progressToNextLevel ?? 0)
            }
        }
        .padding(20)
        .liquidGlass(tint: .purple, cornerRadius: 24)
    }

    func skillRow(skill: SkillType, level: Int, progress: Double) -> some View {
        let color = Color(hex: skill.color)
        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.25))
                    .frame(width: 42, height: 42)
                    .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)

                Image(systemName: skill.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(skill.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("Lv.\(level)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color)
                }

                GlassProgressBar(
                    progress: progress,
                    height: 6,
                    gradientColors: [color, color.opacity(0.6)],
                    showPercentage: false,
                    glowColor: color.opacity(0.3)
                )
            }
        }
    }

    // MARK: - Menu Section
    var menuSection: some View {
        VStack(spacing: 0) {
            menuRow(icon: "person.fill", label: "Edit Profile", color: .blue) {
                editingName = appState.currentUser?.displayName ?? ""
                editingEmoji = appState.currentUser?.avatarEmoji ?? "🦞"
                showEditProfile = true
            }
            GlassDivider()
                .padding(.horizontal, 16)

            menuRow(icon: "person.2.fill", label: "Friends", color: .cyan) { showFriends = true }
            GlassDivider()
                .padding(.horizontal, 16)

            menuRow(icon: "bell.fill", label: "Notifications", color: .orange) {}
            GlassDivider()
                .padding(.horizontal, 16)

            menuRow(icon: "lock.fill", label: "Privacy & Security", color: .purple) {}
            GlassDivider()
                .padding(.horizontal, 16)

            menuRow(icon: "arrow.triangle.2.circlepath", label: "Reset Progress", color: .red) {
                appState.resetOnboarding()
            }
        }
        .liquidGlass(tint: .purple, cornerRadius: 24)
    }

    func menuRow(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)

                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.25))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Shared Profile Components
struct ProfileStatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .liquidGlass(tint: color, cornerRadius: 14)
    }
}

struct ProfileRowButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 28)
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct ProfileRowToggle: View {
    let icon: String
    let title: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 28)
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(.purple)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct EditProfileSheet: View {
    @Binding var name: String
    @Binding var emoji: String
    @Binding var isPresented: Bool
    let onSave: () -> Void

    let emojiOptions = ["🦞", "🦁", "🐉", "🦊", "🦅", "🐺", "🦋", "🐬", "🐻", "🦄", "⚡", "🔥", "🌙", "⭐", "🎯"]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "06060F"), Color(hex: "0A0F1C")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Text(emoji)
                        .font(.system(size: 80))
                        .padding(.top, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojiOptions, id: \.self) { e in
                                Button {
                                    emoji = e
                                } label: {
                                    Text(e)
                                        .font(.system(size: 32))
                                        .frame(width: 56, height: 56)
                                        .background(
                                            Circle().fill(
                                                emoji == e
                                                    ? Color.purple.opacity(0.4)
                                                    : Color.white.opacity(0.08)
                                            )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                        TextField("Your name", text: $name)
                            .foregroundColor(.white)
                            .font(.system(size: 17))
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.06))
                            )
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        isPresented = false
                    }
                    .foregroundColor(.purple)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct FriendsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var socialService = SocialService.shared

    @State private var newFriendName: String = ""
    @State private var selectedFriend: FriendProfile?
    @State private var challengeTitle: String = "Daily Focus Sprint"
    @State private var showChallengeComposer: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "06060F"), Color(hex: "0A0F1C")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                header
                addFriendRow
                friendsList
                invitesSection
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showChallengeComposer) {
            if let selectedFriend {
                FriendChallengeComposer(
                    friend: selectedFriend,
                    challengeTitle: $challengeTitle
                ) {
                    _ = socialService.challengeFriend(
                        friendId: selectedFriend.id,
                        challengeTitle: challengeTitle
                    )
                    showChallengeComposer = false
                }
            }
        }
    }

    var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            Spacer()
            Text("Friends")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Text("\(socialService.friends.count)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.cyan)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.cyan.opacity(0.12)))
        }
    }

    var addFriendRow: some View {
        HStack(spacing: 10) {
            TextField("Add friend name", text: $newFriendName)
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.06))
                )
                .foregroundColor(.white)

            Button("Add") {
                let trimmed = newFriendName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                socialService.addFriend(name: trimmed, avatar: "👋")
                newFriendName = ""
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.purple.opacity(0.35)))
        }
    }

    var friendsList: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(socialService.friends) { friend in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 42, height: 42)
                            Text(friend.avatar)
                                .font(.system(size: 21))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(friend.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Text("\(friend.xp) XP · \(friend.streak)d streak")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Circle()
                            .fill(friend.isOnline ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)

                        Button {
                            selectedFriend = friend
                            showChallengeComposer = true
                        } label: {
                            Text("Challenge")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.blue.opacity(0.32)))
                        }

                        Button {
                            socialService.removeFriend(id: friend.id)
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.red.opacity(0.9))
                                .padding(8)
                                .background(Circle().fill(Color.red.opacity(0.12)))
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
            }
            .padding(.top, 4)
        }
    }

    var invitesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sent Challenges")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.8))

            if socialService.sentInvites.isEmpty {
                Text("No active invites yet.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            } else {
                ForEach(socialService.sentInvites.prefix(3)) { invite in
                    HStack {
                        Text(socialService.friend(for: invite.friendId)?.name ?? "Friend")
                            .foregroundColor(.white)
                        Spacer()
                        Text(invite.challengeTitle)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    .font(.system(size: 12))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
        )
    }
}

struct FriendChallengeComposer: View {
    let friend: FriendProfile
    @Binding var challengeTitle: String
    let onSend: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0A0F1C").ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Challenge \(friend.name)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                TextField("Challenge name", text: $challengeTitle)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.08))
                    )
                    .foregroundColor(.white)

                Button {
                    onSend()
                    dismiss()
                } label: {
                    Text("Send Challenge")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.purple)
                        )
                }
            }
            .padding(24)
        }
    }
}

#Preview {
    ProfileView().environmentObject(AppState())
}
