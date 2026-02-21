//
//  FontTestView.swift
//  Moore
//
//  Created on 2026-02-21.
//

import SwiftUI

/// フォントテスト用のView（開発中のみ使用）
struct FontTestView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("フォント比較テスト")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity)
                
                Divider()
                
                // 日本語比較
                comparisonSection(
                    title: "日本語",
                    text: "あいうえお 漢字 カタカナ",
                    size: 24
                )
                
                // 英語比較
                comparisonSection(
                    title: "英語",
                    text: "The quick brown fox",
                    size: 24
                )
                
                // 特徴的な文字
                comparisonSection(
                    title: "特徴的な文字",
                    text: "あき Q g 0 O",
                    size: 32
                )
                
                Divider()
                
                // ウェイト比較
                VStack(alignment: .leading, spacing: 15) {
                    Text("Noto Sans JP - ウェイト比較")
                        .font(.system(size: 18, weight: .bold))
                    
                    Group {
                        Text("Thin (100)")
                            .font(.notoSansJP(20, weight: .thin))
                        Text("Light (300)")
                            .font(.notoSansJP(20, weight: .light))
                        Text("Regular (400)")
                            .font(.notoSansJP(20, weight: .regular))
                        Text("Medium (500)")
                            .font(.notoSansJP(20, weight: .medium))
                        Text("Semibold (600)")
                            .font(.notoSansJP(20, weight: .semibold))
                        Text("Bold (700)")
                            .font(.notoSansJP(20, weight: .bold))
                        Text("Heavy (800)")
                            .font(.notoSansJP(20, weight: .heavy))
                        Text("Black (900)")
                            .font(.notoSansJP(20, weight: .black))
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func comparisonSection(title: String, text: String, size: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Noto Sans JP:")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                        .frame(width: 120, alignment: .leading)
                    Text(text)
                        .font(.notoSansJP(size))
                }
                
                HStack {
                    Text("システム:")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .frame(width: 120, alignment: .leading)
                    Text(text)
                        .font(.system(size: size))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
    }
}

#Preview {
    FontTestView()
}
