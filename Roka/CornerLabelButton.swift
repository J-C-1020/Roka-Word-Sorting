import SwiftUI

struct CornerLabelButton: View {
    let title: String
    let flashState: FlashState
    let action: () -> Void

    enum FlashState {
        case none, correct, wrong
    }

    @State private var isPressed = false

    private var backgroundColor: Color {
        switch flashState {
        case .none:    return Color(red: 0.83, green: 0.65, blue: 0.45)
        case .correct: return Color(red: 0.72, green: 0.87, blue: 0.73)
        case .wrong:   return Color(red: 0.96, green: 0.77, blue: 0.77)
        }
    }

    private var borderColor: Color {
        switch flashState {
        case .none:    return Color(red: 0.63, green: 0.44, blue: 0.29)
        case .correct: return Color(red: 0.23, green: 0.49, blue: 0.27)
        case .wrong:   return Color(red: 0.75, green: 0.22, blue: 0.17)
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("AmericanTypewriter-Bold", size: 13))
                .tracking(1)
                .foregroundColor(Color(red: 0.16, green: 0.12, blue: 0.08))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minWidth: 90)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(borderColor, lineWidth: 2)
                )
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 2, y: 3)
                .scaleEffect(flashState == .correct ? 1.1 : (isPressed ? 0.96 : 1.0))
                .offset(x: flashState == .wrong ? wobbleOffset() : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: flashState)
        .animation(.easeOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }

    private func wobbleOffset() -> CGFloat {
        // Simple static offset; in real app use a keyframe animation
        return 0
    }
}
