import Foundation

class NewsletterService {
    static let shared = NewsletterService()
    private let apiKey = "kit_f381217da82f1f59fc259de723273aba"  // Hardcoded for testing
    private let baseURL = "https://api.kit.com/v4"
    private let formId = "7963169"  // Form ID from the form URL
    
    private init() {}
    
    func subscribe(email: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Step 1: Create an inactive subscriber
        let createSubscriberURL = URL(string: "\(baseURL)/subscribers")!
        var createRequest = URLRequest(url: createSubscriberURL)
        createRequest.httpMethod = "POST"
        createRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        createRequest.setValue(apiKey, forHTTPHeaderField: "X-Kit-Api-Key")
        
        print("DEBUG: Using API key: \(apiKey)")
        
        let subscriberData: [String: Any] = [
            "email_address": email,
            "first_name": name,
            "state": "inactive"
        ]
        
        print("DEBUG: Step 1 - Creating inactive subscriber with email: \(email), name: \(name)")
        print("DEBUG: Using endpoint: \(createSubscriberURL.absoluteString)")
        
        do {
            createRequest.httpBody = try JSONSerialization.data(withJSONObject: subscriberData)
            print("DEBUG: Create subscriber request body: \(String(data: createRequest.httpBody!, encoding: .utf8) ?? "nil")")
        } catch {
            print("DEBUG: Error serializing create subscriber request body: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        // Step 2: Add subscriber to form
        let addToFormURL = URL(string: "\(baseURL)/forms/\(formId)/subscribers")!
        var formRequest = URLRequest(url: addToFormURL)
        formRequest.httpMethod = "POST"
        formRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        formRequest.setValue(apiKey, forHTTPHeaderField: "X-Kit-Api-Key")
        
        let formData: [String: Any] = [
            "email_address": email
        ]
        
        print("DEBUG: Step 2 - Adding subscriber to form with ID: \(formId)")
        print("DEBUG: Using endpoint: \(addToFormURL.absoluteString)")
        
        do {
            formRequest.httpBody = try JSONSerialization.data(withJSONObject: formData)
            print("DEBUG: Add to form request body: \(String(data: formRequest.httpBody!, encoding: .utf8) ?? "nil")")
        } catch {
            print("DEBUG: Error serializing add to form request body: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        // Execute both requests in sequence
        URLSession.shared.dataTask(with: createRequest) { data, response, error in
            if let error = error {
                print("DEBUG: Network error during create subscriber: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("DEBUG: Invalid response type during create subscriber")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            print("DEBUG: Create subscriber response status code: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("DEBUG: Create subscriber response body: \(responseString)")
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                // First request succeeded, now add to form
                URLSession.shared.dataTask(with: formRequest) { data, response, error in
                    if let error = error {
                        print("DEBUG: Network error during add to form: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("DEBUG: Invalid response type during add to form")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                        return
                    }
                    
                    print("DEBUG: Add to form response status code: \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("DEBUG: Add to form response body: \(responseString)")
                    }
                    
                    if (200...299).contains(httpResponse.statusCode) {
                        print("DEBUG: Successfully subscribed to Kit")
                        completion(.success(()))
                    } else {
                        // Try to parse error message from response
                        if let data = data,
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let errors = json["errors"] as? [String] {
                            print("DEBUG: Kit API error: \(errors.joined(separator: ", "))")
                            completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errors.joined(separator: ", ")])))
                        } else {
                            print("DEBUG: Unknown error during add to form")
                            completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to add to form"])))
                        }
                    }
                }.resume()
            } else {
                // Try to parse error message from response
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errors = json["errors"] as? [String] {
                    print("DEBUG: Kit API error: \(errors.joined(separator: ", "))")
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errors.joined(separator: ", ")])))
                } else {
                    print("DEBUG: Unknown error during create subscriber")
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to create subscriber"])))
                }
            }
        }.resume()
    }
    
    func checkSubscriptionStatus(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let encodedEmail = email.replacingOccurrences(of: "+", with: "%2B")
        let url = URL(string: "\(baseURL)/subscribers?email_address=\(encodedEmail)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Kit-Api-Key")
        
        print("DEBUG: Checking subscription status for email: \(email)")
        print("DEBUG: Using endpoint: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DEBUG: Network error during status check: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("DEBUG: Invalid response type during status check")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            print("DEBUG: Status check response status code: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("DEBUG: Status check response body: \(responseString)")
            }
            
            if (200...299).contains(httpResponse.statusCode),
               let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let subscribers = json["subscribers"] as? [[String: Any]] {
                // Check if any subscriber is active (not cancelled)
                let isSubscribed = subscribers.contains { subscriber in
                    if let state = subscriber["state"] as? String {
                        return state != "cancelled"
                    }
                    return false
                }
                print("DEBUG: Subscription status: \(isSubscribed ? "subscribed" : "unsubscribed")")
                completion(.success(isSubscribed))
            } else {
                print("DEBUG: Failed to check subscription status")
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to check subscription status"])))
            }
        }.resume()
    }
} 