import WidgetKit
import SwiftUI
import FirebaseFirestore

struct CharacterDayWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CharacterDayEntry {
        CharacterDayEntry(date: Date(), activity: CharacterSchedule.ScheduledActivity(
            id: "placeholder",
            name: "Wake Up",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            storyId: nil,
            isEnabled: true,
            iconName: "sunrise.fill",
            description: "Time to wake up and start the day!"
        ), character: .Patrick)
    }

    func getSnapshot(in context: Context, completion: @escaping (CharacterDayEntry) -> ()) {
        let entry = CharacterDayEntry(date: Date(), activity: CharacterSchedule.ScheduledActivity(
            id: "snapshot",
            name: "Wake Up",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            storyId: nil,
            isEnabled: true,
            iconName: "sunrise.fill",
            description: "Time to wake up and start the day!"
        ), character: .Patrick)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            do {
                let schedule = try await loadSchedule()
                let currentActivity = schedule.currentActivity()
                let nextActivity = schedule.nextActivity()
                
                let now = Date()
                let midnight = Calendar.current.startOfDay(for: now)
                let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
                
                let entries = [
                    CharacterDayEntry(date: now, activity: currentActivity, character: schedule.character),
                    CharacterDayEntry(date: nextMidnight, activity: nextActivity, character: schedule.character)
                ]
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            } catch {
                let entry = CharacterDayEntry(date: Date(), activity: nil, character: nil)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        }
    }
    
    private func loadSchedule() async throws -> CharacterSchedule {
        // Load from shared container
        if let schedule = SharedDataManager.shared.loadSchedule() {
            return schedule
        }
        // Fallback to default schedule
        return CharacterSchedule.createDefaultSchedule(for: .Patrick)
    }
}

struct CharacterDayEntry: TimelineEntry {
    let date: Date
    let activity: CharacterSchedule.ScheduledActivity?
    let character: Channel?
}

// Helper to map activity name to image key
private func widgetImageName(for activity: CharacterSchedule.ScheduledActivity) -> String {
    let activityKey: String
    switch activity.name.lowercased() {
    case "wake up": activityKey = "wake_up"
    case "breakfast": activityKey = "breakfast"
    case "school time": activityKey = "school"
    case "afternoon play": activityKey = "play"
    case "dinner": activityKey = "dinner"
    case "bath time": activityKey = "bath"
    case "brush teeth": activityKey = "brushing"
    case "bedtime story": activityKey = "bedtime_story"
    case "sleep time": activityKey = "sleep"
    default: activityKey = "default"
    }
    return "widget_patrick_\(activityKey)"
}

struct CharacterDayWidgetEntryView : View {
    var entry: CharacterDayWidgetProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let activity = entry.activity {
            ZStack {
                Color(.systemBackground)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                VStack(alignment: .leading, spacing: 8) {
                    // Activity-specific Patrick image
                    Image(widgetImageName(for: activity))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                    HStack {
                        Text(activity.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    Text(activity.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    if family == .systemMedium {
                        HStack {
                            Text(timeUntilNextActivity())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
            }
        } else {
            ZStack {
                Color(.systemBackground)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                VStack(spacing: 12) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("No activity scheduled")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }
    
    private func timeUntilNextActivity() -> String {
        guard let activity = entry.activity else { return "" }
        let now = Date()
        let timeUntil = activity.startTime.timeIntervalSince(now)
        
        if timeUntil < 0 {
            return "In progress"
        } else if timeUntil < 3600 {
            let minutes = Int(timeUntil / 60)
            return "In \(minutes) minutes"
        } else {
            let hours = Int(timeUntil / 3600)
            return "In \(hours) hours"
        }
    }
}

struct CharacterDayWidget: Widget {
    let kind: String = "CharacterDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CharacterDayWidgetProvider()) { entry in
            CharacterDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Character's Day")
        .description("See what your favorite character is up to!")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    CharacterDayWidget()
} timeline: {
    CharacterDayEntry(date: Date(), activity: CharacterSchedule.ScheduledActivity(
        id: "preview",
        name: "Wake Up",
        startTime: Date(),
        endTime: Date().addingTimeInterval(3600),
        storyId: nil,
        isEnabled: true,
        iconName: "sunrise.fill",
        description: "Time to wake up and start the day!"
    ), character: .Patrick)
} 