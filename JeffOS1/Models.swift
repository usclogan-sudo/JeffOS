import Foundation

enum FollowUpStatus: String, Codable, CaseIterable {
    case overdue = "Overdue"
    case today = "Today"
    case waiting = "Waiting on Them"
    case cooling = "Relationship Cooling"
    case healthy = "Healthy"
}

enum FollowUpPriority: String, Codable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var weight: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

struct Account: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: String
    var opportunityValue: Double?
    var stage: String?
    var healthScore: Int
    var contacts: [Contact]
}

struct Contact: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var title: String?
    var accountName: String
    var importance: Int
    var lastInboundAt: Date?
    var lastOutboundAt: Date?
    var lastMeetingAt: Date?
    var nextMoveOwner: String
    var openCommitments: [Commitment]
    var suggestedAction: String?
    var suggestedDraft: String?
    var status: FollowUpStatus
    var priority: FollowUpPriority
    var relationshipHealth: Int

    var daysSinceMeaningfulContact: Int {
        let dates = [lastInboundAt, lastOutboundAt, lastMeetingAt].compactMap { $0 }
        guard let latest = dates.max() else { return 999 }
        return max(0, Calendar.current.dateComponents([.day], from: latest, to: Date()).day ?? 0)
    }
}

struct Commitment: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var dueDate: Date?
    var completed: Bool
    var source: String
}

struct GraphMessage: Codable, Hashable {
    let id: String
    let conversationId: String?
    let subject: String
    let bodyPreview: String
    let receivedDateTime: Date?
    let sentDateTime: Date?
    let from: GraphRecipient?
    let toRecipients: [GraphRecipient]?
    let isRead: Bool?
}

struct GraphRecipient: Codable, Hashable {
    let emailAddress: GraphEmailAddress
}

struct GraphEmailAddress: Codable, Hashable {
    let name: String?
    let address: String
}

struct GraphEvent: Codable, Hashable {
    let id: String
    let subject: String
    let start: GraphDateTime
    let end: GraphDateTime
    let attendees: [GraphAttendee]?
    let organizer: GraphRecipient?
}

struct GraphDateTime: Codable, Hashable {
    let dateTime: String
    let timeZone: String
}

struct GraphAttendee: Codable, Hashable {
    let emailAddress: GraphEmailAddress
}

struct RelationshipAnalysis: Codable {
    let executiveSummary: String
    let people: [AnalyzedPerson]
}

struct AnalyzedPerson: Codable {
    let name: String
    let email: String
    let accountName: String
    let reason: String
    let nextMoveOwner: String
    let priority: String
    let status: String
    let relationshipHealth: Int
    let suggestedAction: String
    let suggestedDraft: String?
    let commitments: [AnalyzedCommitment]
}

struct AnalyzedCommitment: Codable {
    let text: String
    let dueDate: String?
    let source: String
}
