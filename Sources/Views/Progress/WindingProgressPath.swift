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
            // Deep starfield background with premium gradient
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
                            // Ambient colored orbs at milestone positions
                            ForEach(Array(allChallenges.enumerated()), id: \.element) { idx, ch in
                                if idx % 5 == 4 {
                                    Circle()
                                        .fill(ch.color.opacity(isCompleted(ch) ? 0.12 : 0.05))
                                        .frame(width: 240, height: 240)
                                        .position(
                                            x: w / 2 + xOffset(for: idx, in: w),
                                            y: CGFloat(idx) * nodeSpacing + 150
                                        )
                                        .blur(radius: 45)
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

            // Stats bar overlay at top with glass morphism
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
        ZStack {
            // Glow layer for completed paths
            if done {
                Path { p in
                    p.move(to: from)
                    let mid = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
                    let ctrl1 = CGPoint(x: (from.x + mid.x) / 2, y: from.y + 30)
                    let ctrl2 = CGPoint(x: (mid.x + to.x) / 2,   y: to.y - 30)
                    p.addCurve(to: to, control1: ctrl1, control2: ctrl2)
                }
                .stroke(
                    LinearGradient(colors: [color.opacity(0.4), color.opacity(0.15)], startPoint: .top, endPoint: .bottom),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .blur(radius: 8)
            }

            // Main line
            Path { p in
                p.move(to: from)
                let mid = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
                let ctrl1 = CGPoint(x: (from.x + mid.x) / 2, y: from.y + 30)
                let ctrl2 = CGPoint(x: (mid.x + to.x) / 2,   y: to.y - 30)
                p.addCurve(to: to, control1: ctrl1, control2: ctrl2)
            }
            .stroke(
                done
                    ? LinearGradient(colors: [color.opacity(0.85), color.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                    : LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.08)], startPoint: .top, endPoint: .bottom),
                style: StrokeStyle(lineWidth: done ? 5 : 3, lineCap: .round, dash: done ? [] : [8, 6])
            )
        }
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
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(category.rawValue.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(color)
                    .tracking(1.2)

                Text("\(category.letterCount) letters")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(color.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.5), color.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 4)
    }
}

// Helper extension to get letter count for category (mock implementation)
extension ChallengeCategory {
    var letterCount: Int {
        switch self {
        case .focus: return 24
        case .memory: return 28
        case .reaction: return 32
        case .breathing: return 20
        case .discipline: return 26
        }
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
    @State private var pulseScale: CGFloat = 1.0

    var nodeSize: CGFloat { isMilestone ? 76 : 68 }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Completed Node: Gold liquid glass with glow
                if completed {
                    // Outer glow layers
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.yellow.opacity(0.3),
                                    Color.orange.opacity(0.1),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: nodeSize / 2,
                                endRadius: nodeSize / 2 + 30
                            )
                        )
                        .frame(width: nodeSize + 60, height: nodeSize + 60)

                    // Main gold gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFD700"),
                                    Color(hex: "FFA500")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: nodeSize, height: nodeSize)
                        .overlay(
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: nodeSize / 2.5, height: nodeSize / 2.5)
                                .offset(x: -nodeSize / 5, y: -nodeSize / 5)
                        )
                        .shadow(color: Color.yellow.opacity(0.6), radius: 16, x: 0, y: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )

                    // Checkmark with glow
                    Image(systemName: "checkmark")
                        .font(.system(size: isMilestone ? 32 : 28, weight: .black))
                        .foregroundColor(.black.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.3), radius: 4)
                }

                // Current/Active Node: Vibrant with pulsing ring
                else if current && unlocked {
                    // Pulsing outer rings
                    Circle()
                        .stroke(challenge.color.opacity(0.3), lineWidth: 8)
                        .frame(width: nodeSize + 32, height: nodeSize + 32)
                        .scaleEffect(pulseScale)
                        .opacity(2.0 - pulseScale)
                        .animation(
                            Animation.easeOut(duration: 1.2).repeatForever(autoreverses: false),
                            value: pulsing
                        )

                    Circle()
                        .stroke(challenge.color.opacity(0.2), lineWidth: 5)
                        .frame(width: nodeSize + 16, height: nodeSize + 16)

                    // Main colored gradient with depth
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    challenge.color,
                                    challenge.color.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: nodeSize, height: nodeSize)
                        .overlay(
                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: nodeSize / 2.8, height: nodeSize / 2.8)
                                .offset(x: -nodeSize / 5, y: -nodeSize / 5)
                        )
                        .shadow(color: challenge.color.opacity(0.7), radius: 18, x: 0, y: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.6), lineWidth: 2.5)
                        )

                    // Challenge icon
                    Image(systemName: challenge.icon)
                        .font(.system(size: isMilestone ? 32 : 28, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: challenge.color.opacity(0.5), radius: 6)
                }

                // Locked Node: Dark glass with subtle details
                else if !unlocked {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: nodeSize, height: nodeSize)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.12), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 8)

                    Image(systemName: "lock.fill")
                        .font(.system(size: isMilestone ? 24 : 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.3))
                }

                // Milestone-specific enhancements
                if isMilestone {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.3),
                                    Color.cyan.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: nodeSize + 8, height: nodeSize + 8)

                    // Crown accent for locked milestones
                    if !completed && !unlocked {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.yellow.opacity(0.4))
                            .offset(y: -nodeSize / 2 - 10)
                    }
                }
            }
            .onAppear {
                if current {
                    pulsing = true
                }
            }
        }
        .disabled(!unlocked)
        .overlay(alignment: .bottom) {
            VStack(spacing: 3) {
                Text(challenge.rawValue)
                    .font(.system(size: 10, weight: unlocked ? .semibold : .regular))
                    .foregroundColor(unlocked ? .white.opacity(0.9) : .white.opacity(0.25))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 95)

                if unlocked && !completed {
                    HStack(spacing: 3) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.cyan)

                        Text("+\(challenge.gemReward)")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.cyan.opacity(0.8))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.cyan.opacity(0.1))
                    .cornerRadius(4)
                }
            }
            .offset(y: nodeSize / 2 + 18)
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
        VStack(spacing: 0) {
            // Spacer for status bar
            Spacer()
                .frame(height: 58)

            HStack(spacing: 12) {
                // Progress stat pill
                StatPillCompact(
                    icon: "checkmark.circle.fill",
                    value: "\(completed)/\(total)",
                    label: "Progress",
                    color: .green
                )

                // Gems stat pill
                StatPillCompact(
                    icon: "diamond.fill",
                    value: "\(gems)",
                    label: "Gems",
                    color: .cyan
                )

                // Streak stat pill
                StatPillCompact(
                    icon: "flame.fill",
                    value: "\(streak)d",
                    label: "Streak",
                    color: .orange
                )

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .liquidGlass(tint: .white, cornerRadius: 20, showBorder: true)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.2), Color.black.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Compact Stat Pill
struct StatPillCompact: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)

                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(color.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    WindingProgressPath().environmentObject(AppState())
}
