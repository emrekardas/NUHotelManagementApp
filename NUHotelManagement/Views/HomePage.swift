import SwiftUI
import Firebase
import FirebaseFirestore
import WeatherKit
import CoreLocation

struct ServiceCard: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
}

struct HomePage: View {
    @StateObject private var roomService = RoomService()
    @StateObject private var locationManager = LocationManager()
    @State private var temperature: Double = 24.5
    @State private var weatherCondition: String = "Sunny"
    @State private var isLoading: Bool = true
    @Binding var selectedTab: Int
    
    private let kemerLocation = CLLocation(latitude: 36.6028, longitude: 30.5598)
    
    let services = [
        ServiceCard(title: "Events", icon: "calendar.badge.clock", color: .blue, destination: AnyView(EventsView())),
        ServiceCard(title: "Sports", icon: "figure.run.circle.fill", color: .green, destination: AnyView(SportsView())),
        ServiceCard(title: "Spa", icon: "sparkles", color: .purple, destination: AnyView(SpaView()))
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Modern Header Section
                        VStack(spacing: 24) {
                            HStack(alignment: .top) {
                                // Hotel Title and Welcome Message
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Kardas Hotel")
                                        .font(.system(size: 38, weight: .bold, design: .rounded))
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                // Modern Weather Widget
                                VStack(alignment: .trailing, spacing: 6) {
                                    if isLoading {
                                        ProgressView()
                                            .scaleEffect(1.2)
                                    } else {
                                        HStack(spacing: 8) {
                                            Image(systemName: weatherCondition.lowercased().contains("sunny") ? "sun.max.fill" : "cloud.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(weatherCondition.lowercased().contains("sunny") ? .yellow : .gray)
                                                .symbolEffect(.bounce)
                                            
                                            Text("\(Int(temperature))°C")
                                                .font(.system(size: 32, weight: .semibold, design: .rounded))
                                        }
                                        
                                        Text(weatherCondition)
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                                )
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                        }
                        .padding(.bottom, 8)
                        .background(Color(.systemBackground))
                        
                        // Featured Rooms Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Featured Rooms")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                
                                Spacer()
                                
                                Button(action: { selectedTab = 1 }) {
                                    Text("View All")
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(roomService.rooms) { room in
                                        NavigationLink(destination: RoomDetailView(room: room)) {
                                            HomeRoomCard(room: room)
                                                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Modern Services Section
                        VStack(spacing: 24) {
                            Text("Hotel Services")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                                ForEach(services) { service in
                                    NavigationLink(destination: service.destination) {
                                        Servisler(service: service) {
                                            // NavigationLink'in programmatik olarak tetiklenmesi için boş bırakıyoruz
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 16)
                    }
                    .padding(.vertical)
                }
            }
            .onAppear { 
                fetchWeather()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("RefreshAfterLogin"))) { _ in
                roomService.fetchRooms()
                fetchWeather()
            }
        }
    }
    
    private func fetchWeather() {
        Task {
            do {
                let weatherService = WeatherService.shared
                let weather = try await weatherService.weather(
                    for: kemerLocation
                )
                
                DispatchQueue.main.async {
                    self.temperature = weather.currentWeather.temperature.value
                    self.weatherCondition = weather.currentWeather.condition.description
                    self.isLoading = false
                }
            } catch {
                print("Hava durumu alınamadı: \(error)")
                // Daha detaylı hata bilgisi için
                print("Detaylı hata: \(String(describing: error))")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(selectedTab: .constant(0))
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}
