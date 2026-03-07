import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedChallenge: AllChallengeType?
    @State private var selectedCategory: ChallengeCategory? = nil
    @State private var searchText: String = ""

    var completedSet: Set<String> {
        Set(appState.progress?.completedChallenges.map { $0.challengeTypeRaw } ?? [])
    }

    var filteredChallenges: [AllChallengeType] {
        var list = AllChallengeType.allCases
        if let cat = selectedCategory { list = list.filter { $0.category == cat } }
        if !searchText.isEmpty {
            list = list.filter { $0.rawValue.localizedCaseInsensitiveContains(searchText) ||
                                  $0.description.localizedCaseInsensitiveContains(searchText) }
        }
        return list
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Header ──
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Practice")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(AllChallengeType.allCases.count) challenges across 5 skills")
                                .font(.system(size: 13)).foregroundColor(.gray)
                        }
                        Spacer()
                        // Completed badge
                        VStack(spacing: 2) {
                            Text("\(completedSet.count)")
                                .font(.system(size: 22, weight: .bold)).foregroundColor(.yellow)
                            Text("done").font(.system(size: 10)).foregroundColor(.gray)
                        }
                        .padding(10)
                        .background(Color.yellow.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 22).padding(.top, 16).padding(.bottom, 14)

                    // ── Search bar ──
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray).font(.system(size: 15))
                        TextField("Search challenges…", text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .tint(.purple)
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.gray).font(.system(size: 14))
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 11)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.07)))
                    .padding(.horizontal, 22).padding(.bottom, 14)

                    // ── Category filter pills ──
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            PracticeCategoryPill(label: "All", icon: "square.grid.2x2.fill",
                                         color: .white, active: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(ChallengeCategory.allCases, id: \.self) { cat in
                                PracticeCategoryPill(label: cat.rawValue, icon: cat.icon,
                                             color: categoryColor(cat), active: selectedCategory == cat) {
                                    selectedCategory = selectedCategory == cat ? nil : cat
                                }
                            }
                        }
                        .padding(.horizontal, 22)
                    }
                    .padding(.bottom, 20)

                    // ── Challenge grid ──
                    if filteredChallenges.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass").font(.system(size: 36)).foregroundColor(.gray.opacity(0.5))
                            Text("No challenges found").font(.headline).foregroundColor(.gray)
                        }
                        .padding(.top, 60)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                            spacing: 14
                        ) {
                            ForEach(filteredChallenges) { challenge in
                                PracticeCard(
                                    challenge: challenge,
                                    isCompleted: completedSet.contains(challenge.rawValue)
                                ) {
                                    selectedChallenge = challenge
                                }
                            }
                        }
                        .padding(.horizontal, 22)
                    }

                    Spacer().frame(height: 110)
                }
            }
        }
        .fullScreenCover(item: $selectedChallenge) { challenge in
            UniversalChallengeView(challenge: challenge).environmentObject(appState)
        }
        .onChange(of: appState.startChallengeFromPath) { _, newValue in
            if newValue, let challenge = appState.selectedChallenge {
                selectedChallenge = challenge
                appState.startChallengeFromPath = false
            }
        }
        .onAppear {
            if appState.startChallengeFromPath, let challenge = appState.selectedChallenge {
                selectedChallenge = challenge
                appState.startChallengeFromPath = false
            }
        }
    }

    func categoryColor(_ cat: ChallengeCategory) -> Color {
        switch cat {
        case .focus:      return .purple
        case .memory:     return .blue
        case .reaction:   return .orange
        case .breathing:  return .green
        case .discipline: return .red
        }
    }
}

// MARK: - Category Pill
struct PracticeCategoryPill: View {
    let label: String
    let icon: String
    let color: Color
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12, weight: .semibold))
                Text(label).font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(active ? .black : color.opacity(0.85))
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(active ? color : color.opacity(0.13))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(active ? 0 : 0.3), lineWidth: 1))
        }
    }
}

// MARK: - Practice Card (Grid)
struct PracticeCard: View {
    let challenge: AllChallengeType
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(challenge.color.opacity(0.18))
                            .frame(width: 46, height: 46)
                        Image(systemName: challenge.icon)
                            .font(.system(size: 20))
                            .foregroundColor(challenge.color)
                    }
                    Spacer()
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.yellow)
                    }
                }

                Text(challenge.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(challenge.description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(3)

                Spacer()

                HStack(spacing: 0) {
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill").font(.system(size: 9)).foregroundColor(.yellow)
                        Text("+\(challenge.xpReward) XP")
                            .font(.system(size: 11, weight: .semibold)).foregroundColor(.yellow)
                    }
                    Spacer()
                    Text("\(challenge.duration)s")
                        .font(.system(size: 11)).foregroundColor(.gray)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.05)))
            .overlay(RoundedRectangle(cornerRadius: 18)
                .stroke(isCompleted ? Color.yellow.opacity(0.4) : challenge.color.opacity(0.25), lineWidth: 1.2))
        }
    }
}

#Preview {
    PracticeView().environmentObject(AppState()).background(Color.black.ignoresSafeArea())
}
