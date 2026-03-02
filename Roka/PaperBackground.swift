import SwiftUI

struct PaperBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.94, blue: 0.91) // warm paper

            // Horizontal ruled lines
            GeometryReader { geo in
                let lineSpacing: CGFloat = 28
                let lineCount = Int(geo.size.height / lineSpacing) + 2
                ForEach(0..<lineCount, id: \.self) { i in
                    Rectangle()
                        .fill(Color(red: 0.29, green: 0.50, blue: 0.76).opacity(0.15))
                        .frame(height: 1)
                        .offset(y: CGFloat(i) * lineSpacing)
                }
            }

            // Red margin line
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 1)
                    .offset(x: 54)
            }
        }
    }
}

#Preview {
    PaperBackground()
}
