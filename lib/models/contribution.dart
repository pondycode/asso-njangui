import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'contribution.g.dart';

@HiveType(typeId: 9)
class FundContribution extends Equatable {
  @HiveField(0)
  final String fundId;

  @HiveField(1)
  final String fundName;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final double previousBalance;

  @HiveField(4)
  final double newBalance;

  const FundContribution({
    required this.fundId,
    required this.fundName,
    required this.amount,
    required this.previousBalance,
    required this.newBalance,
  });

  FundContribution copyWith({
    String? fundId,
    String? fundName,
    double? amount,
    double? previousBalance,
    double? newBalance,
  }) {
    return FundContribution(
      fundId: fundId ?? this.fundId,
      fundName: fundName ?? this.fundName,
      amount: amount ?? this.amount,
      previousBalance: previousBalance ?? this.previousBalance,
      newBalance: newBalance ?? this.newBalance,
    );
  }

  @override
  List<Object?> get props => [
    fundId,
    fundName,
    amount,
    previousBalance,
    newBalance,
  ];

  Map<String, dynamic> toJson() {
    return {
      'fundId': fundId,
      'fundName': fundName,
      'amount': amount,
      'previousBalance': previousBalance,
      'newBalance': newBalance,
    };
  }

  factory FundContribution.fromJson(Map<String, dynamic> json) {
    return FundContribution(
      fundId: json['fundId'],
      fundName: json['fundName'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      previousBalance: (json['previousBalance'] ?? 0.0).toDouble(),
      newBalance: (json['newBalance'] ?? 0.0).toDouble(),
    );
  }
}

@HiveType(typeId: 10)
class Contribution extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String memberId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final List<FundContribution> fundContributions;

  @HiveField(4)
  final double totalAmount;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String? receiptNumber;

  @HiveField(7)
  final String? processedBy;

  @HiveField(8)
  final DateTime? processedDate;

  @HiveField(9)
  final bool isProcessed;

  @HiveField(10)
  final String? paymentMethod;

  @HiveField(11)
  final String? reference;

  @HiveField(12)
  final Map<String, dynamic> metadata;

  @HiveField(13)
  final List<String> transactionIds;

  const Contribution({
    required this.id,
    required this.memberId,
    required this.date,
    required this.fundContributions,
    required this.totalAmount,
    this.notes,
    this.receiptNumber,
    this.processedBy,
    this.processedDate,
    this.isProcessed = false,
    this.paymentMethod,
    this.reference,
    this.metadata = const {},
    this.transactionIds = const [],
  });

  int get fundCount => fundContributions.length;

  bool get isMultiFund => fundContributions.length > 1;

  double get calculatedTotal => fundContributions.fold(
    0.0,
    (sum, contribution) => sum + contribution.amount,
  );

  bool get isValidTotal => (totalAmount - calculatedTotal).abs() < 0.01;

  List<String> get fundNames =>
      fundContributions.map((c) => c.fundName).toList();

  FundContribution? getContributionForFund(String fundId) {
    try {
      return fundContributions.firstWhere((c) => c.fundId == fundId);
    } catch (e) {
      return null;
    }
  }

  double getAmountForFund(String fundId) {
    final contribution = getContributionForFund(fundId);
    return contribution?.amount ?? 0.0;
  }

  Contribution copyWith({
    String? id,
    String? memberId,
    DateTime? date,
    List<FundContribution>? fundContributions,
    double? totalAmount,
    String? notes,
    String? receiptNumber,
    String? processedBy,
    DateTime? processedDate,
    bool? isProcessed,
    String? paymentMethod,
    String? reference,
    Map<String, dynamic>? metadata,
    List<String>? transactionIds,
  }) {
    return Contribution(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      date: date ?? this.date,
      fundContributions: fundContributions ?? this.fundContributions,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      processedBy: processedBy ?? this.processedBy,
      processedDate: processedDate ?? this.processedDate,
      isProcessed: isProcessed ?? this.isProcessed,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reference: reference ?? this.reference,
      metadata: metadata ?? this.metadata,
      transactionIds: transactionIds ?? this.transactionIds,
    );
  }

  Contribution process(String processedBy) {
    return copyWith(
      isProcessed: true,
      processedBy: processedBy,
      processedDate: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    memberId,
    date,
    fundContributions,
    totalAmount,
    notes,
    receiptNumber,
    processedBy,
    processedDate,
    isProcessed,
    paymentMethod,
    reference,
    metadata,
    transactionIds,
  ];

  @override
  String toString() {
    return 'Contribution(id: $id, memberId: $memberId, totalAmount: $totalAmount, fundCount: $fundCount)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'date': date.toIso8601String(),
      'fundContributions': fundContributions.map((c) => c.toJson()).toList(),
      'totalAmount': totalAmount,
      'notes': notes,
      'receiptNumber': receiptNumber,
      'processedBy': processedBy,
      'processedDate': processedDate?.toIso8601String(),
      'isProcessed': isProcessed,
      'paymentMethod': paymentMethod,
      'reference': reference,
      'metadata': metadata,
      'transactionIds': transactionIds,
    };
  }

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'],
      memberId: json['memberId'],
      date: DateTime.parse(json['date']),
      fundContributions: (json['fundContributions'] as List)
          .map((c) => FundContribution.fromJson(c))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      notes: json['notes'],
      receiptNumber: json['receiptNumber'],
      processedBy: json['processedBy'],
      processedDate: json['processedDate'] != null
          ? DateTime.parse(json['processedDate'])
          : null,
      isProcessed: json['isProcessed'] ?? false,
      paymentMethod: json['paymentMethod'],
      reference: json['reference'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      transactionIds: List<String>.from(json['transactionIds'] ?? []),
    );
  }

  static Contribution create({
    required String memberId,
    required Map<String, double> fundAmounts,
    required Map<String, String> fundNames,
    required Map<String, double> previousBalances,
    String? notes,
    String? paymentMethod,
    String? reference,
    DateTime? date,
    String? hostId,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final contributionDate = date ?? DateTime.now();

    final fundContributions = fundAmounts.entries.map((entry) {
      final fundId = entry.key;
      final amount = entry.value;
      final previousBalance = previousBalances[fundId] ?? 0.0;

      return FundContribution(
        fundId: fundId,
        fundName: fundNames[fundId] ?? 'Unknown Fund',
        amount: amount,
        previousBalance: previousBalance,
        newBalance: previousBalance + amount,
      );
    }).toList();

    final totalAmount = fundContributions.fold(0.0, (sum, c) => sum + c.amount);

    return Contribution(
      id: id,
      memberId: memberId,
      date: contributionDate,
      fundContributions: fundContributions,
      totalAmount: totalAmount,
      notes: notes,
      paymentMethod: paymentMethod,
      reference: reference,
      metadata: hostId != null ? {'hostId': hostId} : {},
    );
  }
}
