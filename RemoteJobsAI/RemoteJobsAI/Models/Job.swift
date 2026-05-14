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
    let postedDate: Date
    let applicationURL: String
    let source: JobSource
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
enum ExperienceLevel: String, Codable, CaseIterable, Identifiable {
    case entryLevel = "Entry Level"
    case midLevel   = "Mid Level"
    case senior     = "Senior"

    var id: String { rawValue }

    var yearsRange: String {
        switch self {
        case .entryLevel: return "0-2 years"
        case .midLevel:   return "3-5 years"
        case .senior:     return "6+ years"
        }
    }
}

// MARK: - JobSource
enum JobSource: String, Codable, CaseIterable, Identifiable {
    case indeed         = "Indeed"
    case linkedin       = "LinkedIn"
    case glassdoor      = "Glassdoor"
    case remoteOK       = "RemoteOK"
    case weworkremotely = "WeWorkRemotely"

    var id: String { rawValue }

    var logoSystemName: String {
        switch self {
        case .indeed:         return "i.circle.fill"
        case .linkedin:       return "link.circle.fill"
        case .glassdoor:      return "g.circle.fill"
        case .remoteOK:       return "globe.americas.fill"
        case .weworkremotely: return "w.circle.fill"
        }
    }

    var badgeColor: String {
        switch self {
        case .indeed:         return "purple"
        case .linkedin:       return "blue"
        case .glassdoor:      return "green"
        case .remoteOK:       return "orange"
        case .weworkremotely: return "red"
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
