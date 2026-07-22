import Foundation
import SwiftData

enum CommitmentStatus: String, CaseIterable, Identifiable {
    case open = "Open"
    case completed = "Completed"

    var id: String { rawValue }
}

@Model
final class Commitment {
    var title: String
    var dueDate: Date?
    var statusRawValue: String
    var createdAt: Date
    var person: Person?

    var status: CommitmentStatus {
        get { CommitmentStatus(rawValue: statusRawValue) ?? .open }
        set { statusRawValue = newValue.rawValue }
    }

    var isOpen: Bool { status == .open }

    init(
        title: String,
        person: Person? = nil,
        dueDate: Date? = nil,
        status: CommitmentStatus = .open,
        createdAt: Date = .now
    ) {
        self.title = title
        self.person = person
        self.dueDate = dueDate
        self.statusRawValue = status.rawValue
        self.createdAt = createdAt
    }
}
