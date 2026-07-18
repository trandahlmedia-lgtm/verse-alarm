import AVFoundation
import Speech
import SwiftUI

/// Listens while the verse is read aloud. Ported 1:1 from the field-tested web app:
/// keyword coverage (≥70%, easing to 50% after 3 attempts) + the "Amen" seal —
/// a word no verse in the bank contains, so the alarm can't die mid-verse.
@MainActor
final class SpeechGate: ObservableObject {

    @Published var heard: Set<String> = []
    @Published var rawTranscript: String = ""
    @Published var coverage: Double = 0
    @Published var amenHeard: Bool = false
    @Published var attempts: Int = 0
    @Published var micDenied: Bool = false
    @Published var listening: Bool = false

    var onWin: (() -> Void)?

    private var needed: [String] = []
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var tapInstalled = false
    private var wantsListening = false
    private var isStarting = false
    private var restartTask: Task<Void, Never>?
    private var won = false

    // Same STOP list as the web app.
    private static let stop: Set<String> = [
        "the","and","for","that","this","with","shall","will","your","you","not","but",
        "his","her","who","are","was","were","them","they","have","has","from","unto",
        "into","upon","all","may","let","our","out","can","which","what","when","does",
        "did","been","also","yes","among"
    ]

    static func keywords(in text: String) -> [String] {
        let cleaned = text.lowercased().map { $0.isLetter || $0.isWhitespace ? $0 : " " }
        return String(cleaned)
            .split(separator: " ")
            .map(String.init)
            .filter { $0.count >= 3 && !stop.contains($0) }
    }

    var coverageNeeded: Double { attempts >= 3 ? 0.5 : 0.7 }
    var sealReady: Bool { coverage >= coverageNeeded && !amenHeard }

    func begin(verse: Verse) async {
        guard !wantsListening && !isStarting else { return }
        isStarting = true
        defer { isStarting = false }

        needed = Array(Set(Self.keywords(in: verse.text)))
        won = false
        micDenied = false
        wantsListening = true

        let speechOK = await requestSpeechAuth()
        let micOK = await AVAudioApplication.requestRecordPermission()
        guard wantsListening, speechOK, micOK else {
            markMicUnavailable()
            return
        }
        startListening()
    }

    private func requestSpeechAuth() async -> Bool {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
    }

    private func startListening() {
        guard wantsListening, !won, !listening else { return }
        restartTask?.cancel()
        restartTask = nil
        tearDownAudio()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default,
                                    options: [.duckOthers, .defaultToSpeaker, .allowBluetooth])
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            if recognizer?.supportsOnDeviceRecognition == true {
                request.requiresOnDeviceRecognition = true
            }
            self.request = request

            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            guard format.sampleRate > 0, format.channelCount > 0 else {
                markMicUnavailable()
                return
            }
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            tapInstalled = true
            engine.prepare()
            try engine.start()
            listening = true

            task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if let result {
                        self.process(result.bestTranscription.formattedString)
                    }
                    if self.wantsListening, error != nil || (result?.isFinal ?? false) {
                        // Recognition cycles end on pauses — count an attempt and restart.
                        self.attempts += 1
                        self.restartSoon()
                    }
                }
            }
        } catch {
            markMicUnavailable()
        }
    }

    private func restartSoon() {
        guard wantsListening, !won else { return }
        listening = false
        restartTask?.cancel()
        restartTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            self?.startListening()
        }
    }

    private func markMicUnavailable() {
        wantsListening = false
        micDenied = true
        tearDownAudio()
    }

    private func process(_ transcript: String) {
        rawTranscript = transcript
        for word in Self.keywords(in: transcript) { heard.insert(word) }
        if transcript.lowercased().contains("amen") { heard.insert("amen") }

        let hits = needed.filter { heard.contains($0) }.count
        coverage = needed.isEmpty ? 1 : Double(hits) / Double(needed.count)
        amenHeard = heard.contains("amen")

        if coverage >= coverageNeeded && amenHeard {
            win()
        }
    }

    /// Honor-mode / simulated wins route through here too.
    func win() {
        guard !won else { return }
        won = true
        stopListening()
        onWin?()
    }

    func stopListening() {
        wantsListening = false
        restartTask?.cancel()
        restartTask = nil
        tearDownAudio()
    }

    private func tearDownAudio() {
        task?.cancel()
        task = nil
        request?.endAudio()
        request = nil
        if engine.isRunning { engine.stop() }
        if tapInstalled {
            engine.inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
        listening = false
    }
}
