import SwiftUI

// MARK: - Fake Notifications Discipline Challenge
// Practice ignoring realistic fake notifications
// Tests impulse control and notification resistance

struct FakeNotificationsChallengeView: View {
    @Environment(\.dismiss) var dismiss
    
    // Game State
    @State private var score: Int = 0
    @State private var timeRemaining: Double = 45
    @State private var notifications: [FakeNotification] = []
    @State private var ignoredCount: Int = 0
    @State private var tappedCount: Int = 0
    @State private var isGameOver: Bool = false
    @State private var showResults: Bool = false
    @State private var currentPhase: Phase = .ready
    @State private var audioManager = AppAudioManager.shared
    
    // Configuration
    let duration: Double = 45
    
    enum Phase {
        case ready
        case playing
        case result
    }
    
    struct FakeNotification: Identifiable {
        let id = UUID()
        var type: NotificationType
        var x: CGFloat
        var y: CGFloat
        var opacity: Double = 0
        var scale: Double = 0
        var appearedAt: Date = Date()
        
        enum NotificationType: String, CaseIterable {
            case message = "New Message"
            case email = "Email"
            case social = "Social Update"
            case reminder = "Reminder"
            case news = "Breaking News"
            case like = "Someone liked your post"
            case comment = "New comment"
            case follow = "New follower"
            case call = "Incoming Call"
            case voip = "Voice Mail"
            
            var icon: String {
                switch self {
                case .message: return "message.fill"
                case .email: return "envelope.fill"
                case .social: return "person.2.fill"
                case .reminder: return "bell.fill"
                case .news: return "newspaper.fill"
                case .like: return "heart.fill"
                case .comment: return "text.bubble.fill"
                case .follow: return "person.badge.plus"
                case .call: return "phone.fill"
                case .voip: return "phone.arrow.down.left"
                }
            }
            
            var color: Color {
                switch self {
                case .message: return .blue
                case .email: return .red
                case .social: return .purple
                case .reminder: return .orange
                case .news: return .yellow
                case .like: return .pink
                case .comment: return .cyan
                case .follow: return .green
                case .call: return .green
                case .voip: return .red
                }
            }
            
            var appIcon: String {
                switch self {
                case .message: return "💬"
                case .email: return "📧"
                case .social: return "👥"
                case .reminder: return "🔔"
                case .news: return "📰"
                case .like: return "❤️"
                case .comment: return "💬"
                case .follow: return "👤"
                case .call: return "📞"
                case .voip: return "📞"
                }
            }
        }
    }
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background - phone-like frame
            LinearGradient(colors: [Color("1E293B"), Color("0A0F1C")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Phone screen
                phoneScreen
                
                Spacer()
                
                // Instructions
                instructionText
                    .padding(.bottom, 40)
            }
            
            // Results overlay
            if showResults {
                resultsOverlay
            }
        }
        .onAppear {
            startGame()
        }
        .onReceive(timer) { _ in
            guard currentPhase == .playing else { return }
            
            timeRemaining -= 0.1
            
            // Spawn notifications
            if Int.random(in: 0..<30) == 0 {
                spawnNotification()
            }
            
            // Cleanup old notifications
            cleanupNotifications()
            
            if timeRemaining <= 0 {
                endGame()
            }
        }
    }
    
    // MARK: - Header
    var header: some View {
        HStack(spacing: 24) {
            // Time
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .foregroundColor(timeRemaining < 10 ? .red : .green)
                Text(String(format: "%.0f", timeRemaining))
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
            
            // Score
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.yellow)
                Text("SCORE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
            
            // Stats
            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("\(ignoredCount)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                    Text("Ignored")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 2) {
                    Text("\(tappedCount)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red)
                    Text("Tapped")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }
    
    // MARK: - Phone Screen
    var phoneScreen: some View {
        ZStack {
            // Phone frame
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.black)
                .frame(width: 300, height: 600)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 4)
                )
                .overlay(
                    // Notch
                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(width: 120, height: 30)
                            .padding(.top, 10)
                        Spacer()
                    }
                )
            
            // Screen content
            VStack(spacing: 0) {
                // Status bar
                HStack {
                    Text("9:41")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "wifi")
                            .font(.system(size: 10))
                        Image(systemName: "battery.100")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                // App content (fake)
                VStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 60)
                            .padding(.horizontal, 12)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Home indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 100, height: 6)
                    .padding(.bottom, 8)
            }
            .frame(width: 280, height: 560)
            .clipShape(RoundedRectangle(cornerRadius: 36))
            
            // Notifications overlay
            ForEach(notifications) { notification in
                NotificationPopup(notification: notification) {
                    handleNotificationTap(notification)
                } onDismiss: {
                    handleNotificationDismiss(notification)
                }
                .position(x: notification.x, y: notification.y)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Instruction Text
    var instructionText: some View {
        VStack(spacing: 8) {
            if currentPhase == .ready {
                Text("GET READY")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.yellow)
            } else if currentPhase == .playing {
                Text("DON'T TAP THE NOTIFICATIONS!")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.red)
            } else {
                Text("RESULT")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
            }
        }
    }
    
    // MARK: - Results Overlay
    var resultsOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("\(score)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("POINTS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(2)
                
                // Stats
                HStack(spacing: 24) {
                    VStack {
                        Text("\(ignoredCount)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.green)
                        Text("Ignored")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("\(tappedCount)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.red)
                        Text("Tapped")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("\(ignoredCount + tappedCount)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Total")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                
                // Performance
                Text(performanceText)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(performanceColor)
                
                // Buttons
                VStack(spacing: 12) {
                    Button {
                        restart()
                    } label: {
                        Text("Try Again")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red)
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
    }
    
    // MARK: - Helpers
    var performanceText: String {
        let accuracy = ignoredCount + tappedCount > 0 ? Double(ignoredCount) / Double(ignoredCount + tappedCount) : 0
        if accuracy >= 0.9 { return "LEGENDARY IMPULSE CONTROL!" }
        if accuracy >= 0.7 { return "GREAT SELF-CONTROL!" }
        if accuracy >= 0.5 { return "KEEP PRACTICING" }
        return "NEEDS MORE FOCUS"
    }
    
    var performanceColor: Color {
        let accuracy = ignoredCount + tappedCount > 0 ? Double(ignoredCount) / Double(ignoredCount + tappedCount) : 0
        if accuracy >= 0.9 { return .yellow }
        if accuracy >= 0.7 { return .green }
        if accuracy >= 0.5 { return .orange }
        return .red
    }
    
    func startGame() {
        score = 0
        timeRemaining = duration
        notifications = []
        ignoredCount = 0
        tappedCount = 0
        isGameOver = false
        showResults = false
        currentPhase = .ready
        
        audioManager.playChallengeStart()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            currentPhase = .playing
        }
    }
    
    func endGame() {
        currentPhase = .result
        isGameOver = true
        audioManager.playChallengeComplete()
        
        // Calculate score
        let baseScore = ignoredCount * 20
        let penalty = tappedCount * 30
        score = max(0, baseScore - penalty)
        
        if score > 0 {
            audioManager.playReward()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showResults = true
        }
    }
    
    func restart() {
        showResults = false
        startGame()
    }
    
    func spawnNotification() {
        let type = FakeNotification.NotificationType.allCases.randomElement()!
        let x = CGFloat.random(in: 50...(250))
        let y = CGFloat.random(in: 80...(200))
        
        var notification = FakeNotification(type: type, x: x, y: y)
        notification.opacity = 0
        notification.scale = 0
        notifications.append(notification)
        
        // Animate in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[index].opacity = 1
                notifications[index].scale = 1
            }
        }
        
        // Auto dismiss after delay (if ignored)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            handleNotificationDismiss(notification)
        }
    }
    
    func cleanupNotifications() {
        let now = Date()
        notifications.removeAll { now.timeIntervalSince($0.appearedAt) > 4 }
    }
    
    func handleNotificationTap(_ notification: FakeNotification) {
        guard currentPhase == .playing else { return }
        
        tappedCount += 1
        audioManager.playError()
        
        // Remove notification
        withAnimation {
            notifications.removeAll { $0.id == notification.id }
        }
        
        // Penalty
        score -= 10
    }
    
    func handleNotificationDismiss(_ notification: FakeNotification) {
        guard currentPhase == .playing else { return }
        
        // Check if already tapped
        if !notifications.contains(where: { $0.id == notification.id }) { return }
        
        ignoredCount += 1
        audioManager.success()
        
        // Remove notification
        withAnimation {
            notifications.removeAll { $0.id == notification.id }
        }
    }
}

// MARK: - Notification Popup
struct NotificationPopup: View {
    let notification: FakeNotificationsChallengeView.FakeNotification
    let onTap: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // App icon
                Text(notification.type.appIcon)
                    .font(.system(size: 28))
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(notification.type.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("Tap to view")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(notification.type.color).opacity(0.95))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .frame(width: 240)
        }
        .opacity(notification.opacity)
        .scaleEffect(notification.scale)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: notification.scale)
    }
}

#Preview {
    FakeNotificationsChallengeView()
}
