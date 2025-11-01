import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct NoteListNoteArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    private var selectionBinding: Binding<Note?> {
        Binding<Note?>(
            get: { viewModel.selectedNote },
            set: { new in
                Task {
                    await MainActor.run {
                        viewModel.select(note: new, userInitiated: true)
                    }
                }
            }
        )
    }
    
    var body: some View {
        List(viewModel.notes, id: \.self, selection: selectionBinding) { note in
            NoteRowView(note: note)
                .contextMenu {
                    NoteListArchiveButton(viewModel: viewModel, note: note)
                }
                .onDrag {
                    let idString = note.objectID.uriRepresentation().absoluteString
                    return NSItemProvider(object: idString as NSString)
                }
                .onDrop(of: [UTType.plainText], isTargeted: nil) { providers in
                    guard let provider = providers.first else { return false }
                    provider.loadObject(ofClass: NSString.self) { (nsstr, error) in
                        guard let idString = nsstr as? String else { return }
                        Task {
                            await MainActor.run {
                                guard
                                   let fromIndex = viewModel.notes.firstIndex(where: {
                                       $0.objectID.uriRepresentation().absoluteString == idString
                                   }),
                                   let toIndex = viewModel.notes.firstIndex(of: note)
                               else { return }
   
                               withAnimation {
                                   let adjustedTo = toIndex > fromIndex ? toIndex + 1 : toIndex
                                   viewModel.moveNotes(fromOffsets: IndexSet(integer: fromIndex), toOffset: adjustedTo)
//                                   viewModel.notes.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: adjstedTo)
                               }
                            }
                        }
                    }
                    return true
                }
        }
        
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "EFEFEF"))
        .onAppear{
            viewModel.fetchNotes()
        }
    }
}
