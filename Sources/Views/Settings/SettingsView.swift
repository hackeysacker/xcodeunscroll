import SwiftUI

// Simple ChallengeType for Settings
struct ChallengeType: Identifiable {
    let id: String
    let icon: String
    let name: String
    let color: Color
    let category: ChallengeCategory
    let description: String
    let instructions: String
    let hint: String
    let difficulty: Int
    
    enum ChallengeCategory: String {
        case mental, meditation, physical, learning, creative, reflection, social, rest
    }
}

// Social challenges
let socialChallenges: [ChallengeType] = [
    ChallengeType(id: "call", icon: "phone.fill", name: "Call Someone", color: Color(hex: "EC4899"), category: .social, description: "Connect", instructions: "Call a friend or family member.", hint: "FaceTime counts!", difficulty: 1),
    ChallengeType(id: " compliment", icon: "hand.thumbsup.fill", name: " compliment", color: Color(hex: "DB2777"), category: .social, description: "Be kind", instructions: "Give a genuine compliment.", hint: "Specific is better.", difficulty: 1),
    ChallengeType(id: "listen", icon: "ear.fill", name: "Deep Listen", color: Color(hex: "BE185D"), category: .social, description: "Active listening", instructions: "Have a conversation without interrupting.", hint: "Ask questions.", difficulty: 2),
    ChallengeType(id: "share", icon: "square.and.arrow.up", name: "Share", color: Color(hex: "9D174D"), category: .social, description: "Share knowledge", instructions: "Share something helpful with someone.", hint: "Articles count!", difficulty: 1),
    ChallengeType(id: "ask", icon: "questionmark.circle.fill", name: "Ask", color: Color(hex: "831843"), category: .social, description: "Learn about someone", instructions: "Ask someone about their life.", hint: "Be curious!", difficulty: 1),
    ChallengeType(id: "appreciate", icon: "heart.fill", name: "Appreciate", color: Color(hex: "701c37"), category: .social, description: "Express gratitude", instructions: "Tell someone why you appreciate them.", hint: "Be specific.", difficulty: 1),
    ChallengeType(id: "help", icon: "handshake.fill", name: "Help", color: Color(hex: "500724"), category: .social, description: "Assist others", instructions: "Help someone with something.", hint: "Small acts count!", difficulty: 1)
]

// Rest challenges
let restChallenges: [ChallengeType] = [
    ChallengeType(id: "nap", icon: "moon.zzz.fill", name: "Power Nap", color: Color(hex: "6366F1"), category: .rest, description: "Rest your mind", instructions: "Close your eyes for 10-20 minutes.", hint: "Set an alarm.", difficulty: 1),
    ChallengeType(id: "relax", icon: "leaf.fill", name: "Relax", color: Color(hex: "4F46E5"), category: .rest, description: "Do nothing", instructions: "Sit quietly. No phone. Just be.", hint: "Stare out the window.", difficulty: 1),
    ChallengeType(id: "daydream", icon: "cloud.fill", name: "Daydream", color: Color(hex: "4338CA"), category: .rest, description: "Use your imagination", instructions: "Imagine your ideal day.", hint: "Be detailed!", difficulty: 1),
    ChallengeType(id: "stretch", icon: "figure.flexibility", name: "Gentle Stretch", color: Color(hex: "3730A3"), category: .rest, description: "Light movement", instructions: "Do gentle stretches.", hint: "No intense workout.", difficulty: 1),
    ChallengeType(id: "music", icon: "music.note", name: "Listen", color: Color(hex: "312E81"), category: .rest, description: "Enjoy music", instructions: "Listen to your favorite songs.", hint: "No podcasts, just music.", difficulty: 1),
    ChallengeType(id: "nature", icon: "tree.fill", name: "Nature", color: Color(hex: "1E1B4B"), category: .rest, description: "Connect with nature", instructions: "Spend time outside.", hint: "Even 5 minutes counts!", difficulty: 1)
]

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled: Bool = true
    @State private var soundEnabled: Bool = true
    @State private var hapticsEnabled: Bool = true
    @State private var darkModeEnabled: Bool = true
    @State private var showDeleteAlert: Bool = false
    
    // Auth state
    @State private var showAuthSheet: Bool = false
    @State private var authEmail: String = ""
    @State private var authPassword: String = ""
    @State private var isSignUp: Bool = false
    @State private var authError: String?
    @State private var isAuthLoading: Bool = false
    
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
                    
                    // Account section
                    accountSection
                    
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
                    
                    // Auth status badge
                    if appState.isAuthenticated {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 10))
                            Text("Synced").font(.system(size: 10))
                        }
                        .foregroundColor(.green)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "person.crop.circle.badge.xmark").font(.system(size: 10))
                            Text("Local").font(.system(size: 10))
                        }
                        .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // Account section for auth
    var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Account")
            
            VStack(spacing: 0) {
                if appState.isAuthenticated {
                    // Signed in state
                    HStack {
                        Image(systemName: "person.badge.checkmark").foregroundColor(.green).frame(width: 24)
                        Text("Signed in")
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            Task {
                                await appState.signOut()
                            }
                        } label: {
                            Text("Sign Out")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                } else {
                    // Not signed in
                    Button {
                        showAuthSheet = true
                        isSignUp = false
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus").foregroundColor(.purple).frame(width: 24)
                            Text("Sign In or Create Account")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
            
            if appState.isAuthenticated {
                // Sync button
                Button {
                    Task {
                        if let userId = appState.currentUser?.id {
                            await appState.syncFromCloud(userId: userId)
                        }
                    }
                } label: {
                    HStack {
                        if appState.isSyncing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise").foregroundColor(.purple)
                        }
                        Text(appState.isSyncing ? "Syncing..." : "Sync Now")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                }
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
            }
            
            Text("Sign in to sync your progress across devices and backup your data.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showAuthSheet) {
            AuthSheet(
                email: $authEmail,
                password: $authPassword,
                isSignUp: $isSignUp,
                error: $authError,
                isLoading: $isAuthLoading,
                onDismiss: { showAuthSheet = false },
                onAuth: performAuth
            )
        }
    }
    
    func performAuth() {
        authError = nil
        isAuthLoading = true
        
        Task {
            do {
                if isSignUp {
                    await appState.signUp(email: authEmail, password: authPassword)
                } else {
                    await appState.signIn(email: authEmail, password: authPassword)
                }
                isAuthLoading = false
                showAuthSheet = false
                authEmail = ""
                authPassword = ""
            } catch {
                isAuthLoading = false
                authError = error.localizedDescription
            }
        }
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
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showChallengePicker) {
            ChallengeTestPicker()
                .environmentObject(appState)
        }
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
    @State private var selectedChallenge: ChallengeType?
    @State private var showChallenge = false
    
    // Challenge data (same as in ProgressPathView)
    let categories: [(String, String, [ChallengeType])] = [
        ("Mental", "brain.head.profile", mentalChallenges),
        ("Meditation", "moon.stars.fill", meditationChallenges),
        ("Physical", "figure.run", physicalChallenges),
        ("Learning", "book.fill", learningChallenges),
        ("Creative", "paintbrush.fill", creativeChallenges),
        ("Reflection", "lightbulb.fill", reflectionChallenges),
        ("Social", "person.2.fill", socialChallenges),
        ("Rest", "moon.fill", restChallenges)
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
    let challenge: ChallengeType
    
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
            
            Text(challenge.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
            
            // Difficulty
            HStack(spacing: 2) {
                ForEach(0..<5) { i in
                    Circle()
                        .fill(i < challenge.difficulty ? challenge.color : Color.gray.opacity(0.3))
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
    let challenge: ChallengeType
    let duration: Int
    let onDismiss: () -> Void
    @EnvironmentObject var appState: AppState
    
    @State private var timeRemaining: Int
    @State private var isRunning = false
    @State private var isCompleted = false
    
    init(challenge: ChallengeType, duration: Int, onDismiss: @escaping () -> Void) {
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
                
                Text(challenge.name)
                    .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                
                Text(challenge.instructions)
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

// Challenge lists
let mentalChallenges: [ChallengeType] = [
    ChallengeType(id: "focus", icon: "eye.fill", name: "Focus", color: Color(hex: "8B5CF6"), category: .mental, description: "Stay focused", instructions: "Put your phone down. Clear your mind. Focus on your breath.", hint: "If your mind wanders, gently bring it back.", difficulty: 1),
    ChallengeType(id: "deep_work", icon: "brain.head.profile", name: "Deep Work", color: Color(hex: "7C3AED"), category: .mental, description: "Concentrate", instructions: "Choose one task. Work continuously without distractions.", hint: "Set a clear intention first.", difficulty: 2),
    ChallengeType(id: "memory", icon: "memorychip", name: "Memory", color: Color(hex: "6366F1"), category: .mental, description: "Exercise memory", instructions: "Recall 5 things you're grateful for. Then 3 happy memories.", hint: "Close your eyes to visualize.", difficulty: 2),
    ChallengeType(id: "puzzle", icon: "puzzlepiece.fill", name: "Puzzle", color: Color(hex: "4F46E5"), category: .mental, description: "Mental puzzle", instructions: "Think of as many uses for a paperclip as possible.", hint: "Consider different categories.", difficulty: 2),
    ChallengeType(id: "concentration", icon: "scope", name: "Concentration", color: Color(hex: "5B21B6"), category: .mental, description: "Sharpen focus", instructions: "Pick an object. Stare at it. Notice every detail.", hint: "Gently bring focus back when it wanders.", difficulty: 2),
    ChallengeType(id: "critical", icon: "questionmark.circle", name: "Critical Think", color: Color(hex: "4338CA"), category: .mental, description: "Analyze problems", instructions: "Think of a problem. List pros and cons. Find 3 solutions.", hint: "Write it down.", difficulty: 3),
    ChallengeType(id: "speed_read", icon: "hare.fill", name: "Speed Read", color: Color(hex: "3730A3"), category: .mental, description: "Read quickly", instructions: "Read an article. Absorb the main points.", hint: "Focus on headers and key terms.", difficulty: 2),
    ChallengeType(id: "mental_math", icon: "plus.forwardslash.minus", name: "Mental Math", color: Color(hex: "312E81"), category: .mental, description: "Calculate", instructions: "Calculate in your head: 15+27, 100-43, 12x8", hint: "Break numbers into parts.", difficulty: 2),
    ChallengeType(id: "mind_map", icon: "map", name: "Mind Map", color: Color(hex: "1E1B4B"), category: .mental, description: "Visualize", instructions: "Create a mind map with a central idea and branches.", hint: "Use colors and images.", difficulty: 2)
]

let meditationChallenges: [ChallengeType] = [
    ChallengeType(id: "meditate", icon: "brain.head.profile", name: "Meditate", color: Color(hex: "06B6D4"), category: .meditation, description: "Clear mind", instructions: "Sit comfortably. Close eyes. Focus on breath. Let thoughts pass.", hint: "Don't fight thoughts.", difficulty: 1),
    ChallengeType(id: "body_scan", icon: "figure.stand", name: "Body Scan", color: Color(hex: "0891B2"), category: .meditation, description: "Scan tension", instructions: "Move awareness from toes up. Release tension.", hint: "Breathe into tight areas.", difficulty: 1),
    ChallengeType(id: "loving", icon: "heart.fill", name: "Loving Kindness", color: Color(hex: "0D9488"), category: .meditation, description: "Compassion", instructions: "Think of someone. Repeat: May you be happy, healthy, at peace.", hint: "Start with yourself.", difficulty: 2),
    ChallengeType(id: "visualization", icon: "sparkles", name: "Visualization", color: Color(hex: "14B8A6"), category: .meditation, description: "Picture goals", instructions: "Visualize your ideal day in vivid detail.", hint: "Engage all senses.", difficulty: 2),
    ChallengeType(id: "mindfulness", icon: "leaf.fill", name: "Mindfulness", color: Color(hex: "0E7490"), category: .meditation, description: "Be present", instructions: "Focus entirely on the present moment.", hint: "Engage all five senses.", difficulty: 1),
    ChallengeType(id: "progressive", icon: "list.number", name: "Progressive", color: Color(hex: "155E75"), category: .meditation, description: "Tense & release", instructions: "Tense each muscle for 5 seconds, then release.", hint: "Notice the difference.", difficulty: 1),
    ChallengeType(id: "chakra", icon: "circle.hexagongrid", name: "Chakra", color: Color(hex: "164E63"), category: .meditation, description: "Balance energy", instructions: "Visualize energy flowing through each chakra.", hint: "Each has a color.", difficulty: 3),
    ChallengeType(id: "zen", icon: "circle.dashed", name: "Zen", color: Color(hex: "083344"), category: .meditation, description: "Empty mind", instructions: "Try to have no thoughts. Acknowledge and let go.", hint: "Like watching clouds.", difficulty: 3)
]

let physicalChallenges: [ChallengeType] = [
    ChallengeType(id: "exercise", icon: "figure.run", name: "Exercise", color: Color(hex: "EF4444"), category: .physical, description: "Get moving", instructions: "20 jumping jacks, 10 push-ups, or jog.", hint: "Any movement counts.", difficulty: 1),
    ChallengeType(id: "stretch", icon: "figure.flexibility", name: "Stretch", color: Color(hex: "DC2626"), category: .physical, description: "Flexibility", instructions: "Stretch tight areas. Hold 20-30 seconds.", hint: "Never bounce.", difficulty: 1),
    ChallengeType(id: "posture", icon: "figure.stand", name: "Posture", color: Color(hex: "B91C1C"), category: .physical, description: "Perfect posture", instructions: "Sit/stand with shoulders back, spine straight.", hint: "Imagine a string pulling you up.", difficulty: 1),
    ChallengeType(id: "breathing", icon: "wind", name: "Breathwork", color: Color(hex: "F87171"), category: .physical, description: "Control breath", instructions: "In 4, hold 4, out 4, hold 4. Repeat 5 times.", hint: "Activates parasympathetic system.", difficulty: 1),
    ChallengeType(id: "yoga", icon: "figure.yoga", name: "Yoga", color: Color(hex: "B91C1C"), category: .physical, description: "Yoga poses", instructions: "Do downward dog, warrior, tree. Hold 30s each.", hint: "Focus on breath.", difficulty: 2),
    ChallengeType(id: "walk", icon: "figure.walk", name: "Walk", color: Color(hex: "991B1B"), category: .physical, description: "Take a walk", instructions: "Go for a 5-minute walk. Notice surroundings.", hint: "Breathe deeply.", difficulty: 1),
    ChallengeType(id: "dance", icon: "music.note.list", name: "Dance", color: Color(hex: "7F1D1D"), category: .physical, description: "Move to music", instructions: "Put on a song. Dance freely.", hint: "No judgment!", difficulty: 1),
    ChallengeType(id: "squats", icon: "figure.strengthtraining", name: "Squats", color: Color(hex: "450A0A"), category: .physical, description: "Leg workout", instructions: "Do 15 squats. Keep back straight.", hint: "Engage your core.", difficulty: 2),
    ChallengeType(id: "plank", icon: "figure.core.training", name: "Plank", color: Color(hex: "7C2D12"), category: .physical, description: "Core strength", instructions: "Hold plank 30-60 seconds. Straight line.", hint: "Don't let hips sag.", difficulty: 2),
    ChallengeType(id: "lunges", icon: "figure.walk", name: "Lunges", color: Color(hex: "78350F"), category: .physical, description: "Leg lunges", instructions: "10 lunges each leg. Step forward.", hint: "Knee over ankle.", difficulty: 2),
    ChallengeType(id: "jumping_jacks", icon: "star.fill", name: "Jumping Jacks", color: Color(hex: "713F12"), category: .physical, description: "Cardio", instructions: "Do 20 jumping jacks.", hint: "Land softly.", difficulty: 1),
    ChallengeType(id: "burpees", icon: "flame.fill", name: "Burpees", color: Color(hex: "5C2D0E"), category: .physical, description: "Full body", instructions: "5 burpees: squat, jump back, pushup, jump up.", hint: "Modify by stepping.", difficulty: 3)
]

let learningChallenges: [ChallengeType] = [
    ChallengeType(id: "read", icon: "book.fill", name: "Read", color: Color(hex: "F59E0B"), category: .learning, description: "Read and learn", instructions: "Read a chapter or 10 pages.", hint: "Take notes.", difficulty: 1),
    ChallengeType(id: "vocabulary", icon: "textformat.abc", name: "Vocabulary", color: Color(hex: "D97706"), category: .learning, description: "Learn words", instructions: "Learn 3 new words. Look up definitions.", hint: "Use them in sentences.", difficulty: 2),
    ChallengeType(id: "language", icon: "globe", name: "Language", color: Color(hex: "B45309"), category: .learning, description: "Practice language", instructions: "Spend time on Duolingo or similar.", hint: "Practice speaking aloud.", difficulty: 2),
    ChallengeType(id: "podcast", icon: "headphones", name: "Podcast", color: Color(hex: "92400E"), category: .learning, description: "Learn by listening", instructions: "Listen to educational podcast.", hint: "Take mental notes.", difficulty: 1),
    ChallengeType(id: "flashcards", icon: "rectangle.stack", name: "Flashcards", color: Color(hex: "B45309"), category: .learning, description: "Review cards", instructions: "Review study cards. Focus on hard ones.", hint: "Repetition helps.", difficulty: 1),
    ChallengeType(id: "ted", icon: "tv", name: "TED Talk", color: Color(hex: "92400E"), category: .learning, description: "Watch & learn", instructions: "Watch a TED talk. Write 3 takeaways.", hint: "Choose interesting topics.", difficulty: 1),
    ChallengeType(id: "news", icon: "newspaper", name: "News", color: Color(hex: "78350F"), category: .learning, description: "Stay informed", instructions: "Read news. Summarize 3 stories.", hint: "Try diverse sources.", difficulty: 1),
    ChallengeType(id: "tutorial", icon: "play.rectangle", name: "Tutorial", color: Color(hex: "5C2D0E"), category: .learning, description: "Learn something new", instructions: "Watch a how-to video.", hint: "Pick something you've wanted to learn.", difficulty: 2)
]

let creativeChallenges: [ChallengeType] = [
    ChallengeType(id: "create", icon: "paintbrush.fill", name: "Create", color: Color(hex: "F97316"), category: .creative, description: "Make something", instructions: "Draw, paint, or make with hands.", hint: "No mistakes, only discoveries.", difficulty: 1),
    ChallengeType(id: "music", icon: "music.note", name: "Music", color: Color(hex: "EA580C"), category: .creative, description: "Play or listen", instructions: "Play instrument or mindfully listen.", hint: "Hear individual instruments.", difficulty: 1),
    ChallengeType(id: "writing", icon: "pencil.line", name: "Writing", color: Color(hex: "C2410C"), category: .creative, description: "Express in writing", instructions: "Free-write for 10 minutes. Don't edit.", hint: "Start with 'I wish...'", difficulty: 2),
    ChallengeType(id: "photography", icon: "camera.fill", name: "Photography", color: Color(hex: "9A3412"), category: .creative, description: "Capture moments", instructions: "Take 5 photos of inspiring things.", hint: "Look for light and shadows.", difficulty: 1),
    ChallengeType(id: "sketch", icon: "pencil.and.outline", name: "Sketch", color: Color(hex: "C2410C"), category: .creative, description: "Quick drawing", instructions: "Sketch anything around you.", hint: "Start with simple shapes.", difficulty: 1),
    ChallengeType(id: "poetry", icon: "text.quote", name: "Poetry", color: Color(hex: "9A3412"), category: .creative, description: "Write poetry", instructions: "Write a short poem (4-8 lines).", hint: "Draw from emotions.", difficulty: 2),
    ChallengeType(id: "sculpt", icon: "cube.fill", name: "Sculpt", color: Color(hex: "7C2D12"), category: .creative, description: "Make 3D art", instructions: "Sculpt with clay or stack blocks.", hint: "Let hands guide you.", difficulty: 2),
    ChallengeType(id: "collage", icon: "square.stack.3d.up", name: "Collage", color: Color(hex: "713F12"), category: .creative, description: "Create collage", instructions: "Cut and arrange images into art.", hint: "Old magazines work!", difficulty: 1)
]

let reflectionChallenges: [ChallengeType] = [
    ChallengeType(id: "journal", icon: "pencil", name: "Journal", color: Color(hex: "10B981"), category: .reflection, description: "Reflect & write", instructions: "Write about your day, feelings, goals.", hint: "Try: What went well? What improved?", difficulty: 1),
    ChallengeType(id: "gratitude", icon: "sun.max.fill", name: "Gratitude", color: Color(hex: "059669"), category: .reflection, description: "Count blessings", instructions: "Write 5 things you're grateful for.", hint: "Include small pleasures.", difficulty: 1),
    ChallengeType(id: "review", icon: "clock.arrow.circlepath", name: "Review", color: Color(hex: "047857"), category: .reflection, description: "Review day", instructions: "Think through your day hour by hour.", hint: "Tomorrow will be better.", difficulty: 2),
    ChallengeType(id: "goals", icon: "target", name: "Goals", color: Color(hex: "065F46"), category: .reflection, description: "Plan future", instructions: "Write 3 goals for tomorrow.", hint: "Use: I will [action] at [time].", difficulty: 2),
    ChallengeType(id: "letter", icon: "envelope.fill", name: "Letter", color: Color(hex: "047857"), category: .reflection, description: "Write a letter", instructions: "Write to yourself or someone.", hint: "You don't have to send it.", difficulty: 2),
    ChallengeType(id: "strengths", icon: "star.circle", name: "Strengths", color: Color(hex: "065F46"), category: .reflection, description: "Know yourself", instructions: "List 5 strengths. How can you use them?", hint: "Ask friends too.", difficulty: 1),
    ChallengeType(id: "values", icon: "scale.3d", name: "Values", color: Color(hex: "064E3B"), category: .reflection, description: "Identify values", instructions: "What matters most? Rank top 5.", hint: "Think what you'd fight for.", difficulty: 2),
    ChallengeType(id: "meditation_journal", icon: "book.closed.fill", name: "Meditation Journal", color: Color(hex: "022C22"), category: .reflection, description: "Meditative writing", instructions: "Write whatever comes to mind for 5 min.", hint: "Don't filter.", difficulty: 2)
]

// MARK: - Auth Sheet

struct AuthSheet: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isSignUp: Bool
    @Binding var error: String?
    @Binding var isLoading: Bool
    let onDismiss: () -> Void
    let onAuth: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "0A0F1C").ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(isSignUp ? "Create Account" : "Sign In")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    Color.clear.frame(width: 50)
                }
                .padding()
                
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("your@email.com", text: $email)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                .padding(.horizontal)
                
                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    SecureField("••••••••", text: $password)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                // Error message
                if let error = error {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // Submit button
                Button {
                    onAuth()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1)
                .padding(.horizontal)
                
                // Toggle sign up / sign in
                Button {
                    isSignUp.toggle()
                    error = nil
                } label: {
                    HStack {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .foregroundColor(.gray)
                        Text(isSignUp ? "Sign In" : "Sign Up")
                            .foregroundColor(.purple)
                    }
                    .font(.system(size: 14, weight: .semibold))
                }
                
                Spacer()
            }
        }
    }
}
