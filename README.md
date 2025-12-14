# Argonautes

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
