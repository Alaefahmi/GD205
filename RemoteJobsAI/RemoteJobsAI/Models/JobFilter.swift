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

    // Default filter for remote entry-level job search
    static var `default`: JobFilter {
        JobFilter(
            keywords: "",
            location: "Remote",
            minSalary: nil,
            maxSalary: nil,
            jobTypes: [.remote],
            experienceLevels: [.entryLevel],
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
        if experienceLevels != [.entryLevel] { count += 1 }
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

// MARK: - SalaryPreset
enum SalaryPreset: String, CaseIterable, Identifiable {
    case any            = "Any"
    case under50k       = "Under $50K"
    case range50to80    = "$50K – $80K"
    case range80to100   = "$80K – $100K"
    case range100to150  = "$100K – $150K"
    case over150k       = "$150K+"

    var id: String { rawValue }

    var min: Int? {
        switch self {
        case .any:           return nil
        case .under50k:      return nil
        case .range50to80:   return 50_000
        case .range80to100:  return 80_000
        case .range100to150: return 100_000
        case .over150k:      return 150_000
        }
    }

    var max: Int? {
        switch self {
        case .any:           return nil
        case .under50k:      return 50_000
        case .range50to80:   return 80_000
        case .range80to100:  return 100_000
        case .range100to150: return 150_000
        case .over150k:      return nil
        }
    }
}

// MARK: - JobCategory
struct JobCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let keyword: String
    let color: String
}

extension JobCategory {
    static let popular: [JobCategory] = [
        JobCategory(name: "Software",  icon: "laptopcomputer",                  keyword: "software engineer",    color: "blue"),
        JobCategory(name: "Design",    icon: "paintpalette.fill",               keyword: "UX designer",          color: "purple"),
        JobCategory(name: "Data",      icon: "chart.bar.fill",                  keyword: "data analyst",         color: "green"),
        JobCategory(name: "Marketing", icon: "megaphone.fill",                  keyword: "digital marketer",     color: "orange"),
        JobCategory(name: "Finance",   icon: "dollarsign.circle.fill",          keyword: "financial analyst",    color: "teal"),
        JobCategory(name: "Writing",   icon: "pencil.and.outline",              keyword: "content writer",       color: "pink"),
        JobCategory(name: "PM",        icon: "list.bullet.clipboard.fill",      keyword: "project manager",      color: "red"),
        JobCategory(name: "Sales",     icon: "chart.line.uptrend.xyaxis",       keyword: "sales manager",        color: "indigo"),
    ]
}
