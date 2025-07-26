import 'package:uuid/uuid.dart';
import '../models/penalty.dart';
import 'database_service.dart';

class PenaltyService {
  static final PenaltyService _instance = PenaltyService._internal();
  factory PenaltyService() => _instance;
  PenaltyService._internal();

  static PenaltyService get instance => _instance;

  final DatabaseService _db = DatabaseService.instance;
  final Uuid _uuid = const Uuid();

  // Penalty Rules Management
  Future<List<PenaltyRule>> getAllPenaltyRules() async {
    return await _db.getAllPenaltyRules();
  }

  Future<List<PenaltyRule>> getActivePenaltyRules() async {
    final rules = await getAllPenaltyRules();
    return rules.where((rule) => rule.isActive).toList();
  }

  Future<PenaltyRule?> getPenaltyRuleById(String id) async {
    return await _db.getPenaltyRuleById(id);
  }

  Future<void> savePenaltyRule(PenaltyRule rule) async {
    await _db.savePenaltyRule(rule);
  }

  Future<void> deletePenaltyRule(String id) async {
    await _db.deletePenaltyRule(id);
  }

  Future<PenaltyRule> createPenaltyRule({
    required String name,
    required String description,
    required PenaltyType type,
    required PenaltyCalculationType calculationType,
    required double baseAmount,
    double? percentage,
    int? gracePeriodDays,
    double? maxAmount,
    double? minAmount,
    String? createdBy,
  }) async {
    final rule = PenaltyRule(
      id: _uuid.v4(),
      name: name,
      description: description,
      type: type,
      calculationType: calculationType,
      baseAmount: baseAmount,
      percentage: percentage,
      gracePeriodDays: gracePeriodDays,
      maxAmount: maxAmount,
      minAmount: minAmount,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    await savePenaltyRule(rule);
    return rule;
  }

  // Penalties Management
  Future<List<Penalty>> getAllPenalties() async {
    return await _db.getAllPenalties();
  }

  Future<List<Penalty>> getPenaltiesForMember(String memberId) async {
    final penalties = await getAllPenalties();
    return penalties.where((penalty) => penalty.memberId == memberId).toList();
  }

  Future<List<Penalty>> getActivePenalties() async {
    final penalties = await getAllPenalties();
    return penalties.where((penalty) => 
      penalty.status == PenaltyStatus.active || penalty.status == PenaltyStatus.pending
    ).toList();
  }

  Future<List<Penalty>> getOverduePenalties() async {
    final penalties = await getActivePenalties();
    return penalties.where((penalty) => penalty.isOverdue).toList();
  }

  Future<Penalty?> getPenaltyById(String id) async {
    return await _db.getPenaltyById(id);
  }

  Future<void> savePenalty(Penalty penalty) async {
    await _db.savePenalty(penalty);
  }

  Future<void> deletePenalty(String id) async {
    await _db.deletePenalty(id);
  }

  // Apply Penalty
  Future<Penalty> applyPenalty({
    required String memberId,
    required String ruleId,
    required String title,
    required String description,
    required double amount,
    DateTime? dueDate,
    String? relatedEntityId,
    String? relatedEntityType,
    String? notes,
    String? appliedBy,
  }) async {
    final rule = await getPenaltyRuleById(ruleId);
    if (rule == null) {
      throw Exception('Penalty rule not found');
    }

    final penalty = Penalty(
      id: _uuid.v4(),
      memberId: memberId,
      ruleId: ruleId,
      type: rule.type,
      title: title,
      description: description,
      amount: amount,
      status: PenaltyStatus.active,
      appliedDate: DateTime.now(),
      dueDate: dueDate,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
      notes: notes,
      appliedBy: appliedBy,
    );

    await savePenalty(penalty);
    return penalty;
  }

  // Calculate Penalty Amount
  double calculatePenaltyAmount(PenaltyRule rule, {
    double? baseValue,
    int? daysPastDue,
  }) {
    double amount = 0.0;

    switch (rule.calculationType) {
      case PenaltyCalculationType.fixedAmount:
        amount = rule.baseAmount;
        break;
      case PenaltyCalculationType.percentage:
        if (baseValue != null && rule.percentage != null) {
          amount = baseValue * (rule.percentage! / 100);
        }
        break;
      case PenaltyCalculationType.dailyRate:
        if (daysPastDue != null) {
          amount = rule.baseAmount * daysPastDue;
        }
        break;
      case PenaltyCalculationType.tiered:
        // Implement tiered calculation logic here
        amount = rule.baseAmount;
        break;
    }

    // Apply min/max limits
    if (rule.minAmount != null && amount < rule.minAmount!) {
      amount = rule.minAmount!;
    }
    if (rule.maxAmount != null && amount > rule.maxAmount!) {
      amount = rule.maxAmount!;
    }

    return amount;
  }

  // Pay Penalty
  Future<void> payPenalty(String penaltyId, double amount, String transactionId) async {
    final penalty = await getPenaltyById(penaltyId);
    if (penalty == null) {
      throw Exception('Penalty not found');
    }

    final newPaidAmount = penalty.paidAmount + amount;
    final newTransactionIds = List<String>.from(penalty.paymentTransactionIds)..add(transactionId);
    
    final updatedPenalty = penalty.copyWith(
      paidAmount: newPaidAmount,
      status: newPaidAmount >= penalty.amount ? PenaltyStatus.paid : penalty.status,
      paidDate: newPaidAmount >= penalty.amount ? DateTime.now() : penalty.paidDate,
      paymentTransactionIds: newTransactionIds,
    );

    await savePenalty(updatedPenalty);
  }

  // Waive Penalty
  Future<void> waivePenalty(String penaltyId, String reason, String waivedBy) async {
    final penalty = await getPenaltyById(penaltyId);
    if (penalty == null) {
      throw Exception('Penalty not found');
    }

    final updatedPenalty = penalty.copyWith(
      status: PenaltyStatus.waived,
      waivedDate: DateTime.now(),
      waivedReason: reason,
      waivedBy: waivedBy,
    );

    await savePenalty(updatedPenalty);
  }

  // Auto-apply penalties based on rules
  Future<List<Penalty>> autoApplyPenalties() async {
    final appliedPenalties = <Penalty>[];
    final rules = await getActivePenaltyRules();
    
    for (final rule in rules) {
      switch (rule.type) {
        case PenaltyType.loanDefault:
          final loanPenalties = await _checkLoanDefaultPenalties(rule);
          appliedPenalties.addAll(loanPenalties);
          break;
        case PenaltyType.missedContribution:
          // Implement missed contribution penalty logic
          break;
        case PenaltyType.meetingAbsence:
          // Implement meeting absence penalty logic
          break;
        default:
          break;
      }
    }

    return appliedPenalties;
  }

  Future<List<Penalty>> _checkLoanDefaultPenalties(PenaltyRule rule) async {
    final appliedPenalties = <Penalty>[];
    // Implementation would check for overdue loans and apply penalties
    // This is a placeholder for the actual implementation
    return appliedPenalties;
  }

  // Get penalty statistics
  Future<Map<String, dynamic>> getPenaltyStatistics() async {
    final penalties = await getAllPenalties();
    
    final totalPenalties = penalties.length;
    final activePenalties = penalties.where((p) => p.isActive).length;
    final paidPenalties = penalties.where((p) => p.isPaid).length;
    final waivedPenalties = penalties.where((p) => p.isWaived).length;
    final overduePenalties = penalties.where((p) => p.isOverdue).length;
    
    final totalAmount = penalties.fold(0.0, (sum, p) => sum + p.amount);
    final paidAmount = penalties.fold(0.0, (sum, p) => sum + p.paidAmount);
    final outstandingAmount = totalAmount - paidAmount;

    return {
      'totalPenalties': totalPenalties,
      'activePenalties': activePenalties,
      'paidPenalties': paidPenalties,
      'waivedPenalties': waivedPenalties,
      'overduePenalties': overduePenalties,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'outstandingAmount': outstandingAmount,
    };
  }
}
