import SwiftUI

struct ExecutionView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Execution")
                .font(.largeTitle.weight(.semibold))
            Text("Asana remains the system of action. Jeff OS decides what deserves attention.")
                .foregroundStyle(.secondary)

            HStack {
                Button("Open Asana") { model.openAsana() }
                    .buttonStyle(.borderedProminent)
                Text("\(model.followUpQueue.count) relationship actions identified")
            }

            List(model.followUpQueue) { contact in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Follow up with \(contact.name)")
                        Text(contact.accountName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Create Task") {
                        model.createAsanaTask(for: contact)
                    }
                }
            }
        }
        .padding(28)
        .navigationTitle("Execution")
    }
}

struct AIWorkspaceView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("AI")
                .font(.largeTitle.weight(.semibold))
            Text("Claude analyzes relationship signals. ChatGPT remains available for strategy, writing and execution.")
                .foregroundStyle(.secondary)
            HStack {
                Button("Open Claude") { model.openClaude() }
                Button("Run Relationship Analysis") {
                    model.refreshMorningBriefing()
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding(28)
        .navigationTitle("AI")
    }
}

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Identity") {
                LabeledContent("Work email", value: IntegrationSettings.workEmail)
            }
            Section("Connections") {
                ConnectionRow(name: "Microsoft 365 / Graph", connected: IntegrationSettings.graphConfigured)
                ConnectionRow(name: "Claude API", connected: IntegrationSettings.claudeConfigured)
                ConnectionRow(name: "Asana", connected: IntegrationSettings.asanaConfigured)
            }
            Section("Follow-Up Rules") {
                LabeledContent("Important client", value: "24 hours")
                LabeledContent("Partner", value: "48 hours")
                LabeledContent("Business development", value: "3 business days")
                LabeledContent("Relationship cooling", value: "7–14 days")
            }
            Section {
                Text("Development build: credentials are read from Xcode environment variables. The next security milestone is MSAL sign-in and Keychain storage.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(28)
        .navigationTitle("Settings")
    }
}

private struct ConnectionRow: View {
    let name: String
    let connected: Bool

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Label(
                connected ? "Connected" : "Not connected",
                systemImage: connected ? "checkmark.circle.fill" : "circle"
            )
        }
    }
}

struct PlaceholderWorkspace: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.largeTitle.weight(.semibold))
            Text(subtitle)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(28)
        .navigationTitle(title)
    }
}
