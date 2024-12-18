//
//  HomeCard.swift
//  NUHotelManagement
//
//  Created by Emre on 07/12/2024.
//

import SwiftUI

// MARK: - Constants
private enum Layout {
    static let cardWidth: CGFloat = 260
    static let imageHeight: CGFloat = 180
    static let cornerRadius: CGFloat = 16
    static let contentPadding: CGFloat = 12
    static let badgeHeight: CGFloat = 24
    static let spacing: CGFloat = 8
}

struct HomeRoomCard: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoomImageView(room: room)
            RoomDetailsView(room: room)
        }
        .frame(width: Layout.cardWidth)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
        .cardShadow()
    }
}

// MARK: - Room Image Component
private struct RoomImageView: View {
    let room: Room
    
    var body: some View {
        AsyncImage(url: URL(string: room.imageUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: Layout.imageHeight)
                .clipped()
                .overlay(BadgesOverlay(room: room))
        } placeholder: {
            LoadingPlaceholder()
        }
    }
}

// MARK: - Badges Overlay
private struct BadgesOverlay: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                StatusBadge(isAvailable: room.availability > 0)
                Spacer()
                RatingBadge(rating: 4.8)
            }
            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
    }
}

// MARK: - Status Badge
private struct StatusBadge: View {
    let isAvailable: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isAvailable ? Color.green : Color.red)
                .frame(width: 6, height: 6)
            Text(isAvailable ? "Available" : "Booked")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .fill(Color.black.opacity(0.4))
        }
    }
}

// MARK: - Rating Badge
private struct RatingBadge: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(.yellow)
            Text(String(format: "%.1f", rating))
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .fill(Color.black.opacity(0.4))
        }
    }
}

// MARK: - Room Details View
private struct RoomDetailsView: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            RoomInfoView(name: room.name, type: room.type)
            RoomFeaturesView(capacity: room.capacity, size: room.size)
            PriceAndButtonView(price: room.price)
        }
        .padding(Layout.contentPadding)
    }
}

// MARK: - Room Info View
private struct RoomInfoView: View {
    let name: String
    let type: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)
                .foregroundColor(Theme.Colors.primary)
            Text(type)
                .font(.caption)
                .foregroundColor(Theme.Colors.secondary)
        }
    }
}

// MARK: - Room Features View
private struct RoomFeaturesView: View {
    let capacity: Int
    let size: String
    
    var body: some View {
        HStack(spacing: 12) {
            FeatureItem(icon: "person.2.fill", text: "\(capacity)")
            FeatureItem(icon: "square.fill", text: size)
        }
    }
}

// MARK: - Price and Button View
private struct PriceAndButtonView: View {
    let price: Double
    
    var body: some View {
        HStack {
            PriceView(price: price)
            Spacer()
            DetailsButton()
        }
    }
}

private struct PriceView: View {
    let price: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Price per night")
                .font(.caption2)
                .foregroundColor(Theme.Colors.secondary)
            Text("$\(Int(price))")
                .font(.headline)
                .foregroundColor(Theme.Colors.accent)
        }
    }
}

private struct DetailsButton: View {
    var body: some View {
        Button(action: {}) {
            Text("Details")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Theme.Colors.accent)
                .cornerRadius(16)
        }
    }
}

// MARK: - Loading Placeholder
private struct LoadingPlaceholder: View {
    var body: some View {
        Rectangle()
            .foregroundColor(Theme.Colors.placeholder)
            .frame(height: Layout.imageHeight)
    }
}

// MARK: - Theme
private enum Theme {
    static let cardBackground = Color(.systemBackground)
    
    enum Colors {
        static let primary = Color.primary
        static let secondary = Color.secondary
        static let accent = Color.accentColor
        static let available = Color.green
        static let unavailable = Color.red
        static let rating = Color.yellow
        static let placeholder = Color.gray.opacity(0.2)
    }
}

// MARK: - View Modifiers
private extension View {
    func badgeStyle() -> some View {
        self
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.5))
            .cornerRadius(12)
    }
    
    func cardShadow() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

// MARK: - Feature Item (Eksik olan component)
private struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Theme.Colors.accent)
            Text(text)
                .font(.caption)
                .foregroundColor(Theme.Colors.accent)
        }
    }
}

