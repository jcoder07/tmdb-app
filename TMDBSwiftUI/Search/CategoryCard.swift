import SwiftUI

struct CategoryCard: View {
    let name: String
    let color: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)

            Text(name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
