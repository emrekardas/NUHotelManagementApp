//
//  RoomCard.swift
//  NUHotelManagement
//
//  Created by Emre on 07/12/2024.
//

import SwiftUI

// Room Card Component
struct RoomCard: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Room Image
            AsyncImage(url: URL(string: room.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(height: 120)
            }
            .cornerRadius(12)
            
            // Room Info
            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(room.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("$\(Int(room.price))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("/night")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Availability indicator
                    Circle()
                        .fill(room.availability > 0 ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
