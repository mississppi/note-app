import Foundation

enum TagTransitionDirection {
    /// 次のタグへ（右から左へスライド）
    case forward
    
    /// 前のタグへ（左から右へスライド）
    case backward

    /// タグ遷移なし
    case none
}