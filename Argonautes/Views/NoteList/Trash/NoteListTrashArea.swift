import SwiftUI
import CoreData
import Argonautes

struct NoteListTrashArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        Button(action: {
            viewModel.toggleTrashDisplay()
        }){
            HStack {
                Image(systemName: "trash")
                    .resizable()
                    .foregroundColor(.black)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
                Text("ゴミ箱")
                    .font(.system(size:18, weight: .regular))
                    .foregroundColor(.black)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .buttonStyle(.plain)
        .foregroundColor(.primary)
        .padding(.vertical,6)
        .padding(.horizontal, 16)
//        .background(viewModel.isShowingTrash ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(8) // <-- 角丸を追加


    }
}
