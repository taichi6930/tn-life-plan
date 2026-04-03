# 人生計画アプリ (Life Planning App)

## 開発セットアップ

### Pre-commit Hooks の有効化

コード品質をチェックするために pre-commit を設定してください：

```bash
# 1. Pre-commit をインストール
pip install pre-commit

# 2. Git hooks をセットアップ
pre-commit install

# 3. 動作確認
pre-commit run --all-files
```

詳細は [PRE_COMMIT_SETUP.md](docs/PRE_COMMIT_SETUP.md) を参照してください。

### テスト実行

```bash
dart test --coverage=coverage
```

### 静的解析・フォーマット確認

```bash
dart analyze
dart format --set-exit-if-changed .
```
