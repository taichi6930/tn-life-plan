/// 国民年金計算テスト
///
/// デシジョンテーブル（有効納付月数の計算）:
///
/// | # | 全額納付月数 | 全額免除 | 3/4免除 | 半額免除 | 1/4免除 | 学生特例 | 期待有効月数 | 説明 |
/// |---|-----------|--------|--------|--------|--------|--------|-----------|------|
/// | 1 | 480       | 0      | 0      | 0      | 0      | 0      | 480       | 完全納付 |
/// | 2 | 0         | 480    | 0      | 0      | 0      | 0      | 240(0.5x) | 全額免除のみ |
/// | 3 | 0         | 0      | 480    | 0      | 0      | 0      | 300(5/8x) | 3/4免除のみ |
/// | 4 | 0         | 0      | 0      | 480    | 0      | 0      | 360(0.75x)| 半額免除のみ |
/// | 5 | 0         | 0      | 0      | 0      | 480    | 0      | 420(7/8x) | 1/4免除のみ |
/// | 6 | 240       | 120    | 120    | 0      | 0      | 0      | 365       | 複合免除1 |
/// | 7 | 100       | 100    | 100    | 100    | 100    | 0      | 350       | 複合免除2 |
/// | 8 | 480       | 0      | 0      | 0      | 0      | 100    | 480       | 学生特例含む（カウント率0） |
/// | 9 | -1        | 0      | 0      | 0      | 0      | 0      | invalid   | 負の値（不正） |
/// |10 | 500       | 0      | 0      | 0      | 0      | 0      | 480(cap)  | 合計>480月（キャップ） |
///
/// デシジョンテーブル（年金額計算）:
///
/// | # | 納付月数 | 納付率 | 月額期待値 | 年額期待値 | 説明 |
/// |----|--------|--------|-----------|----------|------|
/// | 1 | 480    | 1.0    | 70,608    | 847,296  | 完全納付（満額） |
/// | 2 | 240    | 0.5    | 35,304    | 423,648  | 半分納付 |
/// | 3 | 0      | 0.0    | 0         | 0        | 無納付 |
///
/// テスト対象クラス:
/// - NationalPensionInput: 入力パラメータ管理・有効納付月数計算

///
import 'package:test/test.dart';

import '../lib/national_pension.dart';

void main() {
  group('NationalPensionInput', () {
    group('isValid()', () {
      test('正常な入力値は有効', () {
        final input = NationalPensionInput(
          fullContributionMonths: 300,
          fullExemptMonths: 100,
        );
        expect(input.isValid(), isTrue);
      });

      test('負の月数は無効', () {
        final input = NationalPensionInput(
          fullContributionMonths: -1,
        );
        expect(input.isValid(), isFalse);
      });

      test('全項目が0以上なら有効', () {
        final input = NationalPensionInput(
          fullContributionMonths: 0,
          fullExemptMonths: 0,
          threeQuarterExemptMonths: 0,
          halfExemptMonths: 0,
          quarterExemptMonths: 0,
          studentDefermentMonths: 0,
        );
        expect(input.isValid(), isTrue);
      });
    });

    group('getEffectiveContributionMonths()', () {
      test('デシジョンテーブル #1: 完全納付480月', () {
        final input = NationalPensionInput(fullContributionMonths: 480);
        expect(input.getEffectiveContributionMonths(), 480.0);
      });

      test('デシジョンテーブル #2: 全額免除480月（カウント率0.5）', () {
        final input = NationalPensionInput(
          fullContributionMonths: 0,
          fullExemptMonths: 480,
        );
        expect(input.getEffectiveContributionMonths(), 240.0);
      });

      test('デシジョンテーブル #3: 3/4免除480月（カウント率5/8）', () {
        final input = NationalPensionInput(
          fullContributionMonths: 0,
          threeQuarterExemptMonths: 480,
        );
        expect(input.getEffectiveContributionMonths(), 300.0);
      });

      test('デシジョンテーブル #4: 半額免除480月（カウント率0.75）', () {
        final input = NationalPensionInput(
          fullContributionMonths: 0,
          halfExemptMonths: 480,
        );
        expect(input.getEffectiveContributionMonths(), 360.0);
      });

      test('デシジョンテーブル #5: 1/4免除480月（カウント率7/8）', () {
        final input = NationalPensionInput(
          fullContributionMonths: 0,
          quarterExemptMonths: 480,
        );
        expect(input.getEffectiveContributionMonths(), 420.0);
      });

      test('デシジョンテーブル #6: 複合免除パターン1', () {
        final input = NationalPensionInput(
          fullContributionMonths: 240,
          fullExemptMonths: 120,
          threeQuarterExemptMonths: 120,
        );
        // 240 + (120 * 0.5) + (120 * 5/8)
        // = 240 + 60 + 75 = 375
        expect(input.getEffectiveContributionMonths(), 375.0);
      });

      test('デシジョンテーブル #7: 複合免除パターン2', () {
        final input = NationalPensionInput(
          fullContributionMonths: 100,
          fullExemptMonths: 100,
          threeQuarterExemptMonths: 100,
          halfExemptMonths: 100,
          quarterExemptMonths: 100,
        );
        // 100 + (100*0.5) + (100*5/8) + (100*0.75) + (100*7/8)
        // = 100 + 50 + 62.5 + 75 + 87.5 = 375
        expect(input.getEffectiveContributionMonths(), 375.0);
      });

      test('デシジョンテーブル #8: 学生特例月数はカウントされない', () {
        final input = NationalPensionInput(
          fullContributionMonths: 480,
          studentDefermentMonths: 100,
        );
        expect(input.getEffectiveContributionMonths(), 480.0);
      });

      test('デシジョンテーブル #10: 合計>480月はキャップされる', () {
        final input = NationalPensionInput(fullContributionMonths: 500);
        expect(input.getEffectiveContributionMonths(), 480.0);
      });

      test('複合計算で480を超える場合はキャップ', () {
        final input = NationalPensionInput(
          fullContributionMonths: 400,
          fullExemptMonths: 200, // +100
          // 400 + 100 = 500 -> 480にキャップ
        );
        expect(input.getEffectiveContributionMonths(), 480.0);
      });
    });

    group('getContributionRate()', () {
      test('納付率 = 有効月数 / 480', () {
        final input = NationalPensionInput(fullContributionMonths: 240);
        expect(input.getContributionRate(), 240.0 / 480);
      });

      test('完全納付なら納付率100%', () {
        final input = NationalPensionInput(fullContributionMonths: 480);
        expect(input.getContributionRate(), 1.0);
      });

      test('0月なら納付率0%', () {
        final input = NationalPensionInput(fullContributionMonths: 0);
        expect(input.getContributionRate(), 0.0);
      });
    });

    group('getApplicablePensionMonthlyAmount()', () {
      test('完全納付なら満額の70608円を返す', () {
        final input = NationalPensionInput(fullContributionMonths: 480);
        expect(input.getApplicablePensionMonthlyAmount(), 70608.0);
      });

      test('半分納付なら半額を返す', () {
        final input = NationalPensionInput(fullContributionMonths: 240);
        expect(input.getApplicablePensionMonthlyAmount(), 35304.0);
      });

      test('納付0月なら0円を返す', () {
        final input = NationalPensionInput(fullContributionMonths: 0);
        expect(input.getApplicablePensionMonthlyAmount(), 0.0);
      });
    });

    group('getApplicablePensionAnnualAmount()', () {
      test('完全納付なら満額の年額847296円を返す', () {
        final input = NationalPensionInput(fullContributionMonths: 480);
        expect(input.getApplicablePensionAnnualAmount(), 70608.0 * 12);
      });

      test('半分納付なら半額の年額を返す', () {
        final input = NationalPensionInput(fullContributionMonths: 240);
        expect(input.getApplicablePensionAnnualAmount(), 35304.0 * 12);
      });

      test('納付0月なら0円を返す', () {
        final input = NationalPensionInput(fullContributionMonths: 0);
        expect(input.getApplicablePensionAnnualAmount(), 0.0);
      });
    });

    group('toString()', () {
      test('入力パラメータの文字列表現を返す', () {
        final input = NationalPensionInput(
          fullContributionMonths: 240,
          fullExemptMonths: 120,
          threeQuarterExemptMonths: 100,
          halfExemptMonths: 20,
        );
        final str = input.toString();
        expect(str, contains('fullContributionMonths: 240'));
        expect(str, contains('fullExemptMonths: 120'));
        expect(str, contains('threeQuarterExemptMonths: 100'));
        expect(str, contains('halfExemptMonths: 20'));
        expect(str, contains('NationalPensionInput'));
      });
    });
  });

  group('EarlyLateAdjustmentCalculator', () {
    /// デシジョンテーブル（受給開始年齢による調整率計算）:
    ///
    /// | # | 受給年齢 | 月数差 | 期待調整率 | 説明 |
    /// |----|--------|--------|----------|------|
    /// | 1 | 60 | -60 | 0.76 | 繰上げ最大（24%減） |
    /// | 2 | 61 | -48 | 0.808 | 繰上げ4年 |
    /// | 3 | 62 | -36 | 0.856 | 繰上げ3年 |
    /// | 4 | 63 | -24 | 0.904 | 繰上げ2年 |
    /// | 5 | 64 | -12 | 0.952 | 繰上げ1年 |
    /// | 6 | 65 | 0 | 1.0 | 標準受給（調整なし） |
    /// | 7 | 66 | 12 | 1.084 | 繰下げ1年 |
    /// | 8 | 70 | 60 | 1.42 | 繰下げ5年（42%増） |
    /// | 9 | 75 | 120 | 1.84 | 繰下げ最大（84%増） |
    /// | 10 | 59 | - | invalid | 最小年齢未満 |
    /// | 11 | 76 | - | invalid | 最大年齢超過 |

    group('isValid()', () {
      test('受給年齢60歳は有効', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 60);
        expect(calc.isValid(), isTrue);
      });

      test('受給年齢65歳は有効', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 65);
        expect(calc.isValid(), isTrue);
      });

      test('受給年齢75歳は有効', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 75);
        expect(calc.isValid(), isTrue);
      });

      test('受給年齢59歳は無効', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 59);
        expect(calc.isValid(), isFalse);
      });

      test('受給年齢76歳は無効', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 76);
        expect(calc.isValid(), isFalse);
      });
    });

    group('getAdjustmentRate()', () {
      test('デシジョンテーブル #1: 繰上げ最大（60歳）= 0.76', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 60);
        expect(calc.getAdjustmentRate(), closeTo(0.76, 0.001));
      });

      test('デシジョンテーブル #2: 繰上げ4年（61歳）= 0.808', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 61);
        expect(calc.getAdjustmentRate(), closeTo(0.808, 0.001));
      });

      test('デシジョンテーブル #3: 繰上げ3年（62歳）= 0.856', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 62);
        expect(calc.getAdjustmentRate(), closeTo(0.856, 0.001));
      });

      test('デシジョンテーブル #4: 繰上げ2年（63歳）= 0.904', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 63);
        expect(calc.getAdjustmentRate(), closeTo(0.904, 0.001));
      });

      test('デシジョンテーブル #5: 繰上げ1年（64歳）= 0.952', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 64);
        expect(calc.getAdjustmentRate(), closeTo(0.952, 0.001));
      });

      test('デシジョンテーブル #6: 標準受給（65歳）= 1.0', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 65);
        expect(calc.getAdjustmentRate(), closeTo(1.0, 0.001));
      });

      test('デシジョンテーブル #7: 繰下げ1年（66歳）= 1.084', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 66);
        expect(calc.getAdjustmentRate(), closeTo(1.084, 0.001));
      });

      test('デシジョンテーブル #8: 繰下げ5年（70歳）= 1.42', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 70);
        expect(calc.getAdjustmentRate(), closeTo(1.42, 0.001));
      });

      test('デシジョンテーブル #9: 繰下げ最大（75歳）= 1.84', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 75);
        expect(calc.getAdjustmentRate(), closeTo(1.84, 0.001));
      });

      test('無効な年齢でgetAdjustmentRateを呼ぶと例外発生', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 59);
        expect(
          () => calc.getAdjustmentRate(),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('applyAdjustment()', () {
      test('60歳受給で月額70608円× 0.76 = 53662円', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 60);
        final adjusted = calc.applyAdjustment(70608.0);
        expect(adjusted, closeTo(70608.0 * 0.76, 0.1));
      });

      test('65歳受給で月額70608円× 1.0 = 70608円（調整なし）', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 65);
        final adjusted = calc.applyAdjustment(70608.0);
        expect(adjusted, closeTo(70608.0, 0.1));
      });

      test('70歳受給で月額70608円× 1.42 = 100263円', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 70);
        final adjusted = calc.applyAdjustment(70608.0);
        expect(adjusted, closeTo(70608.0 * 1.42, 0.1));
      });
    });

    group('applyAnnualAdjustment()', () {
      test('60歳受給で年額847296円× 0.76 = 643945円', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 60);
        final adjusted = calc.applyAnnualAdjustment(847296.0);
        expect(adjusted, closeTo(847296.0 * 0.76, 0.1));
      });

      test('70歳受給で年額847296円× 1.42 = 1203140円', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 70);
        final adjusted = calc.applyAnnualAdjustment(847296.0);
        expect(adjusted, closeTo(847296.0 * 1.42, 0.1));
      });
    });

    group('toString()', () {
      test('60歳受給の文字列表現', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 60);
        final str = calc.toString();
        expect(str, contains('awardAge: 60'));
        expect(str, contains('0.76'));
      });

      test('65歳受給の文字列表現', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 65);
        final str = calc.toString();
        expect(str, contains('awardAge: 65'));
        expect(str, contains('1.00'));
      });

      test('70歳受給の文字列表現', () {
        final calc = EarlyLateAdjustmentCalculator(awardAge: 70);
        final str = calc.toString();
        expect(str, contains('awardAge: 70'));
        expect(str, contains('1.42'));
      });
    });
  });
}
