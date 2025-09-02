import SwiftUI

struct NoteListAddTagButton: View {
    
    var body: some View {
        Button(action: {
            
        }) {
            HStack(spacing: 8){
                Image(systemName: "plus")
                Text("Add Tag")
                Spacer()
            }
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.black)
                .frame(height: 45)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color(hex: "cococo"), lineWidth: 1)
//                )

        }
        .frame(maxWidth: .infinity)
//        .padding(.horizontal, 10)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "cococo"), lineWidth: 1)
        )
    }
}
