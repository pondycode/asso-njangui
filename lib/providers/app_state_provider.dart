import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../models/fund.dart';
import '../models/transaction.dart';
import '../models/loan.dart';
import '../models/contribution.dart';
import '../services/database_service.dart';

class AppStateProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  // State variables
  List<Member> _members = [];
  List<Fund> _funds = [];
  List<Transaction> _transactions = [];
  List<Loan> _loans = [];
  List<Contribution> _contributions = [];

  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<Member> get members => _members;
  List<Fund> get funds => _funds;
  List<Transaction> get transactions => _transactions;
  List<Loan> get loans => _loans;
  List<Contribution> get contributions => _contributions;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Filtered getters
  List<Member> get activeMembers =>
      _members.where((m) => m.status == MemberStatus.active).toList();

  List<Fund> get activeFunds => _funds.where((f) => f.isActive).toList();

  List<Loan> get activeLoans => _loans.where((l) => l.isActive).toList();

  List<Loan> get pendingLoans =>
      _loans.where((l) => l.status == LoanStatus.pending).toList();

  // Statistics getters
  double get totalSavings => _funds
      .where((f) => f.type == FundType.savings)
      .fold(0.0, (sum, f) => sum + f.balance);

  double get totalInvestments => _funds
      .where((f) => f.type == FundType.investment)
      .fold(0.0, (sum, f) => sum + f.balance);

  double get totalEmergencyFunds => _funds
      .where((f) => f.type == FundType.emergency)
      .fold(0.0, (sum, f) => sum + f.balance);

  double get totalOutstandingLoans => _loans
      .where((l) => l.isActive)
      .fold(0.0, (sum, l) => sum + l.remainingBalance);

  int get totalMembers => _members.length;
  int get activeMembersCount => activeMembers.length;

  // Initialize data
  Future<void> initialize() async {
    try {
      // Ensure database is initialized
      if (!_db.isInitialized) {
        await _db.init();
      }
      await _loadAllData();
    } catch (e) {
      _setError('Failed to initialize app state: $e');
    }
  }

  Future<void> _loadAllData() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadMembers(),
        _loadFunds(),
        _loadTransactions(),
        _loadLoans(),
        _loadContributions(),
      ]);
      _clearError();
    } catch (e) {
      _setError('Failed to load data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadMembers() async {
    _members = await _db.getAllMembers();
  }

  Future<void> _loadFunds() async {
    _funds = await _db.getAllFunds();
  }

  Future<void> _loadTransactions() async {
    _transactions = await _db.getAllTransactions();
  }

  Future<void> _loadLoans() async {
    _loans = await _db.getAllLoans();
  }

  Future<void> _loadContributions() async {
    _contributions = await _db.getAllContributions();
  }

  // Member operations
  Future<void> addMember(Member member) async {
    try {
      await _db.saveMember(member);
      _members.add(member);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add member: $e');
    }
  }

  Future<void> updateMember(Member member) async {
    try {
      await _db.saveMember(member);
      final index = _members.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _members[index] = member;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update member: $e');
    }
  }

  Future<void> deleteMember(String memberId) async {
    try {
      await _db.deleteMember(memberId);
      _members.removeWhere((m) => m.id == memberId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete member: $e');
    }
  }

  // Fund operations
  Future<void> addFund(Fund fund) async {
    try {
      await _db.saveFund(fund);
      _funds.add(fund);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add fund: $e');
    }
  }

  Future<void> updateFund(Fund fund) async {
    try {
      await _db.saveFund(fund);
      final index = _funds.indexWhere((f) => f.id == fund.id);
      if (index != -1) {
        _funds[index] = fund;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update fund: $e');
    }
  }

  Future<void> deleteFund(String fundId) async {
    try {
      // Check if fund has any transactions or contributions
      final fundTransactions = _transactions
          .where((t) => t.fundId == fundId)
          .toList();
      final fundContributions = _contributions
          .where((c) => c.fundContributions.any((fc) => fc.fundId == fundId))
          .toList();

      if (fundTransactions.isNotEmpty || fundContributions.isNotEmpty) {
        throw Exception(
          'Cannot delete fund with existing transactions or contributions. Please archive the fund instead.',
        );
      }

      await _db.deleteFund(fundId);
      _funds.removeWhere((f) => f.id == fundId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete fund: $e');
    }
  }

  // Transaction operations
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _db.saveTransaction(transaction);
      _transactions.add(transaction);

      // Update related entities
      await _updateMemberBalances(transaction);
      await _updateFundBalances(transaction);

      notifyListeners();
    } catch (e) {
      _setError('Failed to add transaction: $e');
    }
  }

  Future<void> updateTransaction(
    Transaction oldTransaction,
    Transaction newTransaction,
  ) async {
    try {
      // Reverse the effects of the old transaction
      await _reverseTransactionEffects(oldTransaction);

      // Save the new transaction
      await _db.saveTransaction(newTransaction);
      final index = _transactions.indexWhere((t) => t.id == newTransaction.id);
      if (index != -1) {
        _transactions[index] = newTransaction;
      }

      // Apply the effects of the new transaction
      await _updateMemberBalances(newTransaction);
      await _updateFundBalances(newTransaction);

      notifyListeners();
    } catch (e) {
      _setError('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transaction = _transactions.firstWhere(
        (t) => t.id == transactionId,
      );

      // Reverse the effects of the transaction
      await _reverseTransactionEffects(transaction);

      await _db.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete transaction: $e');
    }
  }

  Future<void> _reverseTransactionEffects(Transaction transaction) async {
    // Create a reverse transaction to undo the effects
    final reverseTransaction = Transaction(
      id: '${transaction.id}_reverse',
      memberId: transaction.memberId,
      fundId: transaction.fundId,
      type: transaction.type,
      amount: -transaction.amount, // Reverse the amount
      date: transaction.date,
      description: 'Reversal of: ${transaction.description}',
      reference: transaction.reference,
      balanceBefore: transaction.balanceAfter,
      balanceAfter: transaction.balanceBefore,
      receiptNumber: transaction.receiptNumber,
    );

    await _updateMemberBalances(reverseTransaction);
    await _updateFundBalances(reverseTransaction);
  }

  Future<void> _updateMemberBalances(Transaction transaction) async {
    final member = _members.firstWhere((m) => m.id == transaction.memberId);

    double newSavings = member.totalSavings;
    double newInvestments = member.totalInvestments;
    double newEmergencyFund = member.emergencyFund;
    double newOutstandingLoans = member.outstandingLoans;

    if (transaction.fundId != null) {
      final fund = _funds.firstWhere((f) => f.id == transaction.fundId);

      switch (fund.type) {
        case FundType.savings:
          newSavings += transaction.effectiveAmount;
          break;
        case FundType.investment:
          newInvestments += transaction.effectiveAmount;
          break;
        case FundType.emergency:
          newEmergencyFund += transaction.effectiveAmount;
          break;
        case FundType.loan:
          break;
      }
    }

    if (transaction.type == TransactionType.loanDisbursement) {
      newOutstandingLoans += transaction.amount;
    } else if (transaction.type == TransactionType.loanRepayment) {
      newOutstandingLoans -= transaction.amount;
    }

    final updatedMember = member.copyWith(
      totalSavings: newSavings,
      totalInvestments: newInvestments,
      emergencyFund: newEmergencyFund,
      outstandingLoans: newOutstandingLoans,
      lastActivityDate: DateTime.now(),
    );

    await updateMember(updatedMember);
  }

  Future<void> _updateFundBalances(Transaction transaction) async {
    if (transaction.fundId == null) return;

    final fundIndex = _funds.indexWhere((f) => f.id == transaction.fundId);
    if (fundIndex == -1) return;

    final fund = _funds[fundIndex];
    final updatedFund = fund.updateMemberBalance(
      transaction.memberId,
      fund.getMemberBalance(transaction.memberId) + transaction.effectiveAmount,
    );

    await updateFund(updatedFund);
  }

  // Loan operations
  Future<void> addLoan(Loan loan) async {
    try {
      await _db.saveLoan(loan);
      _loans.add(loan);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add loan: $e');
    }
  }

  Future<void> updateLoan(Loan loan) async {
    try {
      await _db.saveLoan(loan);
      final index = _loans.indexWhere((l) => l.id == loan.id);
      if (index != -1) {
        _loans[index] = loan;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update loan: $e');
    }
  }

  Future<void> deleteLoan(String loanId) async {
    try {
      final loan = _loans.firstWhere((l) => l.id == loanId);

      // Check if loan can be deleted
      if (loan.status == LoanStatus.active && loan.paidAmount > 0) {
        throw Exception(
          'Cannot delete loan with existing payments. Please mark as cancelled instead.',
        );
      }

      if (loan.status == LoanStatus.disbursed) {
        throw Exception(
          'Cannot delete disbursed loan. Please mark as cancelled instead.',
        );
      }

      // If loan was disbursed, we need to reverse the disbursement transaction
      if (loan.disbursementDate != null) {
        final disbursementTransactions = _transactions
            .where(
              (t) =>
                  t.type == TransactionType.loanDisbursement &&
                  t.reference?.contains(loan.id) == true,
            )
            .toList();

        for (final transaction in disbursementTransactions) {
          await deleteTransaction(transaction.id);
        }
      }

      await _db.deleteLoan(loanId);
      _loans.removeWhere((l) => l.id == loanId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete loan: $e');
    }
  }

  // Contribution operations
  Future<void> processContribution(Contribution contribution) async {
    try {
      // Save contribution
      await _db.saveContribution(contribution);
      _contributions.add(contribution);

      // Create transactions for each fund contribution
      final transactions = <Transaction>[];
      for (final fundContribution in contribution.fundContributions) {
        final transaction = Transaction(
          id: '${contribution.id}_${fundContribution.fundId}',
          memberId: contribution.memberId,
          fundId: fundContribution.fundId,
          type: TransactionType.contribution,
          amount: fundContribution.amount,
          date: contribution.date,
          description: 'Contribution to ${fundContribution.fundName}',
          reference: contribution.reference,
          balanceBefore: fundContribution.previousBalance,
          balanceAfter: fundContribution.newBalance,
          receiptNumber: contribution.receiptNumber,
        );

        transactions.add(transaction);
        await addTransaction(transaction);
      }

      // Update contribution with transaction IDs
      final updatedContribution = contribution.copyWith(
        transactionIds: transactions.map((t) => t.id).toList(),
        isProcessed: true,
        processedDate: DateTime.now(),
      );

      await _db.saveContribution(updatedContribution);

      notifyListeners();
    } catch (e) {
      _setError('Failed to process contribution: $e');
    }
  }

  Future<void> updateContribution(
    Contribution oldContribution,
    Contribution newContribution,
  ) async {
    try {
      // First, reverse the effects of the old contribution
      if (oldContribution.isProcessed) {
        for (final transactionId in oldContribution.transactionIds) {
          await deleteTransaction(transactionId);
        }
      }

      // Save the new contribution
      await _db.saveContribution(newContribution);
      final index = _contributions.indexWhere(
        (c) => c.id == newContribution.id,
      );
      if (index != -1) {
        _contributions[index] = newContribution;
      }

      // Process the new contribution if it should be processed
      if (newContribution.isProcessed) {
        final transactions = <Transaction>[];
        for (final fundContribution in newContribution.fundContributions) {
          final transaction = Transaction(
            id: '${newContribution.id}_${fundContribution.fundId}',
            memberId: newContribution.memberId,
            fundId: fundContribution.fundId,
            type: TransactionType.contribution,
            amount: fundContribution.amount,
            date: newContribution.date,
            description: 'Contribution to ${fundContribution.fundName}',
            reference: newContribution.reference,
            balanceBefore: fundContribution.previousBalance,
            balanceAfter: fundContribution.newBalance,
            receiptNumber: newContribution.receiptNumber,
          );

          transactions.add(transaction);
          await addTransaction(transaction);
        }

        // Update contribution with new transaction IDs
        final finalContribution = newContribution.copyWith(
          transactionIds: transactions.map((t) => t.id).toList(),
        );

        await _db.saveContribution(finalContribution);
        _contributions[index] = finalContribution;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to update contribution: $e');
    }
  }

  Future<void> deleteContribution(String contributionId) async {
    try {
      final contribution = _contributions.firstWhere(
        (c) => c.id == contributionId,
      );

      // Check if contribution can be deleted
      if (contribution.isProcessed && contribution.transactionIds.isNotEmpty) {
        // Delete all related transactions first
        for (final transactionId in contribution.transactionIds) {
          await deleteTransaction(transactionId);
        }
      }

      await _db.deleteContribution(contributionId);
      _contributions.removeWhere((c) => c.id == contributionId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete contribution: $e');
    }
  }

  // Search operations
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<Map<String, List<dynamic>>> performGlobalSearch(String query) async {
    try {
      return await _db.globalSearch(query);
    } catch (e) {
      _setError('Search failed: $e');
      return {};
    }
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Refresh data
  Future<void> refresh() async {
    await _loadAllData();
  }

  // Get member by ID
  Member? getMemberById(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get fund by ID
  Fund? getFundById(String id) {
    try {
      return _funds.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get loan by ID
  Loan? getLoanById(String id) {
    try {
      return _loans.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }
}
