//
//  Booking.swift
//  NUHotelManagement
//
//  Created by Emre on 16/12/2024.
//
// Models/Booking.swift
// Models/Booking.swift
import FirebaseFirestore

struct Booking: Identifiable, Codable {
    var id: String?
    let userId: String
    let roomId: String
    let roomName: String
    let roomNumber: String
    let roomImageUrl: String
    let startDate: Timestamp
    let endDate: Timestamp
    let numberOfGuests: Int
    let status: String
    let totalPrice: Double
    let createdAt: Timestamp
    let specialRequests: String
    
    // Computed properties for formatted dates
    var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startDate.dateValue())
    }
    
    var formattedEndDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: endDate.dateValue())
    }
    
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt.dateValue())
    }
    
    // Computed property for number of nights
    var numberOfNights: Int {
        let calendar = Calendar.current
        let start = startDate.dateValue()
        let end = endDate.dateValue()
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case roomId
        case roomName
        case roomNumber
        case roomImageUrl
        case startDate
        case endDate
        case numberOfGuests
        case status
        case totalPrice
        case createdAt
        case specialRequests
    }
    
    // Helper function to format any date
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    init(id: String? = nil,
         userId: String,
         roomId: String,
         roomName: String,
         roomNumber: String,
         roomImageUrl: String,
         startDate: Timestamp,
         endDate: Timestamp,
         numberOfGuests: Int,
         status: String,
         totalPrice: Double,
         createdAt: Timestamp,
         specialRequests: String) {
        self.id = id
        self.userId = userId
        self.roomId = roomId
        self.roomName = roomName
        self.roomNumber = roomNumber
        self.roomImageUrl = roomImageUrl
        self.startDate = startDate
        self.endDate = endDate
        self.numberOfGuests = numberOfGuests
        self.status = status
        self.totalPrice = totalPrice
        self.createdAt = createdAt
        self.specialRequests = specialRequests
    }
    
    // Firebase'den veriyi çekerken kullanılacak
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        roomId = try container.decode(String.self, forKey: .roomId)
        roomName = try container.decode(String.self, forKey: .roomName)
        roomNumber = try container.decode(String.self, forKey: .roomNumber)
        roomImageUrl = try container.decode(String.self, forKey: .roomImageUrl)
        startDate = try container.decode(Timestamp.self, forKey: .startDate)
        endDate = try container.decode(Timestamp.self, forKey: .endDate)
        numberOfGuests = try container.decode(Int.self, forKey: .numberOfGuests)
        status = try container.decode(String.self, forKey: .status)
        totalPrice = try container.decode(Double.self, forKey: .totalPrice)
        createdAt = try container.decode(Timestamp.self, forKey: .createdAt)
        specialRequests = try container.decode(String.self, forKey: .specialRequests)
    }
}

// Extension for date formatting options
extension Booking {
    enum DateFormat {
        case short
        case medium
        case long
        case custom(String)
        
        var formatter: DateFormatter {
            let formatter = DateFormatter()
            switch self {
            case .short:
                formatter.dateStyle = .short
                formatter.timeStyle = .none
            case .medium:
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
            case .long:
                formatter.dateStyle = .long
                formatter.timeStyle = .short
            case .custom(let format):
                formatter.dateFormat = format
            }
            return formatter
        }
    }
    
    func getFormattedDate(_ timestamp: Timestamp, format: DateFormat = .medium) -> String {
        return format.formatter.string(from: timestamp.dateValue())
    }
}