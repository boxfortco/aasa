import SwiftUI

struct EditChildView: View {
    @Binding var children: [ChildProfile]
    let childToEdit: ChildProfile
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var age: Int
    @State private var selectedAvatarId: String
    
    init(children: Binding<[ChildProfile]>, childToEdit: ChildProfile) {
        self._children = children
        self.childToEdit = childToEdit
        self._name = State(initialValue: childToEdit.name)
        self._age = State(initialValue: childToEdit.age)
        self._selectedAvatarId = State(initialValue: childToEdit.avatarId)
    }
    
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
                        Text("Edit Child")
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
                            
                            Button(action: saveChanges) {
                                Text("Save Changes")
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
    
    private func saveChanges() {
        if let index = children.firstIndex(where: { $0.id == childToEdit.id }) {
            let updatedChild = ChildProfile(
                id: childToEdit.id,
                name: name,
                age: age,
                avatarId: selectedAvatarId
            )
            children[index] = updatedChild
        }
        dismiss()
    }
}

#Preview {
    EditChildView(
        children: .constant([]),
        childToEdit: ChildProfile(name: "Test Child", age: 5, avatarId: "patrick")
    )
} 