//
//  BookingDetailView.swift
//  NUHotelManagement
//
//  Created by Emre on 16/12/2024.
//
// Views/Components/BookingDetailView.swift

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BookingDetailView: View {
    @StateObject private var viewModel = BookingDetailViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    // Booking oluşturma için gerekli state'ler
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(24 * 60 * 60)
    @State private var numberOfGuests = 1
    @State private var specialRequests = ""
    
    let bookingId: String?
    let room: Room?
    
    init(bookingId: String? = nil, room: Room? = nil) {
        self.bookingId = bookingId
        self.room = room
    }
    
    var body: some View {
        Group {
            if let bookingId = bookingId {
                // Mevcut booking detayları
                ScrollView {
                    existingBookingView
                }
            } else if let room = room {
                // Yeni booking oluşturma formu
                newBookingView(room: room)
            }
        }
        .navigationTitle(bookingId != nil ? "Booking Details" : "New Booking")
        .alert("Booking Status", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .task {
            if let bookingId = bookingId {
                await viewModel.fetchBooking(bookingId: bookingId)
            }
        }
    }
    
    // Mevcut booking detayları
    private var existingBookingView: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            } else if let booking = viewModel.booking {
                // Booking Details
                VStack(alignment: .leading, spacing: 16) {
                    // Room Image
                    AsyncImage(url: URL(string: booking.roomImageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Room Info
                    Group {
                        DetailRow(title: "Room", value: booking.roomName)
                        DetailRow(title: "Room Number", value: booking.roomNumber)
                        DetailRow(title: "Check-in", value: booking.getFormattedDate(booking.startDate, format: .medium))
                        DetailRow(title: "Check-out", value: booking.getFormattedDate(booking.endDate, format: .medium))
                        DetailRow(title: "Number of Nights", value: "\(booking.numberOfNights)")
                        DetailRow(title: "Guests", value: "\(booking.numberOfGuests)")
                        DetailRow(title: "Total Price", value: "$\(String(format: "%.2f", booking.totalPrice))")
                        DetailRow(title: "Status", value: booking.status.capitalized)
                        DetailRow(title: "Booking Date", value: booking.getFormattedDate(booking.createdAt, format: .custom("dd MMM yyyy HH:mm")))
                        
                        if !booking.specialRequests.isEmpty {
                            DetailRow(title: "Special Requests", value: booking.specialRequests)
                        }
                    }
                    
                    // Cancel Button
                    if booking.status == "confirmed" {
                        Button(action: {
                            Task {
                                do {
                                    try await viewModel.cancelBooking(bookingId: bookingId!)
                                    alertMessage = "Booking cancelled successfully"
                                    showAlert = true
                                } catch {
                                    alertMessage = "Failed to cancel booking: \(error.localizedDescription)"
                                    showAlert = true
                                }
                            }
                        }) {
                            Text("Cancel Booking")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                }
                .padding()
            }
        }
    }
    
    // Yeni booking oluşturma formu
    private func newBookingView(room: Room) -> some View {
        Form {
            Section(header: Text("Room Details")) {
                AsyncImage(url: URL(string: room.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(room.name)
                    .font(.headline)
                Text("$\(room.price, specifier: "%.2f") per night")
                    .foregroundColor(.blue)
            }
            
            Section(header: Text("Booking Details")) {
                DatePicker("Check-in", selection: $startDate, in: Date()..., displayedComponents: [.date])
                DatePicker("Check-out", selection: $endDate, in: startDate..., displayedComponents: [.date])
                Stepper("Number of Guests: \(numberOfGuests)", value: $numberOfGuests, in: 1...room.capacity)
            }
            
            Section(header: Text("Special Requests")) {
                TextEditor(text: $specialRequests)
                    .frame(height: 100)
            }
            
            Section(header: Text("Price Details")) {
                let nights = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
                VStack(alignment: .leading, spacing: 8) {
                    Text("Number of nights: \(nights)")
                    Text("Price per night: $\(room.price, specifier: "%.2f")")
                    Text("Total Price: $\(room.price * Double(nights), specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            
            Section {
                Button(action: {
                    createBooking(for: room)
                }) {
                    Text("Confirm Booking")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func createBooking(for room: Room) {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "Please login first"
            showAlert = true
            return
        }
        
        let nights = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        let totalPrice = room.price * Double(nights)
        
        Task {
            do {
                try await viewModel.createBooking(
                    userId: userId,
                    room: room,
                    startDate: startDate,
                    endDate: endDate,
                    numberOfGuests: numberOfGuests,
                    totalPrice: totalPrice,
                    specialRequests: specialRequests
                )
                alertMessage = "Booking created successfully"
                showAlert = true
            } catch {
                alertMessage = "Failed to create booking: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        BookingDetailView(bookingId: "example-booking-id")
    }
}


