import SwiftUI

struct NoteRowView: View {
    @ObservedObject var note: Note
//    let note: Note
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
            
            VStack(alignment: .leading, spacing: 4){
                Text(note.title ?? "No Title")
                    .font(.system(size:14, weight: .semibold))
                    .foregroundColor(.primary)
                
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
}
