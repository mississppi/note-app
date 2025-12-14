import SwiftUI
import CoreData

/// ゴミ箱のノート一覧を表示するView
struct TrashListView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            //header
            HStack {
                Text("ゴミ箱")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.leading, 24)
                Spacer()

            }
            .frame(height: 60)

            Divider()

            if viewModel.trashedNotes.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "trash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("ゴミ箱は空です")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.trashedNotes, id: \.self) { note in 
                    TrashRowView(note: note, viewModel: viewModel)
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            viewModel.fetchTrashedNotes()
        }
    }

}