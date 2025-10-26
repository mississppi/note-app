import SwiftUI
import CoreData
import Argonautes

struct NoteListSearchArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    @FocusState private var searchFieldFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .foregroundColor(.black) // アイコンの色を黒に設定
                .scaledToFit()
                .frame(width: 18, height: 18)
            
            // Text field for search input
            TextField("Search", text: $viewModel.searchText)
                .textFieldStyle(.plain) // テキストフィールドのスタイルをプレーンに
                .font(.system(size: 18))
                .foregroundColor(.black) // テキストの色を黒に設定
                .focused($searchFieldFocused)
            
        }
        .frame(height: 45)
        .padding(.horizontal, 16) // 左右のパディング
        .padding(.vertical, 8)    // 上下のパディング
        .cornerRadius(8) // 角丸
        .frame(maxWidth: .infinity) // 幅いっぱいに広げる
        .background(Color(hex: "#E0E0E0"))
        .onAppear {
            DispatchQueue.main.async {
                searchFieldFocused = false
            }
        }
    }
}
