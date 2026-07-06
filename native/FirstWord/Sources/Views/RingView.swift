import SwiftUI

struct RingView: View {
    let simulated: Bool

    @EnvironmentObject var model: AppModel
    @StateObject private var gate = SpeechGate()
    @StateObject private var streaks = StreakStore.shared
    private let bell = BellPlayer()

    @State private var verse: Verse = VerseBank.today()
    @State private var elapsed: Int = 0
    @State private var honorAvailable = false
    @State private var graceProgress: Double = 0
    @State private var honorProgress: Double = 0

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Spacer(minLength: 14)
            verseBlock
            Spacer(minLength: 14)
            transcriptLine
            sealLine
            if honorAvailable || gate.micDenied { honorButton }
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 24)
        .onAppear(perform: begin)
        .onDisappear { cleanup() }
        .onReceive(ticker) { _ in
            elapsed += 1
            if elapsed >= 45 { honorAvailable = true }
        }
    }

    private var topBar: some View {
        HStack {
            if simulated {
                Text("TEST RUN")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.gold))
            }
            Spacer()
            // Grace escape — hold the cross 10 seconds. Always there, never advertised.
            Text("✝")
                .font(.system(size: 22))
                .foregroundStyle(Theme.faint.opacity(0.5 + graceProgress * 0.5))
                .onLongPressGesture(minimumDuration: 10) {
                    finish(sealed: false)
                } onPressingChanged: { pressing in
                    withAnimation(.linear(duration: pressing ? 10 : 0.3)) {
                        graceProgress = pressing ? 1 : 0
                    }
                }
        }
        .padding(.top, 16)
        .frame(height: 52)
    }

    private var verseBlock: some View {
        VStack(spacing: 18) {
            Text("READ IT ALOUD")
                .font(.system(size: 11, weight: .heavy))
                .tracking(3)
                .foregroundStyle(Theme.gold)

            highlightedVerse
                .serif(26)
                .lineSpacing(9)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)

            Text("— \(verse.ref)")
                .serif(16)
                .italic()
                .foregroundStyle(Theme.dim)
        }
    }

    /// Words light up gold as they're heard — the web app's best feedback loop.
    private var highlightedVerse: Text {
        let parts = verse.text.split(separator: " ", omittingEmptySubsequences: false)
        var result = Text("")
        for (i, partSub) in parts.enumerated() {
            let part = String(partSub)
            let key = part.lowercased().filter(\.isLetter)
            let hit = key.count >= 3 && gate.heard.contains(key)
            var t = Text(part).foregroundColor(hit ? Theme.gold : Theme.white)
            if hit { t = t.bold() }
            result = result + t
            if i < parts.count - 1 { result = result + Text(" ") }
        }
        return result
    }

    private var transcriptLine: some View {
        Text(gate.listening ? (gate.rawTranscript.isEmpty ? "Listening…" : gate.rawTranscript) : "…")
            .font(.system(size: 13))
            .foregroundStyle(Theme.faint)
            .lineLimit(2)
            .frame(minHeight: 36)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }

    private var sealLine: some View {
        let ready = gate.sealReady
        return Text("Read it all… then seal it: \"Amen.\"")
            .serif(15, weight: ready ? .bold : .regular)
            .italic()
            .foregroundStyle(ready ? Theme.gold : Theme.dim)
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(
                Capsule().fill(ready ? Theme.gold.opacity(0.12) : Theme.panel)
            )
            .overlay(
                Capsule().stroke(ready ? Theme.gold : .clear, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.3), value: ready)
            .padding(.bottom, 10)
    }

    private var honorButton: some View {
        VStack(spacing: 6) {
            Text(gate.micDenied ? "Microphone unavailable — honor mode:" : "Can't speak right now?")
                .font(.system(size: 12))
                .foregroundStyle(Theme.dim)
            Text("Hold here after reading silently (8s)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.white.opacity(0.6 + honorProgress * 0.4))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Capsule().fill(Theme.panel))
                .overlay(Capsule().stroke(Theme.white.opacity(0.15 + honorProgress * 0.6), lineWidth: 1))
                .onLongPressGesture(minimumDuration: 8) {
                    gate.win()
                } onPressingChanged: { pressing in
                    withAnimation(.linear(duration: pressing ? 8 : 0.3)) {
                        honorProgress = pressing ? 1 : 0
                    }
                }
        }
        .padding(.top, 8)
    }

    private func begin() {
        verse = simulated ? VerseBank.random() : VerseBank.today()
        gate.onWin = { finish(sealed: true) }
        bell.start()
        Task { await gate.begin(verse: verse) }
    }

    private func finish(sealed: Bool) {
        cleanup()
        if !simulated {
            AlarmService.shared.stopRinging()
        }
        if sealed {
            if !simulated { streaks.recordWin() }
            model.phase = .won
        } else {
            model.phase = .home
        }
    }

    private func cleanup() {
        bell.stop()
        gate.stopListening()
    }
}
