import AppIntents
import Foundation

/// Fired by the alarm's "Read" button. Opens the app straight into the wake flow.
struct OpenRingIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Read the Verse"
    static var description = IntentDescription("Opens First Word to read this morning's verse.")
    static var openAppWhenRun: Bool = true

    init() {}

    func perform() async throws -> some IntentResult {
        AppModel.signalRing()
        return .result()
    }
}
