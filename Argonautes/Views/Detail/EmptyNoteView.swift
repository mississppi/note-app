import SwiftUI

struct EmptyNoteView: View {
    var body: some View {
        Text("No Note")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}