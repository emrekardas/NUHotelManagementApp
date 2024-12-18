import FirebaseFirestore

struct ServiceRequest: Identifiable, Codable {
    var id: String?
    let type: String
    let notes: String
    let status: String
    let createdAt: Timestamp
    let bookingId: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case notes
        case status
        case createdAt
        case bookingId
        case userId
    }
} 