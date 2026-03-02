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
    static let inkLight     = Color(red: 0.16, green: 0.12, blue: 0.08).opacity(0.65)
    static let tan          = Color(red: 0.63, green: 0.44, blue: 0.29)
    static let tanLight     = Color(red: 0.83, green: 0.65, blue: 0.45)
    static let correct      = Color(red: 0.23, green: 0.49, blue: 0.27)
    static let correctLight = Color(red: 0.72, green: 0.87, blue: 0.73)
    static let wrong        = Color(red: 0.75, green: 0.22, blue: 0.17)
    static let wrongLight   = Color(red: 0.96, green: 0.77, blue: 0.77)
    static let ruleLine     = Color(red: 0.29, green: 0.50, blue: 0.76).opacity(0.15)
    static let marginLine   = Color.red.opacity(0.2)
    static let selected     = Color(red: 0.20, green: 0.38, blue: 0.65)
    static let selectedLight = Color(red: 0.78, green: 0.88, blue: 0.97)
}

enum RokaFont {
    static func boldScaled(_ style: Font.TextStyle, base: CGFloat) -> Font {
        .custom("AmericanTypewriter-Bold", size: base, relativeTo: style)
    }
    static func regularScaled(_ style: Font.TextStyle, base: CGFloat) -> Font {
        .custom("AmericanTypewriter", size: base, relativeTo: style)
    }
}

// MARK: - Haptics

enum RokaHaptic {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let med   = UIImpactFeedbackGenerator(style: .medium)
    private static let notif = UINotificationFeedbackGenerator()
    private static let sel   = UISelectionFeedbackGenerator()

    static func tap()     { light.impactOccurred() }
    static func toggle()  { med.impactOccurred() }      // category selected/deselected
    static func correct() { notif.notificationOccurred(.success) }
    static func wrong()   { notif.notificationOccurred(.error) }
    static func pick()    { sel.selectionChanged() }
}

// MARK: - Shake modifier

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// MARK: - Back Button

struct RokaBackButton: View {
    let action: () -> Void
    var body: some View {
        Button { RokaHaptic.tap(); action() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(RokaColor.inkLight)
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
                .font(RokaFont.boldScaled(.body, base: 14))
                .tracking(1)
                .foregroundColor(RokaColor.inkLight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(RokaColor.inkLight, lineWidth: 2)
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

// MARK: - Category Answer Button (toggleable for L2/L3, single-tap for L1)

enum RokaCategoryFlash { case none, correct, wrong }

struct RokaCategoryButton: View {
    let title: String
    let isSelected: Bool          // only used in L2/L3
    let flashState: RokaCategoryFlash
    let isShaking: Bool
    let action: () -> Void

    @State private var shakeValue: CGFloat = 0
    @State private var isPressed = false

    private var bg: Color {
        switch flashState {
        case .none:    return isSelected ? RokaColor.selectedLight : RokaColor.tanLight
        case .correct: return RokaColor.correctLight
        case .wrong:   return RokaColor.wrongLight
        }
    }
    private var border: Color {
        switch flashState {
        case .none:    return isSelected ? RokaColor.selected : RokaColor.tan
        case .correct: return RokaColor.correct
        case .wrong:   return RokaColor.wrong
        }
    }
    // Symbol prefix — differentiate without color
    private var prefix: String {
        switch flashState {
        case .none:    return isSelected ? "● " : ""
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
                .scaleEffect(flashState == .correct ? 1.08 : (isSelected ? 1.04 : (isPressed ? 0.95 : 1.0)))
        }
        .buttonStyle(PlainButtonStyle())
        .modifier(ShakeEffect(animatableData: shakeValue))
        .animation(.spring(response: 0.22, dampingFraction: 0.6), value: isSelected)
        .animation(.spring(response: 0.22, dampingFraction: 0.6), value: flashState)
        .animation(.easeOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
        .onChange(of: isShaking) { _, shaking in
            guard shaking else { return }
            withAnimation(.linear(duration: 0.4)) { shakeValue += 1 }
        }
        .accessibilityLabel(isSelected ? "\(title), selected" : title)
    }
}

// MARK: - Confirm Button

struct RokaConfirmButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("CONFIRM")
                .font(RokaFont.boldScaled(.caption, base: 13))
                .tracking(1)
                .foregroundColor(RokaColor.paper)
                .padding(.horizontal, 20)
                .padding(.vertical, 11)
                .background(RokaColor.ink)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(RokaColor.ink, lineWidth: 2)
                )
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 2, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Confirm selection")
        .transition(.scale(scale: 0.5).combined(with: .opacity))
    }
}

// MARK: - Feedback Icon

struct RokaFeedbackIcon: View {
    let isCorrect: Bool
    var body: some View {
        Image(systemName: isCorrect ? "checkmark" : "xmark")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(isCorrect ? RokaColor.correct : RokaColor.wrong)
            .accessibilityLabel(isCorrect ? "Correct" : "Incorrect")
            .transition(.scale(scale: 0.4).combined(with: .opacity))
    }
}

// MARK: - Timer Bar

struct TimerBarView: View {
    let progress: Double

    private var barColor: Color {
        if progress > 0.5  { return RokaColor.correct }
        if progress > 0.25 { return Color.orange }
        return RokaColor.wrong
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3).fill(RokaColor.ink.opacity(0.1))
                RoundedRectangle(cornerRadius: 3)
                    .fill(barColor)
                    .frame(width: geo.size.width * max(0, min(1, progress)))
                    .animation(.linear(duration: 0.05), value: progress)
            }
        }
        .accessibilityLabel("Time remaining: \(Int(progress * 100))%")
    }
}
