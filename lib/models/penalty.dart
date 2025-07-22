import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'penalty.g.dart';

@HiveType(typeId: 13)
enum PenaltyType {
  @HiveField(0)
  lateFee,
  @HiveField(1)
  missedContribution,
  @HiveField(2)
  loanDefault,
  @HiveField(3)
  meetingAbsence,
  @HiveField(4)
  ruleViolation,
  @HiveField(5)
  custom,
}

@HiveType(typeId: 14)
enum PenaltyStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  active,
  @HiveField(2)
  paid,
  @HiveField(3)
  waived,
  @HiveField(4)
  cancelled,
}

@HiveType(typeId: 15)
enum PenaltyCalculationType {
  @HiveField(0)
  fixedAmount,
  @HiveField(1)
  percentage,
  @HiveField(2)
  dailyRate,
  @HiveField(3)
  tiered,
}

@HiveType(typeId: 16)
class PenaltyRule extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final PenaltyType type;

  @HiveField(4)
  final PenaltyCalculationType calculationType;

  @HiveField(5)
  final double baseAmount;

  @HiveField(6)
  final double? percentage;

  @HiveField(7)
  final int? gracePeriodDays;

  @HiveField(8)
  final double? maxAmount;

  @HiveField(9)
  final double? minAmount;

  @HiveField(10)
  final bool isActive;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  @HiveField(13)
  final String? createdBy;

  const PenaltyRule({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.calculationType,
    required this.baseAmount,
    this.percentage,
    this.gracePeriodDays,
    this.maxAmount,
    this.minAmount,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    calculationType,
    baseAmount,
    percentage,
    gracePeriodDays,
    maxAmount,
    minAmount,
    isActive,
    createdAt,
    updatedAt,
    createdBy,
  ];

  PenaltyRule copyWith({
    String? id,
    String? name,
    String? description,
    PenaltyType? type,
    PenaltyCalculationType? calculationType,
    double? baseAmount,
    double? percentage,
    int? gracePeriodDays,
    double? maxAmount,
    double? minAmount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return PenaltyRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      calculationType: calculationType ?? this.calculationType,
      baseAmount: baseAmount ?? this.baseAmount,
      percentage: percentage ?? this.percentage,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      maxAmount: maxAmount ?? this.maxAmount,
      minAmount: minAmount ?? this.minAmount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

@HiveType(typeId: 12)
class Penalty extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String memberId;

  @HiveField(2)
  final String ruleId;

  @HiveField(3)
  final PenaltyType type;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final double amount;

  @HiveField(7)
  final double paidAmount;

  @HiveField(8)
  final PenaltyStatus status;

  @HiveField(9)
  final DateTime appliedDate;

  @HiveField(10)
  final DateTime? dueDate;

  @HiveField(11)
  final DateTime? paidDate;

  @HiveField(12)
  final DateTime? waivedDate;

  @HiveField(13)
  final String? waivedBy;

  @HiveField(14)
  final String? waivedReason;

  @HiveField(15)
  final String? relatedEntityId; // loan ID, contribution ID, etc.

  @HiveField(16)
  final String? relatedEntityType; // 'loan', 'contribution', etc.

  @HiveField(17)
  final String? notes;

  @HiveField(18)
  final String? appliedBy;

  @HiveField(19)
  final List<String> paymentTransactionIds;

  const Penalty({
    required this.id,
    required this.memberId,
    required this.ruleId,
    required this.type,
    required this.title,
    required this.description,
    required this.amount,
    this.paidAmount = 0.0,
    this.status = PenaltyStatus.pending,
    required this.appliedDate,
    this.dueDate,
    this.paidDate,
    this.waivedDate,
    this.waivedBy,
    this.waivedReason,
    this.relatedEntityId,
    this.relatedEntityType,
    this.notes,
    this.appliedBy,
    this.paymentTransactionIds = const [],
  });

  @override
  List<Object?> get props => [
    id,
    memberId,
    ruleId,
    type,
    title,
    description,
    amount,
    paidAmount,
    status,
    appliedDate,
    dueDate,
    paidDate,
    waivedDate,
    waivedBy,
    waivedReason,
    relatedEntityId,
    relatedEntityType,
    notes,
    appliedBy,
    paymentTransactionIds,
  ];

  double get remainingAmount => amount - paidAmount;
  bool get isPaid => status == PenaltyStatus.paid;
  bool get isWaived => status == PenaltyStatus.waived;
  bool get isActive => status == PenaltyStatus.active;
  bool get isPending => status == PenaltyStatus.pending;
  bool get isOverdue =>
      dueDate != null &&
      DateTime.now().isAfter(dueDate!) &&
      !isPaid &&
      !isWaived;

  Penalty copyWith({
    String? id,
    String? memberId,
    String? ruleId,
    PenaltyType? type,
    String? title,
    String? description,
    double? amount,
    double? paidAmount,
    PenaltyStatus? status,
    DateTime? appliedDate,
    DateTime? dueDate,
    DateTime? paidDate,
    DateTime? waivedDate,
    String? waivedBy,
    String? waivedReason,
    String? relatedEntityId,
    String? relatedEntityType,
    String? notes,
    String? appliedBy,
    List<String>? paymentTransactionIds,
  }) {
    return Penalty(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      ruleId: ruleId ?? this.ruleId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      waivedDate: waivedDate ?? this.waivedDate,
      waivedBy: waivedBy ?? this.waivedBy,
      waivedReason: waivedReason ?? this.waivedReason,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      notes: notes ?? this.notes,
      appliedBy: appliedBy ?? this.appliedBy,
      paymentTransactionIds:
          paymentTransactionIds ?? this.paymentTransactionIds,
    );
  }
}
