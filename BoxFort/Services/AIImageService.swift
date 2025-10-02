import Foundation
import UIKit

class AIImageService: ObservableObject {
    private let openAIAPIKey = "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"
    private let openAIURL = "https://api.openai.com/v1/images/edits"
    
    @Published var isProcessing = false
    @Published var error: String?
    
    func generateImageWithPatrick(originalImage: UIImage, childName: String? = nil) async throws -> String {
        DispatchQueue.main.async {
            self.isProcessing = true
            self.error = nil
        }
        
        do {
            // 1. Load the Patrick character model from assets.
            guard let patrickImage = UIImage(named: "Scrapbook") else {
                throw NSError(domain: "AIImageService", code: 100, userInfo: [NSLocalizedDescriptionKey: "Character asset 'Scrapbook' not found."])
            }
            
            // 2. Resize images to a standard size to reduce upload payload and processing time.
            let targetSize = CGSize(width: 1024, height: 1024)
            let resizedUserImage = originalImage.resized(to: targetSize)
            let resizedPatrickImage = patrickImage.resized(to: targetSize)

            // 3. Convert both resized images to JPEG data to reduce file size.
            guard let userImageData = resizedUserImage.jpegData(compressionQuality: 0.7),
                  let patrickImageData = resizedPatrickImage.jpegData(compressionQuality: 0.7) else {
                throw NSError(domain: "AIImageService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert images to JPEG data."])
            }
            
            // 4. Create the prompt.
            let prompt = """
            Your task is to place the cartoon character from the first image into the scene from the second image.
            Follow these rules strictly:
            1. The second image (the scene) is the base. It MUST NOT BE ALTERED. Do not change, distort, or modify any part of the original scene, especially any people in it. The background and all original elements must remain identical.
            2. The first image (the character) should be placed onto the scene. Integrate it naturally by matching the lighting, shadows, and perspective.
            3. The character MUST maintain its original proportions and art style. DO NOT stretch, warp, or distort the character.
            4. Do not obscure any main subjects in the scene.

            To be clear: The only change to the second image should be the addition of the character from the first image.
            """

            // 5. Construct the multipart/form-data request body.
            let boundary = UUID().uuidString
            var request = URLRequest(url: URL(string: openAIURL)!)
            request.httpMethod = "POST"
            request.timeoutInterval = 180 // Set a longer timeout of 3 minutes.
            request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            // Add model parameter
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
            body.append("gpt-image-1\r\n".data(using: .utf8)!)
            
            // Add prompt
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(prompt)\r\n".data(using: .utf8)!)
            
            // Add Patrick image data (first image)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image[]\"; filename=\"patrick.jpeg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(patrickImageData)
            body.append("\r\n".data(using: .utf8)!)
            
            // Add user's scene image data (second image)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image[]\"; filename=\"scene.jpeg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(userImageData)
            body.append("\r\n".data(using: .utf8)!)
            
            // Add size parameter
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"size\"\r\n\r\n".data(using: .utf8)!)
            body.append("1024x1024\r\n".data(using: .utf8)!)
            
            // End boundary
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            // 6. Make the API request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let errorString = String(data: data, encoding: .utf8) ?? "Unknown API Error"
                throw NSError(domain: "AIImageService", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "API Error: \(errorString)"])
            }
            
            // 7. Parse the response to get the base64 data of the generated image.
            let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let responseData = jsonResponse?["data"] as? [[String: Any]],
                  let firstImage = responseData.first,
                  let base64String = firstImage["b64_json"] as? String else {
                throw NSError(domain: "AIImageService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not find valid base64 image data in the API response."])
            }
            
            return base64String
            
        } catch {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.error = error.localizedDescription
            }
            throw error
        }
    }
} 