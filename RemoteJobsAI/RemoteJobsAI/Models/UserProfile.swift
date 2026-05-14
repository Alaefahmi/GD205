import Foundation

// MARK: - UserProfile
struct UserProfile: Codable, Equatable {
    var name: String
    var email: String
    var phone: String
    var linkedinURL: String
    var githubURL: String
    var portfolioURL: String
    var headline: String
    var summary: String
    var education: Education
    var skills: [String]
    var experiences: [WorkExperience]
    var resumeText: String
    var avatarData: Data?

    static var sample: UserProfile {
        UserProfile(
            name: "Alex Johnson",
            email: "alex.johnson@email.com",
            phone: "+1 (555) 234-5678",
            linkedinURL: "https://linkedin.com/in/alexjohnson",
            githubURL: "https://github.com/alexjohnson",
            portfolioURL: "https://alexjohnson.dev",
            headline: "Software Engineer | Remote Work Enthusiast",
            summary: "Motivated software engineer with a bachelor's degree in Computer Science. Experienced in building scalable web and mobile applications. Passionate about clean code, user experience, and continuous learning.",
            education: Education.bachelorSample,
            skills: [
                "Swift", "SwiftUI", "Python", "JavaScript", "TypeScript",
                "React", "Node.js", "REST APIs", "Git", "SQL", "AWS",
                "Docker", "Agile", "Unit Testing", "CI/CD"
            ],
            experiences: WorkExperience.sampleList,
            resumeText: UserProfile.sampleResumeText,
            avatarData: nil
        )
    }

    static var empty: UserProfile {
        UserProfile(
            name: "",
            email: "",
            phone: "",
            linkedinURL: "",
            githubURL: "",
            portfolioURL: "",
            headline: "",
            summary: "",
            education: Education.empty,
            skills: [],
            experiences: [],
            resumeText: "",
            avatarData: nil
        )
    }

    var isComplete: Bool {
        !name.isEmpty && !email.isEmpty && !resumeText.isEmpty
    }

    var completionPercentage: Double {
        var filled = 0
        let total = 8
        if !name.isEmpty        { filled += 1 }
        if !email.isEmpty       { filled += 1 }
        if !phone.isEmpty       { filled += 1 }
        if !linkedinURL.isEmpty { filled += 1 }
        if !summary.isEmpty     { filled += 1 }
        if !skills.isEmpty      { filled += 1 }
        if !experiences.isEmpty { filled += 1 }
        if !resumeText.isEmpty  { filled += 1 }
        return Double(filled) / Double(total)
    }
}

// MARK: - Education
struct Education: Codable, Equatable {
    var degree: String
    var major: String
    var institution: String
    var graduationYear: Int
    var gpa: String?
    var honors: String?

    static var bachelorSample: Education {
        Education(
            degree: "Bachelor of Science",
            major: "Computer Science",
            institution: "University of California, Berkeley",
            graduationYear: 2022,
            gpa: "3.7",
            honors: "Magna Cum Laude"
        )
    }

    static var empty: Education {
        Education(
            degree: "Bachelor's",
            major: "",
            institution: "",
            graduationYear: Calendar.current.component(.year, from: Date()),
            gpa: nil,
            honors: nil
        )
    }

    var formatted: String {
        "\(degree) in \(major) – \(institution) (\(graduationYear))"
    }
}

// MARK: - WorkExperience
struct WorkExperience: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var company: String
    var startDate: String
    var endDate: String?
    var isCurrent: Bool
    var description: String
    var achievements: [String]

    static var sampleList: [WorkExperience] {
        [
            WorkExperience(
                id: UUID().uuidString,
                title: "Junior Software Engineer",
                company: "TechStart Inc.",
                startDate: "Jun 2022",
                endDate: "Present",
                isCurrent: true,
                description: "Developing and maintaining iOS and web applications for a fast-growing SaaS startup.",
                achievements: [
                    "Reduced app load time by 40% through caching optimizations",
                    "Built reusable SwiftUI component library used across 3 products",
                    "Collaborated with cross-functional teams in an agile environment"
                ]
            ),
            WorkExperience(
                id: UUID().uuidString,
                title: "Software Engineering Intern",
                company: "DataFlow Solutions",
                startDate: "May 2021",
                endDate: "Aug 2021",
                isCurrent: false,
                description: "Contributed to backend Python services and data pipeline development.",
                achievements: [
                    "Automated data ingestion pipeline saving 8 hours/week of manual work",
                    "Wrote unit tests achieving 85% code coverage on new modules"
                ]
            )
        ]
    }
}

// MARK: - Resume Text Sample
extension UserProfile {
    static let sampleResumeText = """
    ALEX JOHNSON
    alex.johnson@email.com | +1 (555) 234-5678
    linkedin.com/in/alexjohnson | github.com/alexjohnson

    SUMMARY
    Motivated software engineer with a Bachelor's degree in Computer Science from UC Berkeley. Experienced in building scalable web and mobile applications with 2+ years of professional experience. Passionate about remote work, clean code, and delivering impactful user experiences.

    EDUCATION
    Bachelor of Science in Computer Science
    University of California, Berkeley | 2022 | GPA: 3.7 | Magna Cum Laude

    EXPERIENCE
    Junior Software Engineer – TechStart Inc. | Jun 2022 – Present
    • Developing and maintaining iOS and web applications for a fast-growing SaaS startup
    • Reduced app load time by 40% through caching optimizations
    • Built reusable SwiftUI component library used across 3 products

    Software Engineering Intern – DataFlow Solutions | May 2021 – Aug 2021
    • Automated data ingestion pipeline saving 8 hours/week
    • Wrote unit tests achieving 85% code coverage

    SKILLS
    Swift, SwiftUI, Python, JavaScript, TypeScript, React, Node.js, REST APIs, Git, SQL, AWS, Docker, Agile, Unit Testing, CI/CD

    CERTIFICATIONS
    • AWS Certified Cloud Practitioner (2023)
    • Apple Developer Academy Graduate (2022)
    """
}
