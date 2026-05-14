import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var userProfile: UserProfile = .sample
    @Published var isGeneratingCoverLetter: Bool = false
    @Published var generatedCoverLetter: String = ""
    @Published var isAutoFilling: Bool = false
    @Published var autoFilledFields: [String: String] = [:]
    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isEditingProfile: Bool = false

    // MARK: - Private
    private let aiService = AIService.shared
    private let profileKey = "userProfile"

    init() {
        loadProfile()
    }

    // MARK: - Profile Management

    func updateProfile(_ updated: UserProfile) {
        userProfile = updated
        saveProfile()
    }

    func saveProfile() {
        isSaving = true
        do {
            let encoded = try JSONEncoder().encode(userProfile)
            UserDefaults.standard.set(encoded, forKey: profileKey)
            saveSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.saveSuccess = false
            }
        } catch {
            errorMessage = "Failed to save profile."
        }
        isSaving = false
    }

    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
    }

    // MARK: - AI Features

    func generateCoverLetter(for job: Job) async {
        isGeneratingCoverLetter = true
        generatedCoverLetter = ""
        errorMessage = nil
        generatedCoverLetter = await aiService.generateCoverLetter(job: job, profile: userProfile)
        isGeneratingCoverLetter = false
    }

    func autoFillApplication(for job: Job) async {
        isAutoFilling = true
        autoFilledFields = [:]
        errorMessage = nil
        autoFilledFields = await aiService.autoFillApplication(job: job, profile: userProfile)
        isAutoFilling = false
    }

    func resetCoverLetter() {
        generatedCoverLetter = ""
    }

    // MARK: - Skills Management

    func addSkill(_ skill: String) {
        guard !skill.isEmpty && !userProfile.skills.contains(skill) else { return }
        userProfile.skills.append(skill)
        saveProfile()
    }

    func removeSkill(_ skill: String) {
        userProfile.skills.removeAll { $0 == skill }
        saveProfile()
    }

    // MARK: - Experience Management

    func addExperience(_ experience: WorkExperience) {
        userProfile.experiences.append(experience)
        saveProfile()
    }

    func removeExperience(at offsets: IndexSet) {
        userProfile.experiences.remove(atOffsets: offsets)
        saveProfile()
    }

    // MARK: - Stats

    var profileCompletionText: String {
        let pct = Int(userProfile.completionPercentage * 100)
        return "\(pct)% complete"
    }

    var missingFields: [String] {
        var missing: [String] = []
        if userProfile.name.isEmpty { missing.append("Name") }
        if userProfile.email.isEmpty { missing.append("Email") }
        if userProfile.phone.isEmpty { missing.append("Phone") }
        if userProfile.linkedinURL.isEmpty { missing.append("LinkedIn") }
        if userProfile.summary.isEmpty { missing.append("Summary") }
        if userProfile.skills.isEmpty { missing.append("Skills") }
        if userProfile.experiences.isEmpty { missing.append("Work Experience") }
        if userProfile.resumeText.isEmpty { missing.append("Resume") }
        return missing
    }
}
