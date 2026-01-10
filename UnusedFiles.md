# 未使用・空ファイルの調査結果

調査日: 2026 年 1 月 10 日

## ❌ 完全に空のファイル（削除推奨）

以下のファイルは完全に空で、どこからも参照されていません：

### 1. CustomTextEditor.swift

**パス**: `Argonautes/Views/Utilities/CustomTextEditor.swift`

- **状態**: 空ファイル
- **参照**: なし（README.md の記載のみ）
- **推奨**: **削除**

### 2. FocusField.swift

**パス**: `Argonautes/Views/Utilities/FocusField.swift`

- **状態**: 空ファイル
- **参照**: なし（README.md の記載のみ）
- **推奨**: **削除**

### 3. AttributedMarkdownEditorView.swift

**パス**: `Argonautes/Views/Detail/AttributedMarkdownEditorView.swift`

- **状態**: ほぼ空（コメントのみ）
- **参照**: なし（README.md の記載のみ）
- **推奨**: **削除**
- **備考**: 作成日 2025/10/26 のまま放置されている

## ⚠️ 未使用のファイル（実装はあるが参照なし）

### 1. MarkdownEditorView.swift

**パス**: `Argonautes/Views/Detail/MarkdownEditorView.swift`

- **状態**: 実装済み（75 行）
- **内容**: Markdown プレビュー機能付きエディタ
- **参照**: なし（どの View からも使われていない）
- **推奨**:
  - 使う予定があれば **保持**
  - 使わないなら **削除**
  - `NoteDetailContentArea.swift` で通常の `TextEditor` が使われている

**実装内容**:

```swift
- Markdown → AttributedString 変換
- プレビュー表示のトグル機能
- Show/Hide Preview ボタン
```

## ✅ 使用されているが参照が少ないファイル

以下は実装されていて、適切に使用されています：

### Note+Accessors.swift

- **使用箇所**: 1 箇所（`NoteRowView.swift`）
- **機能**: `displayTitle` プロパティの提供
- **推奨**: **保持**（有用な拡張）

### すべての Enum・定数ファイル

以下はすべて適切に使用されています：

- ✅ `TagError.swift` - 19 箇所で使用
- ✅ `DetailContentType.swift` - 13 箇所で使用
- ✅ `TagTransitionDirection.swift` - 7 箇所で使用
- ✅ `NoteListViewModelConstants.swift` - 7 箇所で使用

### Utilities

- ✅ `Color+Extensions.swift` - 12 箇所で使用（hex color 初期化）
- ✅ `View+Extensions.swift` - 2 箇所で使用（TransparentTitleBarModifier）

### Common Components

- ✅ `NoteListChevronButton.swift` - タグナビゲーションで使用

## 📊 削除推奨ファイルサマリー

```
削除推奨: 3ファイル
├── CustomTextEditor.swift (空)
├── FocusField.swift (空)
└── AttributedMarkdownEditorView.swift (空)

検討が必要: 1ファイル
└── MarkdownEditorView.swift (未使用だが実装済み)
```

## 🔧 アクション推奨事項

### 即座に削除して OK

```bash
# 空ファイルの削除
rm Argonautes/Views/Utilities/CustomTextEditor.swift
rm Argonautes/Views/Utilities/FocusField.swift
rm Argonautes/Views/Detail/AttributedMarkdownEditorView.swift
```

### 要検討

1. **MarkdownEditorView.swift**

   - 実装が完成しているので、今後使う予定があるか確認
   - 使わないなら削除
   - 使うなら `NoteDetailContentArea.swift` で統合

2. **README.md と Develop.md の更新**
   - 削除したファイルの記載を削除
   - ディレクトリ構造図を更新

## 📝 テストファイルについて

### ExampleTests.swift

**パス**: `ArgonautesTests/ExampleTests.swift`

- **状態**: サンプルテスト（Hello World 程度）
- **推奨**: 削除しても OK（他に実際のテストがある）
- **備考**: 本物のテストは以下に存在
  - `CoreDataNoteServiceTests.swift`
  - `TagServiceTests.swift`
  - `NoteListViewModelTests.swift`
  - `TagFilteringInNoteListTests.swift`
  - `NoteListViewTests.swift`

## 📈 クリーンアップ後の効果

- **削除ファイル数**: 3〜4 ファイル
- **コードベースの明確化**: ✅
- **メンテナンス性**: ↑ 向上
- **混乱の軽減**: ✅
