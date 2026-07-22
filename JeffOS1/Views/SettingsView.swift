import SwiftData
import SwiftUI

struct SettingsView: View {
    @Query private var people: [Person]
    @Query private var commitments: [Commitment]
    @Query private var meetings: [Meeting]
    @AppStorage("displayName") private var displayName = "Jeff"
    @AppStorage("appearance") private var appearance = "System"
    @AppStorage("dailyPriorityLimit") private var dailyPriorityLimit = 3

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Display Name", text: $displayName)
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag("System")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                }
            }

            Section("Dashboard") {
                Stepper("Show \(dailyPriorityLimit) daily priorities", value: $dailyPriorityLimit, in: 1...8)
            }

            Section("Local Data") {
                LabeledContent("People", value: "\(people.count)")
                LabeledContent("Open Commitments", value: "\(commitments.filter(\.isOpen).count)")
                LabeledContent("Meetings", value: "\(meetings.count)")
                Text("Sprint 1 stores all information privately on this Mac with SwiftData.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Keyboard Shortcuts") {
                shortcutRow("Dashboard", keys: "⌘1")
                shortcutRow("People", keys: "⌘2")
                shortcutRow("Commitments", keys: "⌘3")
                shortcutRow("Settings", keys: "⌘4")
                shortcutRow("Quick Capture", keys: "⌘K")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .padding(.bottom, 64)
    }

    private func shortcutRow(_ title: String, keys: String) -> some View {
        LabeledContent(title) {
            Text(keys)
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}
