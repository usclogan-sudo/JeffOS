import SwiftUI

@main
struct JeffOS1App: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
        }
        .defaultSize(width: 1260, height: 820)
    }
}
