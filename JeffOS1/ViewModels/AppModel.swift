import Combine
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
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
}
