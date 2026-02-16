import SwiftUI

struct TransparentTitleBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear() {
                if let window = NSApplication.shared.windows.first {
                    window.titlebarAppearsTransparent = true
                    window.titleVisibility  = .hidden
                }
            }
    }
}
