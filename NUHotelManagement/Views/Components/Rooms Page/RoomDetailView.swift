//
//  RoomDetailView.swift
//  NUHotelManagement
//
//  Created by Emre on 07/12/2024.
//

import SwiftUI

struct RoomDetailView: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss
    @State private var showingBookingView = false
    @State private var newBookingId: Int?
    @State private var showBookingConfirmation = false
    
    // Amenity ikonları için dictionary
    private let amenityIcons: [String: String] = [
        "Wi-Fi": "wifi",
        "Air Conditioning": "snowflake",
        "Mini Bar": "wineglass",
        "Room Service": "bell.fill",
        "Safe": "lock.shield.fill",
        "Coffee Machine": "cup.and.saucer.fill",
        "Hair Dryer": "wind",
        "Iron": "bolt.fill",
        "Bathtub": "shower.fill",
        "Workspace": "desk.fill",
        "Kitchen": "cooktop.fill",
        "Parking": "car.fill",
        "Gym Access": "figure.run",
        "Pool Access": "figure.pool.swim",
        "Breakfast": "fork.knife",
        "Air Conditioner": "snowflake",
        "Television": "tv",
        "Spa": "heart.text.square",
        "Bed": "bed.double.fill",
        // Diğer amenity'ler için ikonlar ekleyebilirsiniz
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Image Gallery
                TabView {
                    ForEach(room.detailImageUrls, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .foregroundColor(.gray.opacity(0.2))
                        }
                    }
                }
                .frame(height: 350)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(room.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // Availability Badge
                            Text(room.availability > 0 ? "Available" : "Booked")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(room.availability > 0 ? Color.green : Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        
                        Text(room.type)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Price Section
                    HStack(alignment: .bottom) {
                        Text("$\(Int(room.price))")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("/night")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Quick Info Section
                    HStack(spacing: 20) {
                        InfoCard(icon: "person.2.fill", title: "Capacity", value: "\(room.capacity) Persons")
                        InfoCard(icon: "square.fill", title: "Size", value: room.size)
                        InfoCard(icon: "mountain.2.fill", title: "View", value: room.view)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(room.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // Amenities Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Amenities")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 160))
                        ], spacing: 16) {
                            ForEach(room.amenities, id: \.self) { amenity in
                                HStack(spacing: 12) {
                                    Image(systemName: amenityIcons[amenity] ?? "star.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 24, height: 24)
                                    
                                    Text(amenity)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                    
                    // Book Now Button
                    Button(action: {
                        showingBookingView = true
                    }) {
                        Text("Book Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(room.availability > 0 ? Color.blue : Color.gray)
                            .cornerRadius(15)
                    }
                    .disabled(room.availability <= 0)
                    .sheet(isPresented: $showingBookingView) {
                        NavigationView {
                            BookingDetailView(room: room)
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Share action
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

