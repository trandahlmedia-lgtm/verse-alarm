import AVFoundation

/// The in-app bell that keeps gentle pressure on until the verse is sealed.
/// (The system alarm wakes you; this carries the moment once the app opens.)
final class BellPlayer {
    private var player: AVAudioPlayer?
    private var ramp: Timer?

    func start() {
        guard let url = Bundle.main.url(forResource: "bell", withExtension: "wav") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.volume = 0.15
        player?.play()

        // Rise gently — loud enough to matter, quiet enough for speech recognition.
        ramp = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let p = self?.player else { return }
            p.volume = min(0.55, p.volume + 0.05)
        }
    }

    func stop() {
        ramp?.invalidate()
        ramp = nil
        player?.stop()
        player = nil
    }
}
