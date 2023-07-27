
import SwiftUI

@main
struct My8PuzzleApp: App {
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .statusBar(hidden: true)
                .ignoresSafeArea(.keyboard)
        }
    }
}
