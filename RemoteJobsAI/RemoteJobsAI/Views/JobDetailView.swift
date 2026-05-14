import SwiftUI

struct JobDetailView: View {
    let job: Job
    @EnvironmentObject var jobsVM: JobsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var showApplyView = false
    @State private var showShareSheet = false
    @State private var showStatusPicker = false
    @State private var animateSave = false

    private var currentJob: Job {
        jobsVM.jobs.first(where: { $0.id == job.id }) ?? job
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Company Header
                companyHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                Divider().padding(.top, 20)

                // MARK: - Key Info Cards
                keyInfoGrid
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                // MARK: - Requirements
                sectionTitle("Requirements")
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                requirementsList
                    .padding(.horizontal, 20)

                // MARK: - Description
                sectionTitle("About This Role")
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                Text(job.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(5)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // MARK: - Application Status
                if currentJob.applicationStatus != .notApplied {
                    sectionTitle("Application Status")
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                    applicationStatusCard
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }

                // MARK: - Similar Jobs Placeholder
                sectionTitle("Source")
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                sourceInfoCard
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer(minLength: 120) // space for bottom bar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Share
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    // Bookmark
                    Button(action: {
                        animateSave = true
                        jobsVM.toggleSave(job: job)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { animateSave = false }
                    }) {
                        Image(systemName: currentJob.isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(currentJob.isSaved ? .accentColor : .primary)
                            .scaleEffect(animateSave ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3), value: animateSave)
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            bottomBar
        }
        .sheet(isPresented: $showApplyView) {
            ApplyView(job: job)
                .environmentObject(profileVM)
                .environmentObject(jobsVM)
        }
        .confirmationDialog("Update Application Status", isPresented: $showStatusPicker, titleVisibility: .visible) {
            ForEach(ApplicationStatus.allCases) { status in
                Button(status.rawValue) {
                    jobsVM.updateApplicationStatus(job: job, status: status)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Company Header
    private var companyHeader: some View {
        HStack(spacing: 16) {
            // Logo
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 72, height: 72)
                Text(String(job.company.prefix(1)))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(job.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(3)
                Text(job.company)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)

                HStack(spacing: 6) {
                    Image(systemName: job.source.logoSystemName)
                        .font(.caption)
                    Text("via \(job.source.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }

    // MARK: - Key Info Grid
    private var keyInfoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            infoCard(icon: "mappin.circle.fill", label: "Location", value: job.location, color: .red)
            infoCard(icon: "dollarsign.circle.fill", label: "Salary", value: job.salary ?? "Not disclosed", color: .green)
            infoCard(icon: job.jobType.icon, label: "Job Type", value: job.jobType.rawValue, color: .blue)
            infoCard(icon: "chart.bar.fill", label: "Experience", value: job.experienceLevel.rawValue, color: .purple)
            infoCard(icon: "calendar", label: "Posted", value: job.postedDateFormatted, color: .orange)
            infoCard(icon: "bolt.fill", label: "Apply", value: job.isEasyApply ? "Easy Apply" : "External", color: job.isEasyApply ? .blue : .gray)
        }
    }

    private func infoCard(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Requirements List
    private var requirementsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(job.requirements, id: \.self) { req in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.accentColor)
                        .padding(.top, 1)
                    Text(req)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineSpacing(3)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .padding(.top, 10)
    }

    // MARK: - Application Status Card
    private var applicationStatusCard: some View {
        HStack(spacing: 16) {
            ForEach([ApplicationStatus.applied, .interview, .offer], id: \.self) { status in
                let isActive = currentJob.applicationStatus == status ||
                    (status == .applied && currentJob.applicationStatus == .interview) ||
                    (status == .applied && currentJob.applicationStatus == .offer) ||
                    (status == .interview && currentJob.applicationStatus == .offer)

                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(isActive ? Color.accentColor : Color(.systemGray5))
                            .frame(width: 36, height: 36)
                        Image(systemName: status.icon)
                            .font(.system(size: 14))
                            .foregroundColor(isActive ? .white : .secondary)
                    }
                    Text(status.rawValue)
                        .font(.caption2)
                        .foregroundColor(isActive ? .accentColor : .secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                if status != .offer {
                    Rectangle()
                        .fill(isActive ? Color.accentColor.opacity(0.4) : Color(.systemGray5))
                        .frame(height: 2)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }

    // MARK: - Source Info Card
    private var sourceInfoCard: some View {
        HStack(spacing: 14) {
            Image(systemName: job.source.logoSystemName)
                .font(.system(size: 28))
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(job.source.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Original listing on \(job.source.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "arrow.up.right.square")
                .foregroundColor(.accentColor)
        }
        .padding(14)
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .padding(.bottom, 12)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                // Status Button
                Button(action: { showStatusPicker = true }) {
                    VStack(spacing: 2) {
                        Image(systemName: currentJob.applicationStatus.icon)
                            .font(.system(size: 16))
                        Text(currentJob.applicationStatus == .notApplied ? "Track" : currentJob.applicationStatus.rawValue)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .frame(width: 60)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .foregroundColor(.primary)
                }

                // Quick Apply Button
                Button(action: { showApplyView = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 16))
                        Text("Quick Apply with AI")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "1a237e"), Color(hex: "3949ab")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Section Title
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
    }
}

#Preview {
    NavigationStack {
        JobDetailView(job: JobService.mockJobs[0])
            .environmentObject(JobsViewModel())
            .environmentObject(ProfileViewModel())
    }
}
