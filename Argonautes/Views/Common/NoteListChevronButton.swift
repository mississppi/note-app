import SwiftUI

struct NoteListChevronButton: View {
    let direction: ChevronDirection
    let action: () -> Void
    
    enum ChevronDirection {
        case left
        case right
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.black)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
