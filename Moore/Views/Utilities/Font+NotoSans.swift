//
//  Font+NotoSans.swift
//  Moore
//
//  Created on 2026-02-21.
//

import SwiftUI

extension Font {
    /// Noto Sans JP フォント（Variable Font）
    /// - Parameters:
    ///   - size: フォントサイズ
    ///   - weight: フォントウェイト（.thin から .black まで対応）
    static func notoSansJP(_ size: CGFloat, weight: Weight = .regular) -> Font {
        return .custom("Noto Sans JP", size: size)
            .weight(weight)
    }
    
    /// Noto Sans JP フォント（固定サイズ）
    static var notoSansJPBody: Font {
        notoSansJP(16)
    }
    
    static var notoSansJPTitle: Font {
        notoSansJP(24, weight: .bold)
    }
    
    static var notoSansJPHeadline: Font {
        notoSansJP(20, weight: .semibold)
    }
    
    static var notoSansJPCaption: Font {
        notoSansJP(12)
    }
}
