import Foundation
import SwiftData

@Model
final class Person {
    var name: String
    var organization: String
    var lastContact: Date?
    var nextAction: String
    var relationshipHealth: Int
    var notes: String

    @Relationship(deleteRule: .nullify, inverse: \Commitment.person)
    var commitments: [Commitment]

    init(
        name: String,
        organization: String,
        lastContact: Date? = nil,
        nextAction: String = "",
        relationshipHealth: Int = 75,
        notes: String = "",
        commitments: [Commitment] = []
    ) {
        self.name = name
        self.organization = organization
        self.lastContact = lastContact
        self.nextAction = nextAction
        self.relationshipHealth = min(100, max(0, relationshipHealth))
        self.notes = notes
        self.commitments = commitments
    }
}
