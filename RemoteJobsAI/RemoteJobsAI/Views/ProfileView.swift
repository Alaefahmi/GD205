import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var jobsVM: JobsViewModel
    @State private var showEditProfile = false
    @State private var showResumeEditor = false
    @State private var showAddSkill = false
    @State private var newSkillText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {

                    // MARK: - Header
                    profileHeader
                        .padding(.bottom, 20)

                    // MARK: - Profile Completion
                    profileCompletionCard
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                    // MARK: - Stats
                    statsSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                    // MARK: - Contact Info
                    contactSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                    // MARK: - Education
                    educationSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                    // MARK: - Skills
                    skillsSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                    // MARK: - Experience
                    experienceSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                    // MARK: - Resume
                    resumeSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showEditProfile = true
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .environmentObject(profileVM)
            }
            .sheet(isPresented: $showResumeEditor) {
                ResumeEditorView()
                    .environmentObject(profileVM)
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1a237e"), Color(hex: "3949ab")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 160)

            // Avatar + name
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 88, height: 88)
                    if profileVM.userProfile.avatarData != nil {
                        Circle()
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(width: 84, height: 84)
                    }
                    Text(String(profileVM.userProfile.name.prefix(1)))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(hex: "1a237e"))
                }
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                .offset(y: 44)
            }
        }
        .frame(maxWidth: .infinity)

        // Name and headline below header
        VStack(spacing: 6) {
            Text(profileVM.userProfile.name)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 56)

            Text(profileVM.userProfile.headline)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            HStack(spacing: 16) {
                if !profileVM.userProfile.linkedinURL.isEmpty {
                    Link(destination: URL(string: profileVM.userProfile.linkedinURL) ?? URL(string: "https://linkedin.com")!) {
                        Label("LinkedIn", systemImage: "link.circle.fill")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
                if !profileVM.userProfile.githubURL.isEmpty {
                    Link(destination: URL(string: profileVM.userProfile.githubURL) ?? URL(string: "https://github.com")!) {
                        Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Profile Completion
    private var profileCompletionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Profile Strength", systemImage: "bolt.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(profileVM.profileCompletionText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(profileVM.userProfile.completionPercentage > 0.7 ? .green : .orange)
            }

            ProgressView(value: profileVM.userProfile.completionPercentage)
                .tint(profileVM.userProfile.completionPercentage > 0.7 ? .green : .orange)
                .scaleEffect(y: 2)

            if !profileVM.missingFields.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("Add \(profileVM.missingFields.first ?? "") to improve your applications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Stats
    private var statsSection: some View {
        HStack(spacing: 0) {
            statItem(value: "\(jobsVM.applicationsCount)", label: "Applied")
            Divider().frame(height: 40)
            statItem(value: "\(jobsVM.interviewsCount)", label: "Interviews")
            Divider().frame(height: 40)
            statItem(value: "\(jobsVM.offersCount)", label: "Offers")
            Divider().frame(height: 40)
            statItem(value: "\(jobsVM.savedCount)", label: "Saved")
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            sectionHeader("Contact Information")

            VStack(spacing: 0) {
                contactRow(icon: "envelope.fill", label: "Email", value: profileVM.userProfile.email)
                Divider().padding(.leading, 46)
                contactRow(icon: "phone.fill", label: "Phone", value: profileVM.userProfile.phone)
                Divider().padding(.leading, 46)
                contactRow(icon: "link", label: "LinkedIn", value: profileVM.userProfile.linkedinURL.isEmpty ? "Not set" : "linkedin.com/in/...")
                Divider().padding(.leading, 46)
                contactRow(icon: "chevron.left.forwardslash.chevron.right", label: "GitHub", value: profileVM.userProfile.githubURL.isEmpty ? "Not set" : "github.com/...")
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    private func contactRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.accentColor)
                .frame(width: 22)
                .padding(.leading, 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value.isEmpty ? "Not set" : value)
                    .font(.subheadline)
                    .foregroundColor(value.isEmpty ? .secondary : .primary)
            }
            Spacer()
        }
        .padding(.vertical, 12)
    }

    // MARK: - Education
    private var educationSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            sectionHeader("Education")

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.purple)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(profileVM.userProfile.education.degree + " in " + profileVM.userProfile.education.major)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(profileVM.userProfile.education.institution)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            Label("Class of \(profileVM.userProfile.education.graduationYear)", systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if let gpa = profileVM.userProfile.education.gpa {
                                Label("GPA: \(gpa)", systemImage: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }

                        if let honors = profileVM.userProfile.education.honors {
                            TagView(text: honors, color: .purple)
                                .padding(.top, 2)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    // MARK: - Skills
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                sectionHeader("Skills")
                Spacer()
                Button(action: { showAddSkill = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 20))
                }
            }

            FlowLayout(spacing: 8) {
                ForEach(profileVM.userProfile.skills, id: \.self) { skill in
                    skillTag(skill)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
        .alert("Add Skill", isPresented: $showAddSkill) {
            TextField("e.g. Python, Figma", text: $newSkillText)
            Button("Add") {
                profileVM.addSkill(newSkillText)
                newSkillText = ""
            }
            Button("Cancel", role: .cancel) { newSkillText = "" }
        }
    }

    private func skillTag(_ skill: String) -> some View {
        HStack(spacing: 4) {
            Text(skill)
                .font(.system(size: 13, weight: .medium))
            Button(action: { profileVM.removeSkill(skill) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.accentColor.opacity(0.12))
        .foregroundColor(.accentColor)
        .cornerRadius(20)
    }

    // MARK: - Experience
    private var experienceSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            sectionHeader("Work Experience")

            VStack(spacing: 0) {
                ForEach(profileVM.userProfile.experiences) { exp in
                    experienceCard(exp)
                    if exp.id != profileVM.userProfile.experiences.last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    private func experienceCard(_ exp: WorkExperience) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(exp.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(exp.company)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(exp.startDate) – \(exp.isCurrent ? "Present" : (exp.endDate ?? ""))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if exp.isCurrent {
                    TagView(text: "Current", color: .green)
                }
            }

            Text(exp.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(3)

            ForEach(exp.achievements, id: \.self) { achievement in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.accentColor)
                        .padding(.top, 1)
                    Text(achievement)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineSpacing(2)
                }
            }
        }
        .padding(16)
    }

    // MARK: - Resume
    private var resumeSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            sectionHeader("Resume")

            Button(action: { showResumeEditor = true }) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.accentColor.opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(profileVM.userProfile.resumeText.isEmpty ? "Upload or paste your resume" : "Resume.txt")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text(profileVM.userProfile.resumeText.isEmpty
                             ? "AI uses your resume to auto-fill applications"
                             : "\(profileVM.userProfile.resumeText.count) characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
        }
    }

    // MARK: - Helpers
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .padding(.bottom, 8)
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }.reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var rowWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth && !rows.last!.isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append(subview)
            rowWidth += size.width + spacing
        }
        return rows
    }
}

// MARK: - EditProfileView
struct EditProfileView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: UserProfile = .empty

    var body: some View {
        NavigationView {
            Form {
                Section("Personal Info") {
                    TextField("Full Name", text: $draft.name)
                    TextField("Email", text: $draft.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone", text: $draft.phone)
                        .keyboardType(.phonePad)
                    TextField("Professional Headline", text: $draft.headline)
                }

                Section("Links") {
                    TextField("LinkedIn URL", text: $draft.linkedinURL)
                        .textInputAutocapitalization(.never)
                    TextField("GitHub URL", text: $draft.githubURL)
                        .textInputAutocapitalization(.never)
                    TextField("Portfolio URL", text: $draft.portfolioURL)
                        .textInputAutocapitalization(.never)
                }

                Section("Summary") {
                    TextEditor(text: $draft.summary)
                        .frame(minHeight: 100)
                }

                Section("Education") {
                    TextField("Degree", text: $draft.education.degree)
                    TextField("Major", text: $draft.education.major)
                    TextField("Institution", text: $draft.education.institution)
                    TextField("GPA (optional)", text: Binding(
                        get: { draft.education.gpa ?? "" },
                        set: { draft.education.gpa = $0.isEmpty ? nil : $0 }
                    ))
                    TextField("Honors (optional)", text: Binding(
                        get: { draft.education.honors ?? "" },
                        set: { draft.education.honors = $0.isEmpty ? nil : $0 }
                    ))
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        profileVM.updateProfile(draft)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                draft = profileVM.userProfile
            }
        }
    }
}

// MARK: - ResumeEditorView
struct ResumeEditorView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var resumeText: String = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.accentColor)
                    Text("Paste your resume text. Our AI uses this to auto-fill job applications.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                TextEditor(text: $resumeText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .font(.system(size: 14, design: .monospaced))

                Text("\(resumeText.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            }
            .navigationTitle("Resume")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        profileVM.userProfile.resumeText = resumeText
                        profileVM.saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                resumeText = profileVM.userProfile.resumeText
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ProfileViewModel())
        .environmentObject(JobsViewModel())
}
