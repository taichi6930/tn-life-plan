# Pre-commit Hooks Setup Guide

## インストール手順

### 1. Pre-commit Framework をインストール

```bash
pip install pre-commit
# または
brew install pre-commit  # macOS
```

### 2. Git Hooks をインストール

```bash
pre-commit install
```

### 3. 手動でテスト実行

```bash
pre-commit run --all-files
```

## 設定内容

`.pre-commit-config.yaml` に以下のDart検査が設定されています：

- **dart-analyze**: 静的解析（コード品質チェック）
- **dart-format**: コードフォーマット確認

## 実行タイミング

Git commit 前に自動的に以下が実行されます：

1. 📝 Dart 静的解析
2. 📐 Dart フォーマット確認

エラーがあると commit がブロックされます。

## よく使うコマンド

```bash
# 全ファイルに対してチェック実行
pre-commit run --all-files

# 特定のhookを実行
pre-commit run dart-analyze --all-files

# アンインストール
pre-commit uninstall
```

## トラブルシューティング

### "hook id does not have a language field" エラー
`language: system` が正しく設定されているか確認してください。

### Dart コマンドが見つからない
Dart SDK がインストールされ、PATH に含まれているか確認してください：

```bash
dart --version
```
