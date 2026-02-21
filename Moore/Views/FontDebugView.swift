//
//  FontDebugView.swift
//  Moore
//
//  Created on 2026-02-21.
//

import SwiftUI
import AppKit

/// フォントのデバッグ情報表示
struct FontDebugView: View {
    @State private var availableFonts: [String] = []
    @State private var notoSansFound = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("フォントデバッグ情報")
                .font(.headline)
            
            if notoSansFound {
                Text("✅ Noto Sans JP が見つかりました")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Text("❌ Noto Sans JP が見つかりません")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            
            Button("システムフォントを確認") {
                checkFonts()
            }
            
            if !availableFonts.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("「Noto」を含むフォント:")
                            .font(.headline)
                        
                        ForEach(availableFonts.filter { $0.contains("Noto") }, id: \.self) { font in
                            Text(font)
                                .font(.caption)
                                .textSelection(.enabled)
                        }
                        
                        Divider().padding(.vertical)
                        
                        Text("すべてのフォント（最初の50個）:")
                            .font(.headline)
                        
                        ForEach(Array(availableFonts.prefix(50)), id: \.self) { font in
                            Text(font)
                                .font(.caption)
                                .textSelection(.enabled)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 400)
            }
        }
        .padding()
        .frame(width: 500, height: 600)
        .onAppear {
            checkFonts()
        }
    }
    
    private func checkFonts() {
        let fontManager = NSFontManager.shared
        availableFonts = fontManager.availableFontFamilies.sorted()
        notoSansFound = availableFonts.contains { $0.contains("Noto Sans JP") }
        
        print("=== フォントデバッグ情報 ===")
        print("Noto Sans JP が見つかりました: \(notoSansFound)")
        
        let notoFonts = availableFonts.filter { $0.contains("Noto") }
        if !notoFonts.isEmpty {
            print("Notoフォント: \(notoFonts)")
        } else {
            print("Notoフォントが1つも見つかりません")
        }
    }
}

#Preview {
    FontDebugView()
}
