Swift 1 分メンテナンス・ドリル（個人開発者向け）
このドリルは、普段 Python, PHP, TypeScript を使いながら、個人開発で Swift (macOS Desktop App) を書いているエンジニアが、「Swift 特有の作法」を忘れないためのものです。

月曜日：Optional 型の安全な取り出し（if let / guard let）
Swift で最も重要な「型安全」の基礎です。他言語のように null を直接触らせない仕組みを復習します。

練習コード:

Swift

let name: String? = "Swift"

// 1. if let: スコープの中でだけ使う
if let safeName = name {
print("Hello, \(safeName)")
}

// 2. guard let: 早期リターン（関数内で使用）
func greet() {
guard let safeName = name else { return }
print("Hi, \(safeName)")
}
ポイント: TS や PHP の「null チェック」を Swift では「安全な箱からの取り出し」と捉えます。

火曜日：?? 演算子（Nil Coalescing）
オプショナルな値が nil だった時のデフォルト値を 1 行で決める、非常に便利な記法です。

練習コード:

Swift

let input: String? = nil
let displayName = input ?? "Guest"
ポイント: Python の value or "default" に相当しますが、Swift は型に厳しいため、この ?? が多用されます。

水曜日：クロージャの省略記法（$0）
配列の操作（map, filter 等）で、引数名を省略して $0 と書く Swift らしい「手癖」を維持します。

練習コード:

Swift

let scores = [10, 20, 30]
let doubled = scores.map { $0 _ 2 }
ポイント: JavaScript の scores.map(s => s _ 2) と同じですが、Swift では最初の引数を $0 と呼びます。

木曜日：計算済みプロパティ（Computed Property）
メソッドではなく、変数のように振る舞うプロパティです。SwiftUI で多用します。

練習コード:

Swift

struct User {
var firstName: String
var lastName: String

    // 読み取り専用。get { } を省略できる
    var fullName: String {
        "\(firstName) \(lastName)"
    }

}
ポイント: 毎回計算が必要な値は、関数にするよりもプロパティにするのが Swift 流です。

金曜日：後置クロージャ（Trailing Closure）
関数の最後の引数がクロージャの場合、カッコの外に出して { } を書くルールです。初見だと「どこのブロック？」と混乱しがちな部分です。

練習コード:

Swift

func performAction(name: String, action: () -> Void) {
print("Executing \(name)")
action()
}

// カッコの外に { } を出す
performAction(name: "Test") {
print("Done!")
}
ポイント: SwiftUI の Button(action: {}) { Text("") } など、あらゆる場所で使われます。

土曜日：Enum と Switch の網羅性
Swift の Enum は他言語より強力です。associated value（付随する値）を持てるのが特徴です。

練習コード:

Swift

enum Result {
case success(String)
case failure(Int)
}

let status = Result.success("データを取得しました")

switch status {
case .success(let message):
print(message)
case .failure(let code):
print("Error: \(code)")
}
ポイント: switch 文はすべてのケースを網羅していないとコンパイルエラーになります。

日曜日：SwiftUI の @State と $（Binding）
デスクトップアプリの UI 更新の鍵です。変数と UI 部品を「繋ぐ」感覚を復習します。

練習コード:

Swift

import SwiftUI

struct MyView: View {
@State private var isOn = false

    var body: some View {
        // $ をつけることで「値を渡す」のではなく「連動（Binding）させる」
        Toggle("設定", isOn: $isOn)
    }

}
ポイント: $マーク がつくのは「その UI 部品が値を書き換える可能性があるとき」です。
