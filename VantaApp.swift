import SwiftUI

@main
struct VantaApp: App {
    @StateObject private var player = PlayerState()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(player)
                .preferredColorScheme(.dark)
        }
    }
}
