import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomePage(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            RoomsPage()
                .tabItem {
                    Image(systemName: "bed.double.fill")
                    Text("Rooms")
                }
                .tag(1)
            
            BookingPage()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Bookings")
                }
                .tag(2)
            
            AccountPage()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Account")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
