import SwiftUI

/// ゴミ箱が空の時の表示View
struct TrashEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("ゴミ箱は空です")
                .font(.system(size: 18))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
