import SwiftUI
import CoreData
import UniformTypeIdentifiers
import Combine

struct NoteListContent: View {
    @ObservedObject var viewModel: NoteListViewModel
    @State private var draggedNote: Note?
    
    private var selectionBinding: Binding<Note?> {
        Binding<Note?>(
            get: { viewModel.selectedNote },
            set: { new in
                Task {
                    await MainActor.run {
                        // ゴミ箱表示中なら閉じる
                        viewModel.selectNote(
                            new,
                            closeTrashIfNeeded: true,
                            userInitiated: false
                        )
                    }
                }
            }
        )
    }
    
    var body: some View {
        List {
            ForEach(viewModel.notes, id: \.self) { note in
                NoteRowView(note: note)
                    .contentShape(Rectangle())
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(
                        viewModel.selectedNote?.objectID == note.objectID 
                            ? Color(hex: "#E6E6E6") 
                            : Color.clear
                    )
                    .opacity(draggedNote?.objectID == note.objectID ? 0.5 : 1.0)
                    .scaleEffect(draggedNote?.objectID == note.objectID ? 0.98 : 1.0)
                    .animation(.easeInOut(duration:0.2), value: draggedNote)
                    .onTapGesture {
                        viewModel.selectNote(
                            note,
                            closeTrashIfNeeded: true,
                            userInitiated: true
                        )
                    }
                    .onDrag {
                        self.draggedNote = note
                        return NSItemProvider(object: note.objectID.uriRepresentation().absoluteString as NSString)
                    }
                    .onDrop(of: [.text], delegate: NoteDropDelegate(
                        note: note,
                        draggedNote: $draggedNote,
                        viewModel: viewModel
                    ))
                    .contextMenu {
                        NoteListArchiveButton(viewModel: viewModel, note: note)
                    }
            }
            .onMove { fromOffsets, toOffset in
                viewModel.moveNotes(fromOffsets: fromOffsets, toOffset: toOffset)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "EFEFEF"))
    }
}

struct NoteDropDelegate: DropDelegate {
    let note: Note
    @Binding var draggedNote: Note?
    let viewModel: NoteListViewModel

    func performDrop(info: DropInfo) -> Bool {
        draggedNote = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func dropEntered(info: DropInfo){
        guard let draggedNote = draggedNote,
                draggedNote != note,
                let from = viewModel.notes.firstIndex(of: draggedNote),
                let to = viewModel.notes.firstIndex(of: note) else {
            return
        }

        withAnimation(.easeInOut(duration: 0.25)){
            viewModel.moveNotes(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }
}