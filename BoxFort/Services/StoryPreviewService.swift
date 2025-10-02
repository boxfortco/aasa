import Foundation
import UIKit
import SwiftyGif

struct StoryPreviewCard: Equatable {
    let book: Book
    let previewPages: [String]
    let animatedGif: Data?
    let deepLink: URL
    let shareText: String
    let qrCode: UIImage?
    let previewImage: UIImage?
    
    static func == (lhs: StoryPreviewCard, rhs: StoryPreviewCard) -> Bool {
        return lhs.book.id == rhs.book.id &&
               lhs.deepLink == rhs.deepLink &&
               lhs.shareText == rhs.shareText
    }
}

class StoryPreviewService: ObservableObject {
    static let shared = StoryPreviewService()
    
    private init() {}
    
    // MARK: - Deep Link Generation
    
    func generateDeepLink(for book: Book) -> URL {
        // Generate search query based on book title and characters
        let searchQuery = generateSearchQuery(for: book)
        let baseURL = "boxfort://search"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
        let urlString = "\(baseURL)?q=\(encodedQuery)"
        return URL(string: urlString) ?? URL(string: "boxfort://")!
    }
    
    // MARK: - Web Deep Link Generation (for sharing outside the app)
    
    func generateWebDeepLink(for book: Book) -> URL {
        // Generate search query based on book title and characters
        let searchQuery = generateSearchQuery(for: book)
        let baseURL = "https://boxfortco.github.io/aasa/search"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
        let urlString = "\(baseURL)?q=\(encodedQuery)"
        return URL(string: urlString) ?? URL(string: "https://boxfortco.github.io")!
    }
    
    // MARK: - Search Query Generation
    
    func generateSearchQuery(for book: Book) -> String {
        // Create a clean, simple search query that will find this book
        var searchTerms: [String] = []
        
        // Add book title words (excluding common words)
        let titleWords = book.title.components(separatedBy: .whitespacesAndNewlines)
            .filter { !["the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by"].contains($0.lowercased()) }
        
        // Take only the first 2-3 meaningful words from the title
        let meaningfulWords = Array(titleWords.prefix(3))
        searchTerms.append(contentsOf: meaningfulWords)
        
        // Add only the main character (first one) if available
        if let mainCharacter = book.characters.first {
            searchTerms.append(mainCharacter)
        }
        
        // Remove duplicates and join
        let uniqueTerms = Array(Set(searchTerms))
        return uniqueTerms.joined(separator: " ")
    }
    
    // MARK: - Preview Card Generation
    
    func generatePreviewCard(for book: Book) async -> StoryPreviewCard {
        let deepLink = generateDeepLink(for: book)
        let webLink = generateWebDeepLink(for: book)
        let shareText = generateShareText(for: book)
        
        // Generate preview image
        let previewImage = await generatePreviewImage(for: book)
        
        // Generate QR code using web deep link for immediate reading
        let qrCode = generateQRCode(for: webLink)
        
        // Select preview pages (first 3-4 pages)
        let previewPages = Array(book.pages.prefix(min(4, book.pages.count)))
        
        // Generate animated preview (optional)
        let animatedGif = await generateAnimatedPreview(for: book)
        
        return StoryPreviewCard(
            book: book,
            previewPages: previewPages,
            animatedGif: animatedGif,
            deepLink: deepLink,
            shareText: shareText,
            qrCode: qrCode,
            previewImage: previewImage
        )
    }
    
    // MARK: - Share Text Generation
    
    func generateShareText(for book: Book) -> String {
        let webLink = generateWebDeepLink(for: book)
        let templates = [
            "📚 Check out '\(book.title)' on BoxFort! My kids love this story!\n\nDownload the app: https://apps.apple.com/us/app/boxfort-kids-books/id6443570027",
            "🌟 Just discovered '\(book.title)' on BoxFort! It's become our new favorite bedtime story!\n\nDownload the app: https://apps.apple.com/us/app/boxfort-kids-books/id6443570027",
            "📖 '\(book.title)' is pure magic!\n\nDownload BoxFort and join the fun: https://apps.apple.com/us/app/boxfort-kids-books/id6443570027"
        ]
        
        return templates.randomElement() ?? "Check out \(book.title) on BoxFort!\n\nDownload the app: https://apps.apple.com/us/app/boxfort-kids-books/id6443570027"
    }
    
    // MARK: - QR Code Generation
    
    func generateQRCode(for url: URL) -> UIImage? {
        guard let data = url.absoluteString.data(using: .utf8) else { return nil }
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(data, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let qrImage = qrFilter?.outputImage else { return nil }
        
        // Scale the QR code
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        
        // Create a simple background
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        
        return renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
            
            // Draw QR code
            let ciContext = CIContext()
            if let cgImage = ciContext.createCGImage(scaledQrImage, from: scaledQrImage.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                uiImage.draw(in: CGRect(x: 20, y: 20, width: 160, height: 160))
            }
        }
    }
    
    // MARK: - Preview Image Generation
    
    func generatePreviewImage(for book: Book) async -> UIImage? {
        // Simply return the book's poster image
        return UIImage(named: book.posterImage)
    }
    
    // MARK: - Deep Link Parsing
    
    func parseBookDeepLink(from url: URL) -> String? {
        guard url.scheme == "boxfort" else { return nil }
        
        if url.host == "book" {
            // Support both "id" and "book_id" parameters for backward compatibility
            return url.queryParameters?["book_id"] ?? url.queryParameters?["id"]
        }
        
        return nil
    }
    
    func parseSearchDeepLink(from url: URL) -> String? {
        // Handle custom URL schemes (boxfort://search?q=...)
        if url.scheme == "boxfort" && url.host == "search" {
            return url.queryParameters?["q"]
        }
        
        // Handle Universal Links (https://boxfortco.github.io/aasa/search?q=...)
        if url.scheme == "https" && url.host == "boxfortco.github.io" && url.path.hasPrefix("/aasa/search") {
            return url.queryParameters?["q"]
        }
        
        return nil
    }
    
    // MARK: - Animated Preview Generation
    
    func generateAnimatedPreview(for book: Book) async -> Data? {
        // Get first 3-4 pages for animation
        let previewPages = Array(book.pages.prefix(min(4, book.pages.count)))
        
        // For now, return the existing GIF if available
        if let gifURL = Bundle.main.url(forResource: book.posterImage, withExtension: "gif"),
           let gifData = try? Data(contentsOf: gifURL) {
            return gifData
        }
        
        // TODO: In the future, we could implement dynamic GIF generation
        // by combining multiple page images into an animated GIF
        // This would involve:
        // 1. Loading each page image
        // 2. Creating frames for animation
        // 3. Combining into GIF format
        
        return nil
    }
} 