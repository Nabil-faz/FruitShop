import SwiftUI

// The main view that displays a tab bar with different views
struct ContentView: View {
    var body: some View {
        TabView{
            ProduktListeView()
                .tabItem{
                    Label("Products",systemImage: "list.bullet")
                }
            VendorListView()
                .tabItem{
                    Label("Vendors",systemImage: "person.3")
                }
            
            CategoryListView()
                .tabItem{
                    Label("Categories",systemImage: "tag")
                }
                CartView()
                .tabItem{
                    Label("Cart",systemImage: "cart")
                }
        }
    }
}


@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
