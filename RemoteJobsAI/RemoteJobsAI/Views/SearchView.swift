import SwiftUI

struct SearchView: View {
    @EnvironmentObject var jobsVM: JobsViewModel
    @State private var isSearchFocused = false
    @State private var selectedJob: Job? = nil
    @State private var showFilterSheet = false
    @State private var showJobDetail = false

    private let popularCategories = JobCategory.popular

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Search Bar
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // MARK: - Filter Chips
                if !jobsVM.searchQuery.isEmpty || isSearchFocused {
                    quickFilterChips
                        .padding(.top, 8)
                }

                Divider()
                    .padding(.top, 8)

                // MARK: - Content
                if jobsVM.isLoading {
                    LoadingView(cardCount: 4)
                } else if !jobsVM.searchQuery.isEmpty {
                    searchResultsView
                } else {
                    browseView
                }
            }
            .navigationTitle("Search Jobs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilterSheet = true }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheet(filter: $jobsVM.filter) { newFilter in
                    Task { await jobsVM.applyFilter(newFilter) }
                }
            }
            .navigationDestination(isPresented: $showJobDetail) {
                if let job = selectedJob {
                    JobDetailView(job: job)
                }
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 18))

            TextField("Job title, company, or keyword", text: $jobsVM.searchQuery)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onTapGesture { isSearchFocused = true }

            if !jobsVM.searchQuery.isEmpty {
                Button(action: {
                    jobsVM.searchQuery = ""
                    Task { await jobsVM.fetchJobs() }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }

    // MARK: - Quick Filter Chips
    private var quickFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChipView(title: "Remote Only", isSelected: jobsVM.filter.jobTypes == [.remote], icon: "house.fill") {
                    var f = jobsVM.filter
                    if f.jobTypes == [.remote] {
                        f.jobTypes = Set(JobType.allCases)
                    } else {
                        f.jobTypes = [.remote]
                    }
                    Task { await jobsVM.applyFilter(f) }
                }

                FilterChipView(title: "Entry Level", isSelected: jobsVM.filter.experienceLevels == [.entryLevel]) {
                    var f = jobsVM.filter
                    if f.experienceLevels == [.entryLevel] {
                        f.experienceLevels = Set(ExperienceLevel.allCases)
                    } else {
                        f.experienceLevels = [.entryLevel]
                    }
                    Task { await jobsVM.applyFilter(f) }
                }

                FilterChipView(title: "$80K+", isSelected: jobsVM.filter.minSalary == 80_000) {
                    var f = jobsVM.filter
                    f.minSalary = f.minSalary == 80_000 ? nil : 80_000
                    Task { await jobsVM.applyFilter(f) }
                }

                FilterChipView(title: "Past Week", isSelected: jobsVM.filter.postedWithinDays == 7, icon: "calendar") {
                    var f = jobsVM.filter
                    f.postedWithinDays = f.postedWithinDays == 7 ? nil : 7
                    Task { await jobsVM.applyFilter(f) }
                }

                FilterChipView(title: "Easy Apply", isSelected: false, icon: "bolt.fill") {
                    // Simulated easy apply filter
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Search Results
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Results header
                HStack {
                    Text("\(jobsVM.jobs.count) results for \"\(jobsVM.searchQuery)\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                if jobsVM.jobs.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results Found",
                        subtitle: "Try different keywords or adjust your filters",
                        actionTitle: "Clear Search"
                    ) {
                        jobsVM.searchQuery = ""
                        Task { await jobsVM.fetchJobs() }
                    }
                } else {
                    ForEach(jobsVM.jobs) { job in
                        JobCardView(
                            job: job,
                            onSave: { jobsVM.toggleSave(job: job) },
                            onTap: {
                                selectedJob = job
                                showJobDetail = true
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }

                Spacer(minLength: 24)
            }
        }
    }

    // MARK: - Browse View (when not searching)
    private var browseView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {

                // Recent Searches
                if !jobsVM.recentSearches.isEmpty {
                    recentSearchesSection
                        .padding(.top, 16)
                }

                // Popular Categories
                Text("Popular Categories")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                categoriesGrid
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                // Trending Jobs
                Text("Trending Remote Jobs")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                trendingJobsList
                    .padding(.top, 8)

                Spacer(minLength: 24)
            }
        }
    }

    // MARK: - Recent Searches
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Recent Searches", systemImage: "clock")
                    .font(.headline)
                Spacer()
                Button("Clear") {
                    jobsVM.clearRecentSearches()
                }
                .font(.subheadline)
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 16)

            ForEach(jobsVM.recentSearches.prefix(5), id: \.self) { search in
                Button(action: {
                    jobsVM.searchQuery = search
                    Task { await jobsVM.searchJobs(query: search) }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.secondary)
                        Text(search)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.left")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
        }
    }

    // MARK: - Categories Grid
    private var categoriesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(popularCategories) { category in
                Button(action: {
                    jobsVM.searchQuery = category.keyword
                    Task { await jobsVM.searchJobs(query: category.keyword) }
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(categoryColor: category.color).opacity(0.15))
                                .frame(width: 58, height: 58)
                            Image(systemName: category.icon)
                                .font(.system(size: 24))
                                .foregroundColor(Color(categoryColor: category.color))
                        }
                        Text(category.name)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // MARK: - Trending Jobs
    private var trendingJobsList: some View {
        LazyVStack(spacing: 10) {
            ForEach(Array(JobService.mockJobs.prefix(8).enumerated()), id: \.offset) { index, job in
                Button(action: { selectedJob = job; showJobDetail = true }) {
                    HStack(spacing: 14) {
                        Text("#\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(job.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text(job.company)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        TagView(text: job.jobType.rawValue, color: .green)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                }
                .buttonStyle(PlainButtonStyle())

                if index < 7 {
                    Divider().padding(.leading, 58)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

#Preview {
    SearchView()
        .environmentObject(JobsViewModel())
        .environmentObject(ProfileViewModel())
}
