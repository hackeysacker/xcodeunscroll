import SwiftUI

struct FocusTimerView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var timer = FocusTimerManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMinutes: Int = 25
    @State private var showSettings: Bool = false
    
    let timerOptions = [15, 25, 30, 45, 60, 90]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                if timer.isRunning {
                    // Timer active view
                    timerActiveView
                } else {
                    // Timer setup view
                    timerSetupView
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            timerSettingsSheet
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Button {
                if timer.isRunning {
                    timer.stop()
                }
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text("Focus Timer")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - Timer Setup View
    
    private var timerSetupView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Timer circle preview
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 20)
                    .frame(width: 280, height: 280)
                
                Circle()
                    .trim(from: 0, to: CGFloat(selectedMinutes) / 60)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 8) {
                    Text("\(selectedMinutes)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.white)
                    Text("minutes")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            
            // Duration picker
            VStack(spacing: 12) {
                Text("Select Duration")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(timerOptions, id: \.self) { minutes in
                            Button {
                                selectedMinutes = minutes
                                AppAudioManager.shared.selection()
                            } label: {
                                Text("\(minutes)m")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedMinutes == minutes ? .white : .gray)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(selectedMinutes == minutes ? Color.purple : Color.white.opacity(0.05))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            // Stats preview
            if let progress = appState.progress {
                HStack(spacing: 24) {
                    StatPreview(
                        icon: "flame.fill",
                        value: "\(progress.streakDays)",
                        label: "Day Streak",
                        color: .orange
                    )
                    StatPreview(
                        icon: "clock.fill",
                        value: progress.formattedTotalFocusTime,
                        label: "Total Focus",
                        color: .blue
                    )
                    StatPreview(
                        icon: "target",
                        value: progress.formattedTodayFocusTime,
                        label: "Today",
                        color: .green
                    )
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Start button
            Button {
                timer.startSession(minutes: selectedMinutes, appState: appState)
                AppAudioManager.shared.playChallengeStart()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                    Text("Start Focus Session")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Timer Active View
    
    private var timerActiveView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Status text
            Text(timer.isBreakTime ? "Take a Break" : "Stay Focused")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            // Timer circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 20)
                    .frame(width: 300, height: 300)
                
                Circle()
                    .trim(from: 0, to: timer.isBreakTime ? timer.breakProgress : timer.progress)
                    .stroke(
                        LinearGradient(
                            colors: timer.isBreakTime ? [.green, .cyan] : [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timer.progress)
                
                VStack(spacing: 8) {
                    Text(timer.isBreakTime ? timer.formattedBreakTimeRemaining : timer.formattedTimeRemaining)
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    if !timer.isBreakTime {
                        Text("Session \(timer.sessionsCompletedToday + 1)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    } else {
                        Text("Break time!")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Current session info
            if !timer.isBreakTime, let session = timer.currentSession {
                HStack(spacing: 24) {
                    StatPreview(
                        icon: "bolt.fill",
                        value: "+\(session.durationMinutes * 10)",
                        label: "XP Possible",
                        color: .yellow
                    )
                    StatPreview(
                        icon: "gem.fill",
                        value: "+\(max(1, session.durationMinutes / 10))",
                        label: "Gems Possible",
                        color: .purple
                    )
                }
            }
            
            Spacer()
            
            // Control buttons
            HStack(spacing: 24) {
                // Stop button
                Button {
                    timer.stop()
                    AppAudioManager.shared.playButtonTap()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 24))
                        Text("End")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.red)
                    .frame(width: 70, height: 70)
                    .background(Color.red.opacity(0.15))
                    .clipShape(Circle())
                }
                
                // Pause/Resume button
                Button {
                    if timer.isPaused {
                        timer.resume()
                    } else {
                        timer.pause()
                    }
                    AppAudioManager.shared.selection()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: timer.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 32))
                        Text(timer.isPaused ? "Resume" : "Pause")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white)
                    .frame(width: 90, height: 90)
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                }
                
                // Skip button (break only)
                if timer.isBreakTime {
                    Button {
                        timer.skip()
                        AppAudioManager.shared.selection()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 24))
                            Text("Skip")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.orange)
                        .frame(width: 70, height: 70)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Circle())
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Timer Settings Sheet
    
    private var timerSettingsSheet: some View {
        NavigationView {
            ZStack {
                Color(hex: "0A0F1C")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Auto-start breaks
                    SettingsToggleRow(
                        icon: "cup.and.saucer.fill",
                        iconColor: .green,
                        title: "Auto-start Breaks",
                        subtitle: "Automatically start break after focus session",
                        isOn: $timer.autoStartBreaks
                    )
                    
                    // Break duration
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Break Duration")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Short Break: \(timer.breakMinutes)m")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Stepper("", value: $timer.breakMinutes, in: 1...15)
                                .labelsHidden()
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        
                        HStack {
                            Text("Long Break: \(timer.longBreakMinutes)m")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Stepper("", value: $timer.longBreakMinutes, in: 10...30)
                                .labelsHidden()
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Sessions before long break
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Long Break Interval")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Sessions before long break: \(timer.sessionsBeforeLongBreak)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Stepper("", value: $timer.sessionsBeforeLongBreak, in: 2...8)
                                .labelsHidden()
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Timer Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showSettings = false
                    }
                    .foregroundColor(.purple)
                }
            }
        }
    }
}

// MARK: - Stat Preview

struct StatPreview: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Settings Toggle Row


