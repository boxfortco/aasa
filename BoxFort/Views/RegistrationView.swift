import SwiftUI

struct RegistrationView: View {
    @StateObject private var authService = AuthenticationService()
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var parentName = ""
    @State private var children: [ChildProfile] = []
    @State private var showingAddChild = false
    @State private var isSubscribedToNewsletter = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isParentConsentGiven = false
    @State private var isRegistering = false
    @State private var editingChild: ChildProfile? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Parent Information")) {
                        TextField("Parent/Guardian Name", text: $parentName)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textContentType(.newPassword)
                        if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Passwords do not match")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    Section(header: Text("Child Information")) {
                        ForEach(children) { child in
                            HStack {
                                if let avatar = child.avatar {
                                    avatar.image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                }
                                VStack(alignment: .leading) {
                                    Text(child.name)
                                        .font(.headline)
                                    Text("Age \(child.age)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: { editingChild = child }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            children.remove(atOffsets: indexSet)
                        }
                        
                        Button(action: { showingAddChild = true }) {
                            Label("Add Child", systemImage: "plus.circle.fill")
                        }
                    }
                    
                    Section(header: Text("Newsletter")) {
                        Toggle("Subscribe to Newsletter", isOn: $isSubscribedToNewsletter)
                    }
                    
                    Section(header: Text("Parental Consent")) {
                        Toggle("I am the parent or legal guardian of the child and consent to the collection of this information", isOn: $isParentConsentGiven)
                    }
                    
                    Section {
                        Button(action: register) {
                            if isRegistering {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Create Account")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                            }
                        }
                        .listRowBackground(Color.blue)
                        .disabled(!isFormValid || isRegistering)
                    }
                }
                .navigationTitle("Create Account")
                .navigationBarItems(trailing: Button("Cancel") {
                    dismiss()
                })
                .alert("Registration Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .sheet(isPresented: $showingAddChild) {
                    AddChildView(children: $children)
                }
                .sheet(item: $editingChild) { child in
                    EditChildView(children: $children, childToEdit: child)
                }
                .disabled(isRegistering)
                
                if isRegistering {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            VStack(spacing: 20) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                Text("Creating your account...")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        )
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        !parentName.isEmpty &&
        !children.isEmpty &&
        isParentConsentGiven
    }
    
    private func register() {
        guard isFormValid else { return }
        
        isRegistering = true
        authService.register(email: email, password: password, parentName: parentName, children: children) { result in
            isRegistering = false
            
            switch result {
            case .success:
                if isSubscribedToNewsletter {
                    authService.updateNewsletterSubscription(isSubscribed: true)
                }
                dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
} 