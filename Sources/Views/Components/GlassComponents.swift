import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let glassBorder      = Color.white.opacity(0.18)
    static let glassBackground  = Color.white.opacity(0.08)
    static let glassHighlight   = Color.white.opacity(0.22)
    static let liquidSurface    = Color.white.opacity(0.06)
    static let deepBackground   = Color(hex: "06060F")
}

// MARK: - Liquid Glass Modifier
struct LiquidGlassModifier: ViewModifier {
    let tint: Color
    let cornerRadius: CGFloat
    let showBorder: Bool

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base material blur
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)

                    // Tint overlay
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.08), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Specular inner highlight at top
                    VStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.18), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: cornerRadius * 2)
                        Spacer(minLength: 0)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: showBorder
                                ? [Color.white.opacity(0.28), tint.opacity(0.25), Color.white.opacity(0.06)]
                                : [Color.clear, Color.clear, Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 6)
            .shadow(color: tint.opacity(0.08), radius: 12)
    }
}

extension View {
    func liquidGlass(tint: Color = .purple, cornerRadius: CGFloat = 22, showBorder: Bool = true) -> some View {
        modifier(LiquidGlassModifier(tint: tint, cornerRadius: cornerRadius, showBorder: showBorder))
    }
}

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: Content
    let intensity: CGFloat
    let tint: Color
    let cornerRadius: CGFloat
    let showBorder: Bool

    init(
        intensity: CGFloat = 20,
        tint: Color = .purple,
        cornerRadius: CGFloat = 22,
        showBorder: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.intensity = intensity
        self.tint = tint
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
    }

    var body: some View {
        content
            .padding(20)
            .liquidGlass(tint: tint, cornerRadius: cornerRadius, showBorder: showBorder)
    }
}

// MARK: - Interactive Glass Card
struct InteractiveGlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let tint: Color
    let action: () -> Void

    @State private var isPressed = false

    init(
        cornerRadius: CGFloat = 22,
        tint: Color = .purple,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            content
                .padding(20)
                .liquidGlass(tint: tint, cornerRadius: cornerRadius)
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }
}

// MARK: - Glass Button
struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isDisabled: Bool
    let isLoading: Bool
    let tint: Color

    @State private var isPressed = false

    init(
        title: String,
        icon: String? = nil,
        isDisabled: Bool = false,
        isLoading: Bool = false,
        tint: Color = .purple,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.tint = tint
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.85)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(isDisabled ? .gray : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: isDisabled
                                    ? [Color.gray.opacity(0.15), Color.gray.opacity(0.08)]
                                    : [tint.opacity(0.55), tint.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    // Specular top shine
                    VStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.clear],
                                    startPoint: .top, endPoint: .center
                                )
                            )
                            .frame(height: 32)
                        Spacer(minLength: 0)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: isDisabled
                                ? [Color.gray.opacity(0.2), Color.clear]
                                : [Color.white.opacity(0.3), tint.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: isDisabled ? .clear : tint.opacity(0.35), radius: isPressed ? 8 : 14, y: isPressed ? 2 : 5)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .disabled(isDisabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isDisabled { isPressed = true } }
                .onEnded   { _ in isPressed = false }
        )
    }
}

// MARK: - Glass Text Field
struct GlassTextField: View {
    let placeholder: String
    let icon: String?
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isFocused ? .purple : .gray)
                    .frame(width: 22)
            }
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .keyboardType(keyboardType)
                    .focused($isFocused)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(isFocused ? 0.06 : 0.03))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused
                        ? LinearGradient(colors: [Color.purple.opacity(0.8), Color.indigo.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.white.opacity(0.18), Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: isFocused ? 1.5 : 1
                )
        )
        .shadow(color: isFocused ? .purple.opacity(0.2) : .clear, radius: 8)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Glass Toggle
struct GlassToggle: View {
    let title: String
    let icon: String?
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            if let icon = icon {
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(isOn ? Color.purple.opacity(0.25) : Color.white.opacity(0.08))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(isOn ? .purple : .gray)
                }
                .animation(.easeInOut(duration: 0.2), value: isOn)
            }
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.purple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .opacity(0.7)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

// MARK: - Redesigned Glass Tab Button
struct GlassTabButton: View {
    let tab: AppState.Tab
    let isActive: Bool
    let action: () -> Void

    var accentColor: Color {
        switch tab {
        case .home:       return .purple
        case .path:       return .cyan
        case .screenTime: return .orange
        case .practice:   return .green
        case .profile:    return .pink
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isActive {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [accentColor.opacity(0.4), accentColor.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 46, height: 30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.3), accentColor.opacity(0.5)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: accentColor.opacity(0.45), radius: 8, y: 2)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 19, weight: isActive ? .semibold : .regular))
                        .foregroundColor(isActive ? .white : .gray.opacity(0.55))
                        .scaleEffect(isActive ? 1.06 : 1.0)
                }
                .frame(height: 30)

                Text(tab.rawValue)
                    .font(.system(size: 9.5, weight: isActive ? .semibold : .medium))
                    .foregroundColor(isActive ? .white : .gray.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isActive)
    }
}

// MARK: - Glass Progress Bar
struct GlassProgressBar: View {
    let progress: Double
    let height: CGFloat
    let gradientColors: [Color]
    let showPercentage: Bool
    let glowColor: Color?

    init(
        progress: Double,
        height: CGFloat = 8,
        gradientColors: [Color] = [.purple, .indigo],
        showPercentage: Bool = false,
        glowColor: Color? = nil
    ) {
        self.progress = progress
        self.height = height
        self.gradientColors = gradientColors
        self.showPercentage = showPercentage
        self.glowColor = glowColor
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.white.opacity(0.07))
                        .frame(height: height)

                    // Fill with glow
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(height, geometry.size.width * min(max(progress, 0), 1)), height: height)
                        .shadow(color: (glowColor ?? gradientColors.first ?? .purple).opacity(0.6), radius: 5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

                    // Top shimmer on fill
                    if progress > 0.05 {
                        RoundedRectangle(cornerRadius: height / 2)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.35), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: max(height, geometry.size.width * min(max(progress, 0), 1)), height: height / 2)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                    }
                }
            }
            .frame(height: height)

            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Glass Icon Button
struct GlassIconButton: View {
    let icon: String
    let size: CGFloat
    let tint: Color
    let action: () -> Void

    @State private var isPressed = false

    init(icon: String, size: CGFloat = 44, tint: Color = .purple, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.tint = tint
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    ZStack {
                        Circle().fill(.ultraThinMaterial)
                        Circle().fill(tint.opacity(0.18))
                        // Specular top
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.22), Color.clear],
                                    startPoint: .top, endPoint: .center
                                )
                            )
                    }
                )
                .overlay(Circle().stroke(tint.opacity(0.4), lineWidth: 1))
                .shadow(color: tint.opacity(0.3), radius: 8)
                .scaleEffect(isPressed ? 0.93 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }
}

// MARK: - Skeleton Loader
struct SkeletonLoader: View {
    @State private var phase: CGFloat = -1

    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    init(width: CGFloat? = nil, height: CGFloat = 20, cornerRadius: CGFloat = 8) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.white.opacity(0.06))
            .frame(width: width, height: height)
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [Color.clear, Color.white.opacity(0.15), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: phase * geo.size.width * 1.5)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            )
            .onAppear {
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

// MARK: - Glass Badge
struct GlassBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                ZStack {
                    Capsule().fill(.ultraThinMaterial)
                    Capsule().fill(color.opacity(0.25))
                }
            )
            .overlay(Capsule().stroke(color.opacity(0.5), lineWidth: 1))
            .shadow(color: color.opacity(0.3), radius: 6)
    }
}

// MARK: - Glass Divider
struct GlassDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.clear, Color.white.opacity(0.1), Color.clear],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
}

// MARK: - Glass Progress Ring
struct GlassProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradientColors: [Color]
    let size: CGFloat

    init(
        progress: Double,
        lineWidth: CGFloat = 6,
        gradientColors: [Color] = [.purple, .cyan],
        size: CGFloat = 60
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.gradientColors = gradientColors
        self.size = size
    }

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .stroke((gradientColors.first ?? .purple).opacity(0.15), lineWidth: lineWidth + 4)
                .blur(radius: 4)

            // Track
            Circle()
                .stroke(Color.white.opacity(0.07), lineWidth: lineWidth)

            // Fill
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: gradientColors,
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(360 * progress - 90)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

            // End dot glow
            if progress > 0.02 {
                Circle()
                    .fill(gradientColors.last ?? .cyan)
                    .frame(width: lineWidth + 2, height: lineWidth + 2)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(360 * progress - 90))
                    .shadow(color: (gradientColors.last ?? .cyan).opacity(0.9), radius: 4)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Floating Background Orb
struct FloatingOrb: View {
    let color: Color
    let size: CGFloat
    let blur: CGFloat
    let opacity: Double

    var body: some View {
        Circle()
            .fill(color.opacity(opacity))
            .frame(width: size, height: size)
            .blur(radius: blur)
            .allowsHitTesting(false)
    }
}

// MARK: - Liquid Glass Stat Pill
struct StatPill: View {
    let icon: String
    let value: String
    let color: Color
    let action: (() -> Void)?

    init(icon: String, value: String, color: Color, action: (() -> Void)? = nil) {
        self.icon = icon
        self.value = value
        self.color = color
        self.action = action
    }

    var body: some View {
        Group {
            if let action {
                Button(action: action) { pillContent }
                    .buttonStyle(PlainButtonStyle())
            } else {
                pillContent
            }
        }
    }

    private var pillContent: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(
            ZStack {
                Capsule().fill(.ultraThinMaterial)
                Capsule().fill(color.opacity(0.14))
                // Specular
                VStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.clear],
                                startPoint: .top, endPoint: .center
                            )
                        )
                        .frame(height: 14)
                    Spacer(minLength: 0)
                }
                .clipShape(Capsule())
            }
        )
        .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 1))
        .shadow(color: color.opacity(0.25), radius: 6)
    }
}

// MARK: - Shimmer Modifier
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [Color.clear, Color.white.opacity(0.25), Color.clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + geometry.size.width * 2 * phase)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer(isActive: Bool = true) -> some View {
        if isActive {
            return AnyView(modifier(ShimmerModifier()))
        } else {
            return AnyView(self)
        }
    }
}

// MARK: - Loading Placeholders
struct ShimmerPlaceholder: View {
    let width: CGFloat?
    let height: CGFloat

    init(width: CGFloat? = nil, height: CGFloat = 20) {
        self.width = width
        self.height = height
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white.opacity(0.07))
            .frame(width: width, height: height)
            .shimmer()
    }
}

struct LoadingCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ShimmerPlaceholder(width: 44, height: 44).clipShape(Circle())
                VStack(alignment: .leading, spacing: 6) {
                    ShimmerPlaceholder(width: 120, height: 14)
                    ShimmerPlaceholder(width: 80, height: 11)
                }
                Spacer()
            }
            ShimmerPlaceholder(height: 12).frame(maxWidth: .infinity)
            ShimmerPlaceholder(width: 140, height: 12)
        }
        .padding(18)
        .liquidGlass(tint: .purple, cornerRadius: 20)
    }
}

// MARK: - Confetti
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animationTrigger = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle, animationTrigger: animationTrigger)
                }
            }
            .onAppear {
                createParticles(count: 60, in: geometry.size)
                animationTrigger = true
            }
        }
        .allowsHitTesting(false)
    }

    func createParticles(count: Int, in size: CGSize) {
        particles = (0..<count).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                color: [Color.purple, .cyan, .yellow, .green, .pink, .orange].randomElement()!,
                size: CGFloat.random(in: 7...13),
                rotation: Double.random(in: 0...360),
                duration: Double.random(in: 2...4)
            )
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var size: CGFloat
    var rotation: Double
    var duration: Double
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    let animationTrigger: Bool
    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 1.5)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                position = CGPoint(x: particle.x, y: particle.y)
                withAnimation(.easeIn(duration: particle.duration)) {
                    position = CGPoint(x: particle.x + CGFloat.random(in: -100...100), y: UIScreen.main.bounds.height + 50)
                    rotation = particle.rotation + Double.random(in: 180...540)
                }
                withAnimation(.linear(duration: particle.duration * 0.8).delay(particle.duration * 0.2)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "06060F"), Color(hex: "0A0F1C"), Color(hex: "0D1526")],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 20) {
                GlassCard(tint: .purple) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Liquid Glass Card").font(.headline).foregroundColor(.white)
                        Text("With specular highlight").font(.subheadline).foregroundColor(.gray)
                    }
                }

                GlassButton(title: "Start Training", icon: "brain.head.profile") {}
                GlassButton(title: "Loading...", isLoading: true) {}

                GlassTextField(placeholder: "Enter your name", icon: "person.fill", text: .constant(""))

                GlassProgressBar(progress: 0.72, showPercentage: true, glowColor: .purple)
                    .padding(.horizontal)

                GlassProgressRing(progress: 0.65, size: 70)

                HStack(spacing: 12) {
                    StatPill(icon: "flame.fill", value: "12", color: .orange)
                    StatPill(icon: "diamond.fill", value: "340", color: .cyan)
                    StatPill(icon: "heart.fill", value: "5/5", color: .red)
                }

                HStack {
                    GlassIconButton(icon: "plus", action: {})
                    GlassIconButton(icon: "heart.fill", tint: .red, action: {})
                    GlassIconButton(icon: "star.fill", tint: .yellow, action: {})
                }

                HStack {
                    GlassBadge(text: "New", color: .purple)
                    GlassBadge(text: "Pro", color: .orange)
                    GlassBadge(text: "Level 5", color: .cyan)
                }
            }
            .padding()
        }
    }
}
