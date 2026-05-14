import Foundation

// MARK: - JobFilter
struct JobFilter: Equatable {
    var keywords: String
    var location: String
    var minSalary: Int?
    var maxSalary: Int?
    var jobTypes: Set<JobType>
    var experienceLevels: Set<ExperienceLevel>
    var sources: Set<JobSource>
    var postedWithinDays: Int?

    // Default filter optimised for remote entry-level & junior graphic design search
    static var `default`: JobFilter {
        JobFilter(
            keywords: "",
            location: "Remote",
            minSalary: nil,
            maxSalary: nil,
            jobTypes: [.remote],
            experienceLevels: [.entryLevel, .junior],
            sources: Set(JobSource.allCases),
            postedWithinDays: 30
        )
    }

    // All-jobs filter (no restrictions)
    static var all: JobFilter {
        JobFilter(
            keywords: "",
            location: "",
            minSalary: nil,
            maxSalary: nil,
            jobTypes: Set(JobType.allCases),
            experienceLevels: Set(ExperienceLevel.allCases),
            sources: Set(JobSource.allCases),
            postedWithinDays: nil
        )
    }

    var isDefault: Bool { self == .default }

    var activeFiltersCount: Int {
        var count = 0
        if !keywords.isEmpty { count += 1 }
        if location != "Remote" && !location.isEmpty { count += 1 }
        if minSalary != nil || maxSalary != nil { count += 1 }
        if jobTypes != [.remote] { count += 1 }
        if experienceLevels != [.entryLevel, .junior] { count += 1 }
        if sources != Set(JobSource.allCases) { count += 1 }
        if postedWithinDays != 30 { count += 1 }
        return count
    }

    var salaryRangeDescription: String {
        switch (minSalary, maxSalary) {
        case (let min?, let max?):
            return "$\(min / 1000)K – $\(max / 1000)K"
        case (let min?, nil):
            return "$\(min / 1000)K+"
        case (nil, let max?):
            return "Up to $\(max / 1000)K"
        case (nil, nil):
            return "Any salary"
        }
    }
}

// MARK: - SalaryRange presets (calibrated for entry-level & junior design roles)
enum SalaryPreset: String, CaseIterable, Identifiable {
    case any          = "Any"
    case under40k     = "Under $40K"
    case range40to55  = "$40K – $55K"
    case range55to70  = "$55K – $70K"
    case range70to90  = "$70K – $90K"
    case over90k      = "$90K+"

    var id: String { rawValue }

    var min: Int? {
        switch self {
        case .any:         return nil
        case .under40k:    return nil
        case .range40to55: return 40_000
        case .range55to70: return 55_000
        case .range70to90: return 70_000
        case .over90k:     return 90_000
        }
    }

    var max: Int? {
        switch self {
        case .any:         return nil
        case .under40k:    return 40_000
        case .range40to55: return 55_000
        case .range55to70: return 70_000
        case .range70to90: return 90_000
        case .over90k:     return nil
        }
    }
}

// MARK: - PopularCategory
struct JobCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let keyword: String
    let color: String
}

extension JobCategory {
    /// Graphic-design-focused browse categories shown on the home/explore screen.
    static let popular: [JobCategory] = [
        JobCategory(name: "UI/UX",      icon: "rectangle.on.rectangle",      keyword: "UI UX designer",      color: "blue"),
        JobCategory(name: "Branding",   icon: "sparkles",                     keyword: "brand designer",      color: "pink"),
        JobCategory(name: "Motion",     icon: "film.fill",                    keyword: "motion designer",     color: "orange"),
        JobCategory(name: "Illustration", icon: "pencil.tip.crop.circle",     keyword: "illustrator",         color: "green"),
        JobCategory(name: "Web Design", icon: "globe",                        keyword: "web designer",        color: "teal"),
        JobCategory(name: "Print",      icon: "printer.fill",                 keyword: "print designer",      color: "red"),
        JobCategory(name: "Social",     icon: "square.grid.2x2.fill",         keyword: "social media designer", color: "indigo"),
        JobCategory(name: "Logo",       icon: "a.circle.fill",                keyword: "logo designer",       color: "purple"),
    ]
}
