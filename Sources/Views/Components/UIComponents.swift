import SwiftUI

// MARK: - Haptic Button

struct HapticButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case ghost
        case destructive
    }
    
    init(title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            AppAudioManager.shared.playButtonTap()
            action()
        }) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(background)
            .cornerRadius(26)
        }
        .scaleEffect(isPressed ? 0.96 : 1)
        .animation(.spring(response: 0.2), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .white
        case .ghost: return .gray
        case .destructive: return .red
        }
    }
    
    @ViewBuilder
    var background: some View {
        switch style {
        case .primary:
            LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
        case .secondary:
            Color.white.opacity(0.1)
        case .ghost:
            Color.clear
        case .destructive:
            Color.red.opacity(0.2)
        }
    }
}

// MARK: - Icon Button

struct IconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    init(_ icon: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            AppAudioManager.shared.playUISelect()
            AppAudioManager.shared.selection()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(Color.white.opacity(0.1))
                .cornerRadius(size / 2)
        }
        .scaleEffect(isPressed ? 0.9 : 1)
        .animation(.spring(response: 0.2), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Selection Card

struct SelectionCard<Content: View>: View {
    let isSelected: Bool
    let content: Content
    let action: () -> Void
    
    init(isSelected: Bool, @ViewBuilder content: () -> Content, action: @escaping () -> Void) {
        self.isSelected = isSelected
        self.content = content()
        self.action = action
    }
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            AppAudioManager.shared.playUISelect()
            AppAudioManager.shared.selection()
            action()
        }) {
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.purple.opacity(0.15) : Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.purple : Color.white.opacity(0.1), lineWidth: 1.5)
                )
        }
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.3), value: isSelected)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Toggle with Haptics

struct HapticToggle: View {
    @Binding var isOn: Bool
    let label: String
    let icon: String
    
    var body: some View {
        Button(action: {
            isOn.toggle()
            if isOn {
                AppAudioManager.shared.success()
            } else {
                AppAudioManager.shared.lightImpact()
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                Text(label)
                    .foregroundColor(.white)
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isOn ? Color.purple : Color.white.opacity(0.1))
                        .frame(width: 50, height: 32)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 26, height: 26)
                        .offset(x: isOn ? 10 : -10)
                        .animation(.spring(response: 0.3), value: isOn)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// MARK: - Slider with Haptics

struct HapticSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let label: String
    
    init(value: Binding<Double>, range: ClosedRange<Double>, step: Double = 1, label: String = "") {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Slider(value: $value, in: range, step: step) { editing in
                if !editing {
                    AppAudioManager.shared.selection()
                }
            }
            .accentColor(.purple)
        }
    }
}

// MARK: - Badge View

struct BadgeView: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(value)
                .font(.system(size: 16, weight: .bold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.15))
        .cornerRadius(20)
    }
}

// MARK: - Animated Score Counter

struct AnimatedScore: View {
    let score: Int
    let icon: String
    let color: Color
    
    @State private var displayedScore: Int = 0
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text("\(displayedScore)")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                displayedScore = score
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.easeOut(duration: 0.3)) {
                displayedScore = newValue
            }
        }
    }
}

// MARK: - Pulse Effect View

struct PulseEffect: View {
    let color: Color
    @State private var isPulsing = false
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .frame(width: 80, height: 80)
            .scaleEffect(isPulsing ? 1.3 : 1)
            .opacity(isPulsing ? 0 : 0.5)
            .animation(
                .easeOut(duration: 1)
                .repeatForever(autoreverses: false),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Floating Score View

struct FloatingScoreView: View {
    let score: Int
    let color: Color
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Text("+\(score)")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(color)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    offset = -60
                    opacity = 0
                }
            }
    }
}

// MARK: - Combo Flame View

struct ComboFlameView: View {
    let combo: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<min(combo, 5), id: \.self) { _ in
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
            }
            if combo > 5 {
                Text("x\(combo)")
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .foregroundColor(combo >= 10 ? .yellow : .orange)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill((combo >= 10 ? Color.yellow : Color.orange).opacity(0.2))
        )
    }
}

// MARK: - Heart Display

struct HeartDisplay: View {
    let current: Int
    let max: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<max, id: \.self) { index in
                Image(systemName: index < current ? "heart.fill" : "heart")
                    .font(.system(size: 16))
                    .foregroundColor(index < current ? .red : .gray)
            }
        }
    }
}

// MARK: - Gem Display

struct GemDisplay: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "diamond.fill")
                .font(.system(size: 14))
                .foregroundColor(.cyan)
            Text("\(count)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - XP Bar

struct XPBar: View {
    let current: Int
    let max: Int
    let level: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Level \(level)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.purple)
                Spacer()
                Text("\(current) / \(max) XP")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(current) / CGFloat(max))
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Streak Display

struct StreakDisplay: View {
    let days: Int
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 16))
                .foregroundColor(days > 0 ? .orange : .gray)
            
            Text("\(days) day\(days == 1 ? "" : "s")")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(days > 0 ? .orange : .gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill((days > 0 ? Color.orange : Color.gray).opacity(0.15))
        )
    }
}
