# 人生計画アプリ (Life Planning App)

## プロジェクト概要

**人生計画アプリ**は、日本の年金制度（基礎年金・厚生年金）に基づいた人生設計をサポートするアプリケーションです。

- **言語**: Dart (バックエンド設計：ドメインモデル)
- **現在の位置**: Unit 1 - Shared Business Logic（年金計算エンジン）
- **テストフレームワーク**: Dart test
- **対象プラットフォーム**: Web（Cloudflare）、iOS/Android（Flutter）

---

## 実装済み機能

### ✅ 国民年金計算ドメインモデル

#### 1. **NationalPensionInput** クラス
- 国民年金の納付情報を管理
- 有効納付月数の計算（全額免除・一部免除対応）
- 納付率の計算
- 基本年金月額・年額の算出

**テストケース**: 23個（すべてパス）

#### 2. **EarlyLateAdjustmentCalculator** クラス
- 受給開始年齢（60～75歳）による調整率計算
- **繰上げ受給**（60～64歳）: 最大24%減
- **標準受給**（65歳）: 調整なし
- **繰下げ受給**（66～75歳）: 最大84%増
- 基礎年金・厚生年金の両方の計算に対応

**テストケース**: 23個（すべてパス）

**総テストケース**: 46個（すべてパス ✅）

---

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
# すべてのテストを実行
dart test

# カバレッジを生成
dart test --coverage=coverage

# 特定のテストグループを実行
dart test -n "NationalPensionInput"
dart test -n "EarlyLateAdjustmentCalculator"
```

### 静的解析・フォーマット確認

```bash
dart analyze
dart format --set-exit-if-changed .
```

---

## ドメイン設計

国民年金計算のドメインモデル設計については、以下のドキュメントを参照してください：

- **[DOMAIN_DESIGN.md](docs/DOMAIN_DESIGN.md)** - クラス図、シーケンス図、設計原則

### 主要なクラス構成

```
┌─────────────────────────┐
│ NationalPensionInput    │  納付情報管理
│                         │  → 有効納付月数計算
│  - fullContribution     │  → 納付率計算
│  - exemptMonths (各種)  │  → 基本年金額算出
└─────────────────────────┘
             ↓
┌─────────────────────────────────────┐
│ EarlyLateAdjustmentCalculator        │  受給年齢調整
│                                     │
│  - awardAge (60～75歳)              │  → 調整率を計算
│                                     │  → 最終受給額を算出
└─────────────────────────────────────┘

※ PensionCalculator（統合）と PensionResult（結果保持）は
   Phase 1 で実装予定
```

---

## 計算例

### 例1: 完全納付 + 標準受給（65歳）

```dart
final input = NationalPensionInput(fullContributionMonths: 480);
final adjuster = EarlyLateAdjustmentCalculator(awardAge: 65);

// 基本年金月額（納付率適用）
final baseAmount = input.getApplicablePensionMonthlyAmount();  // ¥70,608

// 調整率（標準受給なので1.0）
final rate = adjuster.getAdjustmentRate();  // 1.0

// 最終受給額
final finalAmount = adjuster.applyAdjustment(baseAmount);  // ¥70,608
```

### 例2: 半分納付 + 繰上げ受給（60歳）

```dart
final input = NationalPensionInput(fullContributionMonths: 240);
final adjuster = EarlyLateAdjustmentCalculator(awardAge: 60);

// 基本年金月額（納付率適用）
final baseAmount = input.getApplicablePensionMonthlyAmount();  // ¥35,304

// 調整率（繰上げ受給 60歳 = 24%減）
final rate = adjuster.getAdjustmentRate();  // 0.76

// 最終受給額
final finalAmount = adjuster.applyAdjustment(baseAmount);  // ¥26,831
```

### 例3: 混合免除 + 繰下げ受給（70歳）

```dart
final input = NationalPensionInput(
  fullContributionMonths: 240,
  fullExemptMonths: 120,
  halfExemptMonths: 120,
);
final adjuster = EarlyLateAdjustmentCalculator(awardAge: 70);

// 有効納付月数：240 + 60 + 90 = 390ヶ月
// 納付率：390 / 480 = 0.8125
// 基本年金月額：¥70,608 × 0.8125 = ¥57,369

// 調整率（繰下げ受給 70歳 = 42%増）
final rate = adjuster.getAdjustmentRate();  // 1.42

// 最終受給額
final baseAmount = input.getApplicablePensionMonthlyAmount();  // ¥57,369
final finalAmount = adjuster.applyAdjustment(baseAmount);     // ¥81,454
```

---

## CI/CD パイプライン

GitHub Actions で自動テスト・カバレッジ収集を実行します：

```yaml
# .github/workflows/test-coverage.yml
- コード解析（dart analyze）
- フォーマット確認（dart format）
- テスト実行（dart test --coverage）
- Codecov へのアップロード
```

---

## ドキュメント

- [NATIONAL_PENSION_SPEC.md](docs/NATIONAL_PENSION_SPEC.md) - 国民年金制度の仕様書
- [DOMAIN_DESIGN.md](docs/DOMAIN_DESIGN.md) - ドメインモデルの設計（クラス図・シーケンス図）
- [BRANCHING_STRATEGY.md](docs/BRANCHING_STRATEGY.md) - Git ブランチ戦略
- [PRE_COMMIT_SETUP.md](docs/PRE_COMMIT_SETUP.md) - git pre-commit セットアップ

---

## ブランチ戦略

GitHub Flow を採用しています：

- **main**: 本番環境（リリース対象）
- **develop**: 開発環境
- **feature/\***: 機能開発ブランチ

詳細は [BRANCHING_STRATEGY.md](docs/BRANCHING_STRATEGY.md) を参照してください。

---

## 今後の実装ロードマップ

### Phase 1: ドメインモデル統合
- [ ] `PensionCalculator` クラスの実装（NationalPensionInput + EarlyLateAdjustmentCalculator）
- [ ] `PensionResult` クラスの実装（計算結果の保持）

### Phase 2: 厚生年金モデル
- [ ] `EmployeePensionInput` クラスの実装
- [ ] `EarlyLateAdjustmentCalculator` の再利用

### Phase 3: Web版実装
- [ ] React/Vue + Cloudflare Workers + Cloudflare D1 SQLite

### Phase 4: モバイル版実装
- [ ] Flutter（iOS/Android）

---

## ライセンス

このプロジェクトはプライベートプロジェクトです。

---

## 開発者

Life Planning App チーム

