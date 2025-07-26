import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'loan_settings.g.dart';

@HiveType(typeId: 9)
class LoanSettings extends Equatable {
  @HiveField(0)
  final double monthlyInterestRatePercentage;

  @HiveField(1)
  final double minimumInterestRatePercentage;

  @HiveField(2)
  final double maximumInterestRatePercentage;

  @HiveField(3)
  final bool allowCustomRates;

  @HiveField(4)
  final int minimumLoanTermMonths;

  @HiveField(5)
  final int maximumLoanTermMonths;

  @HiveField(6)
  final double maxLoanToContributionRatio;

  @HiveField(7)
  final int minimumContributionMonths;

  @HiveField(8)
  final DateTime lastUpdated;

  @HiveField(9)
  final String updatedBy;

  @HiveField(10)
  final Map<String, dynamic> metadata;

  const LoanSettings({
    required this.monthlyInterestRatePercentage,
    this.minimumInterestRatePercentage = 1.0,
    this.maximumInterestRatePercentage = 20.0,
    this.allowCustomRates = true,
    this.minimumLoanTermMonths = 1,
    this.maximumLoanTermMonths = 60,
    this.maxLoanToContributionRatio = 3.0,
    this.minimumContributionMonths = 6,
    required this.lastUpdated,
    this.updatedBy = 'System',
    this.metadata = const {},
  });

  /// Calculate monthly interest amount for a given principal
  double calculateMonthlyInterest(double principalAmount) {
    return principalAmount * (monthlyInterestRatePercentage / 100);
  }

  // Default settings factory
  factory LoanSettings.defaultSettings() {
    return LoanSettings(
      monthlyInterestRatePercentage: 5.0, // 5% of principal per month
      lastUpdated: DateTime.now(),
    );
  }

  LoanSettings copyWith({
    double? monthlyInterestRatePercentage,
    double? minimumInterestRatePercentage,
    double? maximumInterestRatePercentage,
    bool? allowCustomRates,
    int? minimumLoanTermMonths,
    int? maximumLoanTermMonths,
    double? maxLoanToContributionRatio,
    int? minimumContributionMonths,
    DateTime? lastUpdated,
    String? updatedBy,
    Map<String, dynamic>? metadata,
  }) {
    return LoanSettings(
      monthlyInterestRatePercentage:
          monthlyInterestRatePercentage ?? this.monthlyInterestRatePercentage,
      minimumInterestRatePercentage:
          minimumInterestRatePercentage ?? this.minimumInterestRatePercentage,
      maximumInterestRatePercentage:
          maximumInterestRatePercentage ?? this.maximumInterestRatePercentage,
      allowCustomRates: allowCustomRates ?? this.allowCustomRates,
      minimumLoanTermMonths:
          minimumLoanTermMonths ?? this.minimumLoanTermMonths,
      maximumLoanTermMonths:
          maximumLoanTermMonths ?? this.maximumLoanTermMonths,
      maxLoanToContributionRatio:
          maxLoanToContributionRatio ?? this.maxLoanToContributionRatio,
      minimumContributionMonths:
          minimumContributionMonths ?? this.minimumContributionMonths,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    monthlyInterestRatePercentage,
    minimumInterestRatePercentage,
    maximumInterestRatePercentage,
    allowCustomRates,
    minimumLoanTermMonths,
    maximumLoanTermMonths,
    maxLoanToContributionRatio,
    minimumContributionMonths,
    lastUpdated,
    updatedBy,
    metadata,
  ];

  Map<String, dynamic> toJson() {
    return {
      'monthlyInterestRatePercentage': monthlyInterestRatePercentage,
      'minimumInterestRatePercentage': minimumInterestRatePercentage,
      'maximumInterestRatePercentage': maximumInterestRatePercentage,
      'allowCustomRates': allowCustomRates,
      'minimumLoanTermMonths': minimumLoanTermMonths,
      'maximumLoanTermMonths': maximumLoanTermMonths,
      'maxLoanToContributionRatio': maxLoanToContributionRatio,
      'minimumContributionMonths': minimumContributionMonths,
      'lastUpdated': lastUpdated.toIso8601String(),
      'updatedBy': updatedBy,
      'metadata': metadata,
    };
  }

  factory LoanSettings.fromJson(Map<String, dynamic> json) {
    return LoanSettings(
      monthlyInterestRatePercentage:
          (json['monthlyInterestRatePercentage'] ?? 5.0).toDouble(),
      minimumInterestRatePercentage:
          (json['minimumInterestRatePercentage'] ?? 1.0).toDouble(),
      maximumInterestRatePercentage:
          (json['maximumInterestRatePercentage'] ?? 20.0).toDouble(),
      allowCustomRates: json['allowCustomRates'] ?? true,
      minimumLoanTermMonths: json['minimumLoanTermMonths'] ?? 1,
      maximumLoanTermMonths: json['maximumLoanTermMonths'] ?? 60,
      maxLoanToContributionRatio: (json['maxLoanToContributionRatio'] ?? 3.0)
          .toDouble(),
      minimumContributionMonths: json['minimumContributionMonths'] ?? 6,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      updatedBy: json['updatedBy'] ?? 'System',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'LoanSettings(monthlyRate: $monthlyInterestRatePercentage%, allowCustom: $allowCustomRates)';
  }
}
