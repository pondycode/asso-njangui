import 'package:uuid/uuid.dart';
import '../models/contribution.dart';
import '../models/member.dart';
import '../models/transaction.dart';
import 'database_service.dart';

class ContributionService {
  static final ContributionService _instance = ContributionService._internal();
  factory ContributionService() => _instance;
  ContributionService._internal();

  static ContributionService get instance => _instance;

  final DatabaseService _db = DatabaseService.instance;

  /// Make a single contribution to a fund
  Future<ContributionResult> makeContribution({
    required String memberId,
    required String fundId,
    required double amount,
    String? notes,
    String? paymentMethod,
    String? reference,
    DateTime? transactionDate,
    String? hostId,
  }) async {
    try {
      // Process the contribution directly without eligibility checks
      return await processContribution(
        memberId: memberId,
        fundAmounts: {fundId: amount},
        contributionType: ContributionType.standard,
        notes: notes,
        paymentMethod: paymentMethod,
        reference: reference,
        transactionDate: transactionDate,
        hostId: hostId,
      );
    } catch (e) {
      return ContributionResult(
        success: false,
        message: 'Error making contribution: $e',
      );
    }
  }

  /// Process a contribution
  Future<ContributionResult> processContribution({
    required String memberId,
    required Map<String, double> fundAmounts,
    required ContributionType contributionType,
    String? notes,
    String? paymentMethod,
    String? reference,
    DateTime? transactionDate,
    String? hostId,
  }) async {
    try {
      // Get member and fund information
      final member = await _db.getMember(memberId);
      if (member == null) {
        return ContributionResult(success: false, message: 'Member not found');
      }

      final fundNames = <String, String>{};
      final previousBalances = <String, double>{};

      for (final fundId in fundAmounts.keys) {
        final fund = await _db.getFund(fundId);
        if (fund == null) {
          return ContributionResult(
            success: false,
            message: 'Fund $fundId not found',
          );
        }
        fundNames[fundId] = fund.name;
        previousBalances[fundId] = fund.getMemberBalance(memberId);
      }

      // Create contribution record
      final contribution = Contribution.create(
        memberId: memberId,
        fundAmounts: fundAmounts,
        fundNames: fundNames,
        previousBalances: previousBalances,
        notes: notes,
        paymentMethod: paymentMethod ?? 'Cash',
        reference: reference,
        date: transactionDate,
        hostId: hostId,
      );

      // Add metadata for contributions
      final updatedContribution = contribution.copyWith(
        metadata: {'contributionType': contributionType.toString()},
      );

      // Save contribution
      await _db.saveContribution(updatedContribution);

      // Create transactions and update fund balances
      final transactions = <Transaction>[];
      for (final fundContribution in updatedContribution.fundContributions) {
        // Update fund balance
        final fund = await _db.getFund(fundContribution.fundId);
        if (fund != null) {
          final updatedFund = fund.updateMemberBalance(
            memberId,
            fundContribution.newBalance,
          );
          await _db.saveFund(updatedFund);
        }

        // Create transaction
        final transaction = Transaction(
          id: const Uuid().v4(),
          memberId: memberId,
          fundId: fundContribution.fundId,
          type: TransactionType.contribution,
          amount: fundContribution.amount,
          date: updatedContribution.date,
          description: 'Contribution to ${fundContribution.fundName}',
          reference: updatedContribution.reference,
          balanceBefore: fundContribution.previousBalance,
          balanceAfter: fundContribution.newBalance,
          receiptNumber: updatedContribution.receiptNumber,
          metadata: {
            'contributionId': updatedContribution.id,
            'contributionType': contributionType.toString(),
            if (hostId != null) 'hostId': hostId,
          },
        );

        transactions.add(transaction);
        await _db.saveTransaction(transaction);
      }

      // Update member balance
      await _updateMemberBalance(member, updatedContribution);

      // Update contribution with transaction IDs
      final finalContribution = updatedContribution.copyWith(
        transactionIds: transactions.map((t) => t.id).toList(),
        isProcessed: true,
        processedDate: DateTime.now(),
        processedBy: 'System', // TODO: Get current user
      );

      await _db.saveContribution(finalContribution);

      return ContributionResult(
        success: true,
        message: 'Contribution processed successfully',
        contribution: finalContribution,
        transactions: transactions,
      );
    } catch (e) {
      return ContributionResult(
        success: false,
        message: 'Error processing contribution: $e',
      );
    }
  }

  Future<void> _updateMemberBalance(
    Member member,
    Contribution contribution,
  ) async {
    final updatedMember = member.copyWith(lastActivityDate: DateTime.now());
    await _db.saveMember(updatedMember);
  }
}

// Enums and Result Classes
enum ContributionType { standard, pledge, installment }

class ContributionResult {
  final bool success;
  final String message;
  final Contribution? contribution;
  final List<Transaction>? transactions;

  ContributionResult({
    required this.success,
    required this.message,
    this.contribution,
    this.transactions,
  });
}
