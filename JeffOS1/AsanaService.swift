import Foundation

enum AsanaServiceError: Error {
    case notConfigured
    case invalidResponse(Int)
}

final class AsanaService {
    func createFollowUpTask(for contact: Contact) async throws {
        guard IntegrationSettings.asanaConfigured else {
            throw AsanaServiceError.notConfigured
        }

        struct Payload: Encodable {
            struct DataBody: Encodable {
                let name: String
                let notes: String
                let projects: [String]
                let due_on: String?
            }
            let data: DataBody
        }

        let dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let due = DateFormatter.asana.string(from: dueDate)

        let commitmentText = contact.openCommitments
            .filter { !$0.completed }
            .map { "• \($0.text)" }
            .joined(separator: "\n")

        let notes = """
        Account: \(contact.accountName)
        Contact: \(contact.name) <\(contact.email)>
        Status: \(contact.status.rawValue)
        Priority: \(contact.priority.rawValue)
        Relationship health: \(contact.relationshipHealth)

        Recommended action:
        \(contact.suggestedAction ?? "Follow up")

        Open commitments:
        \(commitmentText.isEmpty ? "None detected" : commitmentText)

        Created by Jeff OS.
        """

        let payload = Payload(
            data: .init(
                name: "Follow up with \(contact.name) — \(contact.accountName)",
                notes: notes,
                projects: [IntegrationSettings.asanaProjectGID],
                due_on: due
            )
        )

        var request = URLRequest(
            url: URL(string: "https://app.asana.com/api/1.0/tasks")!
        )
        request.httpMethod = "POST"
        request.setValue(
            "Bearer \(IntegrationSettings.asanaAccessToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            throw AsanaServiceError.invalidResponse(
                (response as? HTTPURLResponse)?.statusCode ?? -1
            )
        }
    }
}

private extension DateFormatter {
    static let asana: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
