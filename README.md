# Argonautes

macOS向けのMarkdown対応ノート管理アプリケーションです。Core DataとSwiftUIを使用して構築されています。

## 📁 プロジェクト構成

### ルート構造

```
Argonautes/
├── Argonautes/              # メインアプリケーションソース
├── Argonautes.xcodeproj/    # Xcodeプロジェクトファイル
├── ArgonautesTests/         # ユニットテスト
└── README.md                # このファイル
```

### Argonautes/ ディレクトリ詳細

```
Argonautes/
├── ArgonautesApp.swift                  # アプリケーションエントリーポイント
├── Persistence.swift                    # Core Dataスタック設定
├── Argonautes.entitlements             # アプリケーション権限設定
│
├── Models/                              # データモデル層
│   ├── Argonautes.xcdatamodeld/        # Core Dataモデル定義
│   ├── Enums/
│   │   └── TagError.swift              # タグ関連のエラー定義
│   └── Note/
│       └── Note+Accessors.swift        # Noteエンティティの拡張
│
├── Services/                            # ビジネスロジック層
│   ├── Protocols/
│   │   └── NoteDataService.swift       # ノートサービスのプロトコル
│   └── Implementations/
│       └── CoreDataNoteService.swift   # Core Data実装
│
├── ViewModels/                          # ViewModel層
│   └── NoteListViewModel.swift         # ノート一覧のビジネスロジック
│
├── Views/                               # UI層
│   ├── ContentView.swift               # ルートビュー
│   │
│   ├── Common/                         # 共通コンポーネント
│   │   └── NoteListChevronButton.swift # シェブロンボタン
│   │
│   ├── Detail/                         # ノート詳細画面
│   │   ├── NoteDetailView.swift        # 詳細画面メイン
│   │   ├── NoteDetailContentView.swift # コンテンツビュー
│   │   ├── NoteDetailContentArea.swift # コンテンツエリア
│   │   ├── NoteDetailTitleView.swift   # タイトルビュー
│   │   ├── NoteDetailTitleArea.swift   # タイトルエリア
│   │   ├── NoteDetailAddNoteButton.swift # 新規ノート追加ボタン
│   │   ├── MarkdownEditorView.swift    # Markdownエディタ
│   │   ├── AttributedMarkdownEditorView.swift # リッチMarkdownエディタ
│   │   ├── EmptyNoteView.swift         # 空状態表示
│   │   └── TrashDetailView.swift       # ゴミ箱詳細ビュー
│   │
│   ├── NoteList/                       # ノート一覧画面
│   │   ├── NoteListView.swift          # 一覧画面メイン
│   │   │
│   │   ├── List/                       # リスト表示
│   │   │   ├── NoteListContent.swift   # リストコンテンツ
│   │   │   ├── NoteRowView.swift       # ノート行表示
│   │   │   └── NoteListTrashButton.swift # ゴミ箱ボタン
│   │   │
│   │   ├── Search/                     # 検索機能
│   │   │   └── NoteListSearchArea.swift # 検索エリア
│   │   │
│   │   ├── Tag/                        # タグ機能
│   │   │   ├── NoteListTagArea.swift   # タグエリア
│   │   │   ├── NoteListTagView.swift   # タグ表示
│   │   │   ├── NoteListAddTagButton.swift # タグ追加ボタン
│   │   │   ├── TagAddModalView.swift   # タグ追加モーダル
│   │   │   ├── TagEditModalView.swift  # タグ編集モーダル
│   │   │   ├── TagDeleteConfirmationView.swift # タグ削除確認
│   │   │   ├── TagDisplayView.swift    # タグ表示
│   │   │   ├── TagContextMenu.swift    # タグコンテキストメニュー
│   │   │   └── TagContextMenuModifier.swift # メニューモディファイア
│   │   │
│   │   └── Trash/                      # ゴミ箱機能
│   │       ├── NoteListTrashArea.swift # ゴミ箱エリア
│   │       ├── TrashListView.swift     # ゴミ箱一覧
│   │       ├── TrashRow.swift          # ゴミ箱行表示
│   │       ├── TrashDeleteConfirmationModalView.swift # 完全削除確認
│   │       └── TrashRestoreConfirmationModalView.swift # 復元確認
│   │
│   └── Utilities/                      # ユーティリティ
│       ├── Color+Extensions.swift      # Color拡張
│       ├── View+Extensions.swift       # View拡張
│       ├── CustomTextEditor.swift      # カスタムテキストエディタ
│       └── FocusField.swift            # フォーカス管理
│
└── Shared/                             # 共通定義
    ├── Constants/
    │   └── NoteListViewModelConstants.swift # 定数定義
    └── Enums/
        ├── DetailContentType.swift     # 詳細コンテンツタイプ
        └── TagTransitionDirection.swift # タグ遷移方向
```

### ArgonautesTests/ ディレクトリ

```
ArgonautesTests/
├── ExampleTests.swift                  # サンプルテスト
├── NoteListViewTests.swift            # ノート一覧ビューテスト
├── Services/
│   ├── CoreDataNoteServiceTests.swift # サービス層テスト
│   └── TagServiceTests.swift          # タグサービステスト
└── ViewModels/
    ├── NoteListViewModelTests.swift   # ViewModelテスト
    └── TagFilteringInNoteListTests.swift # タグフィルタリングテスト
```

## 🏗️ アーキテクチャ

### レイヤー構成

このプロジェクトはMVVMアーキテクチャを採用しています：

```
┌─────────────────────────────────────┐
│            Views (SwiftUI)          │ ← ユーザーインターフェース
└──────────────┬──────────────────────┘
               │ @Published
               ↓
┌─────────────────────────────────────┐
│          ViewModels                 │ ← プレゼンテーションロジック
└──────────────┬──────────────────────┘
               │ Protocol
               ↓
┌─────────────────────────────────────┐
│     Services (Implementations)      │ ← ビジネスロジック
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│       Models (Core Data)            │ ← データ永続化
└─────────────────────────────────────┘
```

### データフロー

1. **View → ViewModel**: ユーザー操作をViewModelに通知
2. **ViewModel → Service**: データ操作をServiceに委譲
3. **Service → Core Data**: 永続化層へのデータアクセス
4. **Core Data → Service → ViewModel**: データ取得
5. **ViewModel → View**: `@Published`プロパティによる自動更新

## 🔧 主要機能

### ノート管理
- ✏️ Markdown形式でのノート作成・編集
- 🔍 ノート検索機能
- 🗑️ ゴミ箱機能（論理削除）
- 📝 リッチテキストエディタ

### タグ管理
- 🏷️ ノートへのタグ付け
- 🎨 タグごとの色分け
- 🔀 タグによるフィルタリング
- ✏️ タグの追加・編集・削除

### データ永続化
- 💾 Core Dataによるローカルストレージ
- 🔄 リアルタイムデータ同期

## デバッグログの見方

### 起動時のログ（正常な場合）

```
🔵 NoteListViewModel init started
🔵 Calling fetchNotes from init
🔴 fetchNotes called
🔴 searchText: ''
🔴 selectedTag: nil
🔴 trashedPredicate: isTrashed == 0
🔴 finalPredicate: isTrashed == 0
🟡 CoreDataNoteService.fetchNotes
🟡 predicate: isTrashed == 0
🟡 Fetched 5 notes from Core Data
🟡 Note 0: title='テスト1', isTrashed=false
🟡 Note 1: title='テスト2', isTrashed=false
🔴 Fetched 5 notes
🔵 NoteListViewModel init completed, notes count: 5
🟢 NoteListContent appeared
🟢 viewModel.notes count: 5
```

### ノートが表示されない場合の確認ポイント

#### 1. Core Data にノートがない

```
🟡 Fetched 0 notes from Core Data  ← これが原因
```

**解決策**: ノートを作成する

#### 2. 全てのノートがゴミ箱に入っている

```
🟡 Fetched 5 notes from Core Data
🟡 Note 0: title='テスト1', isTrashed=true  ← 全部 true
🟡 Note 1: title='テスト2', isTrashed=true
🔴 Fetched 0 notes  ← フィルタ後は 0 件
```

**解決策**: ノートを復元 or 新規作成

#### 3. タグフィルタで除外されている

```
🔴 selectedTag: Some Tag  ← タグが選択されている
🔴 finalPredicate: tag == <Tag> AND isTrashed == 0
🟡 Fetched 0 notes from Core Data  ← そのタグのノートがない
```

**解決策**: タグを変更 or そのタグのノートを作成

## アーキテクチャ

### ディレクトリ構成

```
Argonautes/
├── Models/
│   └── Enums/
├── Services/
│   ├── Implementations/
│   │   └── CoreDataNoteService.swift
│   └── Protocols/
│       └── NoteDataService.swift
├── ViewModels/
│   └── NoteListViewModel.swift
└── Views/
    ├── Detail/
    ├── NoteList/
    │   ├── List/           # ノート一覧
    │   ├── Search/         # 検索
    │   ├── Tag/            # タグ
    │   └── Trash/          # ゴミ箱
    │       ├── NoteListTrashArea.swift   # ゴミ箱ボタン
    │       ├── TrashListView.swift        # ゴミ箱一覧（メイン）
    │       └── TrashRowView.swift         # ゴミ箱の行
    └── Utilities/
```

### データフロー

```
View → ViewModel → Service → Core Data
  ↑        ↓
  └─ @Published
```

## Archive → Trash リファクタリング

### 変更内容

| Before                     | After                    |
| -------------------------- | ------------------------ |
| `archivedNotes`            | `trashedNotes`           |
| `fetchArchivedNotes()`     | `fetchTrashedNotes()`    |
| `restoreNoteFromArchive()` | `restoreNoteFromTrash()` |
| `isArchived` (Core Data)   | `isTrashed`              |
| `archivedAt` (Core Data)   | `trashedAt`              |
| `NoteStatus.archived`      | ❌ 削除                  |
| `note.status`              | ❌ 削除                  |
| `ArchiveListView`          | `TrashListView`          |
| `ArchiveRowView`           | `TrashRowView`           |

### Core Data モデル

#### Note エンティティ

- ✅ `isTrashed: Boolean` (Default: NO)
- ✅ `trashedAt: Date?`
- ✅ `deletedTagName: String?`
- ❌ `status: String` (削除)

### 削除されたもの

- ❌ `NoteStatus` enum
- ❌ `archiveNote()` メソッド
- ❌ `Archive/` ディレクトリ
- ❌ `ArchiveListView.swift`
- ❌ `ArchiveRowView.swift`

## トラブルシューティング

### ビルドエラー

#### プロトコル準拠エラー

```
error: type 'CoreDataNoteService' does not conform to protocol 'NoteDataService'
```

**解決策**: プロトコルに `trashNote()` を追加

#### `note.isTrashed` が見つからない

```
error: value of type 'Note' has no member 'isTrashed'
```

**解決策**:

1. Core Data モデルに `isTrashed` を追加
2. Cmd + B でビルド

### 実行時エラー

#### ノートが表示されない

**確認手順**:

1. デバッグログを確認
2. Core Data にノートがあるか確認
3. `isTrashed` の値を確認
4. タグフィルタを確認

## 開発メモ

### 今後の改善点

- [ ] Trash を独立した画面に（`Views/Trash/` に移動）
- [ ] エラーハンドリングの強化
- [ ] ユニットテストの追加

###

file:////Library/Containers/XXXXXXX.Argonautes/Data/Library/Application%20Support/Argonautes/Argonautes.sqlite
