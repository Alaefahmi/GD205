import SwiftUI

struct HomeView: View {
    @EnvironmentObject var jobsVM: JobsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var selectedCategory: JobCategory? = nil
    @State private var selectedJob: Job? = nil
    @State private var showAllJobs = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {

                    // MARK: - Header Banner
                    headerBanner
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // MARK: - Quick Stats
                    quickStatsCard
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    // MARK: - Categories
                    sectionHeader(title: "Browse Categories", action: nil)
                        .padding(.top, 20)

                    categoriesScrollView
                        .padding(.bottom, 4)

                    // MARK: - Featured Jobs
                    sectionHeader(title: "Top Remote Jobs Today", action: {
                        showAllJobs = true
                    })
                    .padding(.top, 12)

                    if jobsVM.isLoading {
                        LoadingView(cardCount: 3)
                            .padding(.horizontal, 16)
                    } else if jobsVM.featuredJobs.isEmpty {
                        EmptyStateView(
                            icon: "briefcase",
                            title: "No Featured Jobs",
                            subtitle: "Pull to refresh to find remote jobs",
                            actionTitle: "Refresh"
                        ) {
                            Task { await jobsVM.fetchFeaturedJobs() }
                        }
                        .padding(.horizontal, 16)
                    } else {
                        featuredJobsList
                    }

                    // MARK: - Recent / All Jobs
                    sectionHeader(title: "Recently Added", action: {
                        showAllJobs = true
                    })
                    .padding(.top, 12)

                    if !jobsVM.jobs.isEmpty {
                        recentJobsList
                    }

                    Spacer(minLength: 32)
                }
            }
            .refreshable {
                await jobsVM.fetchJobs()
                await jobsVM.fetchFeaturedJobs()
            }
            .navigationTitle("RemoteJobsAI")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        avatarView
                    }
                }
            }
            .navigationDestination(for: Job.self) { job in
                JobDetailView(job: job)
            }
            .navigationDestination(isPresented: $showAllJobs) {
                JobListView()
            }
        }
    }

    // MARK: - Sub-views

    private var headerBanner: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1a237e"), Color(hex: "283593"), Color(hex: "3949ab")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 140)

            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(profileVM.userProfile.name.components(separatedBy: " ").first ?? "there")! 👋")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                Text("Find Your Dream\nRemote Job")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineSpacing(2)
            }
            .padding(20)

            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 120)
                .offset(x: 260, y: -40)
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 80)
                .offset(x: 300, y: 30)
        }
    }

    private var quickStatsCard: some View {
        HStack(spacing: 0) {
            statItem(value: "\(jobsVM.applicationsCount)", label: "Applied", icon: "paperplane.fill", color: .blue)
            Divider().frame(height: 44)
            statItem(value: "\(jobsVM.interviewsCount)", label: "Interviews", icon: "person.fill.questionmark", color: .orange)
            Divider().frame(height: 44)
            statItem(value: "\(jobsVM.savedCount)", label: "Saved", icon: "heart.fill", color: .red)
            Divider().frame(height: 44)
            statItem(value: "\(jobsVM.offersCount)", label: "Offers", icon: "star.fill", color: .green)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var categoriesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(JobCategory.popular) { category in
                    categoryCard(category: category)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    private func categoryCard(category: JobCategory) -> some View {
        Button(action: {
            selectedCategory = category
            jobsVM.searchQuery = category.keyword
            Task { await jobsVM.searchJobs(query: category.keyword) }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(categoryColor: category.color).opacity(0.15))
                        .frame(width: 60, height: 60)
                    Image(systemName: category.icon)
                        .font(.system(size: 26))
                        .foregroundColor(Color(categoryColor: category.color))
                }
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(width: 76)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var featuredJobsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(jobsVM.featuredJobs) { job in
                    NavigationLink(value: job) {
                        FeaturedJobCard(job: job) {
                            jobsVM.toggleSave(job: job)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    private var recentJobsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(jobsVM.jobs.prefix(5)) { job in
                NavigationLink(value: job) {
                    JobCardView(job: job) {
                        jobsVM.toggleSave(job: job)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 34, height: 34)
            Text(String(profileVM.userProfile.name.prefix(1)))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.accentColor)
        }
    }

    private func sectionHeader(title: String, action: (() -> Void)?) -> some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            if let action {
                Button("See All", action: action)
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - FeaturedJobCard
struct FeaturedJobCard: View {
    let job: Job
    var onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 42, height: 42)
                    Text(String(job.company.prefix(1)))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Spacer()

                Button(action: onSave) {
                    Image(systemName: job.isSaved ? "heart.fill" : "heart")
                        .foregroundColor(job.isSaved ? .red : .gray)
                        .font(.system(size: 18))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(job.company)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(job.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }

            HStack(spacing: 6) {
                Image(systemName: "house.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
                Text(job.jobType.rawValue)
                    .font(.caption2)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }

            Text(job.salary ?? "Competitive")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
        }
        .padding(16)
        .frame(width: 180)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}


#Preview {
    HomeView()
        .environmentObject(JobsViewModel())
        .environmentObject(ProfileViewModel())
}
