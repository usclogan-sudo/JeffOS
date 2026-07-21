import Foundation

struct OrchestrationResult {
    let summary: String
    let accounts: [Account]
}

final class RelationshipOrchestrationService {
    private let graph = MicrosoftGraphService()
    private let claude = ClaudeRelationshipService()
    private let asana = AsanaService()

    func run() async throws -> OrchestrationResult {
        async let messages = graph.recentMessages()
        async let events = graph.upcomingEvents()

        let analysis = try await claude.analyze(
            messages: messages,
            events: events
        )

        return OrchestrationResult(
            summary: analysis.executiveSummary,
            accounts: RelationshipMapper.map(analysis.people)
        )
    }

    func createTask(for contact: Contact) async throws {
        try await asana.createFollowUpTask(for: contact)
    }

    func createDraft(for contact: Contact) async throws {
        let subject = "Following up"
        let body = contact.suggestedDraft ?? """
        Hi \(contact.name),

        I wanted to follow up and keep this moving. Let me know what would be most helpful from me.

        Thanks,
        Jeff
        """
        try await graph.createDraft(
            to: contact.email,
            subject: subject,
            body: body
        )
    }
}

enum RelationshipMapper {
    static func map(_ people: [AnalyzedPerson]) -> [Account] {
        let grouped = Dictionary(grouping: people, by: \.accountName)

        return grouped.map { accountName, people in
            let contacts = people.map { person in
                Contact(
                    id: UUID(),
                    name: person.name,
                    email: person.email,
                    title: nil,
                    accountName: person.accountName,
                    importance: priority(person.priority).weight,
                    lastInboundAt: nil,
                    lastOutboundAt: nil,
                    lastMeetingAt: nil,
                    nextMoveOwner: person.nextMoveOwner,
                    openCommitments: person.commitments.map {
                        Commitment(
                            id: UUID(),
                            text: $0.text,
                            dueDate: parseDate($0.dueDate),
                            completed: false,
                            source: $0.source
                        )
                    },
                    suggestedAction: person.suggestedAction,
                    suggestedDraft: person.suggestedDraft,
                    status: status(person.status),
                    priority: priority(person.priority),
                    relationshipHealth: min(100, max(0, person.relationshipHealth))
                )
            }

            return Account(
                id: UUID(),
                name: accountName,
                type: "Relationship",
                opportunityValue: nil,
                stage: nil,
                healthScore: contacts.map(\.relationshipHealth).min() ?? 75,
                contacts: contacts
            )
        }
        .sorted { $0.healthScore < $1.healthScore }
    }

    private static func status(_ raw: String) -> FollowUpStatus {
        FollowUpStatus(rawValue: raw) ?? .today
    }

    private static func priority(_ raw: String) -> FollowUpPriority {
        FollowUpPriority(rawValue: raw) ?? .medium
    }

    private static func parseDate(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: raw)
    }
}
