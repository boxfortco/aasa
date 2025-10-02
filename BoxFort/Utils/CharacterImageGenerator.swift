import UIKit
import SwiftUI

class CharacterImageGenerator {
    static func generatePlaceholderImage(name: String, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            let backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Border
            let borderColor = UIColor.systemBlue
            borderColor.setStroke()
            let borderRect = CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2)
            context.stroke(borderRect)
            
            // Text
            let textColor = UIColor.systemBlue
            let textFont = UIFont.systemFont(ofSize: 16, weight: .medium)
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: textFont,
                .foregroundColor: textColor
            ]
            
            let textSize = name.size(withAttributes: textAttributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            name.draw(in: textRect, withAttributes: textAttributes)
        }
    }
    
    static func generateCharacterPartImages() {
        let imageNames = [
            // Default pack
            "character_head_basic_1", "character_head_basic_2",
            "character_torso_basic_1", "character_torso_basic_2", 
            "character_legs_basic_1", "character_legs_basic_2",
            
            // Patrick pack
            "character_head_patrick_1", "character_head_patrick_2",
            "character_torso_patrick_1", "character_torso_patrick_2",
            "character_legs_patrick_1", "character_legs_patrick_2",
            
            // Kevin pack
            "character_head_kevin_1", "character_head_kevin_2",
            "character_torso_kevin_1", "character_torso_kevin_2",
            "character_legs_kevin_1", "character_legs_kevin_2",
            
            // Arty pack
            "character_head_arty_1", "character_head_arty_2",
            "character_torso_arty_1", "character_torso_arty_2",
            "character_legs_arty_1", "character_legs_arty_2"
        ]
        
        for imageName in imageNames {
            let image = generatePlaceholderImage(name: imageName)
            
            // Save to documents directory for testing
            if let data = image.pngData() {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let imagePath = documentsPath.appendingPathComponent("\(imageName).png")
                
                do {
                    try data.write(to: imagePath)
                    print("Generated placeholder image: \(imagePath)")
                } catch {
                    print("Failed to save placeholder image: \(error)")
                }
            }
        }
    }
}

// Extension to create UIImage from SwiftUI Color
extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
} 