import Firebase
import FirebaseFirestore
import Combine
import SwiftUI

final class RoomService: ObservableObject {
    @Published private(set) var rooms: [Room] = []
    private let db = Firestore.firestore()
    
    init() {
        fetchRooms()
    }
    
    func fetchRooms() {
        db.collection("rooms").addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching rooms: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self?.rooms = documents.compactMap { document -> Room? in
                let data = document.data()
                return Room(
                    id: document.documentID,
                    name: data["name"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    type: data["type"] as? String ?? "",
                    price: data["price"] as? Double ?? 0.0,
                    size: data["size"] as? String ?? "",
                    view: data["view"] as? String ?? "",
                    imageUrl: data["imageUrl"] as? String ?? "",
                    detailImageUrls: data["detailImageUrls"] as? [String] ?? [],
                    amenities: data["amenities"] as? [String] ?? [],
                    roomNumbers: data["roomNumbers"] as? [String] ?? [],
                    capacity: data["capacity"] as? Int ?? 0,
                    availability: data["availability"] as? Int ?? 0,
                    hasBalcony: data["hasBalcony"] as? Bool ?? false
                )
            }
        }
    }
}
