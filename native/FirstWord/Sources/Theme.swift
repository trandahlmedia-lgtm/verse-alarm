import SwiftUI

enum Theme {
    static let bg = Color(red: 0.039, green: 0.039, blue: 0.043)      // #0A0A0B midnight
    static let coal = Color(red: 0.067, green: 0.067, blue: 0.078)    // #111114
    static let panel = Color(red: 0.086, green: 0.086, blue: 0.102)   // #16161A
    static let gold = Color(red: 0.902, green: 0.722, blue: 0.298)    // #E6B84C
    static let white = Color(red: 0.961, green: 0.949, blue: 0.918)   // #F5F2EA warm white
    static let body = Color(red: 0.796, green: 0.784, blue: 0.753)    // #CBC8C0
    static let dim = Color(red: 0.961, green: 0.949, blue: 0.918).opacity(0.55)
    static let faint = Color(red: 0.961, green: 0.949, blue: 0.918).opacity(0.30)
    static let green = Color(red: 0.298, green: 0.686, blue: 0.431)   // #4CAF6E
}

extension View {
    /// The app's serif voice — Scripture reads like print, not like an app.
    func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> some View {
        font(.system(size: size, weight: weight, design: .serif))
    }
}
