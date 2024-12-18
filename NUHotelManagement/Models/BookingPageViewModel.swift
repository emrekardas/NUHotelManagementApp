// ViewModels/BookingPageViewModel.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

class BookingPageViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove() // Listener'ı temizle
    }
    
    init() {
        fetchUserBookings()
    }
    
    func fetchUserBookings() {
        guard let userId = Auth.auth().currentUser?.uid else { 
            print("⚠️ No user logged in")
            return 
        }
        
        print("👤 Fetching bookings for user: \(userId)")
        isLoading = true
        
        // Varsa önceki listener'ı temizle
        listener?.remove()
        
        listener = db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    print("❌ Error fetching bookings: \(error.localizedDescription)")
                    self.error = error.localizedDescription
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("📄 No documents found")
                    self.bookings = []
                    return
                }
                
                print("📚 Found \(documents.count) booking documents")
                
                // Unique ID'leri takip etmek için Set kullan
                var uniqueBookings: [String: Booking] = [:]
                
                for document in documents {
                    do {
                        var booking = try document.data(as: Booking.self)
                        booking.id = document.documentID
                        uniqueBookings[document.documentID] = booking
                        print("✅ Added/Updated booking: \(document.documentID)")
                    } catch {
                        print("❌ Error decoding booking: \(error)")
                        print("📄 Document data: \(document.data())")
                    }
                }
                
                // Dictionary'den Array'e çevir
                self.bookings = Array(uniqueBookings.values)
                    .sorted { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
                
                print("📱 Final unique bookings count: \(self.bookings.count)")
            }
    }
    
    func cancelBooking(_ booking: Booking) {
        let now = Date()
        guard booking.startDate.dateValue() > now else {
            self.error = "Cannot cancel a booking after check-in date"
            return
        }
        
        Task {
            do {
                try await db.collection("bookings")
                    .document(booking.id!)
                    .updateData(["status": "cancelled"])
                
                await fetchUserBookings()
            } catch {
                print("❌ Error cancelling booking: \(error)")
                self.error = error.localizedDescription
            }
        }
    }
    
    func requestService(service: String, notes: String, for booking: Booking) {
        guard let bookingId = booking.id,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        let serviceRequest = ServiceRequest(
            id: nil,
            type: service,
            notes: notes,
            status: "pending",
            createdAt: Timestamp(date: Date()),
            bookingId: bookingId,
            userId: userId
        )
        
        Task {
            do {
                try await db.collection("serviceRequests").addDocument(from: serviceRequest)
                print("✅ Service requested successfully")
            } catch {
                print("❌ Error requesting service: \(error)")
                self.error = error.localizedDescription
            }
        }
    }
}