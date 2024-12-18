import Firebase
import FirebaseFirestore

class FirebaseConfig {
    static let shared = FirebaseConfig()
    
    private init() {
        FirebaseApp.configure()
    }
    
    // Firestore reference
    let db = Firestore.firestore()
}
