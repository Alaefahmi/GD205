import Foundation

// MARK: - UserProfile
struct UserProfile: Codable, Equatable {
    var name: String
    var email: String
    var phone: String
    var linkedinURL: String
    /// Behance or Dribbble portfolio URL (primary creative portfolio link)
    var portfolioURL: String
    /// Secondary portfolio or personal design website
    var websiteURL: String
    var headline: String
    var summary: String
    var education: Education
    var skills: [String]
    /// Self-rated proficiency (0.0–1.0) for each primary design tool
    var toolProficiency: [String: Double]
    var experiences: [WorkExperience]
    var resumeText: String
    var avatarData: Data?

    static var sample: UserProfile {
        UserProfile(
            name: "Maya Rivera",
            email: "maya.rivera@email.com",
            phone: "+1 (555) 487-2910",
            linkedinURL: "https://linkedin.com/in/mayariveradesigns",
            portfolioURL: "https://behance.net/mayarivera",
            websiteURL: "https://mayarivera.design",
            headline: "Junior Graphic Designer · Branding & UI · Open to Remote",
            summary: "Creative and detail-oriented graphic designer with a Bachelor's degree in Visual Communication Design. Passionate about crafting bold brand identities, intuitive UI layouts, and eye-catching digital assets. Seeking entry-level or junior roles where I can grow within a collaborative creative team.",
            education: Education.bachelorSample,
            skills: [
                "Figma", "Adobe Illustrator", "Adobe Photoshop",
                "Adobe InDesign", "After Effects", "Canva",
                "Sketch", "Procreate", "Adobe XD",
                "Typography", "Brand Identity", "UI Design",
                "Motion Graphics", "Print Production", "Colour Theory"
            ],
            toolProficiency: [
                "Figma": 0.90,
                "Adobe Illustrator": 0.85,
                "Adobe Photoshop": 0.80,
                "Adobe InDesign": 0.75,
                "After Effects": 0.60,
                "Canva": 0.95
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
            portfolioURL: "",
            websiteURL: "",
            headline: "",
            summary: "",
            education: Education.empty,
            skills: [],
            toolProficiency: [:],
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
        let total = 9
        if !name.isEmpty        { filled += 1 }
        if !email.isEmpty       { filled += 1 }
        if !phone.isEmpty       { filled += 1 }
        if !linkedinURL.isEmpty { filled += 1 }
        if !portfolioURL.isEmpty { filled += 1 }
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
            degree: "Bachelor of Fine Arts",
            major: "Visual Communication Design",
            institution: "Rhode Island School of Design",
            graduationYear: 2024,
            gpa: "3.8",
            honors: "Cum Laude"
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
                title: "Graphic Design Intern",
                company: "Bright Studio Co.",
                startDate: "Jun 2023",
                endDate: "Dec 2023",
                isCurrent: false,
                description: "Contributed to branding and digital design projects for small-business clients at a boutique creative agency.",
                achievements: [
                    "Designed logo and brand identity system for 4 client launches",
                    "Produced social media templates in Canva and Figma adopted across 3 brand accounts",
                    "Assisted art director with InDesign layout for a 32-page product catalogue"
                ]
            ),
            WorkExperience(
                id: UUID().uuidString,
                title: "Freelance Visual Designer",
                company: "Self-Employed",
                startDate: "Jan 2024",
                endDate: nil,
                isCurrent: true,
                description: "Independently delivering branding, print, and social media design for clients across e-commerce and hospitality sectors.",
                achievements: [
                    "Built complete brand identity (logo, colour palette, typography, guidelines) for 6 clients",
                    "Created motion graphics reels for Instagram that averaged 40% higher engagement",
                    "Maintained 5-star rating on portfolio and client referral platforms"
                ]
            )
        ]
    }
}

// MARK: - Resume Text Sample
extension UserProfile {
    static let sampleResumeText = """
    MAYA RIVERA
    maya.rivera@email.com | +1 (555) 487-2910
    linkedin.com/in/mayariveradesigns | behance.net/mayarivera | mayarivera.design

    SUMMARY
    Creative and detail-oriented graphic designer with a BFA in Visual Communication Design from RISD. Skilled in brand identity, UI design, and motion graphics. Seeking entry-level or junior design roles with a forward-thinking creative team. Portfolio: behance.net/mayarivera | Dribbble: dribbble.com/mayarivera

    EDUCATION
    Bachelor of Fine Arts in Visual Communication Design
    Rhode Island School of Design | 2024 | GPA: 3.8 | Cum Laude

    EXPERIENCE
    Freelance Visual Designer | Jan 2024 – Present
    • Designed complete brand identities (logo, colour palette, typography, brand guidelines) for 6 clients
    • Created motion graphics reels for Instagram averaging 40% higher engagement than static posts
    • Maintained 5-star client satisfaction through clear communication and on-time delivery

    Graphic Design Intern – Bright Studio Co. | Jun 2023 – Dec 2023
    • Contributed to branding and digital projects for small-business clients at a boutique creative agency
    • Designed logo and identity systems for 4 client brand launches
    • Produced Canva and Figma social media templates adopted across 3 active brand accounts
    • Assisted art director with InDesign layout and prepress for a 32-page product catalogue

    SKILLS & TOOLS
    Figma, Adobe Illustrator, Adobe Photoshop, Adobe InDesign, After Effects, Canva, Sketch, Procreate, Adobe XD
    Typography · Brand Identity · UI Design · Motion Graphics · Print Production · Colour Theory

    PORTFOLIO
    Behance: behance.net/mayarivera
    Dribbble: dribbble.com/mayarivera
    Website: mayarivera.design
    """
}
