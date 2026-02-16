import SwiftUI

struct TrashRow: View {
    let note: Note
    @ObservedObject var viewModel: NoteListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title ?? "無題")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)

            Text(note.formattedTrashedDate)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
}