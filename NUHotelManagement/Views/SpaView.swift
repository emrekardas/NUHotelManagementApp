//
//  SpaView.swift
//  NUHotelManagement
//
//  Created by Emre on 07/12/2024.
//

import SwiftUI

struct SpaService: Identifiable {
    let id = UUID()
    let name: String
    let duration: String
    let price: Int
    let description: String
    let icon: String
}

struct SpaView: View {
    let spaServices = [
        SpaService(
            name: "Classic Massage",
            duration: "60 min",
            price: 100,
            description: "Relaxing full body massage",
            icon: "sparkles"
        ),
        SpaService(
            name: "Facial Treatment",
            duration: "45 min",
            price: 80,
            description: "Rejuvenating facial care",
            icon: "face.smiling"
        ),
        SpaService(
            name: "Turkish Bath",
            duration: "90 min",
            price: 120,
            description: "Traditional Turkish hamam experience",
            icon: "drop.fill"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Spa & Wellness")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .padding(.top)
                
                ForEach(spaServices) { service in
                    SpaServiceCard(service: service)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct SpaServiceCard: View {
    let service: SpaService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: service.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.purple)
                
                Text(service.name)
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Text("$\(service.price)")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Text(service.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text(service.duration)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    SpaView()
}
