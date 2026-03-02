import SwiftUI

struct HowToPlaySheet: View {
    @Binding var isPresented: Bool

    private let rules: [(tag: String, text: String)] = [
        ("REAL",      "The word exists in English — it refers to something genuine, whether tangible or not."),
        ("NOT REAL",  "The word is invented nonsense — a Roka word with no meaning, designed to trick you."),
        ("PHYSICAL",  "The word refers to something real that exists in the physical world — you can see, touch, or hold it. Coffee, bridge, pencil."),
        ("ABSTRACT",  "The word refers to something real but intangible — a concept, feeling, or idea. Freedom, courage, justice."),
    ]

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { withAnimation(.easeOut(duration: 0.22)) { isPresented = false } }

            // Sheet
            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack {
                    Text("How to Play")
                        .font(.custom("AmericanTypewriter-Bold", size: 22))
                        .foregroundColor(Color(red: 0.16, green: 0.12, blue: 0.08))
                        .opacity(0.82)

                    Spacer()

                    Button {
                        withAnimation(.easeOut(duration: 0.22)) { isPresented = false }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(red: 0.16, green: 0.12, blue: 0.08).opacity(0.45))
                            .padding(8)
                            .background(Color.black.opacity(0.05))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 24)

                // Rules
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(rules, id: \.tag) { rule in
                        RuleRow(tag: rule.tag, text: rule.text)
                    }
                }

                // Divider
                Rectangle()
                    .fill(Color(red: 0.16, green: 0.12, blue: 0.08).opacity(0.1))
                    .frame(height: 1)
                    .padding(.vertical, 20)

                // Note
                Text("A word can belong to more than one category. Any correct label counts as a right answer.")
                    .font(.custom("AmericanTypewriter", size: 14))
                    .foregroundColor(Color(red: 0.16, green: 0.12, blue: 0.08).opacity(0.48))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .italic()
            }
            .padding(32)
            .background(
                ZStack {
                    // Paper texture
                    Color(red: 0.96, green: 0.94, blue: 0.91)

                    // Ruled lines
                    GeometryReader { geo in
                        let spacing: CGFloat = 28
                        let count = Int(geo.size.height / spacing) + 2
                        ForEach(0..<count, id: \.self) { i in
                            Rectangle()
                                .fill(Color(red: 0.29, green: 0.50, blue: 0.76).opacity(0.15))
                                .frame(height: 1)
                                .offset(y: CGFloat(i) * spacing)
                        }
                    }

                    // Left margin
                    HStack {
                        Rectangle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 1)
                            .padding(.leading, 44)
                        Spacer()
                    }
                }
            )
            .cornerRadius(6)
            .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 10)
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

struct RuleRow: View {
    let tag: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(tag)
                .font(.custom("AmericanTypewriter-Bold", size: 11))
                .tracking(0.8)
                .foregroundColor(Color(red: 0.16, green: 0.12, blue: 0.08))
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Color(red: 0.83, green: 0.65, blue: 0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color(red: 0.63, green: 0.44, blue: 0.29), lineWidth: 1.5)
                )
                .cornerRadius(3)
                .fixedSize()

            Text(text)
                .font(.custom("AmericanTypewriter", size: 15))
                .foregroundColor(Color(red: 0.16, green: 0.12, blue: 0.08).opacity(0.72))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
