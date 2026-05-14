import SwiftUI

@main
struct RemoteJobsAIApp: App {
    @StateObject private var jobsVM = JobsViewModel()
    @StateObject private var profileVM = ProfileViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(jobsVM)
                .environmentObject(profileVM)
                .preferredColorScheme(.none) // Supports both light and dark mode
        }
    }
}
