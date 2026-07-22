import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query(sort: \Person.name) private var people: [Person]
    @Query(sort: \Commitment.createdAt, order: .reverse) private var commitments: [Commitment]
    @Query(sort: \Meeting.startDate) private var meetings: [Meeting]
    @AppStorage("dailyPriorityLimit") private var dailyPriorityLimit = 3
    @State private var isAddingMeeting = false

    private let columns = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                greeting
                if people.isEmpty && commitments.isEmpty && meetings.isEmpty {
                    onboardingEmptyState
                } else {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 18) {
                        prioritiesSection
                        meetingsSection
                        waitingSection
                        commitmentsSection
                    }
                }
            }
            .padding(28)
            .padding(.bottom, 64)
        }
        .navigationTitle("Dashboard")
        .sheet(isPresented: $isAddingMeeting) {
            MeetingEditorView()
        }
        .animation(.snappy, value: openCommitments.count)
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(timeOfDayGreeting)
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text("Here’s what deserves your attention today.")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var onboardingEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 40))
                .foregroundStyle(.yellow)
            Text("Welcome to Jeff OS")
                .font(.title2.weight(.semibold))
            Text("Add your first relationship or capture your first commitment to begin.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 360)
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var timeOfDayGreeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 0..<12: "Good morning, Jeff."
        case 12..<18: "Good afternoon, Jeff."
        default: "Good evening, Jeff."
        }
    }

    private var prioritiesSection: some View {
        DashboardCard(title: "Today's Priorities", systemImage: "flag.fill", tint: .orange) {
            if priorities.isEmpty {
                DashboardEmptyState(message: "Your priority list is clear.", systemImage: "checkmark.circle")
            } else {
                ForEach(priorities.prefix(max(1, dailyPriorityLimit))) { commitment in
                    CommitmentSummaryRow(commitment: commitment, showsPerson: true)
                }
            }
        }
    }

    private var meetingsSection: some View {
        DashboardCard(title: "Today's Meetings", systemImage: "calendar", tint: .blue) {
            if todaysMeetings.isEmpty {
                DashboardEmptyState(message: "No meetings scheduled today.", systemImage: "calendar.badge.checkmark")
            } else {
                ForEach(todaysMeetings) { meeting in
                    HStack(spacing: 12) {
                        Text(meeting.startDate.formatted(date: .omitted, time: .shortened))
                            .font(.callout.monospacedDigit().weight(.semibold))
                            .frame(width: 76, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(meeting.title)
                                .fontWeight(.medium)
                            if !meeting.location.isEmpty {
                                Text(meeting.location)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }

            Button("Add Meeting", systemImage: "plus") {
                isAddingMeeting = true
            }
            .controlSize(.small)
        }
    }

    private var waitingSection: some View {
        DashboardCard(title: "Waiting on Jeff", systemImage: "person.crop.circle.badge.clock", tint: .purple) {
            if waitingOnJeff.isEmpty {
                DashboardEmptyState(message: "Nobody is waiting on you.", systemImage: "person.2")
            } else {
                ForEach(waitingOnJeff.prefix(5)) { person in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(person.name).fontWeight(.medium)
                            Spacer()
                            HealthBadge(value: person.relationshipHealth)
                        }
                        Text(person.nextAction)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var commitmentsSection: some View {
        DashboardCard(title: "Open Commitments", systemImage: "checklist", tint: .green) {
            if openCommitments.isEmpty {
                DashboardEmptyState(message: "All commitments are complete.", systemImage: "checkmark.seal")
            } else {
                ForEach(openCommitments.prefix(5)) { commitment in
                    CommitmentSummaryRow(commitment: commitment, showsPerson: true)
                }
            }
        }
    }

    private var openCommitments: [Commitment] {
        commitments
            .filter(\.isOpen)
            .sorted { lhs, rhs in
                switch (lhs.dueDate, rhs.dueDate) {
                case let (left?, right?): left < right
                case (_?, nil): true
                case (nil, _?): false
                case (nil, nil): lhs.createdAt < rhs.createdAt
                }
            }
    }

    private var priorities: [Commitment] {
        let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: .now)) ?? .now
        return openCommitments.filter { commitment in
            guard let dueDate = commitment.dueDate else { return false }
            return dueDate < endOfToday
        }
    }

    private var todaysMeetings: [Meeting] {
        meetings.filter { Calendar.current.isDateInToday($0.startDate) }
    }

    private var waitingOnJeff: [Person] {
        people
            .filter { !$0.nextAction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sorted { $0.relationshipHealth < $1.relationshipHealth }
    }
}

private struct DashboardCard<Content: View>: View {
    let title: String
    let systemImage: String
    let tint: Color
    @ViewBuilder let content: Content

    init(
        title: String,
        systemImage: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(tint)
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                content
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 1)
        }
    }
}

private struct DashboardEmptyState: View {
    let message: String
    let systemImage: String

    var body: some View {
        Label(message, systemImage: systemImage)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 100)
    }
}

struct HealthBadge: View {
    let value: Int

    var body: some View {
        Label("\(value)", systemImage: "heart.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .contentTransition(.numericText())
    }

    private var color: Color {
        switch value {
        case 80...: .green
        case 60...: .orange
        default: .red
        }
    }
}

struct CommitmentSummaryRow: View {
    @Environment(\.modelContext) private var modelContext
    let commitment: Commitment
    let showsPerson: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                withAnimation(.snappy) {
                    commitment.status = .completed
                    try? modelContext.save()
                }
            } label: {
                Image(systemName: "circle")
            }
            .buttonStyle(.plain)
            .help("Mark complete")

            VStack(alignment: .leading, spacing: 3) {
                Text(commitment.title)
                    .fontWeight(.medium)
                HStack(spacing: 8) {
                    if showsPerson, let person = commitment.person {
                        Text(person.name)
                    }
                    if let dueDate = commitment.dueDate {
                        Text(dueDate, format: .dateTime.month(.abbreviated).day())
                            .foregroundStyle(Calendar.current.startOfDay(for: dueDate) < Calendar.current.startOfDay(for: .now) ? .red : .secondary)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 3)
    }
}
