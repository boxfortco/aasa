import Foundation
import FirebaseFunctions
import FirebaseFirestore
import Combine

class WeeklyBookService: ObservableObject {
    static let shared = WeeklyBookService()
    private let functions = Functions.functions()
    
    @Published var weeklyBooks: [Book] = []
    @Published var countdownTime: String = ""
    @Published var isCountdownActive: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private var countdownTimer: Timer?
    private var countdownConfig: CountdownConfig?
    
    private init() {
        loadWeeklyBooks()
        loadCountdownConfig()
    }
    
    // MARK: - Weekly Books
    
    func loadWeeklyBooks() {
        isLoading = true
        error = nil
        
        functions.httpsCallable("getWeeklyBooks").call { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    print("Error loading weekly books: \(error.localizedDescription)")
                    return
                }
                
                guard let data = result?.data as? [String: Any],
                      let weeklyDelivery = data["weeklyDelivery"] as? [String: Any],
                      let booksData = weeklyDelivery["books"] as? [[String: Any]] else {
                    self?.error = "Invalid data format"
                    return
                }
                
                do {
                    let books = try booksData.compactMap { bookData -> Book? in
                        let jsonData = try JSONSerialization.data(withJSONObject: bookData)
                        return try JSONDecoder().decode(Book.self, from: jsonData)
                    }
                    
                    self?.weeklyBooks = books
                    print("Loaded \(books.count) weekly books")
                    
                } catch {
                    self?.error = "Failed to decode books: \(error.localizedDescription)"
                    print("Error decoding books: \(error)")
                }
            }
        }
    }
    
    // MARK: - Countdown Timer
    
    func loadCountdownConfig() {
        functions.httpsCallable("getCountdownTimer").call { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error loading countdown config: \(error.localizedDescription)")
                    return
                }
                
                guard let data = result?.data as? [String: Any] else {
                    print("Invalid countdown config data")
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let config = try JSONDecoder().decode(CountdownConfig.self, from: jsonData)
                    self?.countdownConfig = config
                    self?.startCountdown()
                } catch {
                    print("Error decoding countdown config: \(error)")
                }
            }
        }
    }
    
    private func startCountdown() {
        guard let config = countdownConfig, config.enabled else {
            isCountdownActive = false
            return
        }
        
        isCountdownActive = true
        updateCountdown()
        
        // Update countdown every second
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }
    }
    
    private func updateCountdown() {
        guard let config = countdownConfig else { return }
        
        let now = Date()
        let targetDate = getNextTargetDate(config: config)
        let timeRemaining = targetDate.timeIntervalSince(now)
        
        if timeRemaining <= 0 {
            countdownTime = "New books available!"
            isCountdownActive = false
            countdownTimer?.invalidate()
            // Reload weekly books when countdown expires
            loadWeeklyBooks()
        } else {
            countdownTime = formatTimeRemaining(timeRemaining)
        }
    }
    
    private func getNextTargetDate(config: CountdownConfig) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Create a date formatter for the target timezone
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: config.timezone) ?? TimeZone.current
        
        // Get current date in target timezone
        let targetTimeZone = TimeZone(identifier: config.timezone) ?? TimeZone.current
        let targetNow = now.addingTimeInterval(TimeInterval(targetTimeZone.secondsFromGMT() - TimeZone.current.secondsFromGMT()))
        
        // Find the next occurrence of the target day and time
        var targetDate = calendar.date(bySettingHour: config.targetHour, minute: config.targetMinute, second: 0, of: targetNow) ?? targetNow
        
        // If we've passed today's target time, move to next week
        if targetDate <= targetNow {
            targetDate = calendar.date(byAdding: .day, value: 7, to: targetDate) ?? targetDate
        }
        
        // Adjust to the correct day of week
        let currentWeekday = calendar.component(.weekday, from: targetDate)
        let targetWeekday = config.targetDay + 1 // Convert from 0-based to 1-based
        
        if currentWeekday != targetWeekday {
            let daysToAdd = (targetWeekday - currentWeekday + 7) % 7
            targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: targetDate) ?? targetDate
        }
        
        return targetDate
    }
    
    private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval) / 86400
        let hours = (Int(timeInterval) % 86400) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if days > 0 {
            return String(format: "%dd %02d:%02d:%02d", days, hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
}

// MARK: - Supporting Types

struct CountdownConfig: Codable {
    let targetDay: Int // 0 = Sunday, 1 = Monday, etc.
    let targetHour: Int
    let targetMinute: Int
    let timezone: String
    let enabled: Bool
}

struct WeeklyDelivery: Codable {
    let id: String
    let deliveryDate: Date
    let countdownEndTime: Date
    let books: [Book]
} 