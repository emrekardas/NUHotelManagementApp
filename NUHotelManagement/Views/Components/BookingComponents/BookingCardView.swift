//
//  BookingCardView.swift
//  NUHotelManagement
//
//  Created by Emre on 16/12/2024.
//

import SwiftUI

struct BookingCardView: View {
    let booking: Booking
    @State private var showActionSheet = false
    @State private var showServiceSheet = false
    let onCancelBooking: () -> Void
    let onRequestService: (String, String) -> Void
    
    private var canCancel: Bool {
        let now = Date()
        return booking.startDate.dateValue() > now && booking.status != "cancelled"
    }
    
    private var canRequestServices: Bool {
        let now = Date()
        return booking.startDate.dateValue() <= now && 
               booking.endDate.dateValue() >= now && 
               booking.status != "cancelled"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Room Image and Title
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: booking.roomImageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.roomName)
                        .font(.headline)
                    
                    HStack {
                        if booking.status == "confirmed" {
                            Label("Confirmed", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else if booking.status == "pending" {
                            Label("Pending", systemImage: "clock.fill")
                                .foregroundColor(.orange)
                        } else if booking.status == "cancelled" {
                            Label("Cancelled", systemImage: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .font(.subheadline)
                }
            }
            
            Divider()
            
            // Booking Details
            VStack(alignment: .leading, spacing: 8) {
                BookingDetailRow(icon: "calendar", text: "Check-in: \(booking.startDate.dateValue().formatted(date: .long, time: .omitted))")
                BookingDetailRow(icon: "calendar.badge.clock", text: "Check-out: \(booking.endDate.dateValue().formatted(date: .long, time: .omitted))")
                BookingDetailRow(icon: "person.2", text: "\(booking.numberOfGuests) Guests")
                BookingDetailRow(icon: "dollarsign.circle", text: String(format: "$%.2f", booking.totalPrice))
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                if canCancel {
                    Button(action: { showActionSheet = true }) {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("Cancel")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                if canRequestServices {
                    Button(action: { showServiceSheet = true }) {
                        HStack {
                            Image(systemName: "bell.fill")
                            Text("Request Service")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .confirmationDialog("Cancel Booking", isPresented: $showActionSheet) {
            Button("Cancel Booking", role: .destructive) {
                onCancelBooking()
            }
            Button("Keep Booking", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this booking?")
        }
        .sheet(isPresented: $showServiceSheet) {
            ServiceRequestView(
                isPresented: $showServiceSheet,
                onRequestService: onRequestService
            )
        }
    }
}

struct BookingDetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(text)
                .font(.subheadline)
        }
    }
}

// Yeni View: Servis İstekleri için

