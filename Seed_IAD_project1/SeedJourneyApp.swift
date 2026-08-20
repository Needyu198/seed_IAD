import SwiftUI

@main
struct SeedJourneyApp: App {
    @State private var journey = JourneyModel()
    private let soundscape = AmbientSoundscape()

    var body: some Scene {
        WindowGroup {
            SeedJourneyView(journey: journey)
                .preferredColorScheme(.dark)
                .task { soundscape.start() }
        }
    }
}
