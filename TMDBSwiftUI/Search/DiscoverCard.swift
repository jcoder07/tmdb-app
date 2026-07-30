import SwiftUI

struct DiscoverCard: View {
    let title: String
    let symbol: String
    let color: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)

            Image(systemName: symbol)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.white.opacity(0.3))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(10)

            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
