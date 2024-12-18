import SwiftUI
import FirebaseFirestore
import Foundation

struct Room: Identifiable, Codable {
    var id: String?
    let name: String
    let description: String
    let type: String
    let price: Double
    let size: String
    let view: String
    let imageUrl: String
    let detailImageUrls: [String]
    let amenities: [String]
    let roomNumbers: [String]
    let capacity: Int
    let availability: Int
    let hasBalcony: Bool
}
