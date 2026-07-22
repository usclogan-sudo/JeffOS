import SwiftData
import SwiftUI

struct QuickCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var people: [Person]
    @State private var text = ""
    @State private var selectedPerson: Person?
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Quick Capture", systemImage: "bolt.fill")
                .font(.title2.weight(.semibold))

            TextField("Call David tomorrow", text: $text)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .focused($isTextFieldFocused)
                .onSubmit(save)

            Picker("Person", selection: $selectedPerson) {
                Text("No person").tag(Person?.none)
                ForEach(people) { person in
                    Text(person.name).tag(Person?.some(person))
                }
            }

            Text("Your words are stored exactly as entered. You can add a due date from Commitments.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Capture", action: save)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                    .disabled(trimmedText.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 480)
        .onAppear { isTextFieldFocused = true }
    }

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        guard !trimmedText.isEmpty else { return }
        modelContext.insert(Commitment(title: trimmedText, person: selectedPerson))
        try? modelContext.save()
        dismiss()
    }
}
