import SwiftData
import SwiftUI

struct CommitmentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Commitment.createdAt, order: .reverse) private var commitments: [Commitment]
    @State private var filter: CommitmentFilter = .open
    @State private var commitmentToEdit: Commitment?
    @State private var isAddingCommitment = false

    private var filteredCommitments: [Commitment] {
        commitments.filter { commitment in
            switch filter {
            case .open: commitment.isOpen
            case .completed: !commitment.isOpen
            case .all: true
            }
        }
        .sorted { lhs, rhs in
            switch (lhs.dueDate, rhs.dueDate) {
            case let (left?, right?): left < right
            case (_?, nil): true
            case (nil, _?): false
            case (nil, nil): lhs.createdAt > rhs.createdAt
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Status", selection: $filter) {
                ForEach(CommitmentFilter.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 360)
            .padding()

            List {
                ForEach(filteredCommitments) { commitment in
                    CommitmentRow(commitment: commitment) {
                        commitmentToEdit = commitment
                    }
                    .contextMenu {
                        Button("Edit") { commitmentToEdit = commitment }
                        Button("Delete", role: .destructive) { delete(commitment) }
                    }
                }
                .onDelete { offsets in
                    offsets.map { filteredCommitments[$0] }.forEach(delete)
                }
            }
            .overlay {
                if filteredCommitments.isEmpty {
                    ContentUnavailableView(
                        "No \(filter.rawValue) Commitments",
                        systemImage: filter == .completed ? "checkmark.seal" : "checklist"
                    )
                }
            }
        }
        .navigationTitle("Commitments")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Commitment", systemImage: "plus") {
                    isAddingCommitment = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        .sheet(isPresented: $isAddingCommitment) {
            CommitmentEditorView(commitment: nil) { commitment in
                modelContext.insert(commitment)
                try? modelContext.save()
            }
        }
        .sheet(item: $commitmentToEdit) { commitment in
            CommitmentEditorView(commitment: commitment) { _ in
                try? modelContext.save()
            }
        }
        .animation(.snappy, value: filteredCommitments.count)
    }

    private func delete(_ commitment: Commitment) {
        withAnimation(.snappy) {
            modelContext.delete(commitment)
            try? modelContext.save()
        }
    }
}

private enum CommitmentFilter: String, CaseIterable, Identifiable {
    case open = "Open"
    case completed = "Completed"
    case all = "All"

    var id: String { rawValue }
}

private struct CommitmentRow: View {
    @Environment(\.modelContext) private var modelContext
    let commitment: Commitment
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.snappy) {
                    commitment.status = commitment.isOpen ? .completed : .open
                    try? modelContext.save()
                }
            } label: {
                Image(systemName: commitment.isOpen ? "circle" : "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(commitment.isOpen ? Color.secondary : Color.green)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(commitment.title)
                    .font(.headline)
                    .strikethrough(!commitment.isOpen)
                HStack(spacing: 12) {
                    if let person = commitment.person {
                        Label(person.name, systemImage: "person")
                    }
                    if let dueDate = commitment.dueDate {
                        Label(dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .foregroundStyle(isOverdue ? .red : .secondary)
                    } else {
                        Label("No due date", systemImage: "calendar.badge.minus")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Edit", systemImage: "pencil", action: onEdit)
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .help("Edit Commitment")
        }
        .padding(.vertical, 6)
    }

    private var isOverdue: Bool {
        guard commitment.isOpen, let dueDate = commitment.dueDate else { return false }
        return Calendar.current.startOfDay(for: dueDate) < Calendar.current.startOfDay(for: .now)
    }
}

struct CommitmentEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Person.name) private var people: [Person]
    let commitment: Commitment?
    let onSave: (Commitment) -> Void

    @State private var title: String
    @State private var selectedPerson: Person?
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var status: CommitmentStatus

    init(commitment: Commitment?, onSave: @escaping (Commitment) -> Void) {
        self.commitment = commitment
        self.onSave = onSave
        _title = State(initialValue: commitment?.title ?? "")
        _selectedPerson = State(initialValue: commitment?.person)
        _hasDueDate = State(initialValue: commitment?.dueDate != nil)
        _dueDate = State(initialValue: commitment?.dueDate ?? .now)
        _status = State(initialValue: commitment?.status ?? .open)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Picker("Person", selection: $selectedPerson) {
                    Text("Unassigned").tag(Person?.none)
                    ForEach(people) { person in
                        Text(person.name).tag(Person?.some(person))
                    }
                }
                Toggle("Has due date", isOn: $hasDueDate.animation(.snappy))
                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                Picker("Status", selection: $status) {
                    ForEach(CommitmentStatus.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(commitment == nil ? "Add Commitment" : "Edit Commitment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .keyboardShortcut(.defaultAction)
                        .disabled(trimmedTitle.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 360)
    }

    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func save() {
        let value = commitment ?? Commitment(title: trimmedTitle)
        value.title = trimmedTitle
        value.person = selectedPerson
        value.dueDate = hasDueDate ? dueDate : nil
        value.status = status
        onSave(value)
        dismiss()
    }
}
