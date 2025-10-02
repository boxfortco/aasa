import Foundation
import FirebaseAuth
import FirebaseFirestore
import OneSignalFramework

class AuthenticationService: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published var isAuthenticated = false
    private let db = Firestore.firestore()
    private let newsletterService = NewsletterService.shared
    private let auth = Auth.auth()
    
    init() {
        // Configure Firestore settings for better timeout handling
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
        
        // Migrate existing users
        migrateExistingUsers()
        
        // Listen for auth state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                // Only set isAuthenticated after we successfully fetch user data
                self.fetchUserData(userId: user.uid) { success in
                    DispatchQueue.main.async {
                        self.isAuthenticated = success
                        if !success {
                            // If we failed to fetch user data, clear the auth state
                            do {
                                try self.auth.signOut()
                                self.currentUser = nil
                            } catch {
                                print("Error signing out: \(error.localizedDescription)")
                            }
                        } else {
                            // Set OneSignal user ID for targeting
                            self.setupOneSignalUser(userId: user.uid)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.currentUser = nil
                    // Clear OneSignal user when signed out
                    OneSignalService.shared.clearUserId()
                }
            }
        }
    }
    
    // MARK: - OneSignal Integration
    
    private func setupOneSignalUser(userId: String) {
        // Set OneSignal user ID for targeting
        OneSignalService.shared.setUserId(userId)
        
        // Set up user segmentation if we have user data
        if let currentUser = currentUser {
            OneSignalService.shared.setupUserSegmentation(user: currentUser)
        }
    }
    
    // MARK: - Existing Methods
    
    private func migrateExistingUsers() {
        print("Starting user data migration...")
        db.collection("users").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                // Check for App Check error
                if error.localizedDescription.contains("App Check") {
                    print("App Check error during migration: \(error.localizedDescription)")
                    return
                }
                
                print("Error fetching users for migration: \(error.localizedDescription)")
                return
            }
            
            print("Found \(snapshot?.documents.count ?? 0) users to check for migration")
            var migrationCount = 0
            
            for document in snapshot?.documents ?? [] {
                let userData = document.data()
                
                // Check if user needs migration
                if userData["loyaltyPoints"] == nil || 
                   userData["loyaltyTier"] == nil || 
                   userData["streakDays"] == nil ||
                   userData["gardenStatus"] == nil {
                    var updates: [String: Any] = [:]
                    
                    // Add version tracking
                    updates["dataVersion"] = 1
                    
                    if userData["loyaltyPoints"] == nil {
                        updates["loyaltyPoints"] = 0
                        print("User \(document.documentID) missing loyaltyPoints")
                    }
                    
                    if userData["loyaltyTier"] == nil {
                        updates["loyaltyTier"] = "Bronze"
                        print("User \(document.documentID) missing loyaltyTier")
                    }
                    
                    if userData["streakDays"] == nil {
                        updates["streakDays"] = 0
                        print("User \(document.documentID) missing streakDays")
                    }
                    
                    if userData["gardenStatus"] == nil {
                        updates["gardenStatus"] = [
                            "currentPlant": nil,
                            "previousPlants": []
                        ]
                        print("User \(document.documentID) missing gardenStatus")
                    }
                    
                    // Update the user document
                    self.db.collection("users").document(document.documentID).updateData(updates) { error in
                        if let error = error {
                            print("Error migrating user \(document.documentID): \(error.localizedDescription)")
                        } else {
                            migrationCount += 1
                            print("Successfully migrated user \(document.documentID)")
                        }
                    }
                }
            }
            
            print("Migration complete. Updated \(migrationCount) users.")
        }
    }
    
    private func fetchUserData(userId: String, completion: @escaping (Bool) -> Void) {
        print("Fetching user data for \(userId)")
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { 
                print("Self was deallocated during user data fetch")
                completion(false)
                return 
            }
            
            if let error = error {
                // Check for App Check error
                if error.localizedDescription.contains("App Check") {
                    print("App Check error: \(error.localizedDescription)")
                    // Try to continue without App Check for now
                    completion(true)
                    return
                }
                
                print("Error fetching user data: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No user data found for \(userId)")
                completion(false)
                return
            }
            
            do {
                // Convert children array to proper format
                if var userData = data as? [String: Any] {
                    var needsUpdate = false
                    
                    // Ensure loyaltyPoints exists
                    if userData["loyaltyPoints"] == nil {
                        userData["loyaltyPoints"] = 0
                        needsUpdate = true
                        print("Adding missing loyaltyPoints for user \(userId)")
                    }
                    
                    // Ensure loyaltyTier exists
                    if userData["loyaltyTier"] == nil {
                        userData["loyaltyTier"] = "Bronze"
                        needsUpdate = true
                        print("Adding missing loyaltyTier for user \(userId)")
                    }
                    
                    // Ensure streakDays exists
                    if userData["streakDays"] == nil {
                        userData["streakDays"] = 0
                        needsUpdate = true
                        print("Adding missing streakDays for user \(userId)")
                    }
                    
                    // Ensure gardenStatus exists
                    if userData["gardenStatus"] == nil {
                        userData["gardenStatus"] = [
                            "currentPlant": nil,
                            "previousPlants": []
                        ]
                        needsUpdate = true
                        print("Adding missing gardenStatus for user \(userId)")
                    }
                    
                    if let children = userData["children"] as? [[String: Any]] {
                        // Ensure each child has a favorites array
                        let updatedChildren = children.map { child -> [String: Any] in
                            var updatedChild = child
                            if updatedChild["favorites"] == nil {
                                updatedChild["favorites"] = []
                                needsUpdate = true
                                print("Adding missing favorites array for child in user \(userId)")
                            }
                            return updatedChild
                        }
                        userData["children"] = updatedChildren
                    }
                    
                    // If we need to update the document, do it now
                    if needsUpdate {
                        print("Updating user document for \(userId) with missing fields")
                        self.db.collection("users").document(userId).updateData(userData) { error in
                            if let error = error {
                                print("Error updating user document: \(error.localizedDescription)")
                            } else {
                                print("Successfully updated user document")
                            }
                        }
                    }
                    
                    // Convert Timestamps to strings before serialization
                    let sanitizedData = self.sanitizeFirebaseData(userData)
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: sanitizedData)
                    let user = try JSONDecoder().decode(User.self, from: jsonData)
                    DispatchQueue.main.async {
                        self.currentUser = user
                        print("Successfully loaded user data for \(userId)")
                        completion(true)
                    }
                } else {
                    print("Failed to convert user data to dictionary for \(userId)")
                    completion(false)
                }
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
                print("DEBUG: Decoding error details - \(error)")
                completion(false)
            }
        }
    }
    
    // Helper function to convert Firebase Timestamps to strings
    private func sanitizeFirebaseData(_ data: [String: Any]) -> [String: Any] {
        var sanitizedData = [String: Any]()
        
        for (key, value) in data {
            if let timestamp = value as? Timestamp {
                // Convert Timestamp to ISO8601 string
                sanitizedData[key] = ISO8601DateFormatter().string(from: timestamp.dateValue())
            } else if let dateString = value as? String, key == "lastActivityDate" {
                // Handle lastActivityDate that might be stored as a string
                sanitizedData[key] = dateString
            } else if let nestedDict = value as? [String: Any] {
                sanitizedData[key] = sanitizeFirebaseData(nestedDict)
            } else if let arrayOfDict = value as? [[String: Any]] {
                sanitizedData[key] = arrayOfDict.map { sanitizeFirebaseData($0) }
            } else {
                sanitizedData[key] = value
            }
        }
        
        return sanitizedData
    }
    
    func register(email: String, password: String, parentName: String, children: [ChildProfile], completion: @escaping (Result<Void, Error>) -> Void) {
        // Set a timeout for the registration process
        let timeout = DispatchTimeInterval.seconds(30)
        let timeoutWorkItem = DispatchWorkItem {
            completion(.failure(NSError(domain: "com.boxfort.error",
                                     code: -1,
                                     userInfo: [NSLocalizedDescriptionKey: "Registration timed out. Please check your internet connection and try again."])))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: timeoutWorkItem)
        
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            // Cancel the timeout work item since we got a response
            timeoutWorkItem.cancel()
            
            guard let self = self else { return }
            
            if let error = error {
                let errorMessage: String
                switch error._code {
                case AuthErrorCode.networkError.rawValue:
                    errorMessage = "Network error. Please check your internet connection and try again."
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    errorMessage = "This email is already registered. Please use a different email or try logging in."
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Please enter a valid email address."
                case AuthErrorCode.weakPassword.rawValue:
                    errorMessage = "Please choose a stronger password. It should be at least 6 characters long."
                default:
                    errorMessage = error.localizedDescription
                }
                
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "com.boxfort.error",
                                             code: error._code,
                                             userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
                return
            }
            
            guard let firebaseUser = result?.user else {
                completion(.failure(NSError(domain: "com.boxfort.error",
                                         code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Failed to create user account."])))
                return
            }
            
            var user = User(from: firebaseUser, parentName: parentName)
            user.children = children
            
            do {
                let userData = try JSONEncoder().encode(user)
                let userDict = try JSONSerialization.jsonObject(with: userData) as? [String: Any] ?? [:]
                
                // Ensure loyaltyPoints and loyaltyTier are set
                var updatedUserDict = userDict
                updatedUserDict["loyaltyPoints"] = 0
                updatedUserDict["loyaltyTier"] = "Bronze"
                
                self.db.collection("users").document(user.id).setData(updatedUserDict) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(.failure(NSError(domain: "com.boxfort.error",
                                                     code: -1,
                                                     userInfo: [NSLocalizedDescriptionKey: "Failed to save user data. Please try again."])))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Set a timeout for the login process
        let timeout = DispatchTimeInterval.seconds(30)
        let timeoutWorkItem = DispatchWorkItem {
            completion(.failure(NSError(domain: "com.boxfort.error",
                                     code: -1,
                                     userInfo: [NSLocalizedDescriptionKey: "Login timed out. Please check your internet connection and try again."])))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: timeoutWorkItem)
        
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            // Cancel the timeout work item since we got a response
            timeoutWorkItem.cancel()
            
            if let error = error {
                let errorMessage: String
                switch error._code {
                case AuthErrorCode.wrongPassword.rawValue:
                    errorMessage = "Incorrect password. Please try again."
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Please enter a valid email address."
                case AuthErrorCode.userNotFound.rawValue:
                    errorMessage = "No account found with this email. Please check your email or sign up."
                case AuthErrorCode.networkError.rawValue:
                    errorMessage = "Network error. Please check your internet connection and try again."
                case AuthErrorCode.tooManyRequests.rawValue:
                    errorMessage = "Too many login attempts. Please try again later."
                default:
                    // Check if the error is related to App Check
                    if error.localizedDescription.contains("App Check") {
                        errorMessage = "Unable to verify app authenticity. Please try again in a few minutes."
                        print("DEBUG: App Check error encountered: \(error.localizedDescription)")
                    } else {
                        errorMessage = error.localizedDescription
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "com.boxfort.error",
                                             code: error._code,
                                             userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
                return
            }
            
            // Don't call completion success until we've actually fetched the user data
            if let userId = result?.user.uid {
                self?.fetchUserData(userId: userId) { success in
                    DispatchQueue.main.async {
                        if success {
                            completion(.success(()))
                        } else {
                            completion(.failure(NSError(domain: "com.boxfort.error",
                                                     code: -1,
                                                     userInfo: [NSLocalizedDescriptionKey: "Failed to load user data. Please try again."])))
                        }
                    }
                }
            } else {
                completion(.failure(NSError(domain: "com.boxfort.error",
                                         code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Login failed. Please try again."])))
            }
        }
    }
    
    func logout() {
        do {
            try auth.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func updateNewsletterSubscription(isSubscribed: Bool) {
        guard let userId = currentUser?.id,
              let email = currentUser?.email,
              let name = currentUser?.parentName else { return }
        
        // Only handle subscribing, not unsubscribing
        if isSubscribed {
            db.collection("users").document(userId).updateData([
                "isSubscribedToNewsletter": true
            ]) { error in
                if let error = error {
                    print("Error updating newsletter subscription: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.currentUser?.isSubscribedToNewsletter = true
                        
                        // Subscribe to Kit
                        self?.newsletterService.subscribe(email: email, name: name) { result in
                            switch result {
                            case .success:
                                print("Successfully subscribed to Kit newsletter")
                            case .failure(let error):
                                print("Error subscribing to Kit newsletter: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    let errorMessage: String
                    switch error._code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        errorMessage = "Please enter a valid email address."
                    case AuthErrorCode.userNotFound.rawValue:
                        errorMessage = "No account found with this email."
                    default:
                        errorMessage = error.localizedDescription
                    }
                    completion(.failure(NSError(domain: "com.boxfort.error",
                                             code: error._code,
                                             userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = auth.currentUser else {
            completion(.failure(NSError(domain: "com.boxfort.error",
                                     code: -1,
                                     userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."])))
            return
        }
        
        // First delete the user document from Firestore
        db.collection("users").document(user.uid).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(NSError(domain: "com.boxfort.error",
                                         code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Failed to delete user data: \(error.localizedDescription)"])))
                return
            }
            
            // Then delete the Firebase Auth account
            user.delete { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(NSError(domain: "com.boxfort.error",
                                                 code: -1,
                                                 userInfo: [NSLocalizedDescriptionKey: "Failed to delete account: \(error.localizedDescription)"])))
                    } else {
                        self.currentUser = nil
                        self.isAuthenticated = false
                        completion(.success(()))
                    }
                }
            }
        }
    }
} 