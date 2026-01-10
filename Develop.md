# Argonautes - 開発ドキュメント

## 🚀 開発環境のセットアップ

### 必要な環境
- **macOS**: 13.0以上推奨
- **Xcode**: 最新版
- **Swift**: 5.9以上

### プロジェクトのビルド方法

1. Xcodeでプロジェクトを開く
```bash
open Argonautes.xcodeproj
```

2. ビルドターゲットを選択（通常は「My Mac」）

3. Command + B でビルド、または Command + R で実行

## 🧪 テストの実行

### ユニットテストの実行
```bash
# Xcodeで Command + U を実行
# または個別のテストファイルから実行
```

### テストファイルの場所
- `ArgonautesTests/` - すべてのテストファイル
  - `Services/` - サービス層のテスト
  - `ViewModels/` - ViewModel層のテスト

## 📦 依存関係

このプロジェクトは外部依存がなく、標準のSwiftUIとCore Dataフレームワークのみを使用しています。

## 🏛️ コードベースの詳細

### 主要なコンポーネント

#### 1. Core Data モデル
**場所**: `Argonautes/Models/Argonautes.xcdatamodeld/`

エンティティ：
- **Note**: ノート本体
  - `id`: UUID
  - `title`: String
  - `content`: String
  - `createdAt`: Date
  - `updatedAt`: Date
  - `isTrashed`: Bool (論理削除フラグ)
  - `tags`: 関連するTagのSet

- **Tag**: タグ
  - `id`: UUID
  - `name`: String
  - `color`: String
  - `notes`: 関連するNoteのSet

#### 2. Service層
**プロトコル**: `Services/Protocols/NoteDataService.swift`
- ノート操作の抽象インターフェースを定義

**実装**: `Services/Implementations/CoreDataNoteService.swift`
- Core Dataを使用した具体的な実装
- CRUD操作（Create, Read, Update, Delete）
- タグフィルタリング
- 検索機能

#### 3. ViewModel層
**主要ファイル**: `ViewModels/NoteListViewModel.swift`

責務：
- ノートの一覧管理
- 検索テキストの管理
- タグフィルタリング
- ゴミ箱/通常ノートの切り替え

主要なプロパティ：
```swift
@Published var notes: [Note]          // 表示するノート一覧
@Published var searchText: String     // 検索テキスト
@Published var selectedTag: Tag?      // 選択中のタグ
@Published var trashedNotes: [Note]   // ゴミ箱のノート
```

#### 4. Views
詳細は [README.md](README.md) のプロジェクト構成を参照

## 🔄 データフローの詳細

### ノート作成の流れ

```
1. User: NoteDetailAddNoteButton をタップ
         ↓
2. View: viewModel.createNote() を呼び出し
         ↓
3. ViewModel: noteService.createNote(title:content:) を呼び出し
         ↓
4. Service: Core Dataに新しいNoteエンティティを作成
         ↓
5. Service: context.save() でデータを永続化
         ↓
6. Service: 作成したNoteを返す
         ↓
7. ViewModel: @Published var notes を更新
         ↓
8. View: 自動的に再描画され、新しいノートが表示される
```

### タグフィルタリングの流れ

```
1. User: TagDisplayView でタグをタップ
         ↓
2. View: viewModel.selectedTag = tag を設定
         ↓
3. ViewModel: selectedTag が変更されたことを検知（didSet）
         ↓
4. ViewModel: fetchNotes() を呼び出し
         ↓
5. ViewModel: 選択されたタグを含む述語を作成
         ↓
6. Service: 述語に基づいてフィルタリングされたノートを取得
         ↓
7. ViewModel: @Published var notes を更新
         ↓
8. View: フィルタリングされたノート一覧が表示される
```

### ゴミ箱機能の流れ

```
1. User: ノートを削除（ゴミ箱に移動）
         ↓
2. View: viewModel.deleteNote(note) を呼び出し
         ↓
3. ViewModel: noteService.trashNote(note) を呼び出し
         ↓
4. Service: note.isTrashed = true に設定
         ↓
5. Service: context.save() で保存
         ↓
6. ViewModel: fetchNotes() を再度呼び出し
         ↓
7. View: ノートが一覧から消える（ゴミ箱に移動）
```

## 🐛 デバッグ

### デバッグログの種類

プロジェクトでは以下の絵文字でログを分類しています：

- 🔵 - ViewModel初期化・ライフサイクル
- 🔴 - データフェッチ関連
- 🟡 - Service層（Core Data操作）
- 🟢 - View表示関連

### よくある問題と解決策

#### 問題1: ノートが表示されない

**確認ポイント**:
1. Core Dataにノートが存在するか
   ```
   🟡 Fetched 0 notes from Core Data  ← 0件の場合は新規作成が必要
   ```

2. すべてゴミ箱に入っていないか
   ```
   🟡 Note 0: title='テスト1', isTrashed=true
   ```

3. タグフィルタが有効になっていないか
   ```
   🔴 selectedTag: Some Tag
   ```

#### 問題2: Core Dataエラー

**デバッグ方法**:
- Xcodeのデータモデルエディタでスキーマを確認
- シミュレータをリセットしてデータを初期化
  ```bash
  # シミュレータのメニュー: Device > Erase All Content and Settings
  ```

#### 問題3: ViewModelが更新されない

**確認事項**:
- `@Published` プロパティが正しく設定されているか
- `ObservableObject` プロトコルに準拠しているか
- Viewで `@StateObject` または `@ObservedObject` を使用しているか

## 📝 コーディング規約

### ファイル命名規則
- **Views**: `<機能名>View.swift` (例: `NoteListView.swift`)
- **ViewModels**: `<機能名>ViewModel.swift` (例: `NoteListViewModel.swift`)
- **Services**: `<実装方法><機能名>Service.swift` (例: `CoreDataNoteService.swift`)
- **Extensions**: `<型名>+<機能>.swift` (例: `Note+Accessors.swift`)

### ディレクトリ構成ルール
- 機能ごとにディレクトリを分ける
- 関連するファイルはサブディレクトリにまとめる
- 最大3階層まで（深すぎる階層を避ける）

### SwiftUIコーディングスタイル
- 小さなViewコンポーネントに分割する
- `@State`, `@Binding`, `@Published` を適切に使い分ける
- プレビューを積極的に活用する

## 🔨 今後の開発予定

### 機能追加候補
- [ ] iCloud同期
- [ ] Markdown プレビュー
- [ ] エクスポート機能（PDF、HTML）
- [ ] ダークモード対応の強化
- [ ] ショートカットキーのカスタマイズ
- [ ] ノートのソート機能

### リファクタリング候補
- [ ] タグサービスの分離（現在はNoteServiceに含まれている）
- [ ] ViewModelのテストカバレッジ向上
- [ ] 非同期処理の最適化（async/await対応）

## 📚 参考リソース

### Apple公式ドキュメント
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)
- [Combine Framework](https://developer.apple.com/documentation/combine)

### プロジェクト固有の情報
- [README.md](README.md) - プロジェクト概要とファイル構成
- [デバッグログの詳細](README.md#デバッグログの見方) - トラブルシューティング情報

## 📌 メモ

### Archive → Trash リファクタリング履歴

過去に「アーカイブ」という名称を「ゴミ箱」に変更するリファクタリングが行われました：

| Before                     | After                    |
| -------------------------- | ------------------------ |
| `archivedNotes`            | `trashedNotes`           |
| `fetchArchivedNotes()`     | `fetchTrashedNotes()`    |
| `isArchived`               | `isTrashed`              |

この変更により、UIとコードの意図がより明確になりました。
