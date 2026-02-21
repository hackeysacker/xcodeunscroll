import SwiftUI

// MARK: - All Challenges View
struct AllChallengesView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: ChallengeCategory?
    @State private var selectedChallenge: AllChallengeType?
    
    var filteredChallenges: [AllChallengeType] {
        if let category = selectedCategory {
            return AllChallengeType.allCases.filter { $0.category == category }
        }
        return Array(AllChallengeType.allCases)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("All Challenges")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Category filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryFilterButton(
                            title: "All",
                            icon: "square.grid.2x2",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach(ChallengeCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                title: category.rawValue,
                                icon: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                
                // Count
                HStack {
                    Text("\(filteredChallenges.count) challenges")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                // Challenges grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredChallenges) { challenge in
                            ChallengeGridItem(challenge: challenge) {
                                selectedChallenge = challenge
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .fullScreenCover(item: $selectedChallenge) { challenge in
            UniversalChallengeView(challenge: challenge)
                .environmentObject(appState)
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.purple : Color.white.opacity(0.1))
            )
        }
    }
}

struct ChallengeGridItem: View {
    let challenge: AllChallengeType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(challenge.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: challenge.icon)
                        .font(.system(size: 22))
                        .foregroundColor(challenge.color)
                }
                
                Text(challenge.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text("\(challenge.duration)s")
                        .font(.system(size: 11))
                }
                .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(challenge.color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
