import Foundation
import Combine

@MainActor
class JobsViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var jobs: [Job] = []
    @Published var featuredJobs: [Job] = []
    @Published var savedJobs: [Job] = []
    @Published var appliedJobs: [Job] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var searchQuery: String = ""
    @Published var filter: JobFilter = .default
    @Published var error: String? = nil
    @Published var currentPage: Int = 1
    @Published var hasMorePages: Bool = true
    @Published var recentSearches: [String] = []
    @Published var selectedJob: Job? = nil

    // MARK: - Stats
    var applicationsCount: Int { appliedJobs.count }
    var interviewsCount: Int { appliedJobs.filter { $0.applicationStatus == .interview }.count }
    var offersCount: Int { appliedJobs.filter { $0.applicationStatus == .offer }.count }
    var savedCount: Int { savedJobs.count }

    // MARK: - Private
    private let jobService = JobService.shared
    private var searchTask: Task<Void, Never>? = nil
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadSavedData()
        setupSearchDebounce()
        Task { await fetchJobs() }
        Task { await fetchFeaturedJobs() }
    }

    // MARK: - Fetch Jobs

    func fetchJobs() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await jobService.fetchJobs(filter: filter)
            jobs = fetched
            currentPage = 1
            hasMorePages = fetched.count >= 10
            syncSavedStatus()
            syncApplicationStatus()
        } catch {
            self.error = "Failed to load jobs. Please try again."
        }
        isLoading = false
    }

    func fetchFeaturedJobs() async {
        do {
            let featured = try await jobService.fetchFeaturedJobs()
            featuredJobs = featured
            syncSavedStatus(in: &featuredJobs)
        } catch {
            // Silently fail for featured jobs
        }
    }

    func fetchMoreJobs() async {
        guard !isLoadingMore && hasMorePages else { return }
        isLoadingMore = true
        do {
            let more = try await jobService.fetchMoreJobs(filter: filter, page: currentPage + 1)
            if more.isEmpty {
                hasMorePages = false
            } else {
                jobs.append(contentsOf: more)
                currentPage += 1
                syncSavedStatus()
            }
        } catch {
            self.error = "Failed to load more jobs."
        }
        isLoadingMore = false
    }

    // MARK: - Search

    func searchJobs(query: String) async {
        guard !query.isEmpty else {
            await fetchJobs()
            return
        }
        isLoading = true
        error = nil
        do {
            let results = try await jobService.searchJobs(query: query)
            jobs = results
            syncSavedStatus()
            syncApplicationStatus()
            addRecentSearch(query)
        } catch {
            self.error = "Search failed. Please try again."
        }
        isLoading = false
    }

    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                searchTask?.cancel()
                searchTask = Task {
                    await self.searchJobs(query: query)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Save / Unsave

    func toggleSave(job: Job) {
        if let idx = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[idx].isSaved.toggle()
        }
        if let idx = featuredJobs.firstIndex(where: { $0.id == job.id }) {
            featuredJobs[idx].isSaved.toggle()
        }

        if savedJobs.contains(where: { $0.id == job.id }) {
            savedJobs.removeAll { $0.id == job.id }
        } else {
            var saved = job
            saved.isSaved = true
            savedJobs.append(saved)
        }
        savePersistentData()
    }

    func isSaved(_ job: Job) -> Bool {
        savedJobs.contains(where: { $0.id == job.id })
    }

    // MARK: - Application Status

    func updateApplicationStatus(job: Job, status: ApplicationStatus) {
        if let idx = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[idx].applicationStatus = status
        }
        if let idx = featuredJobs.firstIndex(where: { $0.id == job.id }) {
            featuredJobs[idx].applicationStatus = status
        }

        if let idx = appliedJobs.firstIndex(where: { $0.id == job.id }) {
            appliedJobs[idx].applicationStatus = status
            if status == .notApplied {
                appliedJobs.remove(at: idx)
            }
        } else if status != .notApplied {
            var applied = job
            applied.applicationStatus = status
            appliedJobs.append(applied)
        }
        savePersistentData()
    }

    func applyToJob(_ job: Job) {
        updateApplicationStatus(job: job, status: .applied)
    }

    // MARK: - Filter

    func applyFilter(_ newFilter: JobFilter) async {
        filter = newFilter
        await fetchJobs()
    }

    func resetFilter() async {
        filter = .default
        await fetchJobs()
    }

    // MARK: - Recent Searches

    func addRecentSearch(_ query: String) {
        guard !query.isEmpty else { return }
        recentSearches.removeAll { $0.lowercased() == query.lowercased() }
        recentSearches.insert(query, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        saveRecentSearches()
    }

    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "recentSearches")
    }

    // MARK: - Persistence

    private func syncSavedStatus() {
        let savedIds = Set(savedJobs.map { $0.id })
        for i in jobs.indices {
            jobs[i].isSaved = savedIds.contains(jobs[i].id)
        }
    }

    private func syncSavedStatus(in jobsArray: inout [Job]) {
        let savedIds = Set(savedJobs.map { $0.id })
        for i in jobsArray.indices {
            jobsArray[i].isSaved = savedIds.contains(jobsArray[i].id)
        }
    }

    private func syncApplicationStatus() {
        let appliedMap = Dictionary(uniqueKeysWithValues: appliedJobs.map { ($0.id, $0.applicationStatus) })
        for i in jobs.indices {
            if let status = appliedMap[jobs[i].id] {
                jobs[i].applicationStatus = status
            }
        }
    }

    private func loadSavedData() {
        if let data = UserDefaults.standard.data(forKey: "savedJobs"),
           let decoded = try? JSONDecoder().decode([Job].self, from: data) {
            savedJobs = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "appliedJobs"),
           let decoded = try? JSONDecoder().decode([Job].self, from: data) {
            appliedJobs = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "recentSearches"),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            recentSearches = decoded
        }
    }

    private func savePersistentData() {
        if let encoded = try? JSONEncoder().encode(savedJobs) {
            UserDefaults.standard.set(encoded, forKey: "savedJobs")
        }
        if let encoded = try? JSONEncoder().encode(appliedJobs) {
            UserDefaults.standard.set(encoded, forKey: "appliedJobs")
        }
    }

    private func saveRecentSearches() {
        if let encoded = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(encoded, forKey: "recentSearches")
        }
    }
}
