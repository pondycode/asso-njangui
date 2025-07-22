import 'dart:math' as math;
import '../models/loan.dart';
import '../models/fund.dart';
import '../models/member.dart';
import '../models/transaction.dart';
import '../providers/loan_settings_provider.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';

class LoanService {
  static final LoanService _instance = LoanService._internal();
  factory LoanService() => _instance;
  LoanService._internal();

  static LoanService get instance => _instance;

  final DatabaseService _db = DatabaseService.instance;
  final LoanSettingsProvider _loanSettings = LoanSettingsProvider();

  /// Check if a member is eligible for a loan
  Future<LoanEligibilityResult> checkEligibility({
    required String memberId,
    required double requestedAmount,
    required String fundId,
  }) async {
    try {
      final member = await _db.getMember(memberId);
      if (member == null) {
        return LoanEligibilityResult(
          isEligible: false,
          reason: 'Member not found',
        );
      }

      final fund = await _db.getFund(fundId);
      if (fund == null) {
        return LoanEligibilityResult(
          isEligible: false,
          reason: 'Fund not found',
        );
      }

      // Check member status
      if (member.status != MemberStatus.active) {
        return LoanEligibilityResult(
          isEligible: false,
          reason: 'Member is not active',
        );
      }

      // Check fund availability
      if (!fund.isActive) {
        return LoanEligibilityResult(
          isEligible: false,
          reason: 'Fund is not active',
        );
      }

      if (fund.balance < requestedAmount) {
        return LoanEligibilityResult(
          isEligible: false,
          reason: 'Insufficient fund balance',
          availableAmount: fund.balance,
        );
      }

      // Check member's outstanding loans
      final memberLoans = await _db.getMemberLoans(memberId);
      final activeLoans = memberLoans.where((loan) => loan.isActive).toList();

      if (activeLoans.length >= 3) {
        // Maximum 3 active loans
        return LoanEligibilityResult(
          isEligible: false,
          reason: 'Maximum number of active loans reached (3)',
        );
      }

      final totalOutstanding = activeLoans.fold(
        0.0,
        (sum, loan) => sum + loan.remainingBalance,
      );
      final maxLoanAmount = _calculateMaxLoanAmount(member, fund);

      if (totalOutstanding + requestedAmount > maxLoanAmount) {
        return LoanEligibilityResult(
          isEligible: false,
          reason: 'Requested amount exceeds maximum loan capacity',
          maxAllowedAmount: maxLoanAmount - totalOutstanding,
        );
      }

      // Check member's contribution history
      final contributions = await _db.getMemberContributions(memberId);
      final fundContributions = contributions
          .where((c) => c.fundContributions.any((fc) => fc.fundId == fundId))
          .toList();

      if (fundContributions.isEmpty) {
        return LoanEligibilityResult(
          isEligible: false,
          reason: 'Member must contribute to the fund before borrowing',
        );
      }

      // Check minimum contribution period using configurable setting
      final firstContribution = fundContributions
          .map((c) => c.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);

      final monthsSinceFirstContribution =
          DateTime.now().difference(firstContribution).inDays / 30;

      final minContributionMonths =
          _loanSettings.settings.minimumContributionMonths;
      if (monthsSinceFirstContribution < minContributionMonths) {
        return LoanEligibilityResult(
          isEligible: false,
          reason:
              'Member must contribute for at least $minContributionMonths months before borrowing',
        );
      }

      return LoanEligibilityResult(
        isEligible: true,
        reason: 'Eligible for loan',
        maxAllowedAmount: maxLoanAmount - totalOutstanding,
        recommendedAmount: _calculateRecommendedAmount(
          member,
          fund,
          requestedAmount,
        ),
      );
    } catch (e) {
      return LoanEligibilityResult(
        isEligible: false,
        reason: 'Error checking eligibility: $e',
      );
    }
  }

  /// Calculate maximum loan amount for a member
  double _calculateMaxLoanAmount(Member member, Fund fund) {
    // Base calculation: configurable ratio x member's total contributions to the fund
    final memberBalance = fund.memberBalances[member.id] ?? 0.0;
    final loanRatio = _loanSettings.settings.maxLoanToContributionRatio;
    final baseAmount = memberBalance * loanRatio;

    // Cap at 50% of fund balance
    final maxFromFund = fund.balance * 0.5;

    return math.min(baseAmount, maxFromFund);
  }

  /// Calculate recommended loan amount
  double _calculateRecommendedAmount(
    Member member,
    Fund fund,
    double requestedAmount,
  ) {
    final maxAmount = _calculateMaxLoanAmount(member, fund);
    return math.min(requestedAmount, maxAmount * 0.8); // 80% of max for safety
  }

  /// Approve a loan application
  Future<LoanApprovalResult> approveLoan({
    required String loanId,
    required String approvedBy,
    String? notes,
  }) async {
    try {
      final loan = await _db.getLoan(loanId);
      if (loan == null) {
        return LoanApprovalResult(success: false, message: 'Loan not found');
      }

      if (loan.status != LoanStatus.pending) {
        return LoanApprovalResult(
          success: false,
          message: 'Loan is not in pending status',
        );
      }

      // Re-check eligibility
      final fundId = loan.metadata['fundId'] as String?;
      if (fundId == null) {
        return LoanApprovalResult(
          success: false,
          message: 'Fund information missing from loan',
        );
      }

      final eligibility = await checkEligibility(
        memberId: loan.memberId,
        requestedAmount: loan.principalAmount,
        fundId: fundId,
      );

      if (!eligibility.isEligible) {
        return LoanApprovalResult(
          success: false,
          message: 'Loan no longer eligible: ${eligibility.reason}',
        );
      }

      final approvedLoan = loan.copyWith(
        status: LoanStatus.approved,
        approvalDate: DateTime.now(),
        approvedBy: approvedBy,
        metadata: {...loan.metadata, 'approvalNotes': notes ?? ''},
      );

      await _db.saveLoan(approvedLoan);

      return LoanApprovalResult(
        success: true,
        message: 'Loan approved successfully',
        loan: approvedLoan,
      );
    } catch (e) {
      return LoanApprovalResult(
        success: false,
        message: 'Error approving loan: $e',
      );
    }
  }

  /// Disburse an approved loan
  Future<LoanDisbursementResult> disburseLoan({
    required String loanId,
    required String disbursedBy,
    String? notes,
  }) async {
    try {
      final loan = await _db.getLoan(loanId);
      if (loan == null) {
        return LoanDisbursementResult(
          success: false,
          message: 'Loan not found',
        );
      }

      if (loan.status != LoanStatus.approved) {
        return LoanDisbursementResult(
          success: false,
          message: 'Loan is not approved',
        );
      }

      final fundId = loan.metadata['fundId'] as String?;
      if (fundId == null) {
        return LoanDisbursementResult(
          success: false,
          message: 'Fund information missing from loan',
        );
      }

      final fund = await _db.getFund(fundId);
      if (fund == null) {
        return LoanDisbursementResult(
          success: false,
          message: 'Fund not found',
        );
      }

      if (fund.balance < loan.principalAmount) {
        return LoanDisbursementResult(
          success: false,
          message: 'Insufficient fund balance',
        );
      }

      // Update fund balance
      final updatedFund = fund.copyWith(
        balance: fund.balance - loan.principalAmount,
        totalWithdrawals: fund.totalWithdrawals + loan.principalAmount,
        lastUpdated: DateTime.now(),
      );

      // Update loan status
      final disbursedLoan = loan.copyWith(
        status: LoanStatus.active,
        disbursementDate: DateTime.now(),
        disbursedBy: disbursedBy,
        metadata: {...loan.metadata, 'disbursementNotes': notes ?? ''},
      );

      // Create transaction record
      final transaction = Transaction(
        id: const Uuid().v4(),
        memberId: loan.memberId,
        fundId: fundId,
        amount: loan.principalAmount,
        type: TransactionType.withdrawal,
        description: 'Loan disbursement - ${loan.purpose}',
        date: DateTime.now(),
        reference: 'LOAN-${loan.id.substring(0, 8)}',
        metadata: {'loanId': loan.id, 'disbursedBy': disbursedBy},
      );

      // Update member's outstanding loans
      final member = await _db.getMember(loan.memberId);
      if (member != null) {
        final updatedMember = member.copyWith(
          outstandingLoans: member.outstandingLoans + loan.principalAmount,
          lastActivityDate: DateTime.now(),
        );
        await _db.saveMember(updatedMember);
      }

      // Save all updates
      await _db.saveFund(updatedFund);
      await _db.saveLoan(disbursedLoan);
      await _db.saveTransaction(transaction);

      return LoanDisbursementResult(
        success: true,
        message: 'Loan disbursed successfully',
        loan: disbursedLoan,
        transaction: transaction,
      );
    } catch (e) {
      return LoanDisbursementResult(
        success: false,
        message: 'Error disbursing loan: $e',
      );
    }
  }

  /// Record a loan repayment
  Future<LoanRepaymentResult> recordRepayment({
    required String loanId,
    required double amount,
    required String recordedBy,
    String? notes,
  }) async {
    try {
      final loan = await _db.getLoan(loanId);
      if (loan == null) {
        return LoanRepaymentResult(success: false, message: 'Loan not found');
      }

      if (!loan.isActive) {
        return LoanRepaymentResult(
          success: false,
          message: 'Loan is not active',
        );
      }

      if (amount <= 0) {
        return LoanRepaymentResult(
          success: false,
          message: 'Invalid payment amount',
        );
      }

      // Calculate current balance with accrued interest
      final balanceCalculation = calculateCurrentBalance(loan);

      if (amount > balanceCalculation.totalBalance) {
        return LoanRepaymentResult(
          success: false,
          message:
              'Payment amount exceeds total outstanding balance of \$${balanceCalculation.totalBalance.toStringAsFixed(2)}',
        );
      }

      // Calculate interest and principal allocation
      double interestPayment = math.min(
        amount,
        balanceCalculation.interestAccrued,
      );
      double principalPayment = amount - interestPayment;

      // Create repayment record
      final repayment = LoanRepayment(
        id: const Uuid().v4(),
        amount: amount,
        principalAmount: principalPayment,
        interestAmount: interestPayment,
        dueDate: DateTime.now(), // Using current date as due date
        paidDate: DateTime.now(),
        isPaid: true,
      );

      // Update loan with new payment
      final updatedRepayments = [...loan.repayments, repayment];

      // Recalculate balance after payment
      final updatedLoanWithPayment = loan.copyWith(
        repayments: updatedRepayments,
      );
      final newBalanceCalculation = calculateCurrentBalance(
        updatedLoanWithPayment,
      );

      final updatedLoan = updatedLoanWithPayment.copyWith(
        paidAmount:
            loan.principalAmount - newBalanceCalculation.principalBalance,
        outstandingAmount: newBalanceCalculation.totalBalance,
        status: newBalanceCalculation.totalBalance <= 0.01
            ? LoanStatus.completed
            : loan.status, // Small tolerance for rounding
        metadata: {
          ...loan.metadata,
          'lastPaymentDate': DateTime.now().toIso8601String(),
          'totalInterestPaid':
              (loan.metadata['totalInterestPaid'] as double? ?? 0.0) +
              interestPayment,
          'totalPrincipalPaid':
              (loan.metadata['totalPrincipalPaid'] as double? ?? 0.0) +
              principalPayment,
          'accruedInterest': newBalanceCalculation.interestAccrued,
          'principalBalance': newBalanceCalculation.principalBalance,
        },
      );

      // Update fund balance (repayment goes back to fund)
      final fundId = loan.metadata['fundId'] as String?;
      if (fundId != null) {
        final fund = await _db.getFund(fundId);
        if (fund != null) {
          final updatedFund = fund.copyWith(
            balance: fund.balance + amount,
            lastUpdated: DateTime.now(),
          );
          await _db.saveFund(updatedFund);
        }
      }

      // Update member's outstanding loans
      final member = await _db.getMember(loan.memberId);
      if (member != null) {
        final updatedMember = member.copyWith(
          outstandingLoans: member.outstandingLoans - amount,
          lastActivityDate: DateTime.now(),
        );
        await _db.saveMember(updatedMember);
      }

      // Create transaction record
      final transaction = Transaction(
        id: const Uuid().v4(),
        memberId: loan.memberId,
        fundId: fundId,
        amount: amount,
        type: TransactionType.loanRepayment,
        description: 'Loan repayment - ${loan.purpose}',
        date: DateTime.now(),
        reference: 'REPAY-${loan.id.substring(0, 8)}',
        metadata: {
          'loanId': loan.id,
          'repaymentId': repayment.id,
          'recordedBy': recordedBy,
        },
      );

      await _db.saveLoan(updatedLoan);
      await _db.saveTransaction(transaction);

      return LoanRepaymentResult(
        success: true,
        message: 'Repayment recorded successfully',
        loan: updatedLoan,
        repayment: repayment,
        transaction: transaction,
      );
    } catch (e) {
      return LoanRepaymentResult(
        success: false,
        message: 'Error recording repayment: $e',
      );
    }
  }

  /// Calculate current outstanding balance using simple interest
  LoanBalanceCalculation calculateCurrentBalance(
    Loan loan, {
    DateTime? asOfDate,
  }) {
    final calculationDate = asOfDate ?? DateTime.now();

    if (loan.disbursementDate == null) {
      return LoanBalanceCalculation(
        principalBalance: loan.principalAmount,
        interestAccrued: 0.0,
        totalBalance: loan.principalAmount,
        lastCalculationDate: calculationDate,
        monthsElapsed: 0,
      );
    }

    // Calculate months elapsed since disbursement
    final monthsElapsed = _calculateMonthsElapsed(
      loan.disbursementDate!,
      calculationDate,
    );

    // Get total payments made
    final totalPayments = loan.repayments
        .where(
          (r) =>
              r.paidDate != null &&
              r.paidDate!.isBefore(
                calculationDate.add(const Duration(days: 1)),
              ),
        )
        .fold(0.0, (sum, r) => sum + r.amount);

    // Simple interest calculation - month by month accumulation
    // Interest is added each month based on configurable rate

    // Get current monthly interest rate from settings
    final monthlyInterestRate = _loanSettings.getCurrentMonthlyInterestRate();

    // Calculate remaining principal (payments go to principal first)
    final remainingPrincipal = math.max(
      0.0,
      loan.principalAmount - totalPayments,
    );

    // Total amount due = remaining principal + (monthly rate * elapsed months)
    // This means interest accumulates month by month, not based on fixed term
    final totalInterestDue = monthlyInterestRate * monthsElapsed;

    // If principal is fully paid, apply remaining payments to interest
    double interestPaid = 0.0;
    if (totalPayments > loan.principalAmount) {
      interestPaid = totalPayments - loan.principalAmount;
    }

    final remainingInterest = math.max(0.0, totalInterestDue - interestPaid);
    final totalBalance = remainingPrincipal + remainingInterest;

    return LoanBalanceCalculation(
      principalBalance: remainingPrincipal,
      interestAccrued: 0.0, // No accrued interest in simple interest model
      totalBalance: totalBalance,
      lastCalculationDate: calculationDate,
      monthsElapsed: monthsElapsed,
      totalPaymentsMade: totalPayments,
    );
  }

  /// Calculate months elapsed between two dates
  int _calculateMonthsElapsed(DateTime startDate, DateTime endDate) {
    if (endDate.isBefore(startDate)) return 0;

    int months =
        (endDate.year - startDate.year) * 12 +
        (endDate.month - startDate.month);

    // If we haven't reached the day of the month yet, don't count the current month
    if (endDate.day < startDate.day) {
      months--;
    }

    return math.max(0, months);
  }

  /// Update loan with current balance calculation
  Future<Loan> updateLoanBalance(Loan loan, {DateTime? asOfDate}) async {
    final calculation = calculateCurrentBalance(loan, asOfDate: asOfDate);

    final updatedLoan = loan.copyWith(
      outstandingAmount: calculation.totalBalance,
      paidAmount: loan.principalAmount - calculation.principalBalance,
      metadata: {
        ...loan.metadata,
        'lastBalanceUpdate': (asOfDate ?? DateTime.now()).toIso8601String(),
        'accruedInterest': calculation.interestAccrued,
        'monthsElapsed': calculation.monthsElapsed,
        'principalBalance': calculation.principalBalance,
      },
    );

    await _db.saveLoan(updatedLoan);
    return updatedLoan;
  }

  /// Get loan statistics for a fund
  Future<FundLoanStatistics> getFundLoanStatistics(String fundId) async {
    try {
      final allLoans = await _db.getAllLoans();
      final fundLoans = allLoans
          .where((loan) => loan.metadata['fundId'] == fundId)
          .toList();

      final totalLoans = fundLoans.length;
      final activeLoans = fundLoans.where((loan) => loan.isActive).length;
      final completedLoans = fundLoans
          .where((loan) => loan.status == LoanStatus.completed)
          .length;
      final defaultedLoans = fundLoans
          .where((loan) => loan.status == LoanStatus.defaulted)
          .length;

      final totalDisbursed = fundLoans
          .where(
            (loan) =>
                loan.status != LoanStatus.pending &&
                loan.status != LoanStatus.cancelled,
          )
          .fold(0.0, (sum, loan) => sum + loan.principalAmount);

      final totalOutstanding = fundLoans
          .where((loan) => loan.isActive)
          .fold(0.0, (sum, loan) => sum + loan.remainingBalance);

      final totalRepaid = fundLoans.fold(
        0.0,
        (sum, loan) => sum + loan.paidAmount,
      );

      return FundLoanStatistics(
        totalLoans: totalLoans,
        activeLoans: activeLoans,
        completedLoans: completedLoans,
        defaultedLoans: defaultedLoans,
        totalDisbursed: totalDisbursed,
        totalOutstanding: totalOutstanding,
        totalRepaid: totalRepaid,
        averageLoanAmount: totalLoans > 0 ? totalDisbursed / totalLoans : 0.0,
        repaymentRate: totalDisbursed > 0
            ? (totalRepaid / totalDisbursed) * 100
            : 0.0,
      );
    } catch (e) {
      return FundLoanStatistics(
        totalLoans: 0,
        activeLoans: 0,
        completedLoans: 0,
        defaultedLoans: 0,
        totalDisbursed: 0.0,
        totalOutstanding: 0.0,
        totalRepaid: 0.0,
        averageLoanAmount: 0.0,
        repaymentRate: 0.0,
      );
    }
  }
}

// Result classes
class LoanEligibilityResult {
  final bool isEligible;
  final String reason;
  final double? maxAllowedAmount;
  final double? recommendedAmount;
  final double? availableAmount;

  LoanEligibilityResult({
    required this.isEligible,
    required this.reason,
    this.maxAllowedAmount,
    this.recommendedAmount,
    this.availableAmount,
  });
}

class LoanApprovalResult {
  final bool success;
  final String message;
  final Loan? loan;

  LoanApprovalResult({required this.success, required this.message, this.loan});
}

class LoanDisbursementResult {
  final bool success;
  final String message;
  final Loan? loan;
  final Transaction? transaction;

  LoanDisbursementResult({
    required this.success,
    required this.message,
    this.loan,
    this.transaction,
  });
}

class LoanRepaymentResult {
  final bool success;
  final String message;
  final Loan? loan;
  final LoanRepayment? repayment;
  final Transaction? transaction;

  LoanRepaymentResult({
    required this.success,
    required this.message,
    this.loan,
    this.repayment,
    this.transaction,
  });
}

class FundLoanStatistics {
  final int totalLoans;
  final int activeLoans;
  final int completedLoans;
  final int defaultedLoans;
  final double totalDisbursed;
  final double totalOutstanding;
  final double totalRepaid;
  final double averageLoanAmount;
  final double repaymentRate;

  FundLoanStatistics({
    required this.totalLoans,
    required this.activeLoans,
    required this.completedLoans,
    required this.defaultedLoans,
    required this.totalDisbursed,
    required this.totalOutstanding,
    required this.totalRepaid,
    required this.averageLoanAmount,
    required this.repaymentRate,
  });
}

class LoanBalanceCalculation {
  final double principalBalance;
  final double interestAccrued;
  final double totalBalance;
  final DateTime lastCalculationDate;
  final int monthsElapsed;
  final double? totalPaymentsMade;

  LoanBalanceCalculation({
    required this.principalBalance,
    required this.interestAccrued,
    required this.totalBalance,
    required this.lastCalculationDate,
    required this.monthsElapsed,
    this.totalPaymentsMade,
  });

  @override
  String toString() {
    return 'LoanBalanceCalculation(principal: $principalBalance, interest: $interestAccrued, total: $totalBalance, months: $monthsElapsed)';
  }
}
