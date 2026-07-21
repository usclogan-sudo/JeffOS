import Foundation
import AppKit
import Combine

@MainActor
final class AppModel: ObservableObject {
    enum Workspace: String, CaseIterable, Identifiable {
        case briefing = "Briefing"
        case accounts = "Accounts"
        case meetings = "Meetings"
        case execution = "Execution"
        case ai = "AI"
        case settings = "Settings"

        var id: String { rawValue }

        var symbol: String {
            switch self {
            case .briefing: return "sun.max.fill"
            case .accounts: return "person.2.fill"
            case .meetings: return "calendar"
            case .execution: return "checkmark.circle.fill"
            case .ai: return "sparkles"
            case .settings: return "gearshape.fill"
            }
        }
    }

    @Published var workspace: Workspace = .briefing
    @Published var status = "Ready"
    @Published var isRefreshing = false
    @Published var executiveSummary = "Connect Microsoft 365, Claude and Asana, then run the morning briefing."
    @Published var accounts: [Account] = SampleData.accounts
    @Published var selectedContact: Contact?
    @Published var lastRefresh: Date?

    private let orchestration = RelationshipOrchestrationService()

    var allContacts: [Contact] {
        accounts.flatMap(\.contacts)
    }

    var followUpQueue: [Contact] {
        allContacts
            .filter { $0.status != .healthy }
            .sorted {
                if $0.priority.weight != $1.priority.weight {
                    return $0.priority.weight > $1.priority.weight
                }
                return $0.relationshipHealth < $1.relationshipHealth
            }
    }

    var overdueCount: Int {
        allContacts.filter { $0.status == .overdue }.count
    }

    var todayCount: Int {
        allContacts.filter { $0.status == .today }.count
    }

    var coolingCount: Int {
        allContacts.filter { $0.status == .cooling }.count
    }

    var medianResponseHours: Int {
        // Placeholder until Graph delta history is persisted locally.
        19
    }

    func refreshMorningBriefing() {
        guard !isRefreshing else { return }
        isRefreshing = true
        status = "Reviewing Outlook, calendar and Asana…"

        Task {
            defer { isRefreshing = false }
            do {
                let result = try await orchestration.run()
                executiveSummary = result.summary
                accounts = result.accounts
                lastRefresh = Date()
                status = "Briefing complete. \(followUpQueue.count) people need attention."
            } catch {
                status = "Using sample data. Connect services in Settings to activate live intelligence."
            }
        }
    }

    func createAsanaTask(for contact: Contact) {
        Task {
            do {
                try await orchestration.createTask(for: contact)
                status = "Created Asana follow-up for \(contact.name)."
            } catch {
                status = "Asana is not connected yet."
            }
        }
    }

    func createOutlookDraft(for contact: Contact) {
        Task {
            do {
                try await orchestration.createDraft(for: contact)
                status = "Draft created in Outlook for \(contact.name)."
            } catch {
                status = "Microsoft 365 draft creation is not connected yet."
            }
        }
    }

    func openOutlook() {
        NSWorkspace.shared.open(URL(string: "https://outlook.office.com/mail/")!)
    }

    func openClaude() {
        NSWorkspace.shared.open(URL(string: "https://claude.ai")!)
    }

    func openAsana() {
        NSWorkspace.shared.open(URL(string: "https://app.asana.com")!)
    }
}
