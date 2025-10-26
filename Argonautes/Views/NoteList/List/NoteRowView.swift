import SwiftUI

struct NoteRowView: View {
    @ObservedObject var note: Note
    private let titleLimit: Int = 13
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
            
            VStack(alignment: .leading, spacing: 4){
                Text(truncatedTitle)
                    .font(.system(size:14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(note.updatedAt ?? Date(), style: .date)
                    .font(.system(size:12))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        .frame(height: 55)
        .listRowSeparator(.hidden)
    }
    
    private var truncatedTitle: String {
        let raw = (note.title ?? "No Title").replacingOccurrences(of: "\n", with: " ")
        if raw.count <= titleLimit {return raw}
        return String(raw.prefix(titleLimit)) + "…"
    }
}
