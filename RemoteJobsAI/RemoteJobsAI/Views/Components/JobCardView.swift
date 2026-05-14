import SwiftUI

struct JobCardView: View {
    let job: Job
    var onSave: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    @State private var isPressed = false

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {

                // MARK: - Top Row: Company + Source Badge + Save
                HStack(alignment: .top) {
                    // Company Logo Placeholder
                    companyLogoView

                    VStack(alignment: .leading, spacing: 2) {
                        Text(job.company)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text(job.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                    }

                    Spacer()

                    // Save Button
                    Button(action: { onSave?() }) {
                        Image(systemName: job.isSaved ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(job.isSaved ? .red : .gray)
                            .padding(6)
                    }
                }

                // MARK: - Tags Row
                HStack(spacing: 8) {
                    // Job Type Tag
                    TagView(text: job.jobType.rawValue, color: jobTypeColor(job.jobType), icon: job.jobType.icon)

                    // Experience Level
                    TagView(text: job.experienceLevel.rawValue, color: .purple)

                    // Easy Apply Badge
                    if job.isEasyApply {
                        TagView(text: "Easy Apply", color: .blue, icon: "bolt.fill")
                    }

                    Spacer()
                }

                // MARK: - Location & Salary
                HStack {
                    Label(job.location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Spacer()

                    if let salary = job.salary {
                        Text(salary)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "1a237e"))
                    }
                }

                // MARK: - Bottom Row: Source + Posted Date
                HStack {
                    sourceBadge

                    Spacer()

                    Text(job.postedDateFormatted)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Application Status Banner (if applicable)
                if job.applicationStatus != .notApplied {
                    applicationStatusBanner
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    // MARK: - Sub-views

    private var companyLogoView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(logoBackgroundColor(for: job.company))
                .frame(width: 46, height: 46)
            Text(String(job.company.prefix(1)))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }

    private var sourceBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: job.source.logoSystemName)
                .font(.caption2)
            Text(job.source.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(sourceBadgeColor(job.source).opacity(0.15))
        .foregroundColor(sourceBadgeColor(job.source))
        .cornerRadius(6)
    }

    private var applicationStatusBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: job.applicationStatus.icon)
                .font(.caption2)
            Text(job.applicationStatus.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(statusBannerColor(job.applicationStatus).opacity(0.12))
        .foregroundColor(statusBannerColor(job.applicationStatus))
        .cornerRadius(8)
    }

    // MARK: - Color Helpers

    private func jobTypeColor(_ type: JobType) -> Color {
        switch type {
        case .remote: return .green
        case .hybrid: return .orange
        case .onsite: return .blue
        }
    }

    private func logoBackgroundColor(for company: String) -> Color {
        let colors: [Color] = [.blue, .purple, .green, .orange, .red, .teal, .indigo, .pink]
        let hash = abs(company.hashValue)
        return colors[hash % colors.count]
    }

    private func sourceBadgeColor(_ source: JobSource) -> Color {
        switch source {
        case .indeed: return .purple
        case .linkedin: return .blue
        case .glassdoor: return .green
        case .remoteOK: return .orange
        case .weworkremotely: return .red
        }
    }

    private func statusBannerColor(_ status: ApplicationStatus) -> Color {
        switch status {
        case .notApplied: return .gray
        case .applied: return .blue
        case .interview: return .orange
        case .offer: return .green
        case .rejected: return .red
        }
    }
}

// MARK: - TagView
struct TagView: View {
    let text: String
    let color: Color
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 3) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 9))
            }
            Text(text)
                .font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(6)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 12) {
            JobCardView(job: JobService.mockJobs[0])
            JobCardView(job: JobService.mockJobs[1])
            JobCardView(job: JobService.mockJobs[5])
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
