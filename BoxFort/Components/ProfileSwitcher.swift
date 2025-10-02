import SwiftUI

struct ProfileSwitcher: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var selectedChildId: String?
    @State private var showingProfileSheet = false
    @State private var showingAddChild = false
    
    var selectedChild: ChildProfile? {
        guard let id = selectedChildId else { return userViewModel.user?.children.first }
        return userViewModel.user?.children.first(where: { $0.id == id })
    }
    
    var body: some View {
        // Kid Profile Button
        if let child = selectedChild, let avatar = child.avatar {
            Button(action: {
                print("DEBUG: Tapped kid profile")
                showingProfileSheet = true
            }) {
                avatar.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingProfileSheet) {
                ProfileSelectionSheet(
                    selectedChildId: $selectedChildId,
                    isPresented: $showingProfileSheet,
                    showingAddChild: $showingAddChild
                )
            }
            .sheet(isPresented: $showingAddChild) {
                if let user = userViewModel.user {
                    AddChildView(children: Binding(
                        get: { user.children },
                        set: { newChildren in
                            userViewModel.user?.children = newChildren
                        }
                    ))
                }
            }
        }
    }
}

struct ProfileSelectionSheet: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var selectedChildId: String?
    @Binding var isPresented: Bool
    @Binding var showingAddChild: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 120, maximum: 140), spacing: 20)
                ], spacing: 20) {
                    ForEach(userViewModel.user?.children ?? []) { child in
                        Button(action: {
                            print("DEBUG: Selected child: \(child.name)")
                            selectedChildId = child.id
                            isPresented = false
                        }) {
                            VStack {
                                if let avatar = child.avatar {
                                    avatar.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(selectedChildId == child.id ? Color.blue : Color.clear, lineWidth: 3)
                                        )
                                }
                                
                                Text(child.name)
                                    .font(Font.custom("LondrinaSolid-Regular", size: 18))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                Button(action: {
                    showingAddChild = true
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add Child")
                            .font(Font.custom("LondrinaSolid-Regular", size: 18))
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Select Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 