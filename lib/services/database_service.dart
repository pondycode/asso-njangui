import 'package:hive_flutter/hive_flutter.dart';
import '../models/member.dart';
import '../models/fund.dart';
import '../models/transaction.dart';
import '../models/loan.dart';
import '../models/contribution.dart';
import '../models/penalty.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static DatabaseService get instance => _instance;

  // Box names
  static const String _membersBox = 'members';
  static const String _fundsBox = 'funds';
  static const String _transactionsBox = 'transactions';
  static const String _loansBox = 'loans';
  static const String _contributionsBox = 'contributions';
  static const String _penaltiesBox = 'penalties';
  static const String _penaltyRulesBox = 'penalty_rules';
  static const String _settingsBox = 'settings';

  // Boxes
  late Box<Member> _members;
  late Box<Fund> _funds;
  late Box<Transaction> _transactions;
  late Box<Loan> _loans;
  late Box<Contribution> _contributions;
  late Box<Penalty> _penalties;
  late Box<PenaltyRule> _penaltyRules;
  late Box<dynamic> _settings;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Open all boxes
      _members = await Hive.openBox<Member>(_membersBox);
      _funds = await Hive.openBox<Fund>(_fundsBox);
      _transactions = await Hive.openBox<Transaction>(_transactionsBox);
      _loans = await Hive.openBox<Loan>(_loansBox);
      _contributions = await Hive.openBox<Contribution>(_contributionsBox);
      _penalties = await Hive.openBox<Penalty>(_penaltiesBox);
      _penaltyRules = await Hive.openBox<PenaltyRule>(_penaltyRulesBox);
      _settings = await Hive.openBox(_settingsBox);

      _isInitialized = true;

      // Initialize default data if needed
      await _initializeDefaultData();
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> _initializeDefaultData() async {
    // Create default funds if none exist
    if (_funds.isEmpty) {
      final defaultFunds = [
        Fund(
          id: 'savings_fund',
          name: 'Savings Fund',
          description: 'General savings fund for all members',
          type: FundType.savings,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          minimumContribution: 10.0,
          contributionFrequencyDays: 30,
        ),
        Fund(
          id: 'investment_fund',
          name: 'Investment Fund',
          description: 'Long-term investment fund with higher returns',
          type: FundType.investment,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          minimumContribution: 50.0,
          interestRate: 8.0,
          contributionFrequencyDays: 30,
        ),
        Fund(
          id: 'emergency_fund',
          name: 'Emergency Fund',
          description: 'Emergency fund for urgent financial needs',
          type: FundType.emergency,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          minimumContribution: 5.0,
          contributionFrequencyDays: 30,
        ),
      ];

      for (final fund in defaultFunds) {
        await _funds.put(fund.id, fund);
      }
    }
  }

  // Member operations
  Future<void> saveMember(Member member) async {
    await _members.put(member.id, member);
  }

  Future<Member?> getMember(String id) async {
    return _members.get(id);
  }

  Future<List<Member>> getAllMembers() async {
    return _members.values.toList();
  }

  Future<List<Member>> getActiveMembers() async {
    return _members.values
        .where((member) => member.status == MemberStatus.active)
        .toList();
  }

  Future<void> deleteMember(String id) async {
    await _members.delete(id);
  }

  Future<List<Member>> searchMembers(String query) async {
    final lowerQuery = query.toLowerCase();
    return _members.values.where((member) {
      return member.firstName.toLowerCase().contains(lowerQuery) ||
          member.lastName.toLowerCase().contains(lowerQuery) ||
          (member.email?.toLowerCase().contains(lowerQuery) ?? false) ||
          member.phoneNumber.contains(query);
    }).toList();
  }

  // Fund operations
  Future<void> saveFund(Fund fund) async {
    await _funds.put(fund.id, fund);
  }

  Future<Fund?> getFund(String id) async {
    return _funds.get(id);
  }

  Future<List<Fund>> getAllFunds() async {
    return _funds.values.toList();
  }

  Future<List<Fund>> getActiveFunds() async {
    return _funds.values.where((fund) => fund.isActive).toList();
  }

  Future<void> deleteFund(String id) async {
    await _funds.delete(id);
  }

  // Transaction operations
  Future<void> saveTransaction(Transaction transaction) async {
    await _transactions.put(transaction.id, transaction);
  }

  Future<Transaction?> getTransaction(String id) async {
    return _transactions.get(id);
  }

  Future<List<Transaction>> getAllTransactions() async {
    return _transactions.values.toList();
  }

  Future<List<Transaction>> getMemberTransactions(String memberId) async {
    return _transactions.values
        .where((transaction) => transaction.memberId == memberId)
        .toList();
  }

  Future<List<Transaction>> getFundTransactions(String fundId) async {
    return _transactions.values
        .where((transaction) => transaction.fundId == fundId)
        .toList();
  }

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _transactions.values.where((transaction) {
      return transaction.date.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactions.delete(id);
  }

  // Loan operations
  Future<void> saveLoan(Loan loan) async {
    await _loans.put(loan.id, loan);
  }

  Future<Loan?> getLoan(String id) async {
    return _loans.get(id);
  }

  Future<List<Loan>> getAllLoans() async {
    return _loans.values.toList();
  }

  Future<List<Loan>> getMemberLoans(String memberId) async {
    return _loans.values.where((loan) => loan.memberId == memberId).toList();
  }

  Future<List<Loan>> getActiveLoans() async {
    return _loans.values.where((loan) => loan.isActive).toList();
  }

  Future<List<Loan>> getLoansByStatus(LoanStatus status) async {
    return _loans.values.where((loan) => loan.status == status).toList();
  }

  Future<void> deleteLoan(String id) async {
    await _loans.delete(id);
  }

  // Contribution operations
  Future<void> saveContribution(Contribution contribution) async {
    await _contributions.put(contribution.id, contribution);
  }

  Future<Contribution?> getContribution(String id) async {
    return _contributions.get(id);
  }

  Future<List<Contribution>> getAllContributions() async {
    return _contributions.values.toList();
  }

  Future<List<Contribution>> getMemberContributions(String memberId) async {
    return _contributions.values
        .where((contribution) => contribution.memberId == memberId)
        .toList();
  }

  Future<void> deleteContribution(String id) async {
    await _contributions.delete(id);
  }

  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    await _settings.put(key, value);
  }

  Future<T?> getSetting<T>(String key) async {
    return _settings.get(key) as T?;
  }

  Future<void> deleteSetting(String key) async {
    await _settings.delete(key);
  }

  // Search operations
  Future<Map<String, List<dynamic>>> globalSearch(String query) async {
    final results = <String, List<dynamic>>{};

    // Search members
    results['members'] = await searchMembers(query);

    // Search transactions
    final lowerQuery = query.toLowerCase();
    results['transactions'] = _transactions.values.where((transaction) {
      return transaction.description.toLowerCase().contains(lowerQuery) ||
          transaction.reference?.toLowerCase().contains(lowerQuery) == true;
    }).toList();

    // Search loans
    results['loans'] = _loans.values.where((loan) {
      return loan.purpose.toLowerCase().contains(lowerQuery);
    }).toList();

    // Search funds
    results['funds'] = _funds.values.where((fund) {
      return fund.name.toLowerCase().contains(lowerQuery) ||
          fund.description.toLowerCase().contains(lowerQuery);
    }).toList();

    return results;
  }

  // Backup and restore
  Future<Map<String, dynamic>> exportData() async {
    return {
      'members': _members.values.map((m) => m.toJson()).toList(),
      'funds': _funds.values.map((f) => f.toJson()).toList(),
      'transactions': _transactions.values.map((t) => t.toJson()).toList(),
      'loans': _loans.values.map((l) => l.toJson()).toList(),
      'contributions': _contributions.values.map((c) => c.toJson()).toList(),
      'settings': _settings.toMap(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await _members.clear();
    await _funds.clear();
    await _transactions.clear();
    await _loans.clear();
    await _contributions.clear();

    // Import members
    if (data['members'] != null) {
      for (final memberData in data['members']) {
        final member = Member.fromJson(memberData);
        await _members.put(member.id, member);
      }
    }

    // Import funds
    if (data['funds'] != null) {
      for (final fundData in data['funds']) {
        final fund = Fund.fromJson(fundData);
        await _funds.put(fund.id, fund);
      }
    }

    // Import transactions
    if (data['transactions'] != null) {
      for (final transactionData in data['transactions']) {
        final transaction = Transaction.fromJson(transactionData);
        await _transactions.put(transaction.id, transaction);
      }
    }

    // Import loans
    if (data['loans'] != null) {
      for (final loanData in data['loans']) {
        final loan = Loan.fromJson(loanData);
        await _loans.put(loan.id, loan);
      }
    }

    // Import contributions
    if (data['contributions'] != null) {
      for (final contributionData in data['contributions']) {
        final contribution = Contribution.fromJson(contributionData);
        await _contributions.put(contribution.id, contribution);
      }
    }
  }

  // Penalty Rules CRUD operations
  Future<List<PenaltyRule>> getAllPenaltyRules() async {
    return _penaltyRules.values.toList();
  }

  Future<PenaltyRule?> getPenaltyRuleById(String id) async {
    return _penaltyRules.get(id);
  }

  Future<void> savePenaltyRule(PenaltyRule rule) async {
    await _penaltyRules.put(rule.id, rule);
  }

  Future<void> deletePenaltyRule(String id) async {
    await _penaltyRules.delete(id);
  }

  // Penalties CRUD operations
  Future<List<Penalty>> getAllPenalties() async {
    return _penalties.values.toList();
  }

  Future<Penalty?> getPenaltyById(String id) async {
    return _penalties.get(id);
  }

  Future<void> savePenalty(Penalty penalty) async {
    await _penalties.put(penalty.id, penalty);
  }

  Future<void> deletePenalty(String id) async {
    await _penalties.delete(id);
  }

  // Clear all data (for restore operations)
  Future<void> clearAllData() async {
    await _members.clear();
    await _funds.clear();
    await _transactions.clear();
    await _loans.clear();
    await _contributions.clear();
    await _penalties.clear();
    await _penaltyRules.clear();
    // Don't clear settings as they contain user preferences
  }

  // Close all boxes
  Future<void> close() async {
    await _members.close();
    await _funds.close();
    await _transactions.close();
    await _loans.close();
    await _contributions.close();
    await _penalties.close();
    await _penaltyRules.close();
    await _settings.close();
    _isInitialized = false;
  }
}
