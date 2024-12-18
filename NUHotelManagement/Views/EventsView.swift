//
//  EventsView.swift
//  NUHotelManagement
//
//  Created by Emre on 07/12/2024.
import SwiftUI

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: String
    let image: String
    let location: String
}

struct EventsView: View {
    let events = [
        Event(
            title: "Pool Party",
            description: "Join us for a night of music and fun by the pool",
            date: "20:00 - 00:00",
            image: "figure.pool.swim.circle",
            location: "Main Pool"
        ),
        Event(
            title: "Live Music Night",
            description: "Live performance by local artists",
            date: "21:00 - 23:00",
            image: "music.note",
            location: "Beach Bar"
        ),
        Event(
            title: "Kids Club",
            description: "Fun activities for children",
            date: "10:00 - 16:00",
            image: "figure.and.child.holdinghands",
            location: "Kids Area"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Hotel Events")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .padding(.top)
                
                ForEach(events) { event in
                    EventCard(event: event)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: event.image)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                
                Text(event.title)
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Text(event.date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(event.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                Text(event.location)
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
    EventsView()
}
