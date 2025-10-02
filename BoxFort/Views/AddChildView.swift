import SwiftUI

struct AddChildView: View {
    @Binding var children: [ChildProfile]
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var age = 3
    @State private var selectedAvatarId = Avatar.allAvatars[0].id
    @State private var showError = false
    @State private var errorMessage = ""
    
    private var avatarGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(Avatar.allAvatars) { avatar in
                    AvatarSelectionButton(
                        avatar: avatar,
                        isSelected: selectedAvatarId == avatar.id,
                        action: { selectedAvatarId = avatar.id }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Text("Add Child")
                            .font(Font.custom("LondrinaSolid-Regular", size: 32))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 20) {
                            TextField("Child's Name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                            
                            Stepper("Age: \(age)", value: $age, in: 0...21)
                                .foregroundColor(.white)
                            
                            Text("Choose Your Character")
                                .font(Font.custom("LondrinaSolid-Regular", size: 18))
                                .foregroundColor(.white)
                            
                            avatarGrid
                            
                            Button(action: addChild) {
                                Text("Add Child")
                                    .font(Font.custom("LondrinaSolid-Regular", size: 20))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .disabled(name.isEmpty)
                        }
                        .padding(.horizontal, 30)
                    }
                }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func addChild() {
        // Validate inputs
        guard !name.isEmpty else {
            errorMessage = "Please enter a name"
            showError = true
            return
        }
        
        // Create new child profile
        let newChild = ChildProfile(
            name: name,
            age: age,
            avatarId: selectedAvatarId
        )
        
        // Add to children array
        children.append(newChild)
        
        // Dismiss view
        dismiss()
    }
}

#Preview {
    AddChildView(children: .constant([]))
} 