import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: ChallengeCategory?
    @State private var showAllChallenges: Bool = false
    @State private var selectedPractice: PracticeOption?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Practice Hub")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(AllChallengeType.allCases.count) exercises across \(ChallengeCategory.allCases.count) categories")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // Quick start row
                quickStartSection
                
                // Category grid
                categoryGrid
            }
            .padding(.bottom, 100)
        }
        .fullScreenCover(item: $selectedPractice) { practice in
            ChallengeView(challenge: practice.challenge)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showAllChallenges) {
            AllChallengesView()
                .environmentObject(appState)
        }
        .sheet(item: $selectedCategory) { category in
            CategoryDetailSheet(category: category, selectedPractice: $selectedPractice)
                .environmentObject(appState)
        }
    }
    
    // MARK: - Quick Start Section
    
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Button {
                showAllChallenges = true
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Browse All Challenges")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("See all \(AllChallengeType.allCases.count) exercises")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Category Grid
    
    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            categoryGridContent
                .padding(.horizontal, 24)
        }
    }
    
    @ViewBuilder
    private var categoryGridContent: some View {
        let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        LazyVGrid(columns: cols, spacing: 12) {
            ForEach(ChallengeCategory.allCases) { category in
                PracticeCategoryCard(category: category) {
                    selectedCategory = category
                }
            }
        }
    }
}

// MARK: - Category Card

struct PracticeCategoryCard: View {
    let category: ChallengeCategory
    let action: () -> Void
    
    private var challengeCount: Int {
        AllChallengeType.allCases.filter { $0.category == category }.count
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(category.categoryColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 18))
                            .foregroundColor(category.categoryColor)
                    }
                    
                    Spacer()
                    
                    Text("\(challengeCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Text(category.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(categorySubtitle(for: category))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(category.categoryColor.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func categorySubtitle(for category: ChallengeCategory) -> String {
        switch category {
        case .focus: return "Train visual focus and attention"
        case .memory: return "Strengthen working memory"
        case .reaction: return "Improve response time"
        case .breathing: return "Calm and regulate breath"
        case .discipline: return "Resist distractions"
        case .speed: return "Sharpen processing speed"
        case .impulse: return "Control impulses and urges"
        case .calm: return "Build mental calm and peace"
        }
    }
}

// MARK: - Category Detail Sheet

struct CategoryDetailSheet: View {
    let category: ChallengeCategory
    @Binding var selectedPractice: PracticeOption?
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    private var challenges: [AllChallengeType] {
        AllChallengeType.allCases.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0A0F1C").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Category header
                        categoryHeader
                        
                        // Challenge list
                        challengeList
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(category.rawValue)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var categoryHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(category.categoryColor.opacity(0.2))
                    .frame(width: 72, height: 72)
                
                Image(systemName: category.icon)
                    .font(.system(size: 30))
                    .foregroundColor(category.categoryColor)
            }
            
            Text(categoryDescription(for: category))
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
    }
    
    private var challengeList: some View {
        VStack(spacing: 10) {
            ForEach(challenges, id: \.self) { challenge in
                ChallengeRow(challenge: challenge) {
                    // Map AllChallengeType to PracticeOption or use a general approach
                    // We treat this as a standalone challenge launch
                    dismiss()
                    // The challenge view is opened directly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appState.selectedChallenge = challenge
                        appState.startChallengeFromPath = true
                    }
                }
            }
        }
    }
    
    private func categoryDescription(for category: ChallengeCategory) -> String {
        switch category {
        case .focus: return "Sharpen your ability to concentrate on tasks and ignore distractions."
        case .memory: return "Build your working memory to hold and manipulate information."
        case .reaction: return "Train your brain to respond quickly to visual and audio cues."
        case .breathing: return "Use controlled breathing to calm your nervous system."
        case .discipline: return "Practice resisting digital distractions and staying on task."
        case .speed: return "Challenge your brain to process information faster."
        case .impulse: return "Learn to pause before acting on impulses."
        case .calm: return "Develop mental tranquility through guided exercises."
        }
    }
}

// MARK: - Challenge Row

struct ChallengeRow: View {
    let challenge: AllChallengeType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(challenge.category.categoryColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: challenge.category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(challenge.category.categoryColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(challenge.rawValue)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                    Text(challenge.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // XP reward badge
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("+\(challenge.xpReward)")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.yellow)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.1))
                )
                
                Image(systemName: "play.fill")
                    .font(.system(size: 12))
                    .foregroundColor(challenge.category.categoryColor)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(challenge.category.categoryColor.opacity(0.15)))
            }
            .padding(14)
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
}

// MARK: - Practice Option (kept for compatibility)

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

#Preview {
    PracticeView()
        .environmentObject(AppState())
        .background(Color.black.ignoresSafeArea())
}