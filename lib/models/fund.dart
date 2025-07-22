import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'fund.g.dart';

@HiveType(typeId: 2)
enum FundType {
  @HiveField(0)
  savings,
  @HiveField(1)
  investment,
  @HiveField(2)
  emergency,
  @HiveField(3)
  loan,
}

@HiveType(typeId: 3)
class Fund extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final FundType type;

  @HiveField(4)
  final double balance;

  @HiveField(5)
  final double targetAmount;

  @HiveField(6)
  final double interestRate;

  @HiveField(7)
  final DateTime createdDate;

  @HiveField(8)
  final DateTime lastUpdated;

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final String? managerId;

  @HiveField(11)
  final double minimumContribution;

  @HiveField(12)
  final double maximumContribution;

  @HiveField(13)
  final int contributionFrequencyDays;

  @HiveField(14)
  final Map<String, double> memberBalances;

  @HiveField(15)
  final Map<String, dynamic> settings;

  @HiveField(16)
  final List<String> allowedMembers;

  @HiveField(17)
  final double totalContributions;

  @HiveField(18)
  final double totalWithdrawals;

  const Fund({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.balance = 0.0,
    this.targetAmount = 0.0,
    this.interestRate = 0.0,
    required this.createdDate,
    required this.lastUpdated,
    this.isActive = true,
    this.managerId,
    this.minimumContribution = 0.0,
    this.maximumContribution = 999999999.0,
    this.contributionFrequencyDays = 30,
    this.memberBalances = const {},
    this.settings = const {},
    this.allowedMembers = const [],
    this.totalContributions = 0.0,
    this.totalWithdrawals = 0.0,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (balance / targetAmount * 100).clamp(0.0, 100.0);
  }

  double get netFlow => totalContributions - totalWithdrawals;

  int get memberCount => memberBalances.length;

  double get averageBalance {
    if (memberBalances.isEmpty) return 0.0;
    return memberBalances.values.reduce((a, b) => a + b) /
        memberBalances.length;
  }

  bool get hasReachedTarget => balance >= targetAmount && targetAmount > 0;

  String get typeDisplayName {
    switch (type) {
      case FundType.savings:
        return 'Savings Fund';
      case FundType.investment:
        return 'Investment Fund';
      case FundType.emergency:
        return 'Emergency Fund';
      case FundType.loan:
        return 'Loan Fund';
    }
  }

  double getMemberBalance(String memberId) {
    return memberBalances[memberId] ?? 0.0;
  }

  bool canMemberContribute(String memberId) {
    return isActive &&
        (allowedMembers.isEmpty || allowedMembers.contains(memberId));
  }

  Fund copyWith({
    String? id,
    String? name,
    String? description,
    FundType? type,
    double? balance,
    double? targetAmount,
    double? interestRate,
    DateTime? createdDate,
    DateTime? lastUpdated,
    bool? isActive,
    String? managerId,
    double? minimumContribution,
    double? maximumContribution,
    int? contributionFrequencyDays,
    Map<String, double>? memberBalances,
    Map<String, dynamic>? settings,
    List<String>? allowedMembers,
    double? totalContributions,
    double? totalWithdrawals,
  }) {
    return Fund(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      targetAmount: targetAmount ?? this.targetAmount,
      interestRate: interestRate ?? this.interestRate,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      managerId: managerId ?? this.managerId,
      minimumContribution: minimumContribution ?? this.minimumContribution,
      maximumContribution: maximumContribution ?? this.maximumContribution,
      contributionFrequencyDays:
          contributionFrequencyDays ?? this.contributionFrequencyDays,
      memberBalances: memberBalances ?? this.memberBalances,
      settings: settings ?? this.settings,
      allowedMembers: allowedMembers ?? this.allowedMembers,
      totalContributions: totalContributions ?? this.totalContributions,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
    );
  }

  Fund updateMemberBalance(String memberId, double newBalance) {
    final updatedBalances = Map<String, double>.from(memberBalances);
    updatedBalances[memberId] = newBalance;

    final totalBalance = updatedBalances.values.fold(
      0.0,
      (sum, balance) => sum + balance,
    );

    return copyWith(
      memberBalances: updatedBalances,
      balance: totalBalance,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    balance,
    targetAmount,
    interestRate,
    createdDate,
    lastUpdated,
    isActive,
    managerId,
    minimumContribution,
    maximumContribution,
    contributionFrequencyDays,
    memberBalances,
    settings,
    allowedMembers,
    totalContributions,
    totalWithdrawals,
  ];

  @override
  String toString() {
    return 'Fund(id: $id, name: $name, type: $type, balance: $balance)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'balance': balance,
      'targetAmount': targetAmount,
      'interestRate': interestRate,
      'createdDate': createdDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
      'managerId': managerId,
      'minimumContribution': minimumContribution,
      'maximumContribution': maximumContribution,
      'contributionFrequencyDays': contributionFrequencyDays,
      'memberBalances': memberBalances,
      'settings': settings,
      'allowedMembers': allowedMembers,
      'totalContributions': totalContributions,
      'totalWithdrawals': totalWithdrawals,
    };
  }

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: FundType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FundType.savings,
      ),
      balance: (json['balance'] ?? 0.0).toDouble(),
      targetAmount: (json['targetAmount'] ?? 0.0).toDouble(),
      interestRate: (json['interestRate'] ?? 0.0).toDouble(),
      createdDate: DateTime.parse(json['createdDate']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isActive: json['isActive'] ?? true,
      managerId: json['managerId'],
      minimumContribution: (json['minimumContribution'] ?? 0.0).toDouble(),
      maximumContribution: (json['maximumContribution'] ?? 999999999.0)
          .toDouble(),
      contributionFrequencyDays: json['contributionFrequencyDays'] ?? 30,
      memberBalances: Map<String, double>.from(json['memberBalances'] ?? {}),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      allowedMembers: List<String>.from(json['allowedMembers'] ?? []),
      totalContributions: (json['totalContributions'] ?? 0.0).toDouble(),
      totalWithdrawals: (json['totalWithdrawals'] ?? 0.0).toDouble(),
    );
  }
}
