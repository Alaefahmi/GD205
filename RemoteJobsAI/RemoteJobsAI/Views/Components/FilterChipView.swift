import SwiftUI

// MARK: - FilterChipView
struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.accentColor : Color(.systemGray4), lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.18), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - FilterChipsScrollView
struct FilterChipsScrollView: View {
    @Binding var selectedJobTypes: Set<JobType>
    @Binding var selectedLevels: Set<ExperienceLevel>
    var additionalChips: [(String, Bool, () -> Void)] = []

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Quick filter chips
                FilterChipView(title: "Remote", isSelected: selectedJobTypes.contains(.remote), icon: "house.fill") {
                    toggleJobType(.remote)
                }
                FilterChipView(title: "Hybrid", isSelected: selectedJobTypes.contains(.hybrid), icon: "building.2.fill") {
                    toggleJobType(.hybrid)
                }
                FilterChipView(title: "Entry Level", isSelected: selectedLevels.contains(.entryLevel)) {
                    toggleLevel(.entryLevel)
                }
                FilterChipView(title: "Mid Level", isSelected: selectedLevels.contains(.midLevel)) {
                    toggleLevel(.midLevel)
                }
                FilterChipView(title: "Senior", isSelected: selectedLevels.contains(.senior)) {
                    toggleLevel(.senior)
                }
                // Additional custom chips
                ForEach(additionalChips, id: \.0) { chip in
                    FilterChipView(title: chip.0, isSelected: chip.1) {
                        chip.2()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    private func toggleJobType(_ type: JobType) {
        if selectedJobTypes.contains(type) {
            selectedJobTypes.remove(type)
        } else {
            selectedJobTypes.insert(type)
        }
    }

    private func toggleLevel(_ level: ExperienceLevel) {
        if selectedLevels.contains(level) {
            selectedLevels.remove(level)
        } else {
            selectedLevels.insert(level)
        }
    }
}

// MARK: - FilterSheet (Full filter panel)
struct FilterSheet: View {
    @Binding var filter: JobFilter
    @Environment(\.dismiss) private var dismiss
    @State private var localFilter: JobFilter = .default

    var onApply: (JobFilter) -> Void

    init(filter: Binding<JobFilter>, onApply: @escaping (JobFilter) -> Void) {
        self._filter = filter
        self.onApply = onApply
        self._localFilter = State(initialValue: filter.wrappedValue)
    }

    var body: some View {
        NavigationView {
            Form {
                // Job Type
                Section("Job Type") {
                    ForEach(JobType.allCases) { type in
                        HStack {
                            Label(type.rawValue, systemImage: type.icon)
                            Spacer()
                            if localFilter.jobTypes.contains(type) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if localFilter.jobTypes.contains(type) {
                                localFilter.jobTypes.remove(type)
                            } else {
                                localFilter.jobTypes.insert(type)
                            }
                        }
                    }
                }

                // Experience Level
                Section("Experience Level") {
                    ForEach(ExperienceLevel.allCases) { level in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.rawValue)
                                Text(level.yearsRange)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if localFilter.experienceLevels.contains(level) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if localFilter.experienceLevels.contains(level) {
                                localFilter.experienceLevels.remove(level)
                            } else {
                                localFilter.experienceLevels.insert(level)
                            }
                        }
                    }
                }

                // Salary
                Section("Salary Range") {
                    ForEach(SalaryPreset.allCases) { preset in
                        HStack {
                            Text(preset.rawValue)
                            Spacer()
                            if localFilter.minSalary == preset.min && localFilter.maxSalary == preset.max {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            localFilter.minSalary = preset.min
                            localFilter.maxSalary = preset.max
                        }
                    }
                }

                // Sources
                Section("Job Sources") {
                    ForEach(JobSource.allCases) { source in
                        HStack {
                            Image(systemName: source.logoSystemName)
                                .foregroundColor(.accentColor)
                            Text(source.rawValue)
                            Spacer()
                            if localFilter.sources.contains(source) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if localFilter.sources.contains(source) {
                                localFilter.sources.remove(source)
                            } else {
                                localFilter.sources.insert(source)
                            }
                        }
                    }
                }

                // Posted Within
                Section("Posted Within") {
                    ForEach([1, 7, 14, 30, 90], id: \.self) { days in
                        HStack {
                            Text(postedDaysLabel(days))
                            Spacer()
                            if localFilter.postedWithinDays == days {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            localFilter.postedWithinDays = days
                        }
                    }
                    HStack {
                        Text("Any time")
                        Spacer()
                        if localFilter.postedWithinDays == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { localFilter.postedWithinDays = nil }
                }

                // Reset
                Section {
                    Button("Reset Filters", role: .destructive) {
                        localFilter = .default
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply (\(localFilter.activeFiltersCount))") {
                        filter = localFilter
                        onApply(localFilter)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func postedDaysLabel(_ days: Int) -> String {
        switch days {
        case 1: return "Past 24 hours"
        case 7: return "Past week"
        case 14: return "Past 2 weeks"
        case 30: return "Past month"
        case 90: return "Past 3 months"
        default: return "Past \(days) days"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack {
            FilterChipView(title: "Remote", isSelected: true, icon: "house.fill") {}
            FilterChipView(title: "Entry Level", isSelected: false) {}
            FilterChipView(title: "USA", isSelected: true) {}
            FilterChipView(title: "Full-time", isSelected: false) {}
        }
        .padding()
    }
}
