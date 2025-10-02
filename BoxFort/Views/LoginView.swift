import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @ObservedObject var authService: AuthenticationService
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var shouldDismiss = false
    @State private var showingForgotPassword = false
    @State private var resetEmailSent = false
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                
                VStack(spacing: 30) {
                    Text("Login")
                        .font(Font.custom("LondrinaSolid-Regular", size: 38))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(Font.custom("LondrinaSolid-Light", size: 16))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button(action: login) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Login")
                                    .font(Font.custom("LondrinaSolid-Regular", size: 20))
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isLoading || email.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .contentShape(Rectangle())
                        
                        Button(action: { showingForgotPassword = true }) {
                            Text("Forgot Password?")
                                .font(Font.custom("LondrinaSolid-Light", size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 30)
                }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert("Reset Password", isPresented: $showingForgotPassword) {
                TextField("Enter your email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                Button("Cancel", role: .cancel) { }
                Button("Reset") {
                    resetPassword()
                }
            } message: {
                Text("Enter your email address and we'll send you a link to reset your password.")
            }
            .alert("Password Reset Email Sent", isPresented: $resetEmailSent) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Check your email for instructions to reset your password.")
            }
        }
        .onChange(of: shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
    }
    
    private func login() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authService.login(email: email, password: password) { result in
            isLoading = false
            switch result {
            case .success:
                shouldDismiss = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }
        
        authService.resetPassword(email: email) { result in
            switch result {
            case .success:
                resetEmailSent = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
} 