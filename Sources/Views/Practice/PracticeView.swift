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

    var categoryColor: Color {
        if let category = selectedCategory {
            return getCategoryColor(category)
        }
        return .purple
    }

    var body: some View {
        ZStack {
            // Background with ambient glow
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            // Ambient glow orbs
            Circle()
                .fill(categoryColor.opacity(0.08))
                .blur(radius: 80)
                .frame(width: 300, height: 300)
                .position(x: -50, y: -100)
                .ignoresSafeArea()

            Circle()
                .fill(categoryColor.opacity(0.06))
                .blur(radius: 100)
                .frame(width: 250, height: 250)
                .position(x: 350, y: 200)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Header Section ──
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Practice")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.white)

                                Text("\(AllChallengeType.allCases.count) challenges across 5 skills")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // Completed badge with glass effect
                            VStack(spacing: 4) {
                                Text("\(completedSet.count)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.yellow)

                                Text("completed")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 58)
                    .padding(.bottom, 20)

                    // ── Search Bar with Glass Effect ──
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.purple)

                        TextField("Search challenges…", text: $searchText)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .tint(.purple)

                        if !searchText.isEmpty {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    searchText = ""
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.purple.opacity(0.6))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.5),
                                    Color.purple.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        ))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 22)
                    .padding(.bottom, 20)

                    // ── Category Filter Pills ──
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            PracticeCategoryPill(
                                label: "All",
                                icon: "square.grid.2x2.fill",
                                color: .white,
                                active: selectedCategory == nil
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedCategory = nil
                                }
                            }

                            ForEach(ChallengeCategory.allCases, id: \.self) { cat in
                                PracticeCategoryPill(
                                    label: cat.rawValue,
                                    icon: cat.icon,
                                    color: getCategoryColor(cat),
                                    active: selectedCategory == cat
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedCategory = selectedCategory == cat ? nil : cat
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 22)
                    }
                    .padding(.bottom, 24)

                    // ── Challenge Grid ──
                    if filteredChallenges.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 44, weight: .thin))
                                .foregroundColor(.gray.opacity(0.4))

                            VStack(spacing: 6) {
                                Text("No challenges found")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)

                                Text("Try adjusting your filters or search terms")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)
                    } else {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 14),
                                GridItem(.flexible(), spacing: 14)
                            ],
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

                    Spacer().frame(height: 120)
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

    func getCategoryColor(_ cat: ChallengeCategory) -> Color {
        switch cat {
        case .focus:      return .purple
        case .memory:     return .blue
        case .reaction:   return .orange
        case .breathing:  return .green
        case .discipline: return .red
        }
    }
}

// MARK: - Category Pill with Liquid Glass
struct PracticeCategoryPill: View {
    let label: String
    let icon: String
    let color: Color
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))

                Text(label)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(active ? .white : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background {
                if active {
                    // Active state: gradient background with glow
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color,
                            color.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(Capsule())
                } else {
                    // Inactive state: glass material
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay(
                Capsule()
                    .stroke(
                        active ? color.opacity(0.6) : color.opacity(0.4),
                        lineWidth: active ? 1.5 : 1
                    )
            )
            .shadow(
                color: active ? color.opacity(0.4) : Color.clear,
                radius: active ? 8 : 0,
                x: 0,
                y: active ? 4 : 0
            )
        }
        .scaleEffect(active ? 1.02 : 1.0)
    }
}

// MARK: - Practice Card with Liquid Glass
struct PracticeCard: View {
    let challenge: AllChallengeType
    let isCompleted: Bool
    let action: () -> Void

    @GestureState private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                // Card background
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        challenge.color.opacity(0.4),
                                        challenge.color.opacity(0.15)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: challenge.color.opacity(0.2),
                        radius: 12,
                        x: 0,
                        y: 6
                    )

                // Completed overlay
                if isCompleted {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.4))
                }

                VStack(alignment: .leading, spacing: 10) {
                    // Icon in glass square
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(challenge.color.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(challenge.color.opacity(0.4), lineWidth: 1)
                                )

                            Image(systemName: challenge.icon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(challenge.color)
                        }
                        .frame(width: 50, height: 50)

                        Spacer()

                        // Completed checkmark
                        if isCompleted {
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .yellow.opacity(0.5), radius: 4)

                                Spacer()
                            }
                        }
                    }

                    // Challenge name
                    Text(challenge.rawValue)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    // Category tag as small pill
                    HStack(spacing: 4) {
                        Circle()
                            .fill(challenge.color)
                            .frame(width: 4, height: 4)

                        Text(challenge.category.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(challenge.color)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                    Spacer()

                    // Difficulty indicator (dots)
                    HStack(spacing: 4) {
                        ForEach(0..<min(challenge.difficulty, 3), id: \.self) { _ in
                            Circle()
                                .fill(challenge.color.opacity(0.7))
                                .frame(width: 5, height: 5)
                        }

                        if challenge.difficulty < 3 {
                            ForEach(0..<(3 - challenge.difficulty), id: \.self) { _ in
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 5, height: 5)
                            }
                        }

                        Spacer()

                        Text("\(challenge.duration)s")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    // Rewards
                    HStack(spacing: 8) {
                        HStack(spacing: 3) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)

                            Text("+\(challenge.xpReward)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                        if challenge.gemReward > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.cyan)

                                Text("+\(challenge.gemReward)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.cyan)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }

                        Spacer()
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
            }
            .opacity(isCompleted ? 0.7 : 1.0)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .brightness(isCompleted ? -0.1 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .gesture(
            LongPressGesture(minimumDuration: 0.001)
                .updating($isPressed) { value, state, _ in
                    state = value
                }
        )
    }
}

#Preview {
    PracticeView().environmentObject(AppState()).background(Color.black.ignoresSafeArea())
}
