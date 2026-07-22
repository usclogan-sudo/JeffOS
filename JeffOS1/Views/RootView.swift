import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var model: AppModel
    @AppStorage("appearance") private var appearance = "System"

    var body: some View {
        NavigationSplitView {
            List(selection: $model.workspace) {
                Section("Jeff OS") {
                    ForEach(AppModel.Workspace.allCases) { workspace in
                        Label(workspace.rawValue, systemImage: workspace.symbol)
                            .tag(workspace)
                    }
                }
            }
            .navigationTitle("Jeff OS")
            .navigationSplitViewColumnWidth(min: 190, ideal: 220)
        } detail: {
            Group {
                switch model.workspace {
                case .dashboard:
                    DashboardView()
                case .people:
                    PeopleView()
                case .commitments:
                    CommitmentsView()
                case .settings:
                    SettingsView()
                }
            }
            .id(model.workspace)
            .transition(.opacity.combined(with: .move(edge: .trailing)))
            .animation(.snappy, value: model.workspace)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    model.isQuickCapturePresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .help("Quick Capture (⌘K)")
                .padding(24)
            }
        }
        .preferredColorScheme(preferredColorScheme)
        .sheet(isPresented: $model.isQuickCapturePresented) {
            QuickCaptureView()
        }
        .task {
            StarterDataService.seedIfNeeded(in: modelContext)
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch appearance {
        case "Light": .light
        case "Dark": .dark
        default: nil
        }
    }
}
