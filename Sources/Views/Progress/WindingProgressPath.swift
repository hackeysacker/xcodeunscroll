import SwiftUI

// MARK: - Winding Progress Path (Duolingo-style, 25 nodes)
struct WindingProgressPath: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedChallenge: AllChallengeType? = nil
    @State private var showChallenge: Bool = false

    let allChallenges = AllChallengeType.allCases
    let nodeSpacing: CGFloat = 140

    var completedSet: Set<String> {
        Set(appState.progress?.completedChallenges.map { $0.challengeTypeRaw } ?? [])
    }

    func isCompleted(_ ch: AllChallengeType) -> Bool { completedSet.contains(ch.rawValue) }
    func isUnlocked(_ i: Int) -> Bool { i == 0 || isCompleted(allChallenges[i - 1]) }
    func isCurrent(_ i: Int) -> Bool { isUnlocked(i) && !isCompleted(allChallenges[i]) }

    func xOffset(for index: Int, in width: CGFloat) -> CGFloat {
        // More pronounced S-curve with varied amplitude for visual interest
        let base = CGFloat(sin(Double(index) * 0.95 + 0.2)) * width * 0.30
        let extra = CGFloat(cos(Double(index) * 0.45)) * width * 0.06
        return base + extra
    }

    var completedCount: Int { allChallenges.filter { isCompleted($0) }.count }

    var body: some View {
        ZStack(alignment: .top) {
            // Deep starfield background
            LinearGradient(
                colors: [Color(hex: "06060F"), Color(hex: "0A0F1C"), Color(hex: "0D1526")],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    GeometryReader { geo in
                        let w = geo.size.width
                        let totalH = CGFloat(allChallenges.count) * nodeSpacing + 280

                        ZStack {
                            // Ambient background glows at milestones
                            ForEach(Array(allChallenges.enumerated()), id: \.element) { idx, ch in
                                if idx % 5 == 4 {
                                    Circle()
                                        .fill(ch.color.opacity(isCompleted(ch) ? 0.08 : 0.03))
                                        .frame(width: 200, height: 200)
                                        .position(
                                            x: w / 2 + xOffset(for: idx, in: w),
                                            y: CGFloat(idx) * nodeSpacing + 150
                                        )
                                        .blur(radius: 30)
                                }
                            }

                            // Path lines (drawn bottom-to-top so lower nodes appear on top)
                            ForEach(0..<allChallenges.count - 1, id: \.self) { i in
                                WPLine(
                                    from: CGPoint(x: w / 2 + xOffset(for: i,   in: w), y: CGFloat(i)   * nodeSpacing + 150),
                                    to:   CGPoint(x: w / 2 + xOffset(for: i+1, in: w), y: CGFloat(i+1) * nodeSpacing + 150),
                                    done: isCompleted(allChallenges[i]),
                                    color: allChallenges[i].color
                                )
                            }

                            // Category banners — one per category at its first node
                            ForEach(Array(ChallengeCategory.allCases.enumerated()), id: \.element) { _, cat in
                                if let firstIdx = allChallenges.firstIndex(where: { $0.category == cat }) {
                                    WPBanner(category: cat)
                                        .position(x: w / 2, y: CGFloat(firstIdx) * nodeSpacing + 80)
                                }
                            }

                            // Nodes
                            ForEach(Array(allChallenges.enumerated()), id: \.element) { idx, ch in
                                WPNode(
                                    challenge: ch,
                                    completed: isCompleted(ch),
                                    unlocked: isUnlocked(idx),
                                    current: isCurrent(idx),
                                    isMilestone: idx % 5 == 4
                                ) {
                                    if isUnlocked(idx) {
                                        selectedChallenge = ch
                                        showChallenge = true
                                    }
                                }
                                .position(
                                    x: w / 2 + xOffset(for: idx, in: w),
                                    y: CGFloat(idx) * nodeSpacing + 150
                                )
                                .id(idx)
                            }
                        }
                        .frame(width: w, height: totalH)
                    }
                    .frame(height: CGFloat(allChallenges.count) * nodeSpacing + 280)
                }
                .onAppear {
                    let cur = min(max(0, completedCount), allChallenges.count - 1)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation { proxy.scrollTo(cur, anchor: .center) }
                    }
                }
            }

            // Stats bar overlay at top
            VStack {
                WPStatsBar(
                    completed: completedCount,
                    total: allChallenges.count,
                    gems: appState.progress?.gems ?? 0,
                    streak: appState.progress?.streakDays ?? 0
                )
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showChallenge) {
            if let ch = selectedChallenge {
                UniversalChallengeView(challenge: ch).environmentObject(appState)
            }
        }
    }
}

// MARK: - Path Line
struct WPLine: View {
    let from: CGPoint
    let to: CGPoint
    let done: Bool
    let color: Color

    var body: some View {
        Path { p in
            p.move(to: from)
            let mid = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
            let ctrl1 = CGPoint(x: (from.x + mid.x) / 2, y: from.y + 30)
            let ctrl2 = CGPoint(x: (mid.x + to.x) / 2,   y: to.y - 30)
            p.addCurve(to: to, control1: ctrl1, control2: ctrl2)
        }
        .stroke(
            done
                ? LinearGradient(colors: [color.opacity(0.75), color.opacity(0.45)], startPoint: .top, endPoint: .bottom)
                : LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom),
            style: StrokeStyle(lineWidth: done ? 4.5 : 3, lineCap: .round, dash: done ? [] : [8, 6])
        )
    }
}

// MARK: - Section Banner
struct WPBanner: View {
    let category: ChallengeCategory

    var color: Color {
        switch category {
        case .focus:      return .purple
        case .memory:     return .blue
        case .reaction:   return .orange
        case .breathing:  return .green
        case .discipline: return .red
        }
    }

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: category.icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
            Text(category.rawValue.uppercased())
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(color)
                .tracking(1.5)
        }
        .padding(.horizontal, 14).padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 1.5))
        )
        .shadow(color: color.opacity(0.2), radius: 8)
    }
}

// MARK: - Node
struct WPNode: View {
    let challenge: AllChallengeType
    let completed: Bool
    let unlocked: Bool
    let current: Bool
    let isMilestone: Bool
    let onTap: () -> Void

    @State private var pulsing = false
    @State private var shimmer = false

    var nodeSize: CGFloat { isMilestone ? 76 : 68 }

    var fillColor: Color {
        if completed { return .yellow }
        if unlocked  { return challenge.color }
        return Color.white.opacity(0.06)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Outer pulse ring for current node
                if current {
                    Circle()
                        .stroke(challenge.color.opacity(0.25), lineWidth: 6)
                        .frame(width: nodeSize + 24, height: nodeSize + 24)
                        .scaleEffect(pulsing ? 1.35 : 1.0)
                        .opacity(pulsing ? 0 : 0.8)
                        .animation(.easeOut(duration: 1.3).repeatForever(autoreverses: false), value: pulsing)
                        .onAppear { pulsing = true }

                    Circle()
                        .stroke(challenge.color.opacity(0.15), lineWidth: 3)
                        .frame(width: nodeSize + 8, height: nodeSize + 8)
                }

                // Milestone glow
                if isMilestone && (completed || unlocked) {
                    Circle()
                        .fill(fillColor.opacity(0.25))
                        .frame(width: nodeSize + 20, height: nodeSize + 20)
                        .blur(radius: 8)
                }

                // Main circle
                Circle()
                    .fill(
                        completed
                            ? LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : unlocked
                                ? LinearGradient(colors: [challenge.color, challenge.color.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.04)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: nodeSize, height: nodeSize)
                    .shadow(color: fillColor.opacity(completed || unlocked ? 0.5 : 0), radius: 14)
                    .overlay(
                        Circle()
                            .stroke(
                                completed ? Color.yellow.opacity(0.4) :
                                unlocked ? challenge.color.opacity(0.5) :
                                Color.white.opacity(0.08),
                                lineWidth: isMilestone ? 2.5 : 1.5
                            )
                    )

                // Icon
                Group {
                    if completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: isMilestone ? 28 : 24, weight: .black))
                            .foregroundColor(.black.opacity(0.8))
                    } else if unlocked {
                        Image(systemName: challenge.icon)
                            .font(.system(size: isMilestone ? 30 : 26))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.2))
                    }
                }

                // Milestone crown
                if isMilestone && !completed && !unlocked {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow.opacity(0.3))
                        .offset(y: -nodeSize / 2 - 6)
                }
            }
        }
        .disabled(!unlocked)
        .overlay(alignment: .bottom) {
            VStack(spacing: 2) {
                Text(challenge.rawValue)
                    .font(.system(size: 10, weight: unlocked ? .semibold : .regular))
                    .foregroundColor(unlocked ? .white.opacity(0.85) : .white.opacity(0.2))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 90)
                if unlocked && !completed {
                    HStack(spacing: 2) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 7))
                            .foregroundColor(.cyan.opacity(0.7))
                        Text("+\(challenge.gemReward)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.cyan.opacity(0.7))
                    }
                }
            }
            .offset(y: nodeSize / 2 + 16)
        }
    }
}

// MARK: - Stats Bar
struct WPStatsBar: View {
    let completed: Int
    let total: Int
    let gems: Int
    let streak: Int

    var body: some View {
        HStack(spacing: 0) {
            statItem(value: "\(completed)/\(total)", label: "unlocked", icon: "checkmark.circle.fill", color: .green)
            divider
            statItem(value: "\(gems)", label: "gems", icon: "diamond.fill", color: .cyan)
            divider
            statItem(value: "\(streak)d", label: "streak", icon: "flame.fill", color: .orange)
        }
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    var divider: some View {
        Rectangle().fill(Color.white.opacity(0.1)).frame(width: 1, height: 26)
    }

    func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).foregroundColor(color).font(.system(size: 13))
            VStack(alignment: .leading, spacing: 0) {
                Text(value).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                Text(label).font(.system(size: 9)).foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WindingProgressPath().environmentObject(AppState())
}
