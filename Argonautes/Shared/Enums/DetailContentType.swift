import Foundation
import SwiftUI

enum DetailContentType{
    /// ノート詳細を表示
    /// - selectedNote が存在する場合
    case noteDetail

    /// ゴミ箱ガイドを表示
    /// - isShowingTrash が true で、何も選択されていない場合
    case trashGuide
    
    /// ゴミ箱のノート詳細を表示
    /// - isShowingTrash が true で、selectedTrashNote が存在する場合
    case trashNoteDetail

    /// 空の状態を表示
    /// - ノートが選択されていない場合
    case empty

    @ViewBuilder
    func view(viewModel: NoteListViewModel) -> some View {
        switch self {
            case .trashGuide:
                TrashDetailView(viewModel: viewModel)
            case .trashNoteDetail:
                TrashNoteDetailView(viewModel: viewModel)
            case .noteDetail:
                NoteDetailContentView(viewModel: viewModel)
            case .empty:
                EmptyNoteView(viewModel: viewModel)
        }
    }
}