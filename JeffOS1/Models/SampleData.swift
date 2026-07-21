import Foundation

enum SampleData {
    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    }

    static let accounts: [Account] = [
        Account(
            id: UUID(),
            name: "Banner Health",
            type: "Client / Opportunity",
            opportunityValue: 150_000,
            stage: "Pilot",
            healthScore: 69,
            contacts: [
                Contact(
                    id: UUID(),
                    name: "Katie LeBlanc",
                    email: "katie@example.com",
                    title: "Executive Sponsor",
                    accountName: "Banner Health",
                    importance: 4,
                    lastInboundAt: daysAgo(2),
                    lastOutboundAt: daysAgo(5),
                    lastMeetingAt: daysAgo(7),
                    nextMoveOwner: "Jeff",
                    openCommitments: [
                        Commitment(
                            id: UUID(),
                            text: "Send revised pilot summary",
                            dueDate: daysAgo(1),
                            completed: false,
                            source: "Pilot discussion"
                        )
                    ],
                    suggestedAction: "Send the revised pilot summary and confirm the decision meeting.",
                    suggestedDraft: "Hi Katie,\n\nI wanted to get the revised pilot summary back in your hands and confirm the right next step for the decision discussion. I’ve incorporated the points we discussed. Would you have time later this week to review it together?\n\nThanks,\nJeff",
                    status: .overdue,
                    priority: .critical,
                    relationshipHealth: 58
                )
            ]
        ),
        Account(
            id: UUID(),
            name: "PeaceHealth",
            type: "Client",
            opportunityValue: nil,
            stage: "Active",
            healthScore: 74,
            contacts: [
                Contact(
                    id: UUID(),
                    name: "Kim Sullivan",
                    email: "kim@example.com",
                    title: nil,
                    accountName: "PeaceHealth",
                    importance: 4,
                    lastInboundAt: daysAgo(1),
                    lastOutboundAt: daysAgo(3),
                    lastMeetingAt: daysAgo(8),
                    nextMoveOwner: "Jeff",
                    openCommitments: [],
                    suggestedAction: "Answer the two open questions before noon.",
                    suggestedDraft: "Hi Kim,\n\nThanks for the thoughtful questions. I’ve pulled together a clear response to both and wanted to get it back to you quickly. Here is how I’m thinking about each one:\n\n[Response]\n\nThanks,\nJeff",
                    status: .today,
                    priority: .high,
                    relationshipHealth: 66
                )
            ]
        ),
        Account(
            id: UUID(),
            name: "Volute",
            type: "Partner",
            opportunityValue: nil,
            stage: "Partnership Development",
            healthScore: 76,
            contacts: [
                Contact(
                    id: UUID(),
                    name: "David Magrini",
                    email: "david@example.com",
                    title: nil,
                    accountName: "Volute",
                    importance: 3,
                    lastInboundAt: daysAgo(9),
                    lastOutboundAt: daysAgo(9),
                    lastMeetingAt: daysAgo(15),
                    nextMoveOwner: "Jeff",
                    openCommitments: [],
                    suggestedAction: "Reconnect with a short partnership update and propose the next working session.",
                    suggestedDraft: "David,\n\nI wanted to reconnect and keep our partnership work moving. I’ve been thinking about the clearest path to package the combined value proposition and would like to compare notes. Do you have 30 minutes next week?\n\nThanks,\nJeff",
                    status: .cooling,
                    priority: .medium,
                    relationshipHealth: 71
                )
            ]
        ),
        Account(
            id: UUID(),
            name: "Corewell Health",
            type: "Opportunity",
            opportunityValue: nil,
            stage: "Nurture",
            healthScore: 83,
            contacts: [
                Contact(
                    id: UUID(),
                    name: "Molly Cosgrove",
                    email: "molly@example.com",
                    title: nil,
                    accountName: "Corewell Health",
                    importance: 3,
                    lastInboundAt: daysAgo(3),
                    lastOutboundAt: daysAgo(1),
                    lastMeetingAt: daysAgo(12),
                    nextMoveOwner: "Them",
                    openCommitments: [],
                    suggestedAction: "Wait until Thursday, then send a light nudge if there is no response.",
                    suggestedDraft: nil,
                    status: .waiting,
                    priority: .low,
                    relationshipHealth: 83
                )
            ]
        )
    ]
}
