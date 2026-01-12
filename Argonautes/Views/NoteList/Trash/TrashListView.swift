import SwiftUI
import CoreData

/// ゴミ箱のノート一覧を表示するView
struct TrashListView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // header
            HStack {
                Text("ゴミ箱")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.leading, 24)
                Spacer()
            }
            .frame(height: 60)

            Divider()

            // 戻るボタン
            Button(action: {
                viewModel.isShowingTrash = false
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14))
                    Text("戻る")
                        .font(.system(size: 14))
                }
                // .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 24)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            viewModel.trashContentType.view(viewModel: viewModel)
            
        }
        .background(Color(hex: "#EFEFEF"))
        .onAppear {
            viewModel.fetchTrashedNotes()
        }
    }

}