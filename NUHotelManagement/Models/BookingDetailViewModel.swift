//
//  BookingViewModel.swift
//  NUHotelManagement
//
//  Created by Emre on 16/12/2024.
//

import Foundation
import FirebaseFirestore

class BookingDetailViewModel: ObservableObject {
    @Published var booking: Booking?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let bookingService = BookingService()
    private let db = Firestore.firestore()
    
    func fetchBooking(bookingId: String) async {
        isLoading = true
        
        do {
            let document = try await db.collection("bookings").document(bookingId).getDocument()
            if document.exists {
                var booking = try document.data(as: Booking.self)
                booking.id = document.documentID
                DispatchQueue.main.async {
                    self.booking = booking
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Booking not found"])
                    self.isLoading = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func createBooking(
        userId: String,
        room: Room,
        startDate: Date,
        endDate: Date,
        numberOfGuests: Int,
        totalPrice: Double,
        specialRequests: String
    ) async throws {
        try await bookingService.createBooking(
            userId: userId,
            room: room,
            startDate: startDate,
            endDate: endDate,
            numberOfGuests: numberOfGuests,
            totalPrice: totalPrice,
            specialRequests: specialRequests
        )
    }
    
    func cancelBooking(bookingId: String) async throws {
        try await bookingService.cancelBooking(bookingId: bookingId)
        // Optionally refresh the booking after cancellation
        await fetchBooking(bookingId: bookingId)
    }
}
