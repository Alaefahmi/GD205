import Foundation

// MARK: - Job Model
struct Job: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let company: String
    let location: String
    let salary: String?
    let description: String
    let requirements: [String]
    let jobType: JobType
    let experienceLevel: ExperienceLevel
    let category: DesignCategory
    let postedDate: Date
    let applicationURL: String
    let source: JobSource
    /// Link to the company's design portfolio showcase (Behance / Dribbble page)
    let companyPortfolioURL: String?
    var isSaved: Bool
    var applicationStatus: ApplicationStatus

    // Computed helpers
    var isEasyApply: Bool {
        source == .linkedin || source == .indeed
    }

    var postedDateFormatted: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour], from: postedDate, to: now)
        if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else {
            return "Just now"
        }
    }

    var salaryFormatted: String {
        salary ?? "Salary not disclosed"
    }
}

// MARK: - DesignCategory
/// Graphic-design-specific job categories shown on the browse / filter screen.
enum DesignCategory: String, Codable, CaseIterable, Identifiable {
    case logoDesign     = "Logo Design"
    case uiUx           = "UI/UX"
    case branding       = "Branding"
    case motionGraphics = "Motion Graphics"
    case illustration   = "Illustration"
    case webDesign      = "Web Design"
    case printDesign    = "Print Design"
    case socialMedia    = "Social Media Design"
    case packaging      = "Packaging"
    case typography     = "Typography"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .logoDesign:     return "a.circle.fill"
        case .uiUx:           return "rectangle.on.rectangle"
        case .branding:       return "sparkles"
        case .motionGraphics: return "film.fill"
        case .illustration:   return "pencil.tip.crop.circle"
        case .webDesign:      return "globe"
        case .printDesign:    return "printer.fill"
        case .socialMedia:    return "square.grid.2x2.fill"
        case .packaging:      return "shippingbox.fill"
        case .typography:     return "textformat"
        }
    }

    var color: String {
        switch self {
        case .logoDesign:     return "purple"
        case .uiUx:           return "blue"
        case .branding:       return "pink"
        case .motionGraphics: return "orange"
        case .illustration:   return "green"
        case .webDesign:      return "teal"
        case .printDesign:    return "red"
        case .socialMedia:    return "indigo"
        case .packaging:      return "brown"
        case .typography:     return "cyan"
        }
    }
}

// MARK: - JobType
enum JobType: String, Codable, CaseIterable, Identifiable {
    case remote = "Remote"
    case hybrid = "Hybrid"
    case onsite = "On-site"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .remote: return "house.fill"
        case .hybrid: return "building.2.fill"
        case .onsite: return "building.fill"
        }
    }

    var color: String {
        switch self {
        case .remote: return "green"
        case .hybrid: return "orange"
        case .onsite: return "blue"
        }
    }
}

// MARK: - ExperienceLevel
/// Only entry-level and junior positions are surfaced in this app.
enum ExperienceLevel: String, Codable, CaseIterable, Identifiable {
    case entryLevel = "Entry Level"
    case junior     = "Junior"

    var id: String { rawValue }

    var yearsRange: String {
        switch self {
        case .entryLevel: return "0–1 year"
        case .junior:     return "1–3 years"
        }
    }
}

// MARK: - JobSource
enum JobSource: String, Codable, CaseIterable, Identifiable {
    case indeed        = "Indeed"
    case linkedin      = "LinkedIn"
    case glassdoor     = "Glassdoor"
    case dribbble      = "Dribbble Jobs"
    case behance       = "Behance Jobs"

    var id: String { rawValue }

    var logoSystemName: String {
        switch self {
        case .indeed:    return "i.circle.fill"
        case .linkedin:  return "link.circle.fill"
        case .glassdoor: return "g.circle.fill"
        case .dribbble:  return "basketball.fill"
        case .behance:   return "b.circle.fill"
        }
    }

    var badgeColor: String {
        switch self {
        case .indeed:    return "purple"
        case .linkedin:  return "blue"
        case .glassdoor: return "green"
        case .dribbble:  return "pink"
        case .behance:   return "indigo"
        }
    }
}

// MARK: - ApplicationStatus
enum ApplicationStatus: String, Codable, CaseIterable, Identifiable {
    case notApplied = "Not Applied"
    case applied    = "Applied"
    case interview  = "Interview"
    case offer      = "Offer"
    case rejected   = "Rejected"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .notApplied: return "circle"
        case .applied:    return "paperplane.fill"
        case .interview:  return "person.fill.questionmark"
        case .offer:      return "star.fill"
        case .rejected:   return "xmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .notApplied: return "gray"
        case .applied:    return "blue"
        case .interview:  return "orange"
        case .offer:      return "green"
        case .rejected:   return "red"
        }
    }
}

// MARK: - Mock Job Data
extension Job {
    static var mockJobs: [Job] {
        let now = Date()
        func daysAgo(_ n: Int) -> Date { Calendar.current.date(byAdding: .day, value: -n, to: now)! }

        return [
            // --- Remote entry-level ---
            Job(
                id: "job-001",
                title: "Junior Graphic Designer",
                company: "Pentagram",
                location: "Remote",
                salary: "$42,000 – $52,000/yr",
                description: "Join one of the world's most celebrated design consultancies as a junior designer. You will assist senior designers on brand identity, print, and digital projects for global clients.",
                requirements: [
                    "Bachelor's in Graphic Design or Visual Communication",
                    "Proficiency in Adobe Illustrator and Photoshop",
                    "Strong typography fundamentals",
                    "Portfolio demonstrating logo and brand work",
                    "0–2 years of experience"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                category: .branding,
                postedDate: daysAgo(1),
                applicationURL: "https://www.pentagram.com/careers",
                source: .linkedin,
                companyPortfolioURL: "https://www.behance.net/pentagram",
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-002",
                title: "Entry-Level UI Designer",
                company: "Figma",
                location: "Remote",
                salary: "$55,000 – $70,000/yr",
                description: "Help shape the future of design tooling by crafting clean, accessible UI across Figma's product suite. You will work closely with product managers and engineers in a fully remote team.",
                requirements: [
                    "Expertise in Figma (components, auto-layout, prototyping)",
                    "Understanding of accessibility (WCAG 2.1)",
                    "Portfolio showing mobile or web UI work",
                    "Degree in Design, HCI, or related field",
                    "0–1 year professional experience"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                category: .uiUx,
                postedDate: daysAgo(2),
                applicationURL: "https://www.figma.com/careers",
                source: .dribbble,
                companyPortfolioURL: "https://dribbble.com/figma",
                isSaved: true,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-003",
                title: "Junior Motion Designer",
                company: "Buck",
                location: "Remote",
                salary: "$48,000 – $60,000/yr",
                description: "Create kinetic brand experiences for leading consumer and tech brands. You will animate in After Effects and contribute to motion style guides.",
                requirements: [
                    "Proficiency in After Effects and Cinema 4D (or Blender)",
                    "Strong sense of timing, easing, and visual storytelling",
                    "Portfolio with at least 3 motion/animation pieces",
                    "Knowledge of Premiere Pro a plus"
                ],
                jobType: .remote,
                experienceLevel: .junior,
                category: .motionGraphics,
                postedDate: daysAgo(3),
                applicationURL: "https://buck.co/careers",
                source: .behance,
                companyPortfolioURL: "https://www.behance.net/buck",
                isSaved: false,
                applicationStatus: .notApplied
            ),
            // --- Hybrid ---
            Job(
                id: "job-004",
                title: "Brand Designer (Entry Level)",
                company: "Mailchimp",
                location: "Atlanta, GA (Hybrid)",
                salary: "$50,000 – $62,000/yr",
                description: "Support Mailchimp's in-house brand team on campaigns, social assets, and product marketing materials. A great launchpad for recent design graduates.",
                requirements: [
                    "Adobe Creative Suite (Illustrator, Photoshop, InDesign)",
                    "Understanding of brand systems and style guides",
                    "Experience with Figma or Sketch",
                    "Strong attention to detail"
                ],
                jobType: .hybrid,
                experienceLevel: .entryLevel,
                category: .branding,
                postedDate: daysAgo(2),
                applicationURL: "https://mailchimp.com/about/careers",
                source: .linkedin,
                companyPortfolioURL: "https://dribbble.com/mailchimp",
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-005",
                title: "Junior Illustrator",
                company: "The New Yorker",
                location: "New York, NY (Hybrid)",
                salary: "$45,000 – $55,000/yr",
                description: "Create editorial illustrations for print and digital features. Collaborate with art directors to develop visual concepts that resonate with a global readership.",
                requirements: [
                    "Distinctive personal illustration style",
                    "Proficiency in Adobe Illustrator and/or Procreate",
                    "Ability to meet tight editorial deadlines",
                    "Portfolio with editorial or narrative illustration samples"
                ],
                jobType: .hybrid,
                experienceLevel: .junior,
                category: .illustration,
                postedDate: daysAgo(5),
                applicationURL: "https://www.newyorker.com/about/careers",
                source: .indeed,
                companyPortfolioURL: "https://www.behance.net/thenewyorker",
                isSaved: true,
                applicationStatus: .applied
            ),
            // --- On-site ---
            Job(
                id: "job-006",
                title: "Graphic Designer – Print & Packaging",
                company: "Landor & Fitch",
                location: "San Francisco, CA",
                salary: "$46,000 – $58,000/yr",
                description: "Design packaging systems and print collateral for consumer goods brands. You will prepare production-ready files and liaise with print vendors.",
                requirements: [
                    "Adobe InDesign and Illustrator expertise",
                    "Knowledge of print production and prepress workflows",
                    "Experience with dieline templates a plus",
                    "Degree in Graphic Design or Packaging Design"
                ],
                jobType: .onsite,
                experienceLevel: .entryLevel,
                category: .printDesign,
                postedDate: daysAgo(7),
                applicationURL: "https://www.landor.com/careers",
                source: .glassdoor,
                companyPortfolioURL: "https://www.behance.net/landorfitch",
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-007",
                title: "Junior Web Designer",
                company: "Squarespace",
                location: "New York, NY",
                salary: "$52,000 – $65,000/yr",
                description: "Design responsive website templates and landing pages used by millions of small businesses. Collaborate with engineers to implement pixel-perfect layouts.",
                requirements: [
                    "Figma proficiency (components, responsive frames, prototyping)",
                    "Solid understanding of HTML/CSS",
                    "Portfolio showing web design projects",
                    "Eye for typography and visual hierarchy"
                ],
                jobType: .onsite,
                experienceLevel: .junior,
                category: .webDesign,
                postedDate: daysAgo(4),
                applicationURL: "https://www.squarespace.com/about/careers",
                source: .linkedin,
                companyPortfolioURL: "https://dribbble.com/squarespace",
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-008",
                title: "Social Media Designer",
                company: "Ogilvy",
                location: "Remote",
                salary: "$40,000 – $50,000/yr",
                description: "Create scroll-stopping social assets for global campaigns across Instagram, TikTok, and YouTube. Concept and produce static, GIF, and short-video formats.",
                requirements: [
                    "Adobe Photoshop and After Effects",
                    "Canva for rapid iteration",
                    "Understanding of platform-specific image and video specs",
                    "Strong concept and copy-pairing skills",
                    "0–2 years experience"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                category: .socialMedia,
                postedDate: daysAgo(1),
                applicationURL: "https://www.ogilvy.com/careers",
                source: .indeed,
                companyPortfolioURL: "https://www.behance.net/ogilvy",
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-009",
                title: "Junior Logo & Identity Designer",
                company: "Wolff Olins",
                location: "Remote",
                salary: "$44,000 – $56,000/yr",
                description: "Work alongside senior identity designers on brand strategy and visual identity systems for challenger brands and large institutions.",
                requirements: [
                    "Adobe Illustrator mastery",
                    "Understanding of brand strategy and semiotics",
                    "Portfolio demonstrating logo and identity system work",
                    "Sketching and concept development skills"
                ],
                jobType: .remote,
                experienceLevel: .junior,
                category: .logoDesign,
                postedDate: daysAgo(3),
                applicationURL: "https://www.wolffolins.com/work-with-us",
                source: .dribbble,
                companyPortfolioURL: "https://dribbble.com/wolffolins",
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-010",
                title: "Entry-Level UX/UI Designer",
                company: "Airbnb",
                location: "Remote",
                salary: "$60,000 – $75,000/yr",
                description: "Join Airbnb's design team to prototype and test new host and guest experiences. Work in a collaborative squad with researchers and content strategists.",
                requirements: [
                    "Figma (high-fidelity prototyping)",
                    "Understanding of user-centered design principles",
                    "Experience conducting usability tests",
                    "Portfolio with case studies, not just visuals"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                category: .uiUx,
                postedDate: daysAgo(6),
                applicationURL: "https://careers.airbnb.com",
                source: .linkedin,
                companyPortfolioURL: "https://dribbble.com/airbnb",
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-011",
                title: "Graphic Design Intern → Full-Time",
                company: "IDEO",
                location: "Chicago, IL (Hybrid)",
                salary: "$38,000 – $46,000/yr",
                description: "A convert-to-full-time role at one of the world's leading design consultancies. Work on human-centered design challenges spanning physical and digital products.",
                requirements: [
                    "Adobe Creative Suite",
                    "Sketch or Figma",
                    "Curiosity and a generalist design mindset",
                    "Recent graduate or up to 1 year experience"
                ],
                jobType: .hybrid,
                experienceLevel: .entryLevel,
                category: .branding,
                postedDate: daysAgo(10),
                applicationURL: "https://www.ideo.com/careers",
                source: .glassdoor,
                companyPortfolioURL: "https://www.behance.net/ideo",
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-012",
                title: "Junior Visual Designer",
                company: "Spotify",
                location: "Remote",
                salary: "$58,000 – $72,000/yr",
                description: "Design visual assets for Spotify's editorial, marketing, and artist-facing surfaces. You will bring music culture to life through bold, culturally relevant visuals.",
                requirements: [
                    "Figma and Adobe Creative Suite",
                    "Strong sense of colour, typography, and composition",
                    "Ability to work within an established design system",
                    "1–2 years of relevant design experience"
                ],
                jobType: .remote,
                experienceLevel: .junior,
                category: .branding,
                postedDate: daysAgo(2),
                applicationURL: "https://www.lifeatspotify.com",
                source: .linkedin,
                companyPortfolioURL: "https://dribbble.com/spotify",
                isSaved: false,
                applicationStatus: .notApplied
            ),
        ]
    }
}
