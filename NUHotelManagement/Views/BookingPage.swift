//
//  BookingPage.swift
//  NUHotelManagement
//
//  Created by Emre on 06/12/2024.
//

import SwiftUI
import FirebaseAuth

struct BookingPage: View {
    @StateObject private var viewModel = BookingPageViewModel()
    @State private var showingLoginAlert = false
    @State private var showServiceConfirmation = false
    @State private var selectedService: String?
    @State private var selectedBooking: Booking?
    @State private var serviceNotes: String = ""
    
    var body: some View {
        Group {
            if Auth.auth().currentUser == nil {
                noUserView
            } else {
                mainBookingView
            }
        }
        .navigationTitle("My Bookings")
    }
    
    private var noUserView: some View {
        VStack(spacing: 25) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                )
            
            VStack(spacing: 10) {
                Text("Login Required")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Please login to view and manage your bookings")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: { showingLoginAlert = true }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Login")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 200)
                .padding()
                .background(Color.blue)
                .cornerRadius(15)
                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
            }
        }
        .padding()
    }
    
    private var mainBookingView: some View {
        VStack(spacing: 0) {
            // Content
            if viewModel.isLoading {
                loadingView
            } else if viewModel.bookings.isEmpty {
                emptyBookingsView
            } else {
                bookingListView
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading your bookings...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyBookingsView: some View {
        VStack(spacing: 30) {
            // Animasyonlu İllüstrasyon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(Color.blue.opacity(0.05))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .symbolEffect(.bounce, options: .repeating)
            }
            
            // Metin Bölümü
            VStack(spacing: 12) {
                Text("No Bookings Yet")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Start your journey by booking a room")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Aksiyon Butonları
            VStack(spacing: 15) {
                // Oda Arama Butonu
                NavigationLink(destination: RoomsPage()) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Browse Rooms")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                
                // Yenileme Butonu
                Button(action: { 
                    withAnimation {
                        viewModel.fetchUserBookings()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                // Arka Plan Deseni
                ForEach(0..<20) { index in
                    Circle()
                        .fill(Color.blue.opacity(0.03))
                        .frame(width: 20, height: 20)
                        .offset(
                            x: CGFloat.random(in: -200...200),
                            y: CGFloat.random(in: -400...400)
                        )
                }
            }
        )
        .padding()
    }
    
    private var bookingListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredBookings) { booking in
                    BookingCardView(
                        booking: booking,
                        onCancelBooking: {
                            viewModel.cancelBooking(booking)
                        },
                        onRequestService: { service, notes in
                            selectedService = service
                            serviceNotes = notes
                            selectedBooking = booking
                            showServiceConfirmation = true
                        }
                    )
                    .transition(.opacity.combined(with: .slide))
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.fetchUserBookings()
        }
        .alert("Confirm Service Request", isPresented: $showServiceConfirmation) {
            Button("Request") {
                if let service = selectedService,
                   let booking = selectedBooking {
                    viewModel.requestService(
                        service: service,
                        notes: serviceNotes,
                        for: booking
                    )
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let service = selectedService {
                Text("Would you like to request \(service)?")
            }
        }
    }
    
    private var filteredBookings: [Booking] {
        return viewModel.bookings
    }
}

