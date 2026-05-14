import SwiftUI

struct JobListView: View {
    @EnvironmentObject var jobsVM: JobsViewModel
    @State private var showFilterSheet = false
    @State private var selectedJob: Job? = nil

    var body: some View {
        Group {
            if jobsVM.isLoading && jobsVM.jobs.isEmpty {
                LoadingView()
            } else if jobsVM.jobs.isEmpty {
                emptyState
            } else {
                jobsList
            }
        }
        .navigationTitle("Remote Jobs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                filterButton
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheet(filter: $jobsVM.filter) { newFilter in
                Task { await jobsVM.applyFilter(newFilter) }
            }
        }
        .refreshable {
            await jobsVM.fetchJobs()
        }
        .navigationDestination(item: $selectedJob) { job in
            JobDetailView(job: job)
        }
    }

    // MARK: - Jobs List
    private var jobsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Active filters summary
                if jobsVM.filter.activeFiltersCount > 0 {
                    activeFiltersBanner
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }

                // Results count
                HStack {
                    Text("\(jobsVM.jobs.count) jobs found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Job cards
                ForEach(jobsVM.jobs) { job in
                    JobCardView(
                        job: job,
                        onSave: { jobsVM.toggleSave(job: job) },
                        onTap: { selectedJob = job }
                    )
                    .padding(.horizontal, 16)
                    .onAppear {
                        // Trigger pagination near end of list
                        if job.id == jobsVM.jobs.last?.id {
                            Task { await jobsVM.fetchMoreJobs() }
                        }
                    }
                }

                // Load more indicator
                if jobsVM.isLoadingMore {
                    InlineLoadingView(message: "Loading more jobs...")
                } else if !jobsVM.hasMorePages && jobsVM.jobs.count > 10 {
                    Text("You've seen all available jobs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 16)
                }

                Spacer(minLength: 24)
            }
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Empty State
    private var emptyState: some View {
        EmptyStateView(
            icon: "briefcase.fill",
            title: "No Jobs Found",
            subtitle: "Try adjusting your filters or search terms to find more opportunities.",
            actionTitle: "Reset Filters"
        ) {
            Task { await jobsVM.resetFilter() }
        }
    }

    // MARK: - Filter Button
    private var filterButton: some View {
        Button(action: { showFilterSheet = true }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18))

                if jobsVM.filter.activeFiltersCount > 0 {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 16, height: 16)
                        Text("\(jobsVM.filter.activeFiltersCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 8, y: -8)
                }
            }
            .frame(width: 36, height: 36)
        }
    }

    // MARK: - Active Filters Banner
    private var activeFiltersBanner: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16))

                if !jobsVM.filter.jobTypes.isEmpty {
                    ForEach(Array(jobsVM.filter.jobTypes), id: \.self) { type in
                        activeFilterChip(text: type.rawValue) {
                            var f = jobsVM.filter
                            f.jobTypes.remove(type)
                            Task { await jobsVM.applyFilter(f) }
                        }
                    }
                }

                if !jobsVM.filter.experienceLevels.isEmpty {
                    ForEach(Array(jobsVM.filter.experienceLevels), id: \.self) { level in
                        activeFilterChip(text: level.rawValue) {
                            var f = jobsVM.filter
                            f.experienceLevels.remove(level)
                            Task { await jobsVM.applyFilter(f) }
                        }
                    }
                }

                let salaryDesc = jobsVM.filter.salaryRangeDescription
                if salaryDesc != "Any salary" {
                    activeFilterChip(text: salaryDesc) {
                        var f = jobsVM.filter
                        f.minSalary = nil
                        f.maxSalary = nil
                        Task { await jobsVM.applyFilter(f) }
                    }
                }

                Button("Clear All") {
                    Task { await jobsVM.resetFilter() }
                }
                .font(.caption)
                .foregroundColor(.red)
                .padding(.leading, 4)
            }
            .padding(.horizontal, 4)
        }
    }

    private func activeFilterChip(text: String, remove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
            Button(action: remove) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.accentColor.opacity(0.15))
        .foregroundColor(.accentColor)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        JobListView()
            .environmentObject(JobsViewModel())
    }
}
