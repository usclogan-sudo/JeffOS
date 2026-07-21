import Foundation

enum ClaudeRelationshipError: Error {
    case notConfigured
    case invalidResponse(Int)
    case missingText
}

final class ClaudeRelationshipService {
    func analyze(
        messages: [GraphMessage],
        events: [GraphEvent]
    ) async throws -> RelationshipAnalysis {
        guard IntegrationSettings.claudeConfigured else {
            throw ClaudeRelationshipError.notConfigured
        }

        let messagesJSON = String(
            data: try JSONEncoder().encode(messages),
            encoding: .utf8
        ) ?? "[]"
        let eventsJSON = String(
            data: try JSONEncoder().encode(events),
            encoding: .utf8
        ) ?? "[]"

        let prompt = """
        You are Jeff Logan's executive chief of staff.

        Jeff's work email is \(IntegrationSettings.workEmail).
        Analyze recent Outlook email and calendar activity through a relationship-management lens.

        Your primary objective is speed to meaningful follow-up.

        Determine:
        - who is waiting on Jeff,
        - who Jeff is waiting on,
        - who needs a same-day response,
        - which important relationships are cooling,
        - explicit and implicit commitments Jeff made,
        - the best next action,
        - a concise draft in Jeff's voice when a response is appropriate.

        Do not treat newsletters, automated notifications, solicitations or low-value messages as relationships.
        Do not invent facts. When uncertain, be conservative.

        Return ONLY valid JSON in this exact shape:
        {
          "executiveSummary": "string",
          "people": [
            {
              "name": "string",
              "email": "string",
              "accountName": "string",
              "reason": "string",
              "nextMoveOwner": "Jeff|Them|Shared",
              "priority": "Critical|High|Medium|Low",
              "status": "Overdue|Today|Waiting on Them|Relationship Cooling|Healthy",
              "relationshipHealth": 0,
              "suggestedAction": "string",
              "suggestedDraft": "string or null",
              "commitments": [
                {
                  "text": "string",
                  "dueDate": "YYYY-MM-DD or null",
                  "source": "email subject or meeting"
                }
              ]
            }
          ]
        }

        EMAIL:
        \(messagesJSON)

        CALENDAR:
        \(eventsJSON)
        """

        struct RequestBody: Encodable {
            struct Message: Encodable {
                let role: String
                let content: String
            }
            let model: String
            let max_tokens: Int
            let messages: [Message]
        }

        var request = URLRequest(
            url: URL(string: "https://api.anthropic.com/v1/messages")!
        )
        request.httpMethod = "POST"
        request.setValue(
            IntegrationSettings.anthropicAPIKey,
            forHTTPHeaderField: "x-api-key"
        )
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder().encode(
            RequestBody(
                model: "claude-sonnet-4-5",
                max_tokens: 5000,
                messages: [.init(role: "user", content: prompt)]
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ClaudeRelationshipError.invalidResponse(
                (response as? HTTPURLResponse)?.statusCode ?? -1
            )
        }

        struct Envelope: Decodable {
            struct Content: Decodable {
                let type: String
                let text: String?
            }
            let content: [Content]
        }

        let envelope = try JSONDecoder().decode(Envelope.self, from: data)
        guard let text = envelope.content.first(where: { $0.type == "text" })?.text else {
            throw ClaudeRelationshipError.missingText
        }

        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return try JSONDecoder().decode(
            RelationshipAnalysis.self,
            from: Data(cleaned.utf8)
        )
    }
}
