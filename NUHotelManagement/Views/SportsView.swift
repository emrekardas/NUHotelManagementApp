//
//  SportsView.swift
//  NUHotelManagement
//
//  Created by Emre on 07/12/2024.
//

import SwiftUI

struct SportActivity: Identifiable {
    let id = UUID()
    let name: String
    let schedule: String
    let instructor: String
    let location: String
    let icon: String
}

struct SportsView: View {
    let activities = [
        SportActivity(
            name: "Morning Yoga",
            schedule: "07:00 - 08:30",
            instructor: "Sarah Johnson",
            location: "Beach Garden",
            icon: "figure.mind.and.body"
        ),
        SportActivity(
            name: "Tennis Lesson",
            schedule: "09:00 - 10:30",
            instructor: "Mike Smith",
            location: "Tennis Court",
            icon: "figure.tennis"
        ),
        SportActivity(
            name: "Swimming Class",
            schedule: "11:00 - 12:30",
            instructor: "David Brown",
            location: "Indoor Pool",
            icon: "figure.pool.swim"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Sports Activities")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .padding(.top)
                
                ForEach(activities) { activity in
                    SportActivityCard(activity: activity)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct SportActivityCard: View {
    let activity: SportActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: activity.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                Text(activity.name)
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Text(activity.schedule)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.blue)
                Text(activity.instructor)
                    .font(.subheadline)
            }
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                Text(activity.location)
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
    SportsView()
}
