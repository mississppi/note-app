import Foundation
import SwiftUI

/// ノート一覧エリアの表示コンテンツタイプ
enum ListContentType {
    /// 通常のノート一覧を表示
    case normal
    
    /// ゴミ箱一覧を表示
    case trash
    
    @ViewBuilder
    func view(viewModel: NoteListViewModel) -> some View {
        switch self {
        case .normal:
            VStack(spacing: 8) {
                NoteListTagArea(viewModel: viewModel)
                NoteListSearchArea(viewModel: viewModel)
                Rectangle()
                    .fill(Color.lightBorderColor)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                NotesListArea(viewModel: viewModel)
            }
        case .trash:
            TrashListView(viewModel: viewModel)
        }
    }
}
