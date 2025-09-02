import SwiftUI
import CoreData
import Argonautes

struct NoteListTrashArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
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
        .frame(height:70)
        .padding(.horizontal, 16)
    }
}
