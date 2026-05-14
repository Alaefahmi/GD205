import SwiftUI

struct ApplyView: View {
    let job: Job
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var jobsVM: JobsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var step: ApplyStep = .overview
    @State private var coverLetter: String = ""
    @State private var formFields: [String: String] = [:]
    @State private var showSubmitConfirmation = false
    @State private var isSubmitting = false
    @State private var applicationSubmitted = false
    @State private var editableCoverLetter: String = ""

    enum ApplyStep: Int, CaseIterable {
        case overview = 0
        case aiGenerate = 1
        case review = 2
        case submit = 3
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Bar
                progressBar

                // Content
                Group {
                    switch step {
                    case .overview:
                        overviewStep
                    case .aiGenerate:
                        aiGenerateStep
                    case .review:
                        reviewStep
                    case .submit:
                        if applicationSubmitted {
                            successView
                        } else {
                            submitStep
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.3), value: step)

                Spacer()

                // Bottom navigation
                if !applicationSubmitted {
                    bottomNavigation
                }
            }
            .navigationTitle("Apply: \(job.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .task {
            await profileVM.autoFillApplication(for: job)
            formFields = profileVM.autoFilledFields
        }
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(ApplyStep.allCases, id: \.rawValue) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue ? Color.accentColor : Color(.systemGray5))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: step)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Step 1: Overview
    private var overviewStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Job Summary Card
                jobSummaryCard

                // Profile readiness
                profileReadinessCard

                // What happens next
                VStack(alignment: .leading, spacing: 12) {
                    Label("What happens next", systemImage: "list.number")
                        .font(.headline)

                    ForEach(Array(nextSteps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 26, height: 26)
                                .background(Color.accentColor)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 3) {
                                Text(step.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(step.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
            .padding(20)
        }
    }

    private var jobSummaryCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 54, height: 54)
                Text(String(job.company.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(job.title)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(job.company)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(job.salary ?? "Salary not disclosed")
                    .font(.caption)
                    .foregroundColor(.accentColor)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1.5)
        )
    }

    private var profileReadinessCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Profile Readiness", systemImage: "person.fill.checkmark")
                    .font(.headline)
                Spacer()
                Text(profileVM.profileCompletionText)
                    .font(.caption)
                    .foregroundColor(profileVM.userProfile.completionPercentage > 0.7 ? .green : .orange)
                    .fontWeight(.semibold)
            }

            ProgressView(value: profileVM.userProfile.completionPercentage)
                .tint(profileVM.userProfile.completionPercentage > 0.7 ? .green : .orange)

            if !profileVM.missingFields.isEmpty {
                Text("Missing: \(profileVM.missingFields.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Label("Your profile is ready for AI auto-fill!", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    // MARK: - Step 2: AI Generate
    private var aiGenerateStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                if profileVM.isGeneratingCoverLetter {
                    AILoadingView(message: "Generating your cover letter")
                        .padding(.top, 40)
                } else if profileVM.generatedCoverLetter.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                            .padding(.top, 40)

                        Text("AI Cover Letter")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Our AI will generate a personalized cover letter based on your profile and the job requirements.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        Button(action: {
                            Task { await profileVM.generateCoverLetter(for: job) }
                        }) {
                            Label("Generate Cover Letter", systemImage: "sparkles")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Label("AI Generated Cover Letter", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                            Spacer()
                            Button("Regenerate") {
                                profileVM.resetCoverLetter()
                                Task { await profileVM.generateCoverLetter(for: job) }
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        }

                        TextEditor(text: $editableCoverLetter)
                            .frame(minHeight: 400)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .font(.body)
                            .onAppear {
                                editableCoverLetter = profileVM.generatedCoverLetter
                            }
                            .onChange(of: profileVM.generatedCoverLetter) { newValue in
                                editableCoverLetter = newValue
                            }

                        HStack {
                            Image(systemName: "info.circle")
                            Text("You can edit the cover letter before submitting")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(20)
                }
            }
        }
    }

    // MARK: - Step 3: Review
    private var reviewStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Review Your Application")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // Auto-filled fields
                if profileVM.isAutoFilling {
                    InlineLoadingView(message: "AI is filling your application...")
                        .padding()
                } else {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(formFields.sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                            if !value.isEmpty {
                                formFieldRow(key: key, value: value)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 24)
        }
    }

    private func formFieldRow(key: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    // MARK: - Step 4: Submit
    private var submitStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Final summary
                VStack(alignment: .leading, spacing: 16) {
                    Text("Ready to Submit")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("You're about to submit your application to \(job.company) for the \(job.title) position.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(spacing: 12) {
                        summaryRow(icon: "person.fill", label: "Name", value: profileVM.userProfile.name)
                        summaryRow(icon: "envelope.fill", label: "Email", value: profileVM.userProfile.email)
                        summaryRow(icon: "briefcase.fill", label: "Position", value: job.title)
                        summaryRow(icon: "building.2.fill", label: "Company", value: job.company)
                        summaryRow(icon: "doc.text.fill", label: "Cover Letter", value: editableCoverLetter.isEmpty ? "Not included" : "Included (\(editableCoverLetter.count) chars)")
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                .padding(20)
            }
        }
    }

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            Spacer()
        }
    }

    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }

            VStack(spacing: 10) {
                Text("Application Submitted!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Your AI-powered application has been submitted to \(job.company). Good luck!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("Back to Jobs")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }

                Button(action: {}) {
                    Text("View Application Status")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Bottom Navigation
    private var bottomNavigation: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                if step.rawValue > 0 {
                    Button(action: {
                        withAnimation { step = ApplyStep(rawValue: step.rawValue - 1) ?? .overview }
                    }) {
                        Text("Back")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(14)
                    }
                }

                Button(action: {
                    if step == .submit {
                        submitApplication()
                    } else {
                        withAnimation { step = ApplyStep(rawValue: step.rawValue + 1) ?? .submit }
                    }
                }) {
                    HStack(spacing: 8) {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: step == .submit ? "paperplane.fill" : "arrow.right")
                        }
                        Text(step == .submit ? "Submit Application" : "Continue")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
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
                .disabled(isSubmitting)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Submit
    private func submitApplication() {
        isSubmitting = true
        coverLetter = editableCoverLetter
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await MainActor.run {
                jobsVM.applyToJob(job)
                isSubmitting = false
                withAnimation { applicationSubmitted = true }
            }
        }
    }

    // MARK: - Data
    private struct NextStep {
        let title: String
        let subtitle: String
    }

    private var nextSteps: [NextStep] {
        [
            NextStep(title: "AI Auto-fill", subtitle: "We'll fill the form using your profile"),
            NextStep(title: "Generate Cover Letter", subtitle: "AI crafts a personalized cover letter"),
            NextStep(title: "Review", subtitle: "Check everything before submitting"),
            NextStep(title: "Submit", subtitle: "We send your application to \(job.company)")
        ]
    }
}

#Preview {
    ApplyView(job: JobService.mockJobs[0])
        .environmentObject(ProfileViewModel())
        .environmentObject(JobsViewModel())
}
