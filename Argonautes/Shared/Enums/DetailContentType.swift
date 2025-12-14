import Foundation
import SwiftUI

enum DetailContentType{
    /// ノート詳細を表示
    /// - selectedNote が存在する場合
    case noteDetail

    /// ゴミ箱（アーカイブ）一覧を表示
    /// - isShowingTrash が true の場合
    case trashList

    /// 空の状態を表示
    /// - ノートが選択されていない場合
    case empty

    @ViewBuilder
    func view(viewModel: NoteListViewModel) -> some View {
        switch self {
            case .trashList:
                TrashListView(viewModel: viewModel)
            case .noteDetail:
                NoteDetailContentView(viewModel: viewModel)
            case .empty:
                EmptyNoteView(viewModel: viewModel)
        }
    }
}