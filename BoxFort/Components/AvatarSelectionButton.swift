import SwiftUI

struct AvatarSelectionButton: View {
    let avatar: Avatar
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                avatar.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
                
                Text(avatar.name)
                    .font(Font.custom("LondrinaSolid-Regular", size: 16))
                    .foregroundColor(.white)
            }
        }
    }
} 