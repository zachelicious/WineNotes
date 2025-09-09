import SwiftUI
import SwiftData

@main
struct WineNotesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Bottle.self, Review.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}