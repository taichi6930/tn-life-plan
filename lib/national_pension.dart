/// 国民年金計算ドメインモデル
/// 
/// 国民年金の計算に必要なすべてのクラスを含む：
/// - NationalPensionInput: 入力パラメータ
/// - PensionResult: 計算結果
/// - PensionCalculator: 計算エンジン

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
    return effective > maxContributionMonths ? maxContributionMonths.toDouble() : effective;
  }

  /// 納付率を計算する
  ///
  /// 納付率 = 有効納付月数 / maxContributionMonths
  double getContributionRate() {
    return getEffectiveContributionMonths() / maxContributionMonths;
  }

  /// 現在の基本年金月額を取得する
  /// 毎年4月に物価スライドに基づいて改定される
  double getCurrentBasicPensionMonthlyAmount() {
    return basicPensionMonthlyAmount;
  }

  /// 現在の基本年金年額を取得する
  double getCurrentBasicPensionAnnualAmount() {
    return basicPensionMonthlyAmount * 12;
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