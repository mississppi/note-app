import SwiftUI

extension Color {
    // MARK: - App Colors
    
    /// ノート詳細エリア（タイトル・本文）の背景色
    static let noteBackground = Color(hex: "#F2F2F7")
    
    /// サイドバー・リストエリアの背景色
    static let listBackground = Color(hex: "#EFEFEF")
    
    /// ノート選択時の背景色
    static let selectedNoteBackground = Color(hex: "#E6E6E6")
    
    /// 検索バーの背景色
    static let searchBarBackground = Color(hex: "#E0E0E0")
    
    /// モーダル・枠線の色
    static let borderColor = Color(hex: "#DDDDDD")
    
    /// 薄い枠線の色
    static let lightBorderColor = Color(hex: "#C0C0C0")
    
    // MARK: - Hex Initializer
    
    /// hex: "#RRGGBB", "RRGGBB", "#RRGGBBAA" などを受け取る
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }

        // 3文字ショートハンドを展開 (e.g. "abc" -> "aabbcc")
        if hex.count == 3 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: Double
        switch hex.count {
        case 6: // RRGGBB
            r = Double((int & 0xFF0000) >> 16) / 255.0
            g = Double((int & 0x00FF00) >> 8) / 255.0
            b = Double(int & 0x0000FF) / 255.0
            a = 1.0
        case 8: // RRGGBBAA
            r = Double((int & 0xFF000000) >> 24) / 255.0
            g = Double((int & 0x00FF0000) >> 16) / 255.0
            b = Double((int & 0x0000FF00) >> 8) / 255.0
            a = Double(int & 0x000000FF) / 255.0
        default:
            // フォールバックは黒
            r = 0; g = 0; b = 0; a = 1
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
