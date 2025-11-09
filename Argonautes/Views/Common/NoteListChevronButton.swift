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
            // ZStack {
            //     Color.clear
            //     .frame(width: 44, height: 44)
            //     .contentShape(Rectangle())

            //     Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
            //         .resizable()
            //         .scaledToFit()
            //         .frame(width: 24, height: 24)
            //         .foregroundColor(.black)
            // }
            HStack {
                if direction == .right { Spacer(minLength: 0) }
                Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .padding(direction == .left ? .leading : .trailing, 2)
                if direction == .left { Spacer(minLength: 0 )}
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(direction == .left ? "前のタグ" : "次のタグ")
    }
}
