import SwiftData
import SwiftUI

struct MeetingEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var startDate = Date.now
    @State private var location = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Meeting title", text: $title)
                DatePicker("Starts", selection: $startDate)
                TextField("Location", text: $location)
            }
            .formStyle(.grouped)
            .navigationTitle("Add Meeting")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        modelContext.insert(Meeting(title: trimmedTitle, startDate: startDate, location: location))
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
        .frame(width: 460, height: 260)
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
