import Foundation

class SharedDataManager {
    static let shared = SharedDataManager()
    
    private let sharedContainer: String = "group.com.boxfort.app"
    private let scheduleKey = "characterSchedule"
    
    private init() {}
    
    func saveSchedule(_ schedule: CharacterSchedule) {
        guard let data = try? JSONEncoder().encode(schedule) else { return }
        UserDefaults(suiteName: sharedContainer)?.set(data, forKey: scheduleKey)
    }
    
    func loadSchedule() -> CharacterSchedule? {
        guard let data = UserDefaults(suiteName: sharedContainer)?.data(forKey: scheduleKey),
              let schedule = try? JSONDecoder().decode(CharacterSchedule.self, from: data) else {
            return nil
        }
        return schedule
    }
    
    func clearSchedule() {
        UserDefaults(suiteName: sharedContainer)?.removeObject(forKey: scheduleKey)
    }
} 