import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @ObservedObject var authService: AuthenticationService
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var parentName = ""
    @State private var children: [ChildProfile] = []
    @State private var showingAddChild = false
    @State private var editingChild: ChildProfile? = nil
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var currentStep = 1
    
    private let avatars = [
        "person.fill",
        "person.2.fill",
        "person.3.fill",
        "person.crop.circle.fill",
        "person.crop.circle.badge.plus",
        "person.crop.circle.badge.checkmark"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Progress indicator
                        ProgressView(value: Double(currentStep), total: 3)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .padding(.horizontal)
                        
                        if currentStep == 1 {
                            parentInfoStep
                        } else if currentStep == 2 {
                            childProfilesStep
                        } else {
                            accountSetupStep
                        }
                    }
                    .padding(.top, 40)
                }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .sheet(isPresented: $showingAddChild) {
                AddChildView(children: $children)
            }
            .sheet(item: $editingChild) { child in
                EditChildView(children: $children, childToEdit: child)
            }
        }
    }
    
    private var parentInfoStep: some View {
        VStack(spacing: 25) {
            Text("Welcome to BoxFort!")
                .font(Font.custom("LondrinaSolid-Regular", size: 32))
                .foregroundColor(.white)
            
            Text("Let's create your family account")
                .font(Font.custom("LondrinaSolid-Light", size: 18))
                .foregroundColor(.white.opacity(0.8))
            
            VStack(spacing: 20) {
                TextField("Your Name", text: $parentName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(Font.custom("LondrinaSolid-Light", size: 16))
                }
                
                Button(action: { currentStep = 2 }) {
                    Text("Next: Add Children")
                        .font(Font.custom("LondrinaSolid-Regular", size: 20))
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(parentName.isEmpty || email.isEmpty)
            }
            .padding(.horizontal, 30)
        }
    }
    
    private var childProfilesStep: some View {
        VStack(spacing: 25) {
            Text("Add Your Children")
                .font(Font.custom("LondrinaSolid-Regular", size: 32))
                .foregroundColor(.white)
            
            Text("Create profiles for each child")
                .font(Font.custom("LondrinaSolid-Light", size: 18))
                .foregroundColor(.white.opacity(0.8))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(children) { child in
                        ChildProfileCard(child: child, onEdit: { editingChild = child })
                    }
                    
                    Button(action: { showingAddChild = true }) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                            Text("Add Child")
                                .font(Font.custom("LondrinaSolid-Light", size: 16))
                        }
                        .foregroundColor(.white)
                        .frame(width: 120, height: 160)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
            }
            
            HStack(spacing: 20) {
                Button(action: { currentStep = 1 }) {
                    Text("Back")
                        .font(Font.custom("LondrinaSolid-Regular", size: 18))
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray)
                .cornerRadius(10)
                
                Button(action: { currentStep = 3 }) {
                    Text("Next: Create Account")
                        .font(Font.custom("LondrinaSolid-Regular", size: 18))
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(children.isEmpty)
            }
            .padding(.horizontal, 30)
        }
    }
    
    private var accountSetupStep: some View {
        VStack(spacing: 25) {
            Text("Create Your Account")
                .font(Font.custom("LondrinaSolid-Regular", size: 32))
                .foregroundColor(.white)
            
            Text("Set up your password")
                .font(Font.custom("LondrinaSolid-Light", size: 18))
                .foregroundColor(.white.opacity(0.8))
            
            VStack(spacing: 20) {
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(Font.custom("LondrinaSolid-Light", size: 16))
                }
                
                HStack(spacing: 20) {
                    Button(action: { currentStep = 2 }) {
                        Text("Back")
                            .font(Font.custom("LondrinaSolid-Regular", size: 18))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
                    
                    Button(action: register) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Create Account")
                                .font(Font.custom("LondrinaSolid-Regular", size: 18))
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(isLoading || password.isEmpty || password != confirmPassword)
                }
            }
            .padding(.horizontal, 30)
        }
    }
    
    private func register() {
        guard !parentName.isEmpty else {
            errorMessage = "Please enter your name"
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "Please enter email"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter password"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard !children.isEmpty else {
            errorMessage = "Please add at least one child"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authService.register(email: email, password: password, parentName: parentName, children: children) { result in
            isLoading = false
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct ChildProfileCard: View {
    let child: ChildProfile
    var onEdit: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                if let avatar = child.avatar {
                    avatar.image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                }
                
                Text(child.name)
                    .font(Font.custom("LondrinaSolid-Regular", size: 18))
                    .foregroundColor(.white)
                
                Text("Age \(child.age)")
                    .font(Font.custom("LondrinaSolid-Light", size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 120, height: 160)
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            
            Button(action: onEdit) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                }
            }
            .offset(x: 10, y: -10)
        }
    }
} 