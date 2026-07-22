import Foundation
import SwiftData

@MainActor
enum StarterDataService {
    static func seedIfNeeded(in context: ModelContext) {
        let peopleCount = (try? context.fetchCount(FetchDescriptor<Person>())) ?? 0
        guard peopleCount == 0 else { return }

        let calendar = Calendar.current
        let now = Date()
        let todayAtTen = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now) ?? now
        let todayAtTwo = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now) ?? now

        let david = Person(
            name: "David Magrini",
            organization: "Volute",
            lastContact: calendar.date(byAdding: .day, value: -8, to: now),
            nextAction: "Schedule the next partnership working session",
            relationshipHealth: 72,
            notes: "Strategic partner. Keep momentum through short, specific follow-ups."
        )
        let kim = Person(
            name: "Kim Sullivan",
            organization: "PeaceHealth",
            lastContact: calendar.date(byAdding: .day, value: -2, to: now),
            nextAction: "Send answers to the two open questions",
            relationshipHealth: 84,
            notes: "Values concise answers and clear ownership."
        )
        let katie = Person(
            name: "Katie LeBlanc",
            organization: "Banner Health",
            lastContact: calendar.date(byAdding: .day, value: -4, to: now),
            nextAction: "Confirm the pilot decision meeting",
            relationshipHealth: 64,
            notes: "Executive sponsor for the current pilot."
        )

        [david, kim, katie].forEach(context.insert)

        context.insert(
            Commitment(
                title: "Send revised pilot summary",
                person: katie,
                dueDate: calendar.startOfDay(for: now)
            )
        )
        context.insert(
            Commitment(
                title: "Call David tomorrow",
                person: david,
                dueDate: calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
            )
        )
        context.insert(
            Commitment(
                title: "Answer Kim's open questions",
                person: kim,
                dueDate: calendar.startOfDay(for: now)
            )
        )

        context.insert(Meeting(title: "Weekly leadership review", startDate: todayAtTen, location: "Conference Room"))
        context.insert(Meeting(title: "Pilot decision prep", startDate: todayAtTwo, location: "Zoom"))

        try? context.save()
    }
}
