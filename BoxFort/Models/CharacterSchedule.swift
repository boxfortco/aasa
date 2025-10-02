import Foundation

struct CharacterSchedule: Codable, Identifiable {
    let id: String
    var character: Channel
    var activities: [ScheduledActivity]
    var lastUpdated: Date
    
    struct ScheduledActivity: Codable, Identifiable {
        let id: String
        var name: String
        var startTime: Date
        var endTime: Date
        var storyId: String?
        var isEnabled: Bool
        var iconName: String
        var description: String
        
        // Default activities that can be used as templates
        static let defaultActivities: [ScheduledActivity] = [
            ScheduledActivity(
                id: UUID().uuidString,
                name: "Wake Up",
                startTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date(),
                storyId: nil,
                isEnabled: true,
                iconName: "sunrise.fill",
                description: "Time to wake up and start the day!"
            ),
            ScheduledActivity(
                id: UUID().uuidString,
                name: "Breakfast",
                startTime: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
                storyId: nil,
                isEnabled: true,
                iconName: "fork.knife",
                description: "Time for a healthy breakfast!"
            ),
            ScheduledActivity(
                id: UUID().uuidString,
                name: "School Time",
                startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date()) ?? Date(),
                storyId: nil,
                isEnabled: true,
                iconName: "book.fill",
                description: "Time to learn and play with friends!"
            ),
            ScheduledActivity(
                id: UUID().uuidString,
                name: "Afternoon Play",
                startTime: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date(),
                storyId: nil,
                isEnabled: true,
                iconName: "figure.play",
                description: "Time for fun activities!"
            ),
            ScheduledActivity(
                id: UUID().uuidString,
                name: "Dinner",
                startTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date(),
                storyId: nil,
                isEnabled: true,
                iconName: "fork.knife.circle.fill",
                description: "Time for a delicious dinner!"
            ),
            ScheduledActivity(
                id: UUID().uuidString,
                name: "Bath Time",
                startTime: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 19, minute: 30, second: 0, of: Date()) ?? Date(),
                storyId: nil,
                isEnabled: true,
                iconName: "shower.fill",
                description: "Time to get clean and fresh!"
            ),
            ScheduledActivity(
                id: UUID().uuidString,
                name: "Brush Teeth",
                startTime: Calendar.current.date(bySettingHour: 19, minute: 30, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 19, minute: 45, second: 0, of: Date()) ?? Date(),
                storyId: nil,
                isEnabled: true,
                iconName: "mouth.fill",
                description: "Time to brush those teeth!"
            ),
            ScheduledActivity(
                id: UUID().uuidString,
                name: "Bedtime Story",
                startTime: Calendar.current.date(bySettingHour: 19, minute: 45, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 20, minute: 15, second: 0, of: Date()) ?? Date(),
                storyId: nil,
                isEnabled: true,
                iconName: "book.closed.fill",
                description: "Time for a cozy bedtime story!"
            ),
            ScheduledActivity(
                id: UUID().uuidString,
                name: "Sleep Time",
                startTime: Calendar.current.date(bySettingHour: 20, minute: 15, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date(),
                storyId: nil,
                isEnabled: true,
                iconName: "moon.zzz.fill",
                description: "Sweet dreams!"
            )
        ]
    }
    
    static func createDefaultSchedule(for character: Channel) -> CharacterSchedule {
        return CharacterSchedule(
            id: UUID().uuidString,
            character: character,
            activities: ScheduledActivity.defaultActivities,
            lastUpdated: Date()
        )
    }
    
    func currentActivity() -> ScheduledActivity? {
        let now = Date()
        return activities.first { activity in
            activity.isEnabled && now >= activity.startTime && now <= activity.endTime
        }
    }
    
    func nextActivity() -> ScheduledActivity? {
        let now = Date()
        return activities
            .filter { $0.isEnabled && $0.startTime > now }
            .sorted { $0.startTime < $1.startTime }
            .first
    }
} 