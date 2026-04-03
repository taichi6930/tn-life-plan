# Copilot Instructions - tn-life-plan

## プロジェクト概要
- **プロジェクト名**: 人生設計アプリ (Life Planning App)
- **言語**: Dart
- **用途**: 国民年金計算ドメインモデルの開発
- **テストフレームワーク**: Dart test

## テスト作成ガイドライン

### デシジョンテーブルの記述
すべてのテストファイルの先頭に**デシジョンテーブル**を記載してください。

**形式**:
```dart
/// デシジョンテーブル（機能名）:
/// 
/// | # | 入力1 | 入力2 | 入力3 | 期待出力 | 説明 |
/// |---|------|------|------|--------|------|
/// | 1 | xxx  | yyy  | zzz  | yyy    | 説明文 |
/// ...
```

**テストファイル**: [test/national_pension_test.dart](test/national_pension_test.dart)

### テストの構成要素

#### 1. グループ分け（`group()`）
```dart
group('クラス名', () {
  group('メソッド名', () {
    // テストケース
  });
});
```

#### 2. テストケース名
- **デシジョンテーブル参照**: `test('デシジョンテーブル #1: 説明文', () { ... })`
- **単体テスト**: `test('機能説明', () { ... })`

**命名規則**:
- `isValid()` → 「正常な入力値は有効」「負の値は無効」
- `calculate()` → 「完全納付で満額支給計算」「半分納付で半額支給計算」
- `getEffectiveContributionMonths()` → 「完全納付480月」「全額免除480月」

#### 3. アサーション
```dart
expect(actual, expected);  // 等値テスト
expect(actual, closeTo(expected, delta));  // 浮動小数点数
expect(actual, isTrue); // boolean
expect(actual, contains('文字列')); // 文字列を含む
```

### テスト対象の重点項目

#### NationalPensionInput
- ✅ `isValid()`: 負の値チェック、全フィールド検証
- ✅ `getEffectiveContributionMonths()`: 480月キャップ、複合免除計算
- ✅ `getContributionRate()`: 納付率計算（有効月数 / 480）

#### PensionResult
- ✅ 計算結果の正確な保持
- ✅ `format()`: カンマ区切り、見出し付きテキスト出力

#### PensionCalculator
- ✅ 月額計算: `基本年金月額 × (有効月数 / 480)`
- ✅ 年額計算: `月額 × 12`

### テスト実行コマンド
```bash
# すべてのテスト実行
dart test

# 特定ファイルだけ実行
dart test test/national_pension_test.dart

# 特定グループだけ実行
dart test test/national_pension_test.dart -n "PensionCalculator"

# フィルター付き実行
dart test test/national_pension_test.dart -n "完全納付"
```

###コード品質基準

#### テストカバレッジ目標
- **NationalPensionInput**: 100%（全メソッド・全分岐）
- **PensionResult**: 100%
- **PensionCalculator**: 100%

#### テストの独立性
- 各テストは独立して実行可能
- グローバル状態に依存しない
- テスト間の順序依存性なし

#### マジックナンバーの排除
```dart
// ❌ NG
expect(result, 70608.0);

// ✅ OK
expect(result, NationalPensionInput.basicPensionMonthlyAmount);
```

### 計算式の検証

#### 有効納付月数の計算式
```
有効納付月数 = 全額納付月数
             + (全額免除月数 × 1/2)
             + (3/4免除月数 × 5/8)
             + (半額免除月数 × 3/4)
             + (1/4免除月数 × 7/8)
             
上限: maxContributionMonths（480月）
```

#### 基本年金月額の計算式
```
基本年金月額 = 基本年金月額定数 × (有効納付月数 / 480)
```

## ドメイン用語辞書
| 用語 | 意味 | カウント率 |
|------|------|----------|
| 全額納付 (full contribution) | 保険料を全額納めた月 | 1.0 |
| 全額免除 (full exemption) | 保険料支払い免除・月額0円 | 0.5 |
| 3/4免除 | 保険料の3/4を免除 | 5/8 |
| 半額免除 | 保険料の50%を免除 | 0.75 |
| 1/4免除 | 保険料の1/4を免除 | 7/8 |
| 学生納付特例 | 学生向け納付猶予制度 | 0.0（追納可） |

## 参考資料
- [NATIONAL_PENSION_SPEC.md](docs/NATIONAL_PENSION_SPEC.md): 仕様書
- [lib/national_pension.dart](lib/national_pension.dart): 実装コード
