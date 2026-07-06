import SwiftUI

struct WonView: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var streaks = StreakStore.shared

    private var shareText: String {
        "Day \(max(streaks.streak, 1)) — the Word was my first word this morning 🌅 #FirstWord"
    }

    var body: some View {
        VStack(spacing: 26) {
            Spacer()

            Text("🔥")
                .font(.system(size: 64))

            VStack(spacing: 8) {
                Text("Sealed.")
                    .serif(38, weight: .bold)
                    .foregroundStyle(Theme.gold)
                Text("The Word was your first word today.")
                    .serif(17)
                    .italic()
                    .foregroundStyle(Theme.body)
            }

            VStack(spacing: 4) {
                Text("\(streaks.streak)")
                    .font(.system(size: 56, weight: .heavy))
                    .foregroundStyle(Theme.white)
                Text(streaks.streak == 1 ? "day in the Word" : "days in the Word")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(Theme.dim)
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 48)
            .background(RoundedRectangle(cornerRadius: 20).fill(Theme.panel))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.gold.opacity(0.3), lineWidth: 1))

            ShareLink(item: shareText) {
                Label("Share the streak", systemImage: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.gold)
            }

            Spacer()

            Button {
                model.phase = .home
            } label: {
                Text("Go win the day")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Theme.gold))
                    .foregroundStyle(.black)
            }
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 26)
    }
}
