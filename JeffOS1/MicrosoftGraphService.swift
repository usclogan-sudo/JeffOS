import Foundation

enum GraphServiceError: Error {
    case notConfigured
    case invalidResponse(Int)
}

final class MicrosoftGraphService {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func recentMessages(days: Int = 7, limit: Int = 75) async throws -> [GraphMessage] {
        guard IntegrationSettings.graphConfigured else {
            throw GraphServiceError.notConfigured
        }

        let cutoff = ISO8601DateFormatter().string(
            from: Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        )

        var components = URLComponents(
            string: "https://graph.microsoft.com/v1.0/me/messages"
        )!
        components.queryItems = [
            URLQueryItem(name: "$top", value: "\(limit)"),
            URLQueryItem(
                name: "$select",
                value: "id,conversationId,subject,bodyPreview,receivedDateTime,sentDateTime,from,toRecipients,isRead"
            ),
            URLQueryItem(name: "$filter", value: "receivedDateTime ge \(cutoff)"),
            URLQueryItem(name: "$orderby", value: "receivedDateTime desc")
        ]

        let envelope: GraphEnvelope<GraphMessage> = try await get(components.url!)
        return envelope.value
    }

    func upcomingEvents(days: Int = 7) async throws -> [GraphEvent] {
        guard IntegrationSettings.graphConfigured else {
            throw GraphServiceError.notConfigured
        }

        let start = ISO8601DateFormatter().string(from: Date())
        let end = ISO8601DateFormatter().string(
            from: Calendar.current.date(byAdding: .day, value: days, to: Date())!
        )

        var components = URLComponents(
            string: "https://graph.microsoft.com/v1.0/me/calendarView"
        )!
        components.queryItems = [
            URLQueryItem(name: "startDateTime", value: start),
            URLQueryItem(name: "endDateTime", value: end),
            URLQueryItem(
                name: "$select",
                value: "id,subject,start,end,attendees,organizer"
            ),
            URLQueryItem(name: "$orderby", value: "start/dateTime")
        ]

        let envelope: GraphEnvelope<GraphEvent> = try await get(components.url!)
        return envelope.value
    }

    func createDraft(to email: String, subject: String, body: String) async throws {
        guard IntegrationSettings.graphConfigured else {
            throw GraphServiceError.notConfigured
        }

        struct DraftBody: Encodable {
            struct Message: Encodable {
                struct Body: Encodable {
                    let contentType = "Text"
                    let content: String
                }
                struct Recipient: Encodable {
                    struct Address: Encodable {
                        let address: String
                    }
                    let emailAddress: Address
                }
                let subject: String
                let body: Body
                let toRecipients: [Recipient]
            }
            let message: Message
            let saveToSentItems = false
        }

        let payload = DraftBody(
            message: .init(
                subject: subject,
                body: .init(content: body),
                toRecipients: [
                    .init(emailAddress: .init(address: email))
                ]
            )
        )

        var request = URLRequest(
            url: URL(string: "https://graph.microsoft.com/v1.0/me/messages")!
        )
        request.httpMethod = "POST"
        request.setValue(
            "Bearer \(IntegrationSettings.graphAccessToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload.message)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            throw GraphServiceError.invalidResponse(
                (response as? HTTPURLResponse)?.statusCode ?? -1
            )
        }
    }

    private func get<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(IntegrationSettings.graphAccessToken)",
            forHTTPHeaderField: "Authorization"
        )
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw GraphServiceError.invalidResponse(
                (response as? HTTPURLResponse)?.statusCode ?? -1
            )
        }
        return try decoder.decode(T.self, from: data)
    }
}

private struct GraphEnvelope<T: Decodable>: Decodable {
    let value: [T]
}
