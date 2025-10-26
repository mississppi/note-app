import SwiftUI

struct MarkdownEditorView: View {
    @ObservedObject var viewModel: NoteListViewModel
    @State private var showPreviewOverlay: Bool = true

    // Markdown -> AttributedString を安全に生成（エラーはログ出力）
    private func attributed(from markdown: String) -> AttributedString? {
        if #available(iOS 15.0, macOS 12.0, *) {
            do {
                return try AttributedString(markdown: markdown)
            } catch {
                print("Sttributestring", error)
                debugPrint("AttributedString(markdown:) failed:", error)
                return nil
            }
        } else {
            // 古い OS の場合は nil を返してプレーンテキスト表示にする
            print("old os")
            debugPrint("AttributedString(markdown:) is unavailable on this OS version")
            return nil
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: { showPreviewOverlay.toggle() }) {
                    Text(showPreviewOverlay ? "Hide Preview" : "Show Preview")
                }
                Spacer()
            }
            .padding(.horizontal, 8)

            ZStack {
                if showPreviewOverlay {
                    ScrollView {
                        Group {
                            if let attr = attributed(from: viewModel.selectedContent) {
                                // AttributedString の属性を尊重するので .font は付けない
                                Text(attr)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                            } else {
                                Text(viewModel.selectedContent)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                            }
                        }
                    }
                    .background(Color.clear)
                    .allowsHitTesting(false) // 編集操作は下の TextEditor に通す
                }

                // TextEditor の見た目をプレビューに合わせるための簡易調整
//                TextEditor(text: $viewModel.selectedContent)
//                    .font(.body)
//                    .padding(8)
//                    .background(Color.clear)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 4)
//                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            print("showPreviewOverlay (onAppear):", showPreviewOverlay)
        }
        .onChange(of: showPreviewOverlay) { newValue in
            print("showPreviewOverlay changed:", newValue)
        }
    }
}
