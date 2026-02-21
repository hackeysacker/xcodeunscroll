import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedPractice: PracticeOption?
    @State private var showAllChallenges: Bool = false
    
    let practices = PracticeOption.allCases
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Practice")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 12)
                
                // All Challenges Button
                Button {
                    showAllChallenges = true
                } label: {
                    HStack {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 24))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("All \(AllChallengeType.allCases.count) Challenges")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Browse every exercise")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.white)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .indigo.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                
                // Practice options
                ForEach(practices, id: \.self) { practice in
                    PracticeCard(practice: practice) {
                        selectedPractice = practice
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
        }
        .fullScreenCover(item: $selectedPractice) { practice in
            ChallengeView(challenge: practice.challenge)
                .environmentObject(appState)
        }
        .fullScreenCover(isPresented: $showAllChallenges) {
            AllChallengesView()
                .environmentObject(appState)
        }
        .onChange(of: appState.startChallengeFromPath) { _, newValue in
            if newValue, let challenge = appState.selectedChallenge {
                // Find the practice option that has this challenge
                if let practice = practices.first(where: { $0.challenge == challenge }) {
                    selectedPractice = practice
                    appState.startChallengeFromPath = false
                }
            }
        }
        .onAppear {
            // Check if we need to start a challenge from path
            if appState.startChallengeFromPath, let challenge = appState.selectedChallenge {
                if let practice = practices.first(where: { $0.challenge == challenge }) {
                    selectedPractice = practice
                    appState.startChallengeFromPath = false
                }
            }
        }
    }
}

enum PracticeOption: CaseIterable, Identifiable {
    case attention
    case memory
    case reaction
    case focus
    
    var id: Self { self }
    
    var challenge: AllChallengeType {
        switch self {
        case .attention: return .movingTarget
        case .memory: return .memoryFlash
        case .reaction: return .reactionInhibition
        case .focus: return .focusHold
        }
    }
    
    var name: String {
        switch self {
        case .attention: return "Attention Training"
        case .memory: return "Memory Match"
        case .reaction: return "Reaction Time"
        case .focus: return "Focus Zone"
        }
    }
    
    var description: String {
        switch self {
        case .attention: return "Track moving objects to improve your focus"
        case .memory: return "Remember sequences and patterns"
        case .reaction: return "React quickly to visual stimuli"
        case .focus: return "Maintain concentration under pressure"
        }
    }
    
    var icon: String {
        switch self {
        case .attention: return "eye.fill"
        case .memory: return "brain.head.profile"
        case .reaction: return "bolt.fill"
        case .focus: return "target"
        }
    }
    
    var color: Color {
        switch self {
        case .attention: return .purple
        case .memory: return .blue
        case .reaction: return .orange
        case .focus: return .green
        }
    }
    
    var xpReward: Int {
        switch self {
        case .attention: return 15
        case .memory: return 20
        case .reaction: return 10
        case .focus: return 25
        }
    }
    
    var duration: String {
        switch self {
        case .attention: return "60s"
        case .memory: return "90s"
        case .reaction: return "30s"
        case .focus: return "120s"
        }
    }
}

struct PracticeCard: View {
    let practice: PracticeOption
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(practice.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: practice.icon)
                        .font(.system(size: 24))
                        .foregroundColor(practice.color)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(practice.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(practice.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // XP & Duration
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("+\(practice.xpReward)")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.yellow)
                    
                    Text(practice.duration)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(practice.color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    PracticeView()
        .environmentObject(AppState())
        .background(Color.black.ignoresSafeArea())
}
