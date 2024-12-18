//
//  ServiceCardView.swift
//  NUHotelManagement
//
//  Created by Emre on 07/12/2024.
//

import SwiftUI

struct Servisler: View {
    let service: ServiceCard
    @State private var isHovered = false
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Modern Icon Container
            Circle()
                .fill(service.color.opacity(0.15))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: service.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(service.color)
                        .symbolEffect(.bounce.byLayer, options: .repeat(2), value: isHovered)
                )
                .shadow(
                    color: service.color.opacity(0.3),
                    radius: isHovered ? 8 : 4,
                    x: 0,
                    y: isHovered ? 4 : 2
                )
            
            // Service Title
            Text(service.title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: isHovered ? 12 : 8,
                    x: 0,
                    y: isHovered ? 6 : 4
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
    }
}

// Preview Provider için güncelleme
struct Servisler_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            Servisler(
                service: ServiceCard(
                    title: "Events",
                    icon: "calendar.badge.clock",
                    color: .blue,
                    destination: AnyView(EventsView())
                ),
                action: {}
            )
            
            Servisler(
                service: ServiceCard(
                    title: "Sports",
                    icon: "figure.run.circle.fill",
                    color: .green,
                    destination: AnyView(SportsView())
                ),
                action: {}
            )
            
            Servisler(
                service: ServiceCard(
                    title: "Spa",
                    icon: "sparkles",
                    color: .purple,
                    destination: AnyView(SpaView())
                ),
                action: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


