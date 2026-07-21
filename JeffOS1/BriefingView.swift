import SwiftUI

struct BriefingView: View {
    @EnvironmentObject private var model: AppModel

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                summaryCard
                metrics
                followUpQueue
            }
            .padding(28)
        }
        .navigationTitle("Briefing")
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(greeting)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Here’s who needs you today.")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
            }
            Spacer()
            Button {
                model.refreshMorningBriefing()
            } label: {
                if model.isRefreshing {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Run Morning Briefing", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.isRefreshing)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Executive Summary", systemImage: "sparkles")
                .font(.headline)
            Text(model.executiveSummary)
                .font(.title3)
                .foregroundStyle(.secondary)
            if let lastRefresh = model.lastRefresh {
                Text("Updated \(lastRefresh.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var metrics: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            MetricCard(value: "\(model.followUpQueue.count)", label: "Need attention")
            MetricCard(value: "\(model.overdueCount)", label: "Overdue")
            MetricCard(value: "\(model.coolingCount)", label: "Cooling")
            MetricCard(value: "\(model.medianResponseHours)h", label: "Median response")
        }
    }

    private var followUpQueue: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("People Waiting on Jeff")
                    .font(.title2.weight(.semibold))
                Spacer()
                Button("View All Accounts") {
                    model.workspace = .accounts
                }
            }

            ForEach(model.followUpQueue.prefix(5)) { contact in
                FollowUpRow(contact: contact)
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning, Jeff." }
        if hour < 17 { return "Good afternoon, Jeff." }
        return "Good evening, Jeff."
    }
}

private struct MetricCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
            Text(label)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
