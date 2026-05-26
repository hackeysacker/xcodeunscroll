//
//  FocusFlowWidget.swift
//  FocusFlowWidget
//
//  Home Screen Widget for FocusFlow - Shows daily progress at a glance
//

import WidgetKit
import SwiftUI

struct FocusFlowEntry: TimelineEntry {
    let date: Date
    let gems: Int
    let hearts: Int
    let currentStreak: Int
    let longestStreak: Int
    let dailyFocusMinutes: Int
    let dailyGoalMinutes: Int
    let isOnStreak: Bool
}

struct FocusFlowProvider: TimelineProvider {
    func placeholder(in context: Context) -> FocusFlowEntry {
        FocusFlowEntry(
            date: Date(),
            gems: 150,
            hearts: 5,
            currentStreak: 7,
            longestStreak: 14,
            dailyFocusMinutes: 45,
            dailyGoalMinutes: 60,
            isOnStreak: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FocusFlowEntry) -> Void) {
        let entry = FocusFlowEntry(
            date: Date(),
            gems: 150,
            hearts: 5,
            currentStreak: 7,
            longestStreak: 14,
            dailyFocusMinutes: 45,
            dailyGoalMinutes: 60,
            isOnStreak: true
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FocusFlowEntry>) -> Void) {
        // Load data from UserDefaults (shared app group)
        let defaults = UserDefaults(suiteName: "group.com.focusflow.app")
        
        let gems = defaults?.integer(forKey: "gems") ?? 0
        let hearts = defaults?.integer(forKey: "hearts") ?? 3
        let currentStreak = defaults?.integer(forKey: "currentStreak") ?? 0
        let longestStreak = defaults?.integer(forKey: "longestStreak") ?? 0
        let dailyFocusMinutes = defaults?.integer(forKey: "dailyFocusMinutes") ?? 0
        let dailyGoalMinutes = defaults?.integer(forKey: "dailyGoalMinutes") ?? 60
        
        // Check if on streak (focused today)
        let lastFocusDate = defaults?.object(forKey: "lastFocusDate") as? Date ?? Date.distantPast
        let calendar = Calendar.current
        let isOnStreak = calendar.isDateInToday(lastFocusDate)
        
        let entry = FocusFlowEntry(
            date: Date(),
            gems: gems,
            hearts: hearts,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            dailyFocusMinutes: dailyFocusMinutes,
            dailyGoalMinutes: dailyGoalMinutes,
            isOnStreak: isOnStreak
        )
        
        // Update every hour
        let nextUpdate = calendar.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// Small Widget - Just streak
struct SmallWidgetView: View {
    let entry: FocusFlowEntry
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundColor(.orange)
            
            Text("\(entry.currentStreak)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text("day streak")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}

// Medium Widget - Progress bar + streak
struct MediumWidgetView: View {
    let entry: FocusFlowEntry
    
    var progress: Double {
        guard entry.dailyGoalMinutes > 0 else { return 0 }
        return min(Double(entry.dailyFocusMinutes) / Double(entry.dailyGoalMinutes), 1.0)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Streak
            VStack {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("\(entry.currentStreak)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("streak")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            
            // Right: Daily progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(entry.dailyFocusMinutes)/\(entry.dailyGoalMinutes)m")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Label("\(entry.hearts)", systemImage: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Label("\(entry.gems)", systemImage: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}

// Large Widget - Full stats
struct LargeWidgetView: View {
    let entry: FocusFlowEntry
    
    var progress: Double {
        guard entry.dailyGoalMinutes > 0 else { return 0 }
        return min(Double(entry.dailyFocusMinutes) / Double(entry.dailyGoalMinutes), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("FocusFlow")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if entry.isOnStreak {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            // Main progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("complete")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 120)
            
            // Stats row
            HStack {
                StatBox(value: "\(entry.currentStreak)", label: "Streak", icon: "flame.fill", color: .orange)
                StatBox(value: "\(entry.longestStreak)", label: "Best", icon: "trophy.fill", color: .yellow)
                StatBox(value: "\(entry.hearts)", label: "Hearts", icon: "heart.fill", color: .red)
                StatBox(value: "\(entry.gems)", label: "Gems", icon: "star.fill", color: .yellow)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FocusFlowWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: FocusFlowProvider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct FocusFlowWidget: Widget {
    let kind: String = "FocusFlowWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FocusFlowProvider()) { entry in
            FocusFlowWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("FocusFlow")
        .description("Track your daily focus progress and streaks.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    FocusFlowWidget()
} timeline: {
    FocusFlowEntry(
        date: Date(),
        gems: 150,
        hearts: 5,
        currentStreak: 7,
        longestStreak: 14,
        dailyFocusMinutes: 45,
        dailyGoalMinutes: 60,
        isOnStreak: true
    )
}

#Preview(as: .systemMedium) {
    FocusFlowWidget()
} timeline: {
    FocusFlowEntry(
        date: Date(),
        gems: 150,
        hearts: 5,
        currentStreak: 7,
        longestStreak: 14,
        dailyFocusMinutes: 45,
        dailyGoalMinutes: 60,
        isOnStreak: true
    )
}

#Preview(as: .systemLarge) {
    FocusFlowWidget()
} timeline: {
    FocusFlowEntry(
        date: Date(),
        gems: 150,
        hearts: 5,
        currentStreak: 7,
        longestStreak: 14,
        dailyFocusMinutes: 45,
        dailyGoalMinutes: 60,
        isOnStreak: true
    )
}