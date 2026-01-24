import SwiftUI
import AppKit

struct NoteDetailContentArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        CustomTextEditor(
            text: $viewModel.selectedContent,
            font: NSFont(name: "HiraginoSans-W3", size: 15)
            // backgroundColor: NSColor(Color(hex: "#F2F2F7"))
            // backgroundColor: NSColor(Color.white)
        )
        .padding()
    }
}
