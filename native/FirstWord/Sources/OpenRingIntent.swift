import AppIntents
import Foundation

/// Fired by the alarm's "Read" button. Opens the app straight into the wake flow.
struct OpenRingIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Read the Verse"
    static let description = IntentDescription("Opens First Word to read this morning's verse.")
    static let openAppWhenRun: Bool = true

    init() {}

    func perform() async throws -> some IntentResult {
        AppModel.signalRing()
        return .result()
    }
}
