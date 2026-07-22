import Combine
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    enum DeepLinkRoute: Equatable {
        case dashboard
        case people
        case commitments
        case capture
        case meetings

        init(url: URL) {
            guard url.scheme?.lowercased() == "jeffos" else {
                self = .dashboard
                return
            }

            switch url.host?.lowercased() {
            case "people": self = .people
            case "commitments": self = .commitments
            case "capture": self = .capture
            case "meetings": self = .meetings
            default: self = .dashboard
            }
        }
    }

    enum Workspace: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case people = "People"
        case commitments = "Commitments"
        case settings = "Settings"

        var id: String { rawValue }

        var symbol: String {
            switch self {
            case .dashboard: return "rectangle.3.group.fill"
            case .people: return "person.2.fill"
            case .commitments: return "checkmark.circle.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    @Published var workspace: Workspace = .dashboard
    @Published var isQuickCapturePresented = false

    func select(_ workspace: Workspace) {
        withAnimation(.snappy) {
            self.workspace = workspace
        }
    }

    func open(_ url: URL) {
        switch DeepLinkRoute(url: url) {
        case .dashboard, .meetings:
            select(.dashboard)
        case .people:
            select(.people)
        case .commitments:
            select(.commitments)
        case .capture:
            select(.dashboard)
            isQuickCapturePresented = true
        }
    }
}
