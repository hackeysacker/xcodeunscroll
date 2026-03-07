import SwiftUI

// MARK: - Loading View
struct LoadingView: View {
    var message: String = "Loading..."
    var color: Color = .purple
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                // Spinning ring
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                // Inner glow
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 30, height: 30)
            }
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Shimmer Loading Placeholder
struct ShimmerPlaceholder: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.06),
                Color.white.opacity(0.12),
                Color.white.opacity(0.06)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .mask(Rectangle())
        .offset(x: phase)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 300
            }
        }
    }
}

// MARK: - Skeleton Card
struct SkeletonCard: View {
    var height: CGFloat = 100
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.05))
            .frame(height: height)
            .overlay(ShimmerPlaceholder())
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.8))
                        )
                }
                .padding(.top, 8)
            }
        }
        .padding(32)
    }
}

// MARK: - Inline Loading Indicator
struct InlineLoading: View {
    var message: String = "Loading..."
    
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .scaleEffect(0.8)
            
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Pull to Refresh Wrapper
struct PullToRefresh<Content: View>: View {
    let onRefresh: () async -> Void
    let content: Content
    
    @State private var isRefreshing = false
    
    init(
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View {
        content
            .refreshable {
                isRefreshing = true
                await onRefresh()
                isRefreshing = false
            }
    }
}

#Preview("Loading View") {
    ZStack {
        Color(hex: "0A0F1C").ignoresSafeArea()
        LoadingView()
    }
}

#Preview("Empty State") {
    ZStack {
        Color(hex: "0A0F1C").ignoresSafeArea()
        EmptyStateView(
            icon: "tray",
            title: "No Data",
            message: "There's nothing here yet. Start by adding your first item.",
            actionTitle: "Get Started"
        ) {
            print("Action tapped")
        }
    }
}
