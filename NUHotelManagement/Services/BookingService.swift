//
//  BookingService.swift
//  NUHotelManagement
//
//  Created by Emre on 16/12/2024.
//
// Services/BookingService.swift

import Foundation
import FirebaseFirestore
import FirebaseAuth

class BookingService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var bookings: [Booking] = []
    
    // Mevcut bookingleri kontrol edip müsait oda numarası bulma
    private func findAvailableRoomNumber(for room: Room, startDate: Date, endDate: Date) async throws -> String {
        let bookingsRef = db.collection("bookings")
        
        // Bu oda için mevcut tüm bookingleri al
        let bookings = try await bookingsRef
            .whereField("roomId", isEqualTo: room.id ?? "")
            .whereField("status", isEqualTo: "confirmed")
            .getDocuments()
        
        // Tüm oda numaralarını set olarak al
        var availableNumbers = Set(room.roomNumbers)
        
        // Mevcut bookinglerdeki tarihleri kontrol et
        for booking in bookings.documents {
            let bookingData = try booking.data(as: Booking.self)
            
            // Tarih çakışması kontrolü
            let bookingStart = bookingData.startDate.dateValue()
            let bookingEnd = bookingData.endDate.dateValue()
            
            if (startDate <= bookingEnd && endDate >= bookingStart) {
                // Tarih çakışması varsa, bu oda numarasını müsait numaralardan çıkar
                availableNumbers.remove(bookingData.roomNumber)
            }
        }
        
        // Müsait numara yoksa hata fırlat
        guard let randomRoomNumber = availableNumbers.randomElement() else {
            throw BookingError.noAvailableRooms
        }
        
        return randomRoomNumber
    }
    
    // Booking oluşturma fonksiyonu
    func createBooking(userId: String, room: Room, startDate: Date, endDate: Date, numberOfGuests: Int, totalPrice: Double, specialRequests: String) async throws -> String {
        let booking = Booking(
            id: nil,
            userId: userId,
            roomId: room.id ?? "",
            roomName: room.name,
            roomNumber: try await findAvailableRoomNumber(for: room, startDate: startDate, endDate: endDate),
            roomImageUrl: room.imageUrl,
            startDate: Timestamp(date: startDate),
            endDate: Timestamp(date: endDate),
            numberOfGuests: numberOfGuests,
            status: "confirmed",
            totalPrice: totalPrice,
            createdAt: Timestamp(date: Date()),
            specialRequests: specialRequests
        )
        
        let documentRef = try await db.collection("bookings").addDocument(data: [
            "userId": booking.userId,
            "roomId": booking.roomId,
            "roomName": booking.roomName,
            "roomNumber": booking.roomNumber,
            "roomImageUrl": booking.roomImageUrl,
            "startDate": booking.startDate,
            "endDate": booking.endDate,
            "numberOfGuests": booking.numberOfGuests,
            "status": booking.status,
            "totalPrice": booking.totalPrice,
            "createdAt": booking.createdAt,
            "specialRequests": booking.specialRequests
        ])
        
        return documentRef.documentID
    }
    
    func fetchUserBookings(userId: String) async throws -> [Booking] {
        let snapshot = try await db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            var booking = try document.data(as: Booking.self)
            booking.id = document.documentID
            return booking
        }
    }
    
    func cancelBooking(bookingId: String) async throws {
        try await db.collection("bookings")
            .document(bookingId)
            .updateData(["status": "cancelled"])
    }
}

enum BookingError: Error {
    case noAvailableRooms
    case invalidDates
    case bookingFailed
    
    var localizedDescription: String {
        switch self {
        case .noAvailableRooms:
            return "No available rooms for the selected dates"
        case .invalidDates:
            return "Invalid booking dates"
        case .bookingFailed:
            return "Booking creation failed"
        }
    }
}

// Codable extension for dictionary conversion
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Failed to encode as dictionary"))
        }
        return dictionary
    }
}