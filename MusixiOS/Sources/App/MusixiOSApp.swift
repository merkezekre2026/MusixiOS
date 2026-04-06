import SwiftUI
import MusicKit

@main
struct MusixiOSApp: App {
    @State private var authorizationService = MusicAuthorizationService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authorizationService)
        }
    }
}
