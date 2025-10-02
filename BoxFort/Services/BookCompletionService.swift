import Foundation
import FirebaseFirestore
import FirebaseAnalytics

class BookCompletionService: ObservableObject {
    static let shared = BookCompletionService()
    private let db = Firestore.firestore()
    private let localCompletedBooksKey = "localCompletedBooks"
    
    @Published var hasCompletedAnyBook = false
    @Published var completedBooks: Set<String> = []
    // @Published var newlyUnlockedPack: CharacterPack? // Character packs not live yet
    
    private init() {
        // Set app first use date if not already set
        if UserDefaults.standard.object(forKey: "app_first_use_date") == nil {
            UserDefaults.standard.set(Date(), forKey: "app_first_use_date")
        }
        
        // Load local completions on init
        Task {
            await checkBookCompletionStatus(for: nil, childId: nil)
        }
    }
    
    func checkBookCompletionStatus(for userId: String?, childId: String?) async {
        // Get local completions from UserDefaults
        let localCompletions = getLocalCompletedBooks()
        var finalCompletions = localCompletions

        // If logged in, get remote completions from Firestore and merge
        if let userId = userId, let childId = childId {
            do {
                let snapshot = try await db.collection("reading_progress")
                    .whereField("userId", isEqualTo: userId)
                    .whereField("childId", isEqualTo: childId)
                    .whereField("completed", isEqualTo: true)
                    .getDocuments()
                
                let remoteCompletions = Set(snapshot.documents.compactMap { $0.data()["bookId"] as? String })
                finalCompletions = finalCompletions.union(remoteCompletions)

            } catch {
                // Fallback to only local completions on error
            }
        } else {
        }
        
        await MainActor.run {
            self.completedBooks = finalCompletions
            let hasCompleted = !finalCompletions.isEmpty
            self.hasCompletedAnyBook = hasCompleted
            
            // If the user has ever completed a book, mark onboarding as complete
            // to handle existing users gracefully upon app update.
            if hasCompleted {
                self.markOnboardingComplete()
            }
            
            // Check for character pack unlocks - not live yet
            // self.checkForCharacterPackUnlocks()
        }
    }
    
    func markBookAsCompleted(bookId: String, userId: String?, childId: String?) async {
        // Always save to local UserDefaults
        saveBookAsCompletedLocally(bookId: bookId)
        
        // Update local state immediately
        await MainActor.run {
            self.completedBooks.insert(bookId)
            self.hasCompletedAnyBook = true
        }
        
        // If onboarding is not yet complete, this first completion will complete it.
        if shouldShowOnboarding() {
            markOnboardingComplete()
        }
        
        // Check for character pack unlocks - not live yet
        /*
        await MainActor.run {
            self.checkForCharacterPackUnlocks()
        }
        */
        
        // If logged in, also save to Firestore
        if let userId = userId, let childId = childId {
            do {
                let completionData: [String: Any] = [
                    "userId": userId,
                    "childId": childId,
                    "bookId": bookId,
                    "completed": true,
                    "timestamp": FieldValue.serverTimestamp()
                ]
                try await db.collection("reading_progress").addDocument(data: completionData)
            } catch {
            }
        }
    }

    private func getLocalCompletedBooks() -> Set<String> {
        let savedBooks = UserDefaults.standard.stringArray(forKey: localCompletedBooksKey) ?? []
        return Set(savedBooks)
    }

    private func saveBookAsCompletedLocally(bookId: String) {
        var completed = getLocalCompletedBooks()
        completed.insert(bookId)
        UserDefaults.standard.set(Array(completed), forKey: localCompletedBooksKey)
        print("DEBUG: Marked book \(bookId) as completed locally.")
    }
    
    func hasCompletedBook(_ bookId: String) -> Bool {
        return completedBooks.contains(bookId)
    }
    
    func shouldShowOnboarding() -> Bool {
        // Onboarding is shown if it has not been marked complete and no books have been completed locally.
        return !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        print("DEBUG: Onboarding marked as complete.")
    }
    
    // MARK: - Character Pack Integration - NOT LIVE YET
    /*
    private func checkForCharacterPackUnlocks() {
        let packManager = CharacterPackManager.shared
        
        // Get previously unlocked packs to detect new unlocks
        let previouslyUnlocked = packManager.unlockedPacks
        
        // Check for unlocks based on completed books
        packManager.checkForUnlocks(completedBooks: completedBooks)
        
        // Check if any new packs were unlocked
        let newlyUnlocked = packManager.unlockedPacks.subtracting(previouslyUnlocked)
        
        if let newPackId = newlyUnlocked.first,
           let newPack = packManager.availablePacks.first(where: { $0.id == newPackId }) {
            newlyUnlockedPack = newPack
            
            // Log analytics for character pack unlock
            Analytics.logEvent("character_pack_unlocked", parameters: [
                "pack_id": newPack.id,
                "pack_name": newPack.name,
                "unlock_book_id": newPack.unlockBookId,
                "unlock_book_title": newPack.unlockBookTitle
            ])
        }
    }
    
    func clearNewlyUnlockedPack() {
        newlyUnlockedPack = nil
    }
    */
} 