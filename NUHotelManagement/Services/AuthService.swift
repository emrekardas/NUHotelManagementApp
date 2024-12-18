import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import CryptoKit
import AuthenticationServices

// Rename User to AppUser to avoid conflicts with FirebaseAuth.User
struct AppUser: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let displayName: String
    let role: String
    let createdAt: Date
    let updatedAt: Date
    
    // Add initializer for social sign in
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.firstName = firebaseUser.displayName?.components(separatedBy: " ").first ?? ""
        self.lastName = firebaseUser.displayName?.components(separatedBy: " ").last ?? ""
        self.displayName = firebaseUser.displayName ?? ""
        self.role = "customer"
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Regular initializer
    init(id: String, email: String, firstName: String, lastName: String, displayName: String, role: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

class AuthService: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false
    var currentNonce: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                Task {
                    await self?.fetchUserData(userId: user.uid)
                }
            } else {
                DispatchQueue.main.async {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            await fetchUserData(userId: result.user.uid)
            
            // Login başarılı olduğunda notification gönder
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("RefreshAfterLogin"),
                    object: nil
                )
            }
        } catch {
            throw error
        }
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async throws {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let uid = result.user.uid
            
            let now = Date()
            let user = AppUser(
                id: uid,
                email: email,
                firstName: firstName,
                lastName: lastName,
                displayName: "\(firstName) \(lastName)",
                role: "customer",
                createdAt: now,
                updatedAt: now
            )
            try await saveUserToFirestore(user)
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        } catch {
            throw error
        }
    }
    
    private func fetchUserData(userId: String) async {
        do {
            let docRef = db.collection("users").document(userId)
            let document = try await docRef.getDocument()
            
            if let data = document.data() {
                let user = AppUser(
                    id: data["id"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    firstName: data["firstName"] as? String ?? "",
                    lastName: data["lastName"] as? String ?? "",
                    displayName: data["displayName"] as? String ?? "",
                    role: data["role"] as? String ?? "customer",
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                    updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                )
                
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            } else {
                // If user doesn't exist in Firestore but exists in Auth
                if let firebaseUser = auth.currentUser {
                    let newUser = AppUser(from: firebaseUser)
                    try? await saveUserToFirestore(newUser)
                    DispatchQueue.main.async {
                        self.currentUser = newUser
                        self.isAuthenticated = true
                    }
                }
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        }
    }
    
    private func saveUserToFirestore(_ user: AppUser) async throws {
        let docRef = db.collection("users").document(user.id)
        let userData: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "displayName": user.displayName,
            "role": user.role,
            "createdAt": user.createdAt,
            "updatedAt": user.updatedAt
        ]
        try await docRef.setData(userData)
    }
    
    // Google Sign In
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = userAuthentication.user.idToken?.tokenString else { throw NSError() }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: userAuthentication.user.accessToken.tokenString
            )
            
            try await signInWithCredential(credential)
        } catch {
            throw error
        }
    }
    
    // Apple Sign In helpers
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Firebase Auth with credential
    func signInWithCredential(_ credential: AuthCredential) async throws {
        do {
            let result = try await Auth.auth().signIn(with: credential)
            let user = AppUser(from: result.user)
            try await saveUserToFirestore(user)
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            throw error
        }
    }
}

enum AuthError: Error {
    case userIdNotFound
}
