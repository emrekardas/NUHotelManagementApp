//
//  RoomsPage.swift
//  NUHotelManagement
//
//  Created by Emre on 06/12/2024.
//

import SwiftUI

struct RoomsPage: View {
    @StateObject private var roomService = RoomService()
    @State private var searchText = ""
    @State private var selectedFilter: RoomFilter = .all
    @State private var isSearchFocused = false
    
    enum RoomFilter: String, CaseIterable {
        case all = "All"
        case available = "Available"
        case suite = "Suite"
        case standard = "Standard"
        case villa = "Villa"
    }
    
    var filteredRooms: [Room] {
        let searchedRooms = searchText.isEmpty ? roomService.rooms :
            roomService.rooms.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        
        switch selectedFilter {
        case .all:
            return searchedRooms
        case .available:
            return searchedRooms.filter { $0.availability > 0 }
        case .suite:
            return searchedRooms.filter { $0.type.lowercased().contains("suite") }
        case .villa:
            return searchedRooms.filter { $0.type.lowercased().contains("villa") }
        case .standard:
            return searchedRooms.filter { $0.type.lowercased().contains("standard") }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Modern Header Section
                        VStack(spacing: 20) {
                            // Animated Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(isSearchFocused ? .blue : .gray)
                                    .animation(.easeInOut, value: isSearchFocused)
                                
                                TextField("Find your perfect room...", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .onTapGesture { isSearchFocused = true }
                                    .onSubmit { isSearchFocused = false }
                                
                                if !searchText.isEmpty {
                                    Button(action: { 
                                        searchText = ""
                                        isSearchFocused = false
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: isSearchFocused ? .blue.opacity(0.1) : .clear, radius: 10)
                            )
                            .padding(.horizontal)
                            .animation(.easeInOut, value: isSearchFocused)
                            
                            // Modern Filter Pills
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(RoomFilter.allCases, id: \.self) { filter in
                                        ModernFilterPill(
                                            title: filter.rawValue,
                                            isSelected: selectedFilter == filter,
                                            action: { 
                                                withAnimation(.spring()) {
                                                    selectedFilter = filter
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                        .background(
                            Rectangle()
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                        )
                        
                        // Modern Room Grid
                        if filteredRooms.isEmpty {
                            ModernEmptyRoomsView()
                                .transition(.opacity)
                        } else {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ],
                                spacing: 20
                            ) {
                                ForEach(filteredRooms) { room in
                                    NavigationLink(destination: RoomDetailView(room: room)) {
                                        RoomCard(room: room)
                                            .shadow(
                                                color: Color.black.opacity(0.08),
                                                radius: 12,
                                                x: 0,
                                                y: 5
                                            )
                                    }
                                }
                            }
                            .padding()
                            .animation(.easeInOut, value: filteredRooms.count)
                        }
                    }
                }
                .navigationTitle("Our Rooms")
            }
        }
    }
}

// Modern Helper Views
struct ModernFilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.white)
                        .shadow(
                            color: isSelected ? .blue.opacity(0.3) : .gray.opacity(0.1),
                            radius: isSelected ? 8 : 4
                        )
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.spring(), value: isSelected)
        }
    }
}

struct ModernEmptyRoomsView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "bed.double.circle")
                    .font(.system(size: 45))
                    .foregroundColor(.blue)
                    .symbolEffect(.bounce, options: .repeating)
            }
            
            VStack(spacing: 8) {
                Text("No Rooms Found")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                
                Text("Try adjusting your search or filters")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 400)
        .padding()
    }
}

// Preview için
struct RoomsPage_Previews: PreviewProvider {
    static var previews: some View {
        RoomsPage()
    }
}
