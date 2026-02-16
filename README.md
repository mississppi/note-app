# Moore

macOS向けのシンプルなMarkdownノート管理アプリ

## 特徴

- 📝 Markdown対応のノート作成・編集
- 🏷️ タグによるノート整理
- 🗑️ ゴミ箱機能（削除前の一時保管）
- 🔍 ノート検索
- 💾 Core Dataでのローカルストレージ

## 技術スタック

- SwiftUI
- Core Data
- macOS 14.6+
- MVVM アーキテクチャ

## ビルド

```bash
open Moore.xcodeproj
```

Xcodeでプロジェクトを開いてCommand + Rで実行

## アーキテクチャ

```
View → ViewModel → Service → Core Data
```

- **Views**: SwiftUIビュー
- **ViewModels**: プレゼンテーションロジック
- **Services**: ビジネスロジック（プロトコルベース）
- **Models**: Core Dataエンティティ

## ライセンス

Private project
