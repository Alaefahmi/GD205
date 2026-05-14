import SwiftUI

struct ContentView: View {
    @EnvironmentObject var jobsVM: JobsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var selectedTab: Tab = .home

    enum Tab: Int, CaseIterable {
        case home = 0
        case search = 1
        case applications = 2
        case profile = 3

        var title: String {
            switch self {
            case .home: return "Home"
            case .search: return "Search"
            case .applications: return "Applications"
            case .profile: return "Profile"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass"
            case .applications: return "list.bullet.rectangle.portrait.fill"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)

            ApplicationsView()
                .tabItem {
                    Label("Applications", systemImage: "list.bullet.rectangle.portrait.fill")
                }
                .badge(jobsVM.interviewsCount > 0 ? "\(jobsVM.interviewsCount)" : nil)
                .tag(Tab.applications)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
        .tint(Color(hex: "1a237e"))
    }
}

// MARK: - ApplicationsView
struct ApplicationsView: View {
    @EnvironmentObject var jobsVM: JobsViewModel
    @State private var selectedFilter: ApplicationStatus? = nil
    @State private var selectedJob: Job? = nil

    private var displayedJobs: [Job] {
        if let filter = selectedFilter {
            return jobsVM.appliedJobs.filter { $0.applicationStatus == filter }
        }
        return jobsVM.appliedJobs
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Status filter
                statusFilterBar

                Divider()

                if displayedJobs.isEmpty {
                    applicationEmptyState
                } else {
                    applicationsList
                }
            }
            .navigationTitle("Applications")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedJob) { job in
                JobDetailView(job: job)
            }
        }
    }

    private var statusFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChipView(title: "All (\(jobsVM.appliedJobs.count))", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }

                ForEach([ApplicationStatus.applied, .interview, .offer, .rejected], id: \.self) { status in
                    let count = jobsVM.appliedJobs.filter { $0.applicationStatus == status }.count
                    if count > 0 {
                        FilterChipView(title: "\(status.rawValue) (\(count))", isSelected: selectedFilter == status, icon: status.icon) {
                            selectedFilter = selectedFilter == status ? nil : status
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var applicationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Stats summary
                applicationStatsRow
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                ForEach(displayedJobs) { job in
                    applicationCard(job)
                        .padding(.horizontal, 16)
                }

                Spacer(minLength: 24)
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var applicationStatsRow: some View {
        HStack(spacing: 8) {
            miniStat(
                value: "\(jobsVM.appliedJobs.filter { $0.applicationStatus == .applied }.count)",
                label: "Pending",
                color: .blue
            )
            miniStat(
                value: "\(jobsVM.interviewsCount)",
                label: "Interview",
                color: .orange
            )
            miniStat(
                value: "\(jobsVM.offersCount)",
                label: "Offers",
                color: .green
            )
            miniStat(
                value: "\(jobsVM.appliedJobs.filter { $0.applicationStatus == .rejected }.count)",
                label: "Rejected",
                color: .red
            )
        }
    }

    private func miniStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func applicationCard(_ job: Job) -> some View {
        Button(action: { selectedJob = job }) {
            HStack(spacing: 14) {
                // Status indicator
                VStack {
                    ZStack {
                        Circle()
                            .fill(statusColor(job.applicationStatus).opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: job.applicationStatus.icon)
                            .font(.system(size: 18))
                            .foregroundColor(statusColor(job.applicationStatus))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(job.company)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 6) {
                        TagView(text: job.applicationStatus.rawValue, color: statusColor(job.applicationStatus))
                        Text(job.postedDateFormatted)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var applicationEmptyState: some View {
        EmptyStateView(
            icon: "list.bullet.rectangle.portrait",
            title: selectedFilter == nil ? "No Applications Yet" : "No \(selectedFilter!.rawValue) Jobs",
            subtitle: selectedFilter == nil
                ? "Start applying to jobs! Use our AI Quick Apply to submit applications fast."
                : "You don't have any jobs with \(selectedFilter!.rawValue) status yet.",
            actionTitle: selectedFilter != nil ? "Show All" : nil
        ) {
            selectedFilter = nil
        }
    }

    private func statusColor(_ status: ApplicationStatus) -> Color {
        switch status {
        case .notApplied: return .gray
        case .applied: return .blue
        case .interview: return .orange
        case .offer: return .green
        case .rejected: return .red
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(JobsViewModel())
        .environmentObject(ProfileViewModel())
}
