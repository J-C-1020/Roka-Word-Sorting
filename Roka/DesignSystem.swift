//
//  DesignSystem.swift
//  Roka
//
//  Created by Yolanda Cantu on 02/03/26.
//

import SwiftUI

// MARK: - Design Tokens

enum RokaColor {
    static let paper        = Color(red: 0.96, green: 0.94, blue: 0.91)
    static let ink          = Color(red: 0.16, green: 0.12, blue: 0.08)
    static let inkFaint     = Color(red: 0.16, green: 0.12, blue: 0.08).opacity(0.38)
    static let inkSubtle    = Color(red: 0.16, green: 0.12, blue: 0.08).opacity(0.55)
    static let inkLight     = Color(red: 0.16, green: 0.12, blue: 0.08).opacity(0.65)
    static let tan          = Color(red: 0.63, green: 0.44, blue: 0.29)
    static let tanLight     = Color(red: 0.83, green: 0.65, blue: 0.45)
    static let correct      = Color(red: 0.23, green: 0.49, blue: 0.27)
    static let correctLight = Color(red: 0.72, green: 0.87, blue: 0.73)
    static let wrong        = Color(red: 0.75, green: 0.22, blue: 0.17)
    static let wrongLight   = Color(red: 0.96, green: 0.77, blue: 0.77)
    static let ruleLine     = Color(red: 0.29, green: 0.50, blue: 0.76).opacity(0.15)
    static let marginLine   = Color.red.opacity(0.2)
}

enum RokaFont {
    static func bold(_ size: CGFloat)    -> Font { .custom("AmericanTypewriter-Bold", size: size) }
    static func regular(_ size: CGFloat) -> Font { .custom("AmericanTypewriter",      size: size) }
    static func boldScaled(_ style: Font.TextStyle, base: CGFloat) -> Font {
        .custom("AmericanTypewriter-Bold", size: base, relativeTo: style)
    }
    static func regularScaled(_ style: Font.TextStyle, base: CGFloat) -> Font {
        .custom("AmericanTypewriter",      size: base, relativeTo: style)
    }
}

// MARK: - Haptics

enum RokaHaptic {
    private static let light  = UIImpactFeedbackGenerator(style: .light)
    private static let notif  = UINotificationFeedbackGenerator()
    private static let sel    = UISelectionFeedbackGenerator()

    /// Light tap — generic button press
    static func tap()     { light.impactOccurred() }
    /// Success pattern
    static func correct() { notif.notificationOccurred(.success) }
    /// Error pattern
    static func wrong()   { notif.notificationOccurred(.error) }
    /// Selection tick — level / menu navigation
    static func pick()    { sel.selectionChanged() }
}

// MARK: - Back Button

struct RokaBackButton: View {
    let action: () -> Void
    var body: some View {
        Button { RokaHaptic.tap(); action() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(RokaColor.inkSubtle)
                .frame(width: 36, height: 36)
                .background(Color.black.opacity(0.07))
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Back")
    }
}

// MARK: - Primary Button

struct RokaPrimaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button { RokaHaptic.tap(); action() } label: {
            Text(title)
                .font(RokaFont.boldScaled(.body, base: 16))
                .tracking(1.2)
                .foregroundColor(RokaColor.paper)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(RokaColor.ink)
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 2, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Secondary Button

struct RokaSecondaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button { RokaHaptic.tap(); action() } label: {
            Text(title)
                .font(RokaFont.regularScaled(.body, base: 14))
                .tracking(1)
                .foregroundColor(RokaColor.inkLight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(RokaColor.ink.opacity(0.2), lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Level Tile Button

struct RokaLevelButton: View {
    let number: Int
    let isUnlocked: Bool
    let action: () -> Void

    var body: some View {
        Button {
            guard isUnlocked else { return }
            RokaHaptic.pick(); action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isUnlocked ? RokaColor.tan : Color(white: 0.80))
                    .shadow(color: .black.opacity(isUnlocked ? 0.2 : 0.08), radius: 6, x: 2, y: 4)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isUnlocked ? Color.clear : Color(white: 0.70), lineWidth: 2)
                VStack(spacing: 4) {
                    Text("\(number)")
                        .font(RokaFont.boldScaled(.title, base: 36))
                        .foregroundColor(isUnlocked ? RokaColor.paper : RokaColor.ink.opacity(0.35))
                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(RokaColor.ink.opacity(0.3))
                    }
                }
            }
            .frame(width: 90, height: 90)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(isUnlocked ? "Level \(number)" : "Level \(number), locked")
        .accessibilityAddTraits(isUnlocked ? .isButton : [.isButton])
    }
}

// MARK: - Category Answer Button

struct RokaCategoryButton: View {
    let title: String
    let flashState: FlashState
    let action: () -> Void

    enum FlashState { case none, correct, wrong }

    @State private var isPressed = false

    private var bg: Color {
        switch flashState {
        case .none:    return RokaColor.tanLight
        case .correct: return RokaColor.correctLight
        case .wrong:   return RokaColor.wrongLight
        }
    }
    private var border: Color {
        switch flashState {
        case .none:    return RokaColor.tan
        case .correct: return RokaColor.correct
        case .wrong:   return RokaColor.wrong
        }
    }
    // Shape/symbol indicator — "differentiate without color"
    private var prefix: String {
        switch flashState {
        case .none:    return ""
        case .correct: return "✓ "
        case .wrong:   return "✗ "
        }
    }

    var body: some View {
        Button(action: action) {
            Text(prefix + title)
                .font(RokaFont.boldScaled(.caption, base: 13))
                .tracking(1)
                .foregroundColor(RokaColor.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minWidth: 90)
                .background(bg)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(border, lineWidth: 2))
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 2, y: 3)
                .scaleEffect(flashState == .correct ? 1.08 : (isPressed ? 0.95 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.22, dampingFraction: 0.6), value: flashState)
        .animation(.easeOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
        .accessibilityLabel(title)
    }
}

// MARK: - Feedback Icon (✓ / ✗)

struct RokaFeedbackIcon: View {
    let isCorrect: Bool
    var body: some View {
        // Both symbol AND color change — satisfies "differentiate without color"
        Image(systemName: isCorrect ? "checkmark" : "xmark")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(isCorrect ? RokaColor.correct : RokaColor.wrong)
            .accessibilityLabel(isCorrect ? "Correct" : "Incorrect")
            .transition(.scale(scale: 0.4).combined(with: .opacity))
    }
}
