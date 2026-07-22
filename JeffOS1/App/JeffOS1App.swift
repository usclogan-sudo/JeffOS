import SwiftUI
import SwiftData

@main
struct JeffOS1App: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
        }
        .modelContainer(for: [Person.self, Commitment.self, Meeting.self])
        .defaultSize(width: 1260, height: 820)
        .commands {
            CommandMenu("Navigate") {
                Button("Dashboard") { model.select(.dashboard) }
                    .keyboardShortcut("1", modifiers: .command)
                Button("People") { model.select(.people) }
                    .keyboardShortcut("2", modifiers: .command)
                Button("Commitments") { model.select(.commitments) }
                    .keyboardShortcut("3", modifiers: .command)
                Button("Settings") { model.select(.settings) }
                    .keyboardShortcut("4", modifiers: .command)
            }
            CommandGroup(after: .newItem) {
                Button("Quick Capture") {
                    model.isQuickCapturePresented = true
                }
                .keyboardShortcut("k", modifiers: .command)
            }
        }
    }
}
