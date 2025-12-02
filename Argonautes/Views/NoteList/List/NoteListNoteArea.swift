import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct NoteListNoteArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    // private var selectionBinding: Binding<Note?> {
    //     Binding<Note?>(
    //         get: { viewModel.selectedNote },
    //         set: { new in
    //             Task {
    //                 await MainActor.run {
    //                     // ゴミ箱表示中なら閉じる
    //                     viewModel.selectNote(
    //                         new,
    //                         closeTrashIfNeeded: true,
    //                         userInitiated: false
    //                     )
    //                 }
    //             }
    //         }
    //     )
    // }
    
    var body: some View {
        List{
            ForEach(viewModel.notes, id: \.self) {
                note in
                NoteRowView(note: note)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectNote(
                            note,
                            closeTrashIfNeeded: true,
                            userInitiated: false
                        )
                    }
                    .contextMenu {
                        NoteListArchiveButton(viewModel: viewModel, note: note)
                    }
                    .listRowBackground(
                        (viewModel.selectedNote?.objectID == note.objectID) ? Color(hex: "#E6E6E6") : Color.clear
                    )
                    // .listRowSeparatorTint(.clear)
            }
            .onMove { fromOffsets, toOffset in
                viewModel.moveNotes(fromOffsets: fromOffsets, toOffset: toOffset)
            }
        }
        // .environment(\.editMode, .constant(.active))  // ← 追加: Edit モードを有効化
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "EFEFEF"))
        // .tint(.clear)
        .onAppear{
            // viewModel.fetchNotes()
        }
    }
}
