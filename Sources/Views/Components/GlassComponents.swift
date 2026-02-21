import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let glassBorder = Color.white.opacity(0.2)
    static let glassBackground = Color.white.opacity(0.1)
    static let glassHighlight = Color.white.opacity(0.15)
}

// MARK: - Glass Card Component (Enhanced)
struct GlassCard<Content: View>: View {
    let content: Content
    let intensity: CGFloat
    let tint: Color
    let cornerRadius: CGFloat
    let showBorder: Bool
    
    init(
        intensity: CGFloat = 20,
        tint: Color = .purple,
        cornerRadius: CGFloat = 20,
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
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: showBorder ? [tint.opacity(0.5), tint.opacity(0.2)] : [Color.clear, Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: showBorder ? 1 : 0
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Interactive Glass Card (with hover/press states)
struct InteractiveGlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    @State private var isHovered: Bool = false
    
    init(
        cornerRadius: CGFloat = 20,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            content
                .padding(20)
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(isHovered ? 0.95 : 0.8)
                )
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isHovered ? 0.2 : 0.15),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(isHovered ? 0.7 : 0.5),
                                    Color.purple.opacity(isHovered ? 0.4 : 0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isHovered ? 1.5 : 1
                        )
                )
                .shadow(
                    color: .black.opacity(isHovered ? 0.35 : 0.25),
                    radius: isHovered ? 16 : 12,
                    x: 0,
                    y: isHovered ? 6 : 4
                )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = false } }
        )
    }
}

// MARK: - Glass Button (Enhanced with states)
struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isDisabled: Bool
    let isLoading: Bool
    let tint: Color
    
    @State private var isPressed: Bool = false
    
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
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: isDisabled 
                                ? [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
                                : [tint.opacity(0.6), tint.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isDisabled ? Color.gray.opacity(0.3) : tint.opacity(0.5),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isDisabled ? .clear : tint.opacity(0.4),
                radius: isPressed ? 8 : 12,
                x: 0,
                y: isPressed ? 2 : 4
            )
        }
        .disabled(isDisabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isDisabled { withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } } }
                .onEnded { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = false } }
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFocused ? .purple : .gray)
                    .frame(width: 24)
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
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isFocused ? Color.purple : Color.white.opacity(0.2),
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Glass Toggle
struct GlassToggle: View {
    let title: String
    let icon: String?
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isOn ? .purple : .gray)
                    .frame(width: 24)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.purple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Glass Tab Button (Enhanced)
struct GlassTabButton: View {
    let tab: AppState.Tab
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: .medium))
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(isActive ? .white : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color.purple.opacity(0.3) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? Color.purple.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - Glass Progress Bar (Enhanced)
struct GlassProgressBar: View {
    let progress: Double
    let height: CGFloat
    let gradientColors: [Color]
    let showPercentage: Bool
    
    init(
        progress: Double,
        height: CGFloat = 8,
        gradientColors: [Color] = [.purple, .indigo],
        showPercentage: Bool = false
    ) {
        self.progress = progress
        self.height = height
        self.gradientColors = gradientColors
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.white.opacity(0.1))
                    
                    // Progress
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(max(progress, 0), 1))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: height)
            
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Glass Icon Button (Enhanced)
struct GlassIconButton: View {
    let icon: String
    let size: CGFloat
    let tint: Color
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    init(icon: String, size: CGFloat = 44, tint: Color = .purple, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.tint = tint
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.8)
                )
                .overlay(
                    Circle()
                        .stroke(tint.opacity(0.5), lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = false } }
        )
    }
}

// MARK: - Skeleton Loader
struct SkeletonLoader: View {
    @State private var isAnimating: Bool = false
    
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
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .mask(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 300 : -300)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
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
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.3))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.5), lineWidth: 1)
            )
    }
}

// MARK: - Glass Divider
struct GlassDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 1)
    }
}

// MARK: - Animated Progress Ring
struct GlassProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradientColors: [Color]
    let size: CGFloat
    
    init(
        progress: Double,
        lineWidth: CGFloat = 6,
        gradientColors: [Color] = [.purple, .indigo],
        size: CGFloat = 60
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.gradientColors = gradientColors
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: gradientColors,
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * progress)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 24) {
                // Basic Glass Card
                GlassCard {
                    VStack(alignment: .leading) {
                        Text("Glass Card")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("With blur effect")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                // Interactive Glass Card
                InteractiveGlassCard(cornerRadius: 16, action: { }) {
                    VStack(alignment: .leading) {
                        Text("Interactive Card")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Tap me!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                // Buttons
                GlassButton(title: "Start Training", icon: "brain.head.profile") {
                    print("Tapped")
                }
                
                GlassButton(title: "Loading...", isLoading: true) { }
                
                GlassButton(title: "Disabled", isDisabled: true) { }
                
                // TextField
                GlassTextField(placeholder: "Enter your name", icon: "person.fill", text: .constant(""))
                
                // Toggle
                GlassToggle(title: "Notifications", icon: "bell.fill", isOn: .constant(true))
                
                // Progress Bar
                GlassProgressBar(progress: 0.7, showPercentage: true)
                    .padding(.horizontal)
                
                // Progress Ring
                GlassProgressRing(progress: 0.65)
                
                // Icon Buttons
                HStack {
                    GlassIconButton(icon: "plus", action: { })
                    GlassIconButton(icon: "heart.fill", tint: .red, action: { })
                    GlassIconButton(icon: "star.fill", tint: .yellow, action: { })
                }
                
                // Badges
                HStack {
                    GlassBadge(text: "New", color: .purple)
                    GlassBadge(text: "Pro", color: .orange)
                    GlassBadge(text: "Premium", color: .yellow)
                }
                
                // Skeleton
                SkeletonLoader(width: 200, height: 20)
                SkeletonLoader(width: 150, height: 16, cornerRadius: 4)
            }
            .padding()
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animationTrigger: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle, animationTrigger: animationTrigger)
                }
            }
            .onAppear {
                createParticles(count: 50, in: geometry.size)
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
                color: [Color.red, .yellow, .green, .blue, .purple, .orange].randomElement()!,
                size: CGFloat.random(in: 8...14),
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
    
    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 1.5)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .onAppear {
                withAnimation(.easeIn(duration: particle.duration)) {
                    position = CGPoint(
                        x: particle.x + CGFloat.random(in: -100...100),
                        y: UIScreen.main.bounds.height + 50
                    )
                    rotation = particle.rotation + 360
                }
            }
    }
}
