import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'transaction.g.dart';

@HiveType(typeId: 4)
enum TransactionType {
  @HiveField(0)
  contribution,
  @HiveField(1)
  withdrawal,
  @HiveField(2)
  loanDisbursement,
  @HiveField(3)
  loanRepayment,
  @HiveField(4)
  interestPayment,
  @HiveField(5)
  fee,
  @HiveField(6)
  transfer,
  @HiveField(7)
  adjustment,
}

@HiveType(typeId: 5)
class Transaction extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String memberId;

  @HiveField(2)
  final String? fundId;

  @HiveField(3)
  final String? loanId;

  @HiveField(4)
  final TransactionType type;

  @HiveField(5)
  final double amount;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final String? reference;

  @HiveField(9)
  final String? approvedBy;

  @HiveField(10)
  final DateTime? approvalDate;

  @HiveField(11)
  final bool isReversed;

  @HiveField(12)
  final String? reversalReason;

  @HiveField(13)
  final DateTime? reversalDate;

  @HiveField(14)
  final String? reversedBy;

  @HiveField(15)
  final Map<String, dynamic> metadata;

  @HiveField(16)
  final double balanceBefore;

  @HiveField(17)
  final double balanceAfter;

  @HiveField(18)
  final String? receiptNumber;

  @HiveField(19)
  final List<String> attachments;

  const Transaction({
    required this.id,
    required this.memberId,
    this.fundId,
    this.loanId,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.reference,
    this.approvedBy,
    this.approvalDate,
    this.isReversed = false,
    this.reversalReason,
    this.reversalDate,
    this.reversedBy,
    this.metadata = const {},
    this.balanceBefore = 0.0,
    this.balanceAfter = 0.0,
    this.receiptNumber,
    this.attachments = const [],
  });

  bool get isCredit {
    return type == TransactionType.contribution ||
           type == TransactionType.loanDisbursement ||
           type == TransactionType.interestPayment;
  }

  bool get isDebit {
    return type == TransactionType.withdrawal ||
           type == TransactionType.loanRepayment ||
           type == TransactionType.fee;
  }

  double get effectiveAmount {
    if (isReversed) return 0.0;
    return isCredit ? amount : -amount;
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.contribution:
        return 'Contribution';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.loanDisbursement:
        return 'Loan Disbursement';
      case TransactionType.loanRepayment:
        return 'Loan Repayment';
      case TransactionType.interestPayment:
        return 'Interest Payment';
      case TransactionType.fee:
        return 'Fee';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  bool get isApproved => approvedBy != null && approvalDate != null;

  bool get canBeReversed => !isReversed && isApproved;

  Transaction copyWith({
    String? id,
    String? memberId,
    String? fundId,
    String? loanId,
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? description,
    String? reference,
    String? approvedBy,
    DateTime? approvalDate,
    bool? isReversed,
    String? reversalReason,
    DateTime? reversalDate,
    String? reversedBy,
    Map<String, dynamic>? metadata,
    double? balanceBefore,
    double? balanceAfter,
    String? receiptNumber,
    List<String>? attachments,
  }) {
    return Transaction(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      fundId: fundId ?? this.fundId,
      loanId: loanId ?? this.loanId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalDate: approvalDate ?? this.approvalDate,
      isReversed: isReversed ?? this.isReversed,
      reversalReason: reversalReason ?? this.reversalReason,
      reversalDate: reversalDate ?? this.reversalDate,
      reversedBy: reversedBy ?? this.reversedBy,
      metadata: metadata ?? this.metadata,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      attachments: attachments ?? this.attachments,
    );
  }

  Transaction reverse(String reason, String reversedBy) {
    return copyWith(
      isReversed: true,
      reversalReason: reason,
      reversalDate: DateTime.now(),
      reversedBy: reversedBy,
    );
  }

  Transaction approve(String approvedBy) {
    return copyWith(
      approvedBy: approvedBy,
      approvalDate: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        memberId,
        fundId,
        loanId,
        type,
        amount,
        date,
        description,
        reference,
        approvedBy,
        approvalDate,
        isReversed,
        reversalReason,
        reversalDate,
        reversedBy,
        metadata,
        balanceBefore,
        balanceAfter,
        receiptNumber,
        attachments,
      ];

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, date: $date)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'fundId': fundId,
      'loanId': loanId,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'reference': reference,
      'approvedBy': approvedBy,
      'approvalDate': approvalDate?.toIso8601String(),
      'isReversed': isReversed,
      'reversalReason': reversalReason,
      'reversalDate': reversalDate?.toIso8601String(),
      'reversedBy': reversedBy,
      'metadata': metadata,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'receiptNumber': receiptNumber,
      'attachments': attachments,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      memberId: json['memberId'],
      fundId: json['fundId'],
      loanId: json['loanId'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.adjustment,
      ),
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
      reference: json['reference'],
      approvedBy: json['approvedBy'],
      approvalDate: json['approvalDate'] != null 
          ? DateTime.parse(json['approvalDate']) 
          : null,
      isReversed: json['isReversed'] ?? false,
      reversalReason: json['reversalReason'],
      reversalDate: json['reversalDate'] != null 
          ? DateTime.parse(json['reversalDate']) 
          : null,
      reversedBy: json['reversedBy'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      balanceBefore: (json['balanceBefore'] ?? 0.0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0.0).toDouble(),
      receiptNumber: json['receiptNumber'],
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }
}
