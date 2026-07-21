import SwiftUI

struct AccountsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var searchText = ""

    private var contacts: [Contact] {
        guard !searchText.isEmpty else { return model.followUpQueue }
        return model.allContacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.accountName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        HSplitView {
            List(contacts, selection: $model.selectedContact) { contact in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(contact.name)
                            .font(.headline)
                        Spacer()
                        Text("\(contact.relationshipHealth)")
                            .font(.caption.monospacedDigit())
                    }
                    Text(contact.accountName)
                        .foregroundStyle(.secondary)
                    Text(contact.status.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 5)
                .tag(contact)
            }
            .searchable(text: $searchText, prompt: "People or accounts")
            .frame(minWidth: 310)

            if let contact = model.selectedContact ?? contacts.first {
                ContactDetailView(contact: contact)
                    .frame(minWidth: 600)
            } else {
                ContentUnavailableView(
                    "No relationships found",
                    systemImage: "person.2"
                )
            }
        }
        .navigationTitle("Accounts")
    }
}

private struct ContactDetailView: View {
    @EnvironmentObject private var model: AppModel
    let contact: Contact

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(contact.name)
                            .font(.system(size: 32, weight: .semibold))
                        Text(contact.accountName)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text(contact.email)
                            .textSelection(.enabled)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(contact.relationshipHealth)")
                            .font(.system(size: 38, weight: .semibold, design: .rounded))
                        Text("Relationship health")
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 10) {
                    Button("Create Outlook Draft") {
                        model.createOutlookDraft(for: contact)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Create Asana Task") {
                        model.createAsanaTask(for: contact)
                    }
                    .buttonStyle(.bordered)

                    Button("Open Outlook") {
                        model.openOutlook()
                    }
                    .buttonStyle(.bordered)
                }

                detailCard(
                    title: "Recommended Next Action",
                    symbol: "arrow.forward.circle.fill"
                ) {
                    Text(contact.suggestedAction ?? "No action recommended.")
                        .font(.title3)
                }

                detailCard(title: "Why This Person Is Here", symbol: "person.crop.circle.badge.exclamationmark") {
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("Status", value: contact.status.rawValue)
                        LabeledContent("Priority", value: contact.priority.rawValue)
                        LabeledContent("Next move", value: contact.nextMoveOwner)
                        LabeledContent(
                            "Last meaningful contact",
                            value: "\(contact.daysSinceMeaningfulContact) days ago"
                        )
                    }
                }

                detailCard(title: "Open Commitments", symbol: "checklist") {
                    if contact.openCommitments.isEmpty {
                        Text("No commitments detected.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(contact.openCommitments) { commitment in
                            Label(commitment.text, systemImage: "circle")
                        }
                    }
                }

                if let draft = contact.suggestedDraft {
                    detailCard(title: "Suggested Draft", symbol: "envelope") {
                        Text(draft)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding(28)
        }
    }

    private func detailCard<Content: View>(
        title: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: symbol)
                .font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
