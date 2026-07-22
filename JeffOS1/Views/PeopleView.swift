import SwiftData
import SwiftUI

struct PeopleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var people: [Person]
    @State private var searchText = ""
    @State private var selectedPerson: Person?
    @State private var personToEdit: Person?
    @State private var isAddingPerson = false
    @State private var personToDelete: Person?

    private var filteredPeople: [Person] {
        guard !searchText.isEmpty else { return people }
        return people.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.organization.localizedCaseInsensitiveContains(searchText) ||
            $0.nextAction.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        HSplitView {
            List(selection: $selectedPerson) {
                ForEach(filteredPeople) { person in
                    PersonListRow(person: person)
                        .tag(person)
                        .contextMenu {
                            Button("Edit") { personToEdit = person }
                            Button("Delete", role: .destructive) { personToDelete = person }
                        }
                }
            }
            .searchable(text: $searchText, prompt: "Search people")
            .frame(minWidth: 300, idealWidth: 340)
            .overlay {
                if filteredPeople.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }

            Group {
                if let selectedPerson {
                    PersonDetailView(
                        person: selectedPerson,
                        onEdit: { personToEdit = selectedPerson },
                        onDelete: { personToDelete = selectedPerson }
                    )
                } else {
                    ContentUnavailableView(
                        "Select a Person",
                        systemImage: "person.crop.circle",
                        description: Text("Choose someone to review their next action and relationship context.")
                    )
                }
            }
            .frame(minWidth: 560, maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("People")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Person", systemImage: "person.badge.plus") {
                    isAddingPerson = true
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }
        .sheet(isPresented: $isAddingPerson) {
            PersonEditorView(person: nil) { newPerson in
                modelContext.insert(newPerson)
                selectedPerson = newPerson
                try? modelContext.save()
            }
        }
        .sheet(item: $personToEdit) { person in
            PersonEditorView(person: person) { _ in
                try? modelContext.save()
            }
        }
        .confirmationDialog(
            "Delete \(personToDelete?.name ?? "this person")?",
            isPresented: Binding(
                get: { personToDelete != nil },
                set: { if !$0 { personToDelete = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                guard let personToDelete else { return }
                if selectedPerson == personToDelete { selectedPerson = nil }
                modelContext.delete(personToDelete)
                try? modelContext.save()
                self.personToDelete = nil
            }
        } message: {
            Text("Their commitments will remain and become unassigned.")
        }
        .animation(.snappy, value: filteredPeople.count)
    }
}

private struct PersonListRow: View {
    let person: Person

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(.tint.opacity(0.15))
                Text(initials)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tint)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(person.name).fontWeight(.medium)
                Text(person.organization)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HealthBadge(value: person.relationshipHealth)
        }
        .padding(.vertical, 4)
    }

    private var initials: String {
        person.name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
    }
}

private struct PersonDetailView: View {
    let person: Person
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(person.name)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                        Text(person.organization)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(person.relationshipHealth)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(healthColor)
                        Text("Relationship Health")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                GroupBox("Next Action") {
                    Text(person.nextAction.isEmpty ? "No next action recorded." : person.nextAction)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }

                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                    GridRow {
                        Text("Last Contact").foregroundStyle(.secondary)
                        Text(person.lastContact?.formatted(date: .abbreviated, time: .omitted) ?? "Not recorded")
                    }
                    GridRow {
                        Text("Open Commitments").foregroundStyle(.secondary)
                        Text("\(person.commitments.filter(\.isOpen).count)")
                            .contentTransition(.numericText())
                    }
                }

                GroupBox("Notes") {
                    Text(person.notes.isEmpty ? "No notes recorded." : person.notes)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
            }
            .padding(28)
        }
        .toolbar {
            ToolbarItemGroup {
                Button("Edit", systemImage: "pencil", action: onEdit)
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            }
        }
    }

    private var healthColor: Color {
        switch person.relationshipHealth {
        case 80...: .green
        case 60...: .orange
        default: .red
        }
    }
}

struct PersonEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let person: Person?
    let onSave: (Person) -> Void

    @State private var name: String
    @State private var organization: String
    @State private var hasLastContact: Bool
    @State private var lastContact: Date
    @State private var nextAction: String
    @State private var relationshipHealth: Int
    @State private var notes: String

    init(person: Person?, onSave: @escaping (Person) -> Void) {
        self.person = person
        self.onSave = onSave
        _name = State(initialValue: person?.name ?? "")
        _organization = State(initialValue: person?.organization ?? "")
        _hasLastContact = State(initialValue: person?.lastContact != nil)
        _lastContact = State(initialValue: person?.lastContact ?? .now)
        _nextAction = State(initialValue: person?.nextAction ?? "")
        _relationshipHealth = State(initialValue: person?.relationshipHealth ?? 75)
        _notes = State(initialValue: person?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Person") {
                    TextField("Name", text: $name)
                    TextField("Organization", text: $organization)
                }
                Section("Relationship") {
                    Toggle("Record last contact", isOn: $hasLastContact.animation(.snappy))
                    if hasLastContact {
                        DatePicker("Last Contact", selection: $lastContact, displayedComponents: .date)
                    }
                    TextField("Next Action", text: $nextAction, axis: .vertical)
                    LabeledContent("Relationship Health") {
                        HStack {
                            Slider(value: healthBinding, in: 0...100, step: 1)
                                .frame(width: 220)
                            Text("\(relationshipHealth)")
                                .monospacedDigit()
                                .frame(width: 32, alignment: .trailing)
                        }
                    }
                }
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(person == nil ? "Add Person" : "Edit Person")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .keyboardShortcut(.defaultAction)
                        .disabled(trimmedName.isEmpty || trimmedOrganization.isEmpty)
                }
            }
        }
        .frame(width: 560, height: 580)
    }

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedOrganization: String { organization.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var healthBinding: Binding<Double> {
        Binding(
            get: { Double(relationshipHealth) },
            set: { relationshipHealth = Int($0) }
        )
    }

    private func save() {
        let value = person ?? Person(name: trimmedName, organization: trimmedOrganization)
        value.name = trimmedName
        value.organization = trimmedOrganization
        value.lastContact = hasLastContact ? lastContact : nil
        value.nextAction = nextAction.trimmingCharacters(in: .whitespacesAndNewlines)
        value.relationshipHealth = relationshipHealth
        value.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(value)
        dismiss()
    }
}
