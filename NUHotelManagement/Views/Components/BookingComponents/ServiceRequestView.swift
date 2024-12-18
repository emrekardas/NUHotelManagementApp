//
//  ServiceRequestView.swift
//  NUHotelManagement
//
//  Created by Emre on 16/12/2024.
//

import SwiftUI

struct ServiceRequestView: View {
    @Binding var isPresented: Bool
    @State private var selectedService: String?
    @State private var additionalNotes = ""
    @State private var showConfirmation = false
    let onRequestService: (String, String) -> Void
    
    private let services = [
        ServiceType(
            name: "Room Cleaning",
            icon: "sparkles",
            price: 50,
            description: "Professional cleaning service for your room"
        ),
        ServiceType(
            name: "Extra Bed",
            icon: "bed.double",
            price: 100,
            description: "Additional comfortable bed"
        ),
        ServiceType(
            name: "Extra Towels",
            icon: "shower",
            price: 25,
            description: "Set of fresh towels"
        ),
        ServiceType(
            name: "Room Service",
            icon: "fork.knife",
            price: 0, // Menü fiyatlarına göre değişir
            description: "Food and beverage service to your room"
        ),
        ServiceType(
            name: "Technical Support",
            icon: "wrench.and.screwdriver",
            price: 0, // Ücretsiz
            description: "Technical assistance for room equipment"
        ),
        ServiceType(
            name: "Other",
            icon: "ellipsis.circle",
            price: 0,
            description: "Other special requests"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Service Selection Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(services, id: \.name) { service in
                            ServiceCardView(
                                service: service,
                                isSelected: selectedService == service.name
                            )
                            .onTapGesture {
                                selectedService = service.name
                            }
                        }
                    }
                    .padding()
                    
                    if selectedService != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            if let service = services.first(where: { $0.name == selectedService }) {
                                Text(service.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                if service.price > 0 {
                                    Text("Price: $\(service.price)")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal)
                                } else if service.name == "Room Service" {
                                    Text("Price: Based on menu selection")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                } else if service.name != "Other" {
                                    Text("Price: Complimentary")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .padding(.horizontal)
                                }
                            }
                            
                            Text("Additional Notes")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            TextEditor(text: $additionalNotes)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
                
                // Bottom Action Bar
                VStack {
                    Divider()
                    
                    HStack {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Request Service") {
                            showConfirmation = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedService == nil)
                    }
                    .padding()
                }
            }
            .navigationTitle("Request Service")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Confirm Service Request", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Confirm") {
                    if let service = selectedService {
                        onRequestService(service, additionalNotes)
                        isPresented = false
                    }
                }
            } message: {
                if let service = selectedService,
                   let serviceDetails = services.first(where: { $0.name == service }) {
                    Text("Would you like to request \(service.lowercased())?\n\(serviceDetails.price > 0 ? "Price: $\(serviceDetails.price)" : "")")
                }
            }
        }
    }
}

// Helper Views
struct ServiceType {
    let name: String
    let icon: String
    let price: Int
    let description: String
}

struct ServiceCardView: View {
    let service: ServiceType
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: service.icon)
                .font(.system(size: 30))
            
            Text(service.name)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            if service.price > 0 {
                Text("$\(service.price)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

