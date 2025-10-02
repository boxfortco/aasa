import Foundation
import FirebaseFirestore
import FirebaseAuth

class CharacterScheduleService: ObservableObject {
    static let shared = CharacterScheduleService()
    
    private let db = Firestore.firestore()
    @Published var currentSchedule: CharacterSchedule?
    
    init() {}
    
    func loadSchedule(for character: Channel) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("[CharacterScheduleService] ERROR: User not authenticated")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        print("[CharacterScheduleService] userId: \(userId)")
        let scheduleRef = db.collection("users").document(userId)
            .collection("characterSchedules").document(character.rawValue)
        print("[CharacterScheduleService] Firestore path: users/\(userId)/characterSchedules/\(character.rawValue)")
        
        let snapshot = try await scheduleRef.getDocument()
        
        if let schedule = try? snapshot.data(as: CharacterSchedule.self) {
            DispatchQueue.main.async {
                self.currentSchedule = schedule
            }
            // Sync with shared container for widget
            SharedDataManager.shared.saveSchedule(schedule)
        } else {
            // Create default schedule if none exists
            let defaultSchedule = CharacterSchedule.createDefaultSchedule(for: character)
            try await scheduleRef.setData(from: defaultSchedule)
            DispatchQueue.main.async {
                self.currentSchedule = defaultSchedule
            }
            // Sync with shared container for widget
            SharedDataManager.shared.saveSchedule(defaultSchedule)
        }
    }
    
    func updateSchedule(_ schedule: CharacterSchedule) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("[CharacterScheduleService] ERROR: User not authenticated")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        print("[CharacterScheduleService] userId: \(userId)")
        let scheduleRef = db.collection("users").document(userId)
            .collection("characterSchedules").document(schedule.character.rawValue)
        print("[CharacterScheduleService] Firestore path: users/\(userId)/characterSchedules/\(schedule.character.rawValue)")
        
        try await scheduleRef.setData(from: schedule)
        DispatchQueue.main.async {
            self.currentSchedule = schedule
        }
        // Sync with shared container for widget
        SharedDataManager.shared.saveSchedule(schedule)
    }
    
    func updateActivity(_ activity: CharacterSchedule.ScheduledActivity) async throws {
        guard var schedule = currentSchedule else { return }
        
        if let index = schedule.activities.firstIndex(where: { $0.id == activity.id }) {
            schedule.activities[index] = activity
            schedule.lastUpdated = Date()
            try await updateSchedule(schedule)
        }
    }
    
    func getCurrentActivity() -> CharacterSchedule.ScheduledActivity? {
        return currentSchedule?.currentActivity()
    }
    
    func getNextActivity() -> CharacterSchedule.ScheduledActivity? {
        return currentSchedule?.nextActivity()
    }
} 