import Foundation
import SwiftUI

/// Day-streak bookkeeping, matching the web app's rules:
/// one win per day; a missed day resets the streak.
@MainActor
final class StreakStore: ObservableObject {
    static let shared = StreakStore()

    @AppStorage("streak") var streak: Int = 0
    @AppStorage("bestStreak") var bestStreak: Int = 0
    @AppStorage("lastWinDay") private var lastWinDay: String = ""

    private init() {
        expireIfBroken()
    }

    private func dayKey(_ date: Date = Date()) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    var wonToday: Bool { lastWinDay == dayKey() }

    /// Reset the streak if more than one calendar day has passed since the last win.
    func expireIfBroken() {
        guard !lastWinDay.isEmpty, streak > 0 else { return }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let last = f.date(from: lastWinDay) else { return }
        let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        if days > 1 { streak = 0 }
    }

    func recordWin() {
        guard !wonToday else { return }
        expireIfBroken()
        streak += 1
        bestStreak = max(bestStreak, streak)
        lastWinDay = dayKey()
    }
}
