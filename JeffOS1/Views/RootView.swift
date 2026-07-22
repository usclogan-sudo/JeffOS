import SwiftUI

struct RootView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            switch model.workspace {
            case .briefing:
                BriefingView()
            case .accounts:
                AccountsView()
            case .meetings:
                PlaceholderWorkspace(
                    title: "Meetings",
                    subtitle: "Meeting preparation, commitments and post-meeting follow-up."
                )
            case .execution:
                ExecutionView()
            case .ai:
                AIWorkspaceView()
            case .settings:
                SettingsView()
            }
        }
    }
}

private struct SidebarView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        List(selection: $model.workspace) {
            Section("Jeff OS") {
                ForEach(AppModel.Workspace.allCases) { workspace in
                    Label(workspace.rawValue, systemImage: workspace.symbol)
                        .tag(workspace)
                }
            }
        }
        .navigationTitle("Jeff OS")
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 8) {
                Circle()
                    .frame(width: 8, height: 8)
                Text(model.status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Spacer()
            }
            .padding()
            .background(.bar)
        }
    }
}
