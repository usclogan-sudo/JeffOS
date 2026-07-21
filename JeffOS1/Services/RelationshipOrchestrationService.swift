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
