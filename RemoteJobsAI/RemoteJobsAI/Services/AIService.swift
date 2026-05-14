import Foundation

// MARK: - AIService
final class AIService {

    static let shared = AIService()
    private init() {}

    // MARK: - Generate Cover Letter

    func generateCoverLetter(job: Job, profile: UserProfile) async -> String {
        // Simulate AI processing delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        let skills = profile.skills.prefix(5).joined(separator: ", ")
        let currentRole = profile.experiences.first?.title ?? "software professional"
        let currentCompany = profile.experiences.first?.company ?? "my current company"

        return """
Dear Hiring Manager at \(job.company),

I am writing to express my enthusiastic interest in the \(job.title) position at \(job.company). With my Bachelor's degree in \(profile.education.major) from \(profile.education.institution) and my experience as a \(currentRole) at \(currentCompany), I am confident that my skills and passion make me an excellent candidate for this role.

\(generateBodyParagraph(job: job, profile: profile, skills: skills))

\(generateAchievementParagraph(profile: profile))

What excites me most about \(job.company) is your commitment to \(companyValueStatement(company: job.company)). Your culture of innovation and remote-first work environment aligns perfectly with my professional values and working style. I have extensive experience collaborating asynchronously with distributed teams and consistently delivering results across time zones.

I am particularly drawn to this \(job.jobType.rawValue) opportunity because I thrive in environments where I can focus deeply on meaningful work while contributing to a global team. My background in \(skills) positions me well to contribute immediately to your team's objectives.

I would love the opportunity to discuss how my background, skills, and enthusiasm can contribute to \(job.company)'s continued success. I am available for an interview at your earliest convenience and can be reached at \(profile.email) or \(profile.phone).

Thank you for considering my application. I look forward to the possibility of joining the exceptional team at \(job.company).

Best regards,
\(profile.name)
\(profile.email)
\(profile.linkedinURL)
"""
    }

    // MARK: - Auto-Fill Application

    func autoFillApplication(job: Job, profile: UserProfile) async -> [String: String] {
        try? await Task.sleep(nanoseconds: 800_000_000)

        var fields: [String: String] = [
            "First Name": profile.name.components(separatedBy: " ").first ?? profile.name,
            "Last Name": profile.name.components(separatedBy: " ").dropFirst().joined(separator: " "),
            "Full Name": profile.name,
            "Email Address": profile.email,
            "Phone Number": profile.phone,
            "LinkedIn Profile": profile.linkedinURL,
            "GitHub Profile": profile.githubURL,
            "Portfolio / Website": profile.portfolioURL,
            "Current Title": profile.experiences.first?.title ?? profile.headline,
            "Current Company": profile.experiences.first?.company ?? "",
            "Degree": profile.education.degree,
            "Field of Study": profile.education.major,
            "University / Institution": profile.education.institution,
            "Graduation Year": String(profile.education.graduationYear),
            "GPA": profile.education.gpa ?? "",
            "Years of Experience": estimatedYearsOfExperience(profile: profile),
            "Skills": profile.skills.joined(separator: ", "),
            "Work Authorization": "Yes, authorized to work in the US",
            "Sponsorship Required": "No",
            "Earliest Start Date": "2 weeks notice",
            "Salary Expectation": job.salary ?? "Open to discussion",
            "Cover Letter": "See attached cover letter"
        ]

        // Add job-specific fields
        if job.jobType == .remote {
            fields["Remote Work Experience"] = "Yes, 2+ years working remotely"
            fields["Time Zone"] = "US Eastern / Pacific (flexible)"
        }

        return fields
    }

    // MARK: - Generate Interview Prep

    func generateInterviewPrep(job: Job, profile: UserProfile) async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        return """
        Interview Prep for \(job.title) at \(job.company)
        
        LIKELY QUESTIONS:
        1. Tell me about yourself and your experience with \(profile.skills.first ?? "your field").
        2. Why do you want to work at \(job.company) specifically?
        3. Describe a challenging project you completed and how you handled obstacles.
        4. How do you stay productive while working remotely?
        5. Where do you see yourself in 3-5 years?
        
        YOUR KEY TALKING POINTS:
        • Bachelor's degree from \(profile.education.institution)
        • Experience: \(profile.experiences.map { $0.title + " at " + $0.company }.joined(separator: ", "))
        • Core skills: \(profile.skills.prefix(5).joined(separator: ", "))
        
        COMPANY RESEARCH:
        \(companyResearch(company: job.company))
        """
    }

    // MARK: - Private Helpers

    private func generateBodyParagraph(job: Job, profile: UserProfile, skills: String) -> String {
        let requirements = job.requirements.prefix(2).joined(separator: " and ")
        return """
        In my current role as a \(profile.experiences.first?.title ?? "professional"), I have developed strong expertise in \(skills). The position's requirements around \(requirements) align closely with the work I have been doing and the problems I am most passionate about solving. I am particularly skilled at building scalable solutions and collaborating effectively in distributed team environments.
        """
    }

    private func generateAchievementParagraph(profile: UserProfile) -> String {
        let achievements = profile.experiences.flatMap { $0.achievements }.prefix(2)
        if achievements.isEmpty {
            return "Throughout my career, I have consistently delivered high-quality results and driven meaningful impact in every role I've held. I bring a strong foundation in both technical and collaborative skills that enable me to thrive in fast-paced environments."
        }
        let achievementText = achievements.map { "• \($0)" }.joined(separator: "\n")
        return "Some of my key accomplishments include:\n\(achievementText)"
    }

    private func companyValueStatement(company: String) -> String {
        let statements: [String: String] = [
            "Shopify": "empowering entrepreneurs and democratizing commerce",
            "GitHub": "building tools that empower developers worldwide",
            "Automattic": "the open web and distributed work culture",
            "Buffer": "transparency and a sustainable approach to business",
            "GitLab": "DevSecOps and your all-remote work model",
            "Stripe": "growing the GDP of the internet",
            "Coinbase": "creating an open financial system for the world",
            "Zapier": "making automation accessible to everyone",
            "Vercel": "the best developer experience possible",
            "Hugging Face": "democratizing artificial intelligence"
        ]
        return statements[company] ?? "innovation, quality, and making a meaningful impact"
    }

    private func companyResearch(company: String) -> String {
        let research: [String: String] = [
            "Shopify": "Canada-based e-commerce platform. 2M+ merchants. Stock: SHOP. CEO: Tobias Lütke. Strong remote culture.",
            "GitHub": "World's leading code hosting platform. Owned by Microsoft. 100M+ developers. CEO: Thomas Dohmke.",
            "Automattic": "Makers of WordPress.com, WooCommerce, Tumblr. 100% distributed company, 1900+ employees in 90+ countries.",
            "Buffer": "Social media management tool. Bootstrapped, transparent culture. Publishes salaries publicly.",
            "GitLab": "DevSecOps platform. World's largest all-remote company. ~2000 team members globally.",
            "Stripe": "Payment infrastructure company. $1T+ annual payment volume. Known for strong engineering culture.",
            "Coinbase": "Largest US cryptocurrency exchange. Publicly traded (COIN). Remote-first since 2020."
        ]
        return research[company] ?? "Research this company's recent news, product launches, and culture on their website and LinkedIn before your interview."
    }

    private func estimatedYearsOfExperience(profile: UserProfile) -> String {
        let exp = profile.experiences
        guard !exp.isEmpty else { return "Entry Level (0-1 years)" }
        return exp.count == 1 ? "1-2 years" : "2-3 years"
    }
}
