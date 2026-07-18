import AlarmKit
import SwiftUI

/// Empty metadata — AlarmKit requires a metadata type for its attributes.
struct VerseMetadata: AlarmMetadata {
    init() {}
}

/// Thin wrapper around AlarmKit. One fixed alarm slot: the daily First Word alarm.
@MainActor
final class AlarmService: ObservableObject {
    static let shared = AlarmService()

    /// A stable ID so re-scheduling always replaces the same alarm.
    static let dailyAlarmID = UUID(uuidString: "0F1257D0-F1D0-4B1B-9E0A-000000000001")!

    @Published var authorized: Bool = false
    @Published var scheduled: Bool = UserDefaults.standard.bool(forKey: "alarmScheduled")

    private init() {}

    func ensureAuthorized() async -> Bool {
        let manager = AlarmManager.shared
        switch manager.authorizationState {
        case .authorized:
            authorized = true
        case .denied:
            authorized = false
        case .notDetermined:
            let state = try? await manager.requestAuthorization()
            authorized = (state == .authorized)
        @unknown default:
            authorized = false
        }
        return authorized
    }

    /// Schedules (or replaces) the daily alarm at hour:minute, every day of the week.
    func scheduleDaily(hour: Int, minute: Int) async throws {
        let manager = AlarmManager.shared

        let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
        let recurrence = Alarm.Schedule.Relative.Recurrence.weekly([
            .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday
        ])
        let schedule = Alarm.Schedule.relative(.init(time: time, repeats: recurrence))

        // The system always provides a stop button on a real alarm — the covenant is
        // enforced by the streak, not by trapping the user. "Read" opens the app.
        let stopButton = AlarmButton(
            text: "Dismiss",
            textColor: .white,
            systemImageName: "xmark.circle"
        )
        let readButton = AlarmButton(
            text: "Read",
            textColor: .black,
            systemImageName: "book.fill"
        )
        let alert = AlarmPresentation.Alert(
            title: "The Word is waiting 🌅",
            stopButton: stopButton,
            secondaryButton: readButton,
            secondaryButtonBehavior: .custom
        )

        let attributes = AlarmAttributes<VerseMetadata>(
            presentation: AlarmPresentation(alert: alert),
            metadata: VerseMetadata(),
            tintColor: Theme.gold
        )

        let configuration = AlarmManager.AlarmConfiguration.alarm(
            schedule: schedule,
            attributes: attributes,
            secondaryIntent: OpenRingIntent(),
            sound: .default
        )

        // Cancel-then-schedule keeps one clean daily slot.
        try? manager.cancel(id: Self.dailyAlarmID)
        _ = try await manager.schedule(id: Self.dailyAlarmID, configuration: configuration)

        scheduled = true
        UserDefaults.standard.set(true, forKey: "alarmScheduled")
    }

    func cancelDaily() {
        try? AlarmManager.shared.cancel(id: Self.dailyAlarmID)
        scheduled = false
        UserDefaults.standard.set(false, forKey: "alarmScheduled")
    }

    /// Silence the currently ringing alarm (called after the verse is sealed).
    func stopRinging() {
        try? AlarmManager.shared.stop(id: Self.dailyAlarmID)
    }
}
