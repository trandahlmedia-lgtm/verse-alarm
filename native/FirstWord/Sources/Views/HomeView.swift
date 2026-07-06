import SwiftUI

struct HomeView: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var alarms = AlarmService.shared
    @StateObject private var streaks = StreakStore.shared

    @AppStorage("alarmHour") private var alarmHour: Int = 6
    @AppStorage("alarmMinute") private var alarmMinute: Int = 30
    @State private var showDeniedHelp = false

    private var pickerBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: alarmHour, minute: alarmMinute, second: 0, of: Date()
                ) ?? Date()
            },
            set: { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                alarmHour = c.hour ?? 6
                alarmMinute = c.minute ?? 30
                if alarms.scheduled { reschedule() }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                header
                streakChip
                verseCard
                alarmCard
                testButton
                footer
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
        }
        .alert("Alarm permission needed", isPresented: $showDeniedHelp) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Not now", role: .cancel) {}
        } message: {
            Text("First Word needs alarm permission to wake you. Settings → First Word → Allow Alarms.")
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("First Word")
                .serif(34, weight: .bold)
                .foregroundStyle(Theme.gold)
            Text("Wake up in the Word · v0.1 native")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.faint)
        }
        .padding(.top, 8)
    }

    private var streakChip: some View {
        HStack(spacing: 8) {
            Text("🔥")
            Text("\(streaks.streak)-day streak")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.white)
            if streaks.bestStreak > streaks.streak {
                Text("· best \(streaks.bestStreak)")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.dim)
            }
            if streaks.wonToday {
                Text("· sealed today ✓")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.green)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .background(Capsule().fill(Theme.panel))
        .overlay(Capsule().stroke(Theme.gold.opacity(0.25), lineWidth: 1))
    }

    private var verseCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TODAY'S VERSE")
                .font(.system(size: 10, weight: .heavy))
                .tracking(2.2)
                .foregroundStyle(Theme.gold)
            Text(VerseBank.today().text)
                .serif(19)
                .foregroundStyle(Theme.white)
                .lineSpacing(5)
            Text("— \(VerseBank.today().ref)")
                .serif(14)
                .italic()
                .foregroundStyle(Theme.dim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.panel))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.white.opacity(0.07), lineWidth: 1))
    }

    private var alarmCard: some View {
        VStack(spacing: 14) {
            DatePicker("", selection: pickerBinding, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
                .frame(maxHeight: 150)

            Button {
                Task { await toggleAlarm() }
            } label: {
                Text(alarms.scheduled ? "Alarm set — every morning ✓" : "Set my alarm")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(alarms.scheduled ? Theme.panel : Theme.gold)
                    )
                    .foregroundStyle(alarms.scheduled ? Theme.green : Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(alarms.scheduled ? Theme.green.opacity(0.5) : .clear, lineWidth: 1)
                    )
            }

            if alarms.scheduled {
                Button("Turn alarm off") { alarms.cancelDaily() }
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.dim)
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.coal))
    }

    private var testButton: some View {
        Button {
            model.phase = .ring(simulated: true)
        } label: {
            Label("Try the wake flow now", systemImage: "sun.horizon.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.gold)
        }
        .padding(.top, 2)
    }

    private var footer: some View {
        Text("The Word is never for sale. Free, forever.")
            .serif(12)
            .italic()
            .foregroundStyle(Theme.faint)
            .padding(.vertical, 18)
    }

    private func toggleAlarm() async {
        guard await alarms.ensureAuthorized() else {
            showDeniedHelp = true
            return
        }
        do {
            try await alarms.scheduleDaily(hour: alarmHour, minute: alarmMinute)
        } catch {
            showDeniedHelp = true
        }
    }

    private func reschedule() {
        Task {
            try? await alarms.scheduleDaily(hour: alarmHour, minute: alarmMinute)
        }
    }
}
