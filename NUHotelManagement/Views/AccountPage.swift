//
//  AccountPage.swift
//  NUHotelManagement
//
//  Created by Emre on 06/12/2024.
//

import SwiftUI
import AuthenticationServices
import FirebaseCore
import FirebaseAuth

struct AccountPage: View {
    @StateObject private var authService = AuthService()
    @State private var isShowingLoginSheet = false
    @State private var isShowingSignUpSheet = false
    @Environment(\.colorScheme) var colorScheme
    
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                guard let nonce = authService.currentNonce else {
                    print("Invalid state: A login callback was received, but no login request was sent.")
                    return
                }
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data")
                    return
                }
                
                let credential = OAuthProvider.credential(
                    withProviderID: "apple.com",
                    idToken: idTokenString,
                    rawNonce: nonce
                )
                
                Task {
                    do {
                        try await authService.signInWithCredential(credential)
                    } catch {
                        print("Error signing in with Apple: \(error)")
                    }
                }
                
            default:
                break
            }
        case .failure(let error):
            print("Apple Sign In failed: \(error)")
        }
    }
    
    private func handleGoogleSignIn() {
        Task {
            do {
                try await authService.signInWithGoogle()
            } catch {
                print("Error signing in with Google: \(error)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if let user = authService.currentUser {
                    // Logged in view
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Header
                            VStack(spacing: 16) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundStyle(.linearGradient(colors: [.blue, .blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 140, height: 140)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 10)
                                
                                VStack(spacing: 8) {
                                    Text(user.displayName)
                                        .font(.title2)
                                        .bold()
                                    
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Text("Role: \(user.role)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(.blue.opacity(0.1))
                                        )
                                }
                            }
                            .padding(.top, 20)
                            
                            // Account Options
                            VStack(spacing: 12) {
                                AccountOptionButton(icon: "gear", title: "Settings", color: .gray)
                                AccountOptionButton(icon: "bell", title: "Notifications", color: .blue)
                                AccountOptionButton(icon: "lock", title: "Privacy", color: .green)
                                AccountOptionButton(icon: "questionmark.circle", title: "Help & Support", color: .purple)
                            }
                            .padding(.vertical)
                            
                            // Sign Out Button
                            Button(action: {
                                try? authService.signOut()
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Sign Out")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(Capsule())
                                .shadow(color: .red.opacity(0.3), radius: 5)
                            }
                        }
                        .padding()
                    }
                } else {
                    // Login/Sign up view
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.linearGradient(colors: [.blue, .blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            
                            VStack(spacing: 8) {
                                Text("Welcome")
                                    .font(.title)
                                    .bold()
                                
                                Text("Please sign in to continue")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 32)
                        
                        // Sign In Options
                        VStack(spacing: 16) {
                            // Email Sign In
                            AuthButton(
                                icon: "envelope.fill",
                                title: "Sign In with Email",
                                gradient: [.blue, .blue.opacity(0.8)],
                                action: { isShowingLoginSheet = true }
                            )
                            
                            // Google Sign In
                            AuthButton(
                                imageName: "google_logo",
                                title: "Continue with Google",
                                foregroundColor: .black,
                                backgroundColor: .white,
                                hasBorder: true,
                                action: handleGoogleSignIn
                            )
                            
                            // Apple Sign In
                            SignInWithAppleButton(
                                onRequest: { request in
                                    let nonce = authService.randomNonceString()
                                    authService.currentNonce = nonce
                                    request.requestedScopes = [.fullName, .email]
                                    request.nonce = authService.sha256(nonce)
                                },
                                onCompletion: handleAppleSignIn
                            )
                            .signInWithAppleButtonStyle(
                                colorScheme == .dark ? .white : .black
                            )
                            .frame(height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            
                            // Create Account
                            Button(action: { isShowingSignUpSheet = true }) {
                                Text("Create New Account")
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Account")
            .sheet(isPresented: $isShowingLoginSheet) {
                LoginView(authService: authService)
            }
            .sheet(isPresented: $isShowingSignUpSheet) {
                SignUpView(authService: authService)
            }
        }
    }
}

// Helper Views
struct AccountOptionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 30)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
        }
    }
}

struct AuthButton: View {
    let icon: String?
    let imageName: String?
    let title: String
    let gradient: [Color]?
    let foregroundColor: Color?
    let backgroundColor: Color?
    let hasBorder: Bool
    let action: () -> Void
    
    init(
        icon: String? = nil,
        imageName: String? = nil,
        title: String,
        gradient: [Color]? = nil,
        foregroundColor: Color? = .white,
        backgroundColor: Color? = nil,
        hasBorder: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.imageName = imageName
        self.title = title
        self.gradient = gradient
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.hasBorder = hasBorder
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                } else if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Group {
                    if let gradient = gradient {
                        LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing)
                    } else if let backgroundColor = backgroundColor {
                        backgroundColor
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Group {
                    if hasBorder {
                        Capsule()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    }
                }
            )
            .shadow(color: (gradient != nil) ? gradient!.first!.opacity(0.3) : .clear, radius: 5)
        }
    }
}

#Preview {
    AccountPage()
}
