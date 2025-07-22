import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'loan_settings.g.dart';

@HiveType(typeId: 9)
class LoanSettings extends Equatable {
  @HiveField(0)
  final double defaultMonthlyInterestRate;

  @HiveField(1)
  final double minimumInterestRate;

  @HiveField(2)
  final double maximumInterestRate;

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
    required this.defaultMonthlyInterestRate,
    this.minimumInterestRate = 1000.0,
    this.maximumInterestRate = 10000.0,
    this.allowCustomRates = true,
    this.minimumLoanTermMonths = 1,
    this.maximumLoanTermMonths = 60,
    this.maxLoanToContributionRatio = 3.0,
    this.minimumContributionMonths = 6,
    required this.lastUpdated,
    this.updatedBy = 'System',
    this.metadata = const {},
  });

  // Default settings factory
  factory LoanSettings.defaultSettings() {
    return LoanSettings(
      defaultMonthlyInterestRate: 3150.0, // Current default
      lastUpdated: DateTime.now(),
    );
  }

  LoanSettings copyWith({
    double? defaultMonthlyInterestRate,
    double? minimumInterestRate,
    double? maximumInterestRate,
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
      defaultMonthlyInterestRate: defaultMonthlyInterestRate ?? this.defaultMonthlyInterestRate,
      minimumInterestRate: minimumInterestRate ?? this.minimumInterestRate,
      maximumInterestRate: maximumInterestRate ?? this.maximumInterestRate,
      allowCustomRates: allowCustomRates ?? this.allowCustomRates,
      minimumLoanTermMonths: minimumLoanTermMonths ?? this.minimumLoanTermMonths,
      maximumLoanTermMonths: maximumLoanTermMonths ?? this.maximumLoanTermMonths,
      maxLoanToContributionRatio: maxLoanToContributionRatio ?? this.maxLoanToContributionRatio,
      minimumContributionMonths: minimumContributionMonths ?? this.minimumContributionMonths,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    defaultMonthlyInterestRate,
    minimumInterestRate,
    maximumInterestRate,
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
      'defaultMonthlyInterestRate': defaultMonthlyInterestRate,
      'minimumInterestRate': minimumInterestRate,
      'maximumInterestRate': maximumInterestRate,
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
      defaultMonthlyInterestRate: (json['defaultMonthlyInterestRate'] ?? 3150.0).toDouble(),
      minimumInterestRate: (json['minimumInterestRate'] ?? 1000.0).toDouble(),
      maximumInterestRate: (json['maximumInterestRate'] ?? 10000.0).toDouble(),
      allowCustomRates: json['allowCustomRates'] ?? true,
      minimumLoanTermMonths: json['minimumLoanTermMonths'] ?? 1,
      maximumLoanTermMonths: json['maximumLoanTermMonths'] ?? 60,
      maxLoanToContributionRatio: (json['maxLoanToContributionRatio'] ?? 3.0).toDouble(),
      minimumContributionMonths: json['minimumContributionMonths'] ?? 6,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      updatedBy: json['updatedBy'] ?? 'System',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'LoanSettings(defaultRate: $defaultMonthlyInterestRate, allowCustom: $allowCustomRates)';
  }
}
