import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'loan.g.dart';

@HiveType(typeId: 6)
enum LoanStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  disbursed,
  @HiveField(3)
  active,
  @HiveField(4)
  completed,
  @HiveField(5)
  defaulted,
  @HiveField(6)
  cancelled,
}

@HiveType(typeId: 7)
class LoanRepayment extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final double principalAmount;

  @HiveField(3)
  final double interestAmount;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final DateTime? paidDate;

  @HiveField(6)
  final bool isPaid;

  @HiveField(7)
  final String? transactionId;

  const LoanRepayment({
    required this.id,
    required this.amount,
    required this.principalAmount,
    required this.interestAmount,
    required this.dueDate,
    this.paidDate,
    this.isPaid = false,
    this.transactionId,
  });

  bool get isOverdue => !isPaid && DateTime.now().isAfter(dueDate);

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  LoanRepayment copyWith({
    String? id,
    double? amount,
    double? principalAmount,
    double? interestAmount,
    DateTime? dueDate,
    DateTime? paidDate,
    bool? isPaid,
    String? transactionId,
  }) {
    return LoanRepayment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      principalAmount: principalAmount ?? this.principalAmount,
      interestAmount: interestAmount ?? this.interestAmount,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      isPaid: isPaid ?? this.isPaid,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    principalAmount,
    interestAmount,
    dueDate,
    paidDate,
    isPaid,
    transactionId,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'principalAmount': principalAmount,
      'interestAmount': interestAmount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'isPaid': isPaid,
      'transactionId': transactionId,
    };
  }

  factory LoanRepayment.fromJson(Map<String, dynamic> json) {
    return LoanRepayment(
      id: json['id'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      principalAmount: (json['principalAmount'] ?? 0.0).toDouble(),
      interestAmount: (json['interestAmount'] ?? 0.0).toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
      isPaid: json['isPaid'] ?? false,
      transactionId: json['transactionId'],
    );
  }
}

@HiveType(typeId: 8)
class Loan extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String memberId;

  @HiveField(2)
  final double principalAmount;

  @HiveField(3)
  final double interestRate;

  @HiveField(4)
  final int termInMonths;

  @HiveField(5)
  final DateTime applicationDate;

  @HiveField(6)
  final DateTime? approvalDate;

  @HiveField(7)
  final DateTime? disbursementDate;

  @HiveField(8)
  final LoanStatus status;

  @HiveField(9)
  final String purpose;

  @HiveField(10)
  final String? approvedBy;

  @HiveField(11)
  final String? disbursedBy;

  @HiveField(12)
  final double paidAmount;

  @HiveField(13)
  final double outstandingAmount;

  @HiveField(14)
  final List<LoanRepayment> repayments;

  @HiveField(15)
  final Map<String, dynamic> metadata;

  @HiveField(16)
  final List<String> guarantors;

  @HiveField(17)
  final String? collateral;

  @HiveField(18)
  final double monthlyPayment;

  const Loan({
    required this.id,
    required this.memberId,
    required this.principalAmount,
    required this.interestRate,
    required this.termInMonths,
    required this.applicationDate,
    this.approvalDate,
    this.disbursementDate,
    required this.status,
    required this.purpose,
    this.approvedBy,
    this.disbursedBy,
    this.paidAmount = 0.0,
    required this.outstandingAmount,
    this.repayments = const [],
    this.metadata = const {},
    this.guarantors = const [],
    this.collateral,
    required this.monthlyPayment,
  });

  double get totalAmount => principalAmount + totalInterest;

  // Interest is calculated month by month based on elapsed time, not fixed term
  double get totalInterest {
    // This will be calculated dynamically based on elapsed months
    // Default to 0 here, actual calculation done in service
    return 0.0;
  }

  double get remainingBalance => totalAmount - paidAmount;

  int get remainingPayments => repayments.where((r) => !r.isPaid).length;

  int get completedPayments => repayments.where((r) => r.isPaid).length;

  double get progressPercentage {
    if (totalAmount <= 0) return 0.0;
    return (paidAmount / totalAmount * 100).clamp(0.0, 100.0);
  }

  bool get isOverdue => repayments.any((r) => r.isOverdue);

  int get daysOverdue {
    final overdueRepayments = repayments.where((r) => r.isOverdue);
    if (overdueRepayments.isEmpty) return 0;
    return overdueRepayments
        .map((r) => r.daysOverdue)
        .reduce((a, b) => a > b ? a : b);
  }

  LoanRepayment? get nextPayment {
    final unpaidRepayments = repayments.where((r) => !r.isPaid).toList();
    if (unpaidRepayments.isEmpty) return null;
    unpaidRepayments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return unpaidRepayments.first;
  }

  bool get isActive =>
      status == LoanStatus.active || status == LoanStatus.disbursed;

  bool get isCompleted => status == LoanStatus.completed;

  String get statusDisplayName {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending Approval';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.disbursed:
        return 'Disbursed';
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.defaulted:
        return 'Defaulted';
      case LoanStatus.cancelled:
        return 'Cancelled';
    }
  }

  static List<LoanRepayment> generateRepaymentSchedule({
    required String loanId,
    required double principalAmount,
    required double interestRate,
    required int termInMonths,
    required DateTime startDate,
    double? monthlyInterestAmount,
  }) {
    final List<LoanRepayment> repayments = [];
    final monthlyInterest =
        monthlyInterestAmount ?? 3150.0; // Use provided rate or default
    final monthlyPrincipal = principalAmount / termInMonths;
    final monthlyPayment = monthlyPrincipal + monthlyInterest;

    // Note: In the new system, interest accumulates month by month
    // regardless of the original term. This schedule is just a guideline.

    for (int i = 0; i < termInMonths; i++) {
      final dueDate = DateTime(
        startDate.year,
        startDate.month + i + 1,
        startDate.day,
      );

      repayments.add(
        LoanRepayment(
          id: '${loanId}_payment_${i + 1}',
          amount: monthlyPayment,
          principalAmount: monthlyPrincipal,
          interestAmount: monthlyInterest,
          dueDate: dueDate,
        ),
      );
    }

    return repayments;
  }

  Loan copyWith({
    String? id,
    String? memberId,
    double? principalAmount,
    double? interestRate,
    int? termInMonths,
    DateTime? applicationDate,
    DateTime? approvalDate,
    DateTime? disbursementDate,
    LoanStatus? status,
    String? purpose,
    String? approvedBy,
    String? disbursedBy,
    double? paidAmount,
    double? outstandingAmount,
    List<LoanRepayment>? repayments,
    Map<String, dynamic>? metadata,
    List<String>? guarantors,
    String? collateral,
    double? monthlyPayment,
  }) {
    return Loan(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      principalAmount: principalAmount ?? this.principalAmount,
      interestRate: interestRate ?? this.interestRate,
      termInMonths: termInMonths ?? this.termInMonths,
      applicationDate: applicationDate ?? this.applicationDate,
      approvalDate: approvalDate ?? this.approvalDate,
      disbursementDate: disbursementDate ?? this.disbursementDate,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      approvedBy: approvedBy ?? this.approvedBy,
      disbursedBy: disbursedBy ?? this.disbursedBy,
      paidAmount: paidAmount ?? this.paidAmount,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      repayments: repayments ?? this.repayments,
      metadata: metadata ?? this.metadata,
      guarantors: guarantors ?? this.guarantors,
      collateral: collateral ?? this.collateral,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
    );
  }

  @override
  List<Object?> get props => [
    id,
    memberId,
    principalAmount,
    interestRate,
    termInMonths,
    applicationDate,
    approvalDate,
    disbursementDate,
    status,
    purpose,
    approvedBy,
    disbursedBy,
    paidAmount,
    outstandingAmount,
    repayments,
    metadata,
    guarantors,
    collateral,
    monthlyPayment,
  ];

  @override
  String toString() {
    return 'Loan(id: $id, memberId: $memberId, amount: $principalAmount, status: $status)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'principalAmount': principalAmount,
      'interestRate': interestRate,
      'termInMonths': termInMonths,
      'applicationDate': applicationDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'disbursementDate': disbursementDate?.toIso8601String(),
      'status': status.name,
      'purpose': purpose,
      'approvedBy': approvedBy,
      'disbursedBy': disbursedBy,
      'paidAmount': paidAmount,
      'outstandingAmount': outstandingAmount,
      'repayments': repayments.map((r) => r.toJson()).toList(),
      'metadata': metadata,
      'guarantors': guarantors,
      'collateral': collateral,
      'monthlyPayment': monthlyPayment,
    };
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      memberId: json['memberId'],
      principalAmount: (json['principalAmount'] ?? 0.0).toDouble(),
      interestRate: (json['interestRate'] ?? 0.0).toDouble(),
      termInMonths: json['termInMonths'] ?? 0,
      applicationDate: DateTime.parse(json['applicationDate']),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
      disbursementDate: json['disbursementDate'] != null
          ? DateTime.parse(json['disbursementDate'])
          : null,
      status: LoanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LoanStatus.pending,
      ),
      purpose: json['purpose'] ?? '',
      approvedBy: json['approvedBy'],
      disbursedBy: json['disbursedBy'],
      paidAmount: (json['paidAmount'] ?? 0.0).toDouble(),
      outstandingAmount: (json['outstandingAmount'] ?? 0.0).toDouble(),
      repayments: (json['repayments'] as List? ?? [])
          .map((r) => LoanRepayment.fromJson(r))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      guarantors: List<String>.from(json['guarantors'] ?? []),
      collateral: json['collateral'],
      monthlyPayment: (json['monthlyPayment'] ?? 0.0).toDouble(),
    );
  }
}
