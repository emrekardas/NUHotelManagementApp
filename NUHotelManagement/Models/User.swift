import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    var id: String?
    let email: String
    let firstName: String
    let lastName: String
    let displayName: String
    let role: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "uid"
        case email
        case firstName
        case lastName
        case displayName
        case role
        case createdAt
        case updatedAt
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
