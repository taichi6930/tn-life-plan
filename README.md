# 人生計画アプリ (Life Planning App)

個人の人生計画をサポートするアプリケーションです。年金計算、資産管理、ライフプラン分析など、人生全体の最適化をサポートします。

## プロジェクト概要

### 目的
- 人生全体を通じた資産・収入管理
- 年金計算と長期資金計画
- ライフアクティビティの可視化と最適化

### 技術スタック
- **Web**: React/Vue + Cloudflare (Workers + D1 SQLite)
- **モバイル**: React Native または Swift/Kotlin
- **バックエンド**: Cloudflare Workers

### 実行計画
4 ユニットに分解して実装：

1. **Unit 1**: Shared Business Logic - 年金計算エンジン
2. **Unit 2**: Web 版実装 - React/Vue + Cloudflare
3. **Unit 3**: iOS 版実装 - Swift または React Native
4. **Unit 4**: Android 版実装 - Kotlin または React Native

## プロジェクト構成

```
tn-life-plan/
├── README.md
├── .gitignore
├── docs/
│   └── BRANCHING_STRATEGY.md    # Git ブランチ戦略
├── packages/                    # モノレポ構成
│   ├── core/                    # ビジネスロジック（Unit 1）
│   ├── web/                     # Web版（Unit 2）
│   ├── ios/                     # iOS版（Unit 3）
│   └── android/                 # Android版（Unit 4）
└── ...
```

## セットアップ

### 前提条件
- Git 2.53.0 以上
- Node.js 18.x 以上（Web・共通ロジック向け）
- Swift 5.9+（iOS向け）
- Kotlin 1.9+（Android向け）

### インストール

```bash
# リポジトリをクローン
git clone https://github.com/taichi6930/tn-life-plan.git
cd tn-life-plan

# 依存関係をインストール
npm install
```

## ブランチ戦略

GitHub Flow を採用しています。詳細は [docs/BRANCHING_STRATEGY.md](docs/BRANCHING_STRATEGY.md) を参照してください。

### ブランチ命名規則

```
feature/<issue-number>-<短い説明>
bugfix/<issue-number>-<短い説明>
hotfix/<description>
```

### 例

```bash
# ブランチ作成と開発
git checkout -b feature/1-initial-setup
# ... 開発 ...
git add .
git commit -m "feat: 初期プロジェクト構成を追加"
git push origin feature/1-initial-setup

# GitHub で PR を作成
```

## ドキュメント

- [ブランチ戦略](docs/BRANCHING_STRATEGY.md)

## ライセンス

MIT License

## 連絡先

- 開発者: taichi
- GitHub: [taichi6930](https://github.com/taichi6930)
