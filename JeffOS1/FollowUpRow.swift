import SwiftUI

struct FollowUpRow: View {
    @EnvironmentObject private var model: AppModel
    let contact: Contact

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            healthIndicator

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(contact.name)
                        .font(.headline)
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(contact.accountName)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(contact.status.rawValue)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                }

                Text(contact.suggestedAction ?? "Follow up")
                    .font(.body)

                HStack(spacing: 16) {
                    Label(
                        "\(contact.daysSinceMeaningfulContact) days since contact",
                        systemImage: "clock"
                    )
                    Label(
                        "\(contact.relationshipHealth) health",
                        systemImage: "heart"
                    )
                    Label(
                        "Next move: \(contact.nextMoveOwner)",
                        systemImage: "arrow.turn.down.right"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 9) {
                    Button("Open") {
                        model.selectedContact = contact
                        model.workspace = .accounts
                    }
                    Button("Draft Reply") {
                        model.createOutlookDraft(for: contact)
                    }
                    Button("Create Asana Task") {
                        model.createAsanaTask(for: contact)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var healthIndicator: some View {
        ZStack {
            Circle()
                .stroke(.tertiary, lineWidth: 5)
            Circle()
                .trim(from: 0, to: CGFloat(contact.relationshipHealth) / 100)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(contact.relationshipHealth)")
                .font(.caption.weight(.semibold))
        }
        .frame(width: 50, height: 50)
    }
}
