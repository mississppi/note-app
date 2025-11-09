import SwiftUI
import CoreData

/// archiveされたノートの一覧を表示するView
/// 
/// 
struct ArchiveListView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            //header
            HStack {
                Text("アーカイブ")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                Spacer()

            }
            .frame(height: 60)

            Divider()

            if viewModel.archivedNotes.isEmpty {
                VStack(spacing: 16) {
            //         Image(systemName: "trash")
            //             .font(.system(size: 60))
            //             .foregroundColor(.gray)

                    Text("ゴミ箱はからです")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
            //     .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.archivedNotes, id: \.self) { note in 
                    ArchiveRowView(note: note, viewModel: viewModel)
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            viewModel.fetchArchivedNotes()
        }
    }

}