import Foundation
import SwiftUI

struct Avatar: Identifiable, Codable {
    let id: String
    let name: String
    let imageName: String
    
    static let allAvatars: [Avatar] = [
        Avatar(
            id: "patrick",
            name: "Patrick",
            imageName: "patrick"
        ),
        Avatar(
            id: "kevin",
            name: "Kevin",
            imageName: "kevin"
        ),
        Avatar(
            id: "arty",
            name: "Arty",
            imageName: "arty"
        ),
        Avatar(
            id: "drtoast",
            name: "Dr Toast",
            imageName: "drtoast"
        ),
        Avatar(
            id: "mrtaco",
            name: "Mr Taco",
            imageName: "mrtaco"
        ),
        Avatar(
            id: "business",
            name: "Business Marshmallow",
            imageName: "business"
        )
    ]
    
    var image: Image {
        Image(imageName)
    }
} 