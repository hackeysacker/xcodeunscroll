import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showLeaderboard = false
    @State private var showInsights = false
    @State private var showEditProfile = false
    @State private var editingName: String = ""
    @State private var editingEmoji: String = ""
    
    // Toggle states
    @State private var darkModeEnabled = true
    @State private var soundEnabled = true
    @State private var hapticsEnabled = true
    @State private var notificationsEnabled = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    
                    // Leaderboard button
                    Button {
                        showLeaderboard = true
                    } label: {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                    }
                    
                    // Achievements button
                    Button {
                        showAchievements = true
                    } label: {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.purple)
                    }
                    
                    // Settings button
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 12)
                
                // Profile card
                profileCard
                
                // Stats summary
                statsSection
                
                // Account section
                accountSection
                
                // Settings shortcuts
                settingsSection
                
                // Data section
                dataSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
        }
        .sheet(isPresented: $showInsights) {
            InsightsView()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(
                name: $editingName,
                emoji: $editingEmoji,
                isPresented: $showEditProfile
            ) {
                // Save changes
                appState.currentUser?.displayName = editingName
                appState.currentUser?.avatarEmoji = editingEmoji
                appState.saveData()
            }
        }
    }
    
    var profileCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text(appState.currentUser?.avatarEmoji ?? "🦞")
                        .font(.system(size: 36))
                }
                
                // Name
                VStack(spacing: 4) {
                    Text(appState.currentUser?.displayName ?? "Focus User")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(appState.currentUser?.goal?.rawValue ?? "Building focus")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                // Level badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    Text("Level \(appState.progress?.level ?? 1)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(12)
            }
        }
    }
    
    var statsSection: some View {
        HStack(spacing: 12) {
            ProfileStatBox(title: "Streak", value: "\(appState.progress?.streakDays ?? 0)", icon: "flame.fill", color: .orange)
            ProfileStatBox(title: "XP", value: "\(appState.progress?.totalXP ?? 0)", icon: "star.fill", color: .yellow)
            ProfileStatBox(title: "Challenges", value: "\(appState.progress?.completedChallenges.count ?? 0)", icon: "checkmark.circle.fill", color: .green)
        }
    }
    
    var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                // Edit Profile
                Button {
                    editingName = appState.currentUser?.displayName ?? ""
                    editingEmoji = appState.currentUser?.avatarEmoji ?? "🦞"
                    showEditProfile = true
                } label: {
                    ProfileRowButton(icon: "person.fill", title: "Edit Profile", color: .blue)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                // Notifications
                Button {
                    // Could navigate to notification settings
                } label: {
                    ProfileRowToggle(icon: "bell.fill", title: "Notifications", color: .orange, isOn: $notificationsEnabled)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                // Privacy
                Button {
                    // Could show privacy settings
                } label: {
                    ProfileRowButton(icon: "lock.fill", title: "Privacy & Security", color: .purple)
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferences")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                ProfileRowToggle(icon: "moon.fill", title: "Dark Mode", color: .indigo, isOn: $darkModeEnabled)
                
                Divider().background(Color.white.opacity(0.1))
                
                ProfileRowToggle(icon: "speaker.wave.2.fill", title: "Sound", color: .green, isOn: $soundEnabled)
                
                Divider().background(Color.white.opacity(0.1))
                
                ProfileRowToggle(icon: "iphone.radiowaves.left.and.right", title: "Haptics", color: .red, isOn: $hapticsEnabled)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                // Restart onboarding
                Button {
                    appState.isOnboarded = false
                } label: {
                    ProfileRowButton(icon: "arrow.counterclockwise", title: "Restart Onboarding", color: .blue)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                // Reset progress
                Button {
                    // Would need confirmation
                    appState.progress?.streakDays = 0
                    appState.progress?.totalXP = 0
                    appState.progress?.hearts = 5
                } label: {
                    ProfileRowButton(icon: "trash.fill", title: "Reset Progress", color: .red)
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
}

// MARK: - Supporting Views
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
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ProfileRowButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
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
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.purple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @Binding var name: String
    @Binding var emoji: String
    @Binding var isPresented: Bool
    let onSave: () -> Void
    
    let emojis = ["🦞", "🦊", "🐯", "🦁", "🐼", "🐨", "🐸", "🦄", "🐲", "🦅", "🐺", "🐙", "🌟", "🔥", "💎", "🎯"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0F1C").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Avatar picker
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                        Text(emoji)
                            .font(.system(size: 48))
                    }
                    
                    // Emoji grid
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                        ForEach(emojis, id: \.self) { emo in
                            Button {
                                emoji = emo
                            } label: {
                                Text(emo)
                                    .font(.system(size: 32))
                                    .frame(width: 50, height: 50)
                                    .background(emoji == emo ? Color.purple.opacity(0.3) : Color.white.opacity(0.05))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("Your name", text: $name)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 40)
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
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    ProfileView().environmentObject(AppState())
}
