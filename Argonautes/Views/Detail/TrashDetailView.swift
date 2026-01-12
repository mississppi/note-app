import SwiftUI

/// ゴミ箱が選択されている時にDetail領域に表示するView
struct TrashDetailView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "trash")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("ゴミ箱")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text("削除したノートはここに保存されます")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            if let countText = viewModel.trashedNotesCountText,
               let guideText = viewModel.trashedNotesGuideText {
                VStack(spacing: 8) {
                    Text(countText)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(guideText)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
    }
}
