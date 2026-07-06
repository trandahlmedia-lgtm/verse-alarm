import SwiftUI

@main
struct FirstWordApp: App {
    @StateObject private var model = AppModel.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .preferredColorScheme(.dark)
        }
    }
}

/// App-wide state. The alarm's "Read" button (via OpenRingIntent) and the in-app
/// test button both funnel into `phase = .ring`.
@MainActor
final class AppModel: ObservableObject {
    static let shared = AppModel()

    enum Phase: Equatable {
        case home
        case ring(simulated: Bool)
        case won
    }

    @Published var phase: Phase = .home

    private init() {
        // If the alarm intent fired while the app was cold-launching, honor it.
        if UserDefaults.standard.bool(forKey: "pendingRing") {
            UserDefaults.standard.set(false, forKey: "pendingRing")
            phase = .ring(simulated: false)
        }
    }

    /// Called from OpenRingIntent — may run before the UI exists.
    nonisolated static func signalRing() {
        Task { @MainActor in
            let model = AppModel.shared
            if case .ring = model.phase { return }
            model.phase = .ring(simulated: false)
            UserDefaults.standard.set(false, forKey: "pendingRing")
        }
        // Belt and braces for cold launch ordering.
        UserDefaults.standard.set(true, forKey: "pendingRing")
    }
}

struct RootView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            switch model.phase {
            case .home:
                HomeView()
            case .ring(let simulated):
                RingView(simulated: simulated)
            case .won:
                WonView()
            }
        }
    }
}
