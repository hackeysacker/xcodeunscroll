import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled: Bool = true
    @State private var soundEnabled: Bool = true
    @State private var hapticsEnabled: Bool = true
    @State private var darkModeEnabled: Bool = true
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark").font(.system(size: 18)).foregroundColor(.white).frame(width: 44, height: 44)
                        }
                        Spacer()
                        Text("Settings").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                        Spacer()
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.top, 16)
                    
                    // Profile section
                    profileSection
                    
                    // Preferences
                    preferencesSection
                    
                    // Testing
                    testingSection
                    
                    // Notifications
                    notificationsSection
                    
                    // Data & Privacy
                    dataSection
                    
                    // Support
                    supportSection
                    
                    // Danger zone
                    dangerZone
                    
                    // App info
                    appInfoSection
                }
                .padding(.bottom, 100)
            }
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                appState.resetOnboarding()
                dismiss()
            }
        } message: {
            Text("This will permanently delete all your data. This action cannot be undone.")
        }
    }
    
    var profileSection: some View {
        GlassCard(cornerRadius: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 70, height: 70)
                    Text(appState.currentUser?.avatarEmoji ?? "🦞")
                        .font(.system(size: 30))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.currentUser?.displayName ?? "Focus User")
                        .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                    Text(appState.currentUser?.goal?.rawValue ?? "Building focus")
                        .font(.system(size: 14)).foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
    }
    
    var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Preferences")
            
            VStack(spacing: 8) {
                GlassToggle(title: "Dark Mode", icon: "moon.fill", isOn: $darkModeEnabled)
                GlassDivider()
                GlassToggle(title: "Sound", icon: "speaker.wave.2.fill", isOn: $soundEnabled)
                GlassDivider()
                GlassToggle(title: "Haptics", icon: "iphone.radiowaves.left.and.right", isOn: $hapticsEnabled)
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
    }
    
    // Testing section for developers
    @State private var showChallengePicker = false
    
    var testingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "🧪 Testing Mode")
            
            VStack(spacing: 0) {
                Button {
                    showChallengePicker = true
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.green)
                        Text("Test Any Challenge")
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                GlassToggle(title: "Quick Test Mode", icon: "bolt.fill", isOn: $appState.testingModeEnabled)
                
                if appState.testingModeEnabled {
                    Divider().background(Color.white.opacity(0.1))
                    
                    HStack {
                        Image(systemName: "timer").foregroundColor(.orange)
                        Text("Quick Duration")
                            .foregroundColor(.white)
                        Spacer()
                        Picker("", selection: $appState.testingDuration) {
                            Text("5s").tag(5)
                            Text("10s").tag(10)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                    }
                    .padding()
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
            
            Text("Tap 'Test Any Challenge' to try any challenge in the app. Quick Test Mode makes all challenges complete in 5 or 10 seconds.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
            
            // Heart System Test
            if appState.testingModeEnabled {
                heartSystemTestSection
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showChallengePicker) {
            ChallengeTestPicker()
                .environmentObject(appState)
        }
    }
    
    // MARK: - Heart System Test Section
    var heartSystemTestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Heart System Test", color: .red)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "heart.fill").foregroundColor(.red)
                    Text("Current Hearts")
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(appState.progress?.hearts ?? 0)/5")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16, weight: .bold))
                }
                .padding()
                
                HStack(spacing: 12) {
                    Button {
                        if var progress = appState.progress, progress.hearts < 5 {
                            progress.hearts += 1
                            appState.progress = progress
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Heart")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    Button {
                        if var progress = appState.progress, progress.hearts > 0 {
                            progress.hearts -= 1
                            appState.progress = progress
                        }
                    } label: {
                        HStack {
                            Image(systemName: "minus.circle.fill")
                            Text("Use Heart")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "clock.fill").foregroundColor(.orange)
                    Text("Refill Slots")
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(appState.progress?.heartRefillSlots ?? 0)/3")
                        .foregroundColor(.cyan)
                        .font(.system(size: 16, weight: .bold))
                }
                .padding()
                
                HStack(spacing: 12) {
                    Button {
                        if var progress = appState.progress, progress.heartRefillSlots < 3 {
                            progress.heartRefillSlots += 1
                            appState.progress = progress
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Slot")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.cyan.opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    Button {
                        if var progress = appState.progress, progress.heartRefillSlots > 0 {
                            progress.heartRefillSlots -= 1
                            appState.progress = progress
                        }
                    } label: {
                        HStack {
                            Image(systemName: "minus.circle.fill")
                            Text("Use Slot")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.3), lineWidth: 1))
        }
        .padding(.top, 8)
    }
    
    var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Notifications")
            
            VStack(spacing: 8) {
                GlassToggle(title: "Push Notifications", icon: "bell.fill", isOn: $notificationsEnabled)
                GlassDivider()
                SettingsRow(icon: "clock.fill", title: "Reminder Time", value: "9:00 AM")
                GlassDivider()
                SettingsRow(icon: "calendar", title: "Daily Goal Reminder", value: "On")
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
    }
    
    var dataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Data & Privacy")
            
            VStack(spacing: 0) {
                SettingsRow(icon: "arrow.clockwise", title: "Sync Progress", value: "")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "square.and.arrow.up", title: "Export Data", value: "")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "trash", title: "Clear Local Data", value: "")
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
        }
        .padding(.horizontal, 16)
    }
    
    var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Support")
            
            VStack(spacing: 0) {
                SettingsRow(icon: "questionmark.circle", title: "Help Center", value: "")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "envelope", title: "Contact Us", value: "")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "star.fill", title: "Rate App", value: "")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "doc.text", title: "Privacy Policy", value: "")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "doc", title: "Terms of Service", value: "")
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
        }
        .padding(.horizontal, 16)
    }
    
    var dangerZone: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Danger Zone", color: .red)
            
            VStack(spacing: 0) {
                Button {
                    showDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill").foregroundColor(.red).frame(width: 24)
                        Text("Delete Account").foregroundColor(.red)
                        Spacer()
                    }
                    .padding(16)
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.red.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal, 16)
    }
    
    var appInfoSection: some View {
        VStack(spacing: 8) {
            Text("FocusFlow").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            Text("Version 1.0.0 (Build 1)").font(.system(size: 12)).foregroundColor(.gray)
            Text("Made with 🦞").font(.system(size: 12)).foregroundColor(.gray)
        }
        .padding(.vertical, 24)
    }
}

struct SectionHeader: View {
    let title: String
    var color: Color = .white
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(color)
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.purple).frame(width: 24)
            Text(title).foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn).tint(.purple)
        }
        .padding(16)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.purple).frame(width: 24)
            Text(title).foregroundColor(.white)
            Spacer()
            let showValue = value.count > 0
            if showValue {
                Text(value).foregroundColor(.gray)
            }
            Image(systemName: "chevron.right").foregroundColor(.gray).font(.system(size: 12))
        }
        .padding(16)
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
import SwiftUI

struct ChallengeTestPicker: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedChallenge: AllChallengeType?
    @State private var showChallenge = false
    
    // Challenge data - using available challenge types
    let categories: [(String, String, [AllChallengeType])] = [
        ("Focus", "eye.fill", AllChallengeType.allCases.filter { $0.category == .focus }.prefix(5).map { $0 }),
        ("Memory", "brain.head.profile", AllChallengeType.allCases.filter { $0.category == .memory }.prefix(5).map { $0 }),
        ("Reaction", "bolt.fill", AllChallengeType.allCases.filter { $0.category == .reaction }.prefix(5).map { $0 }),
        ("Breathing", "wind", AllChallengeType.allCases.filter { $0.category == .breathing }.prefix(5).map { $0 }),
        ("Discipline", "hand.raised.fill", AllChallengeType.allCases.filter { $0.category == .discipline }.prefix(5).map { $0 })
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "0A0F1C").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("Test Challenges")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 50)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(categories, id: \.0) { category, icon, challenges in
                            VStack(alignment: .leading, spacing: 12) {
                                // Category header
                                HStack(spacing: 8) {
                                    Image(systemName: icon)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(category)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(challenges.count)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 16)
                                
                                // Challenge grid
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 10) {
                                    ForEach(challenges) { challenge in
                                        Button {
                                            selectedChallenge = challenge
                                            showChallenge = true
                                        } label: {
                                            ChallengeTestCard(challenge: challenge)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .fullScreenCover(isPresented: $showChallenge) {
            if let challenge = selectedChallenge {
                TestingChallengeView(challenge: challenge, duration: appState.testingDuration) {
                    showChallenge = false
                }
                .environmentObject(appState)
            }
        }
    }
}

struct ChallengeTestCard: View {
    let challenge: AllChallengeType
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(challenge.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: challenge.icon)
                    .font(.system(size: 18))
                    .foregroundColor(challenge.color)
            }
            
            Text(challenge.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
            
            // Difficulty
            HStack(spacing: 2) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(i < 2 ? challenge.color : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(challenge.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct TestingChallengeView: View {
    let challenge: AllChallengeType
    let duration: Int
    let onDismiss: () -> Void
    @EnvironmentObject var appState: AppState
    
    @State private var timeRemaining: Int
    @State private var isRunning = false
    @State private var isCompleted = false
    
    init(challenge: AllChallengeType, duration: Int, onDismiss: @escaping () -> Void) {
        self.challenge = challenge
        self.duration = duration
        self.onDismiss = onDismiss
        self._timeRemaining = State(initialValue: duration)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), challenge.color.opacity(0.2)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Close
                HStack {
                    Spacer()
                    Button { onDismiss() } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 28)).foregroundColor(.gray)
                    }
                }
                .padding()
                
                Spacer()
                
                // Icon
                ZStack {
                    Circle().fill(challenge.color.opacity(0.3)).frame(width: 120, height: 120)
                    Image(systemName: challenge.icon).font(.system(size: 50)).foregroundColor(challenge.color)
                }
                
                Text(challenge.rawValue)
                    .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                
                Text(challenge.description)
                    .font(.system(size: 14)).foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Timer
                if !isCompleted {
                    Text(timeString(timeRemaining))
                        .font(.system(size: 56, weight: .bold, design: .rounded)).foregroundColor(.white)
                        .monospacedDigit()
                }
                
                Spacer()
                
                // Controls
                if !isCompleted {
                    Button {
                        isRunning = true
                        startTimer()
                    } label: {
                        Text("Start")
                            .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                            .frame(width: 180, height: 50)
                            .background(challenge.color)
                            .cornerRadius(25)
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("🎉 Complete!")
                            .font(.system(size: 24, weight: .bold)).foregroundColor(.yellow)
                        
                        Button { onDismiss() } label: {
                            Text("Done")
                                .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(width: 140, height: 44)
                                .background(challenge.color)
                                .cornerRadius(22)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                isCompleted = true
            }
        }
    }
    
    func timeString(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
