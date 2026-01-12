import Foundation
import SwiftUI

/// ゴミ箱一覧の表示コンテンツタイプ
enum TrashContentType {
    /// 空の状態を表示
    case empty
    
    /// ゴミ箱のノート一覧を表示
    case list
    
    @ViewBuilder
    func view(viewModel: NoteListViewModel) -> some View {
        switch self {
        case .empty:
            TrashEmptyStateView()
        case .list:
            TrashNotesListView(viewModel: viewModel)
        }
    }
}
