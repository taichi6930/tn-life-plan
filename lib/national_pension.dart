/// 国民年金計算ドメインモデル
///
/// 国民年金の計算に必要なクラスを含む：
/// - NationalPensionInput: 入力パラメータ管理・有効納付月数計算
/// - EarlyLateAdjustmentCalculator: 受給開始年齢に基づく調整率計算

/// 受給開始年齢に基づく調整率を計算するクラス
///
/// 繰上げ受給（60～64歳）または繰下げ受給（66～75歳）の選択に応じて、
/// 年金額の調整率を計算する。この計算は基礎年金と厚生年金の両方に使用可能。
///
/// 調整率の計算式：
/// - 繰上げ受給（60～64歳）:
///   調整率 = 1.0 - (0.004 × 月数)
///   月数 = (65 - 受給年齢) × 12
///   例: 60歳 → 1.0 - (0.004 × 60) = 0.76
///
/// - 標準受給（65歳）:
///   調整率 = 1.0（調整なし）
///
/// - 繰下げ受給（66～75歳）:
///   調整率 = 1.0 + (0.007 × 月数)
///   月数 = (受給年齢 - 65) × 12
///   例: 70歳 → 1.0 + (0.007 × 60) = 1.42
class EarlyLateAdjustmentCalculator {
  /// 受給開始年齢（60～75歳）
  final int awardAge;

  /// 標準受給開始年齢
  static const int standardAwardAge = 65;

  /// 繰上げ受給の最小年齢
  static const int minAwardAge = 60;

  /// 繰下げ受給の最大年齢
  static const int maxAwardAge = 75;

  /// 繰上げ受給の減率（月あたり）
  static const double earlyAwardReductionRate = 0.004;

  /// 繰下げ受給の増率（月あたり）
  static const double lateAwardIncreaseRate = 0.007;

  /// コンストラクタ
  EarlyLateAdjustmentCalculator({required this.awardAge});

  /// 入力値のバリデーション
  /// 受給年齢が 60～75歳の範囲内か確認する
  bool isValid() {
    return awardAge >= minAwardAge && awardAge <= maxAwardAge;
  }

  /// 調整率を計算する
  ///
  /// 返り値は 0.76 ～ 1.42 の範囲
  /// （60歳受給で24%減、75歳受給で42%増）
  double getAdjustmentRate() {
    if (!isValid()) {
      throw ArgumentError('受給年齢は $minAwardAge～$maxAwardAge 歳である必要があります。');
    }

    if (awardAge < standardAwardAge) {
      // 繰上げ受給: 60～64歳
      final monthsEarlier = (standardAwardAge - awardAge) * 12;
      return 1.0 - (earlyAwardReductionRate * monthsEarlier);
    } else if (awardAge > standardAwardAge) {
      // 繰下げ受給: 66～75歳
      final monthsLater = (awardAge - standardAwardAge) * 12;
      return 1.0 + (lateAwardIncreaseRate * monthsLater);
    } else {
      // 標準受給: 65歳
      return 1.0;
    }
  }

  /// 指定された年金月額に調整率を適用する
  ///
  /// 計算式: 年金月額 × 調整率
  double applyAdjustment(double pensionMonthlyAmount) {
    return pensionMonthlyAmount * getAdjustmentRate();
  }

  /// 指定された年金年額に調整率を適用する
  ///
  /// 計算式: 年金年額 × 調整率
  double applyAnnualAdjustment(double pensionAnnualAmount) {
    return pensionAnnualAmount * getAdjustmentRate();
  }

  @override
  String toString() {
    return 'EarlyLateAdjustmentCalculator(awardAge: $awardAge, adjustmentRate: ${getAdjustmentRate().toStringAsFixed(2)})';
  }
}

/// 国民年金計算の入力パラメータを管理するクラス
///
/// ユーザーが入力する年金計算パラメータを管理し、
/// 有効納付月数の計算と納付率の算出を行う。
class NationalPensionInput {
  /// 令和8年度の基本年金月額（¥）
  static const double basicPensionMonthlyAmount = 70608;

  /// 完全納付期間（20歳～60歳の40年間）
  static const int maxContributionMonths = 480;

  /// 全額納付月数（0～480月）
  final int fullContributionMonths;

  /// 全額免除月数（カウント率: 1/2）
  final int fullExemptMonths;

  /// 3/4免除月数（カウント率: 5/8）
  final int threeQuarterExemptMonths;

  /// 半額免除月数（カウント率: 3/4）
  final int halfExemptMonths;

  /// 1/4免除月数（カウント率: 7/8）
  final int quarterExemptMonths;

  /// 学生納付特例月数（カウント率: 0、追納可能）
  final int studentDefermentMonths;

  /// コンストラクタ
  NationalPensionInput({
    required this.fullContributionMonths,
    this.fullExemptMonths = 0,
    this.threeQuarterExemptMonths = 0,
    this.halfExemptMonths = 0,
    this.quarterExemptMonths = 0,
    this.studentDefermentMonths = 0,
  });

  /// 入力値のバリデーション
  /// すべての条件を満たす場合はtrueを返す
  bool isValid() {
    // 各月数が負でないことをチェック
    if (fullContributionMonths < 0 ||
        fullExemptMonths < 0 ||
        threeQuarterExemptMonths < 0 ||
        halfExemptMonths < 0 ||
        quarterExemptMonths < 0 ||
        studentDefermentMonths < 0) {
      return false;
    }

    return true;
  }

  /// 有効納付月数を計算する
  ///
  /// 計算式:
  /// 有効納付月数 = 全額納付月数
  ///               + (全額免除月数 × 1/2)
  ///               + (3/4免除月数 × 5/8)
  ///               + (半額免除月数 × 3/4)
  ///               + (1/4免除月数 × 7/8)
  ///
  /// 上限: maxContributionMonths月（480月を超えたら480月にしてしまう）
  /// 学生納付特例月数は含まない
  double getEffectiveContributionMonths() {
    final effective = fullContributionMonths.toDouble() +
        (fullExemptMonths * 0.5) +
        (threeQuarterExemptMonths * 5 / 8) +
        (halfExemptMonths * 0.75) +
        (quarterExemptMonths * 7 / 8);

    // 480ヶ月を超えたら480ヶ月にしてしまう
    return effective > maxContributionMonths
        ? maxContributionMonths.toDouble()
        : effective;
  }

  /// 納付率を計算する
  ///
  /// 納付率 = 有効納付月数 / maxContributionMonths
  double getContributionRate() {
    return getEffectiveContributionMonths() / maxContributionMonths;
  }

  /// 納付率を適用した年金月額を取得する
  /// 毎年4月に物価スライドに基づいて改定される
  double getApplicablePensionMonthlyAmount() {
    return basicPensionMonthlyAmount * getContributionRate();
  }

  /// 納付率を適用した年金年額を取得する
  double getApplicablePensionAnnualAmount() {
    return getApplicablePensionMonthlyAmount() * 12;
  }

  @override
  String toString() {
    return '''
NationalPensionInput(
  basicPensionMonthlyAmount: ¥$basicPensionMonthlyAmount,
  fullContributionMonths: $fullContributionMonths,
  fullExemptMonths: $fullExemptMonths,
  threeQuarterExemptMonths: $threeQuarterExemptMonths,
  halfExemptMonths: $halfExemptMonths,
  quarterExemptMonths: $quarterExemptMonths,
  studentDefermentMonths: $studentDefermentMonths,
  effectiveContributionMonths: ${getEffectiveContributionMonths()},
)
    ''';
  }
}
