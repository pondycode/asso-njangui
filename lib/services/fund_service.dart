import '../models/fund.dart';
import 'database_service.dart';

class FundService {
  static final FundService _instance = FundService._internal();
  factory FundService() => _instance;
  FundService._internal();

  static FundService get instance => _instance;

  final DatabaseService _db = DatabaseService.instance;

  /// Activate a fund
  Future<FundOperationResult> activateFund(String fundId) async {
    try {
      final fund = await _db.getFund(fundId);
      if (fund == null) {
        return FundOperationResult(
          success: false,
          message: 'Fund not found',
        );
      }

      if (fund.isActive) {
        return FundOperationResult(
          success: false,
          message: 'Fund is already active',
        );
      }

      final updatedFund = fund.copyWith(
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      await _db.saveFund(updatedFund);

      return FundOperationResult(
        success: true,
        message: 'Fund activated successfully',
        fund: updatedFund,
      );
    } catch (e) {
      return FundOperationResult(
        success: false,
        message: 'Error activating fund: $e',
      );
    }
  }

  /// Deactivate a fund
  Future<FundOperationResult> deactivateFund(String fundId, {String? reason}) async {
    try {
      final fund = await _db.getFund(fundId);
      if (fund == null) {
        return FundOperationResult(
          success: false,
          message: 'Fund not found',
        );
      }

      if (!fund.isActive) {
        return FundOperationResult(
          success: false,
          message: 'Fund is already inactive',
        );
      }

      // Add deactivation metadata
      final metadata = Map<String, dynamic>.from(fund.settings);
      metadata['deactivatedDate'] = DateTime.now().toIso8601String();
      if (reason != null) {
        metadata['deactivationReason'] = reason;
      }

      final updatedFund = fund.copyWith(
        isActive: false,
        lastUpdated: DateTime.now(),
        settings: metadata,
      );

      await _db.saveFund(updatedFund);

      return FundOperationResult(
        success: true,
        message: 'Fund deactivated successfully',
        fund: updatedFund,
      );
    } catch (e) {
      return FundOperationResult(
        success: false,
        message: 'Error deactivating fund: $e',
      );
    }
  }

  /// Toggle fund status (activate/deactivate)
  Future<FundOperationResult> toggleFundStatus(String fundId, {String? reason}) async {
    try {
      final fund = await _db.getFund(fundId);
      if (fund == null) {
        return FundOperationResult(
          success: false,
          message: 'Fund not found',
        );
      }

      if (fund.isActive) {
        return await deactivateFund(fundId, reason: reason);
      } else {
        return await activateFund(fundId);
      }
    } catch (e) {
      return FundOperationResult(
        success: false,
        message: 'Error toggling fund status: $e',
      );
    }
  }

  /// Get all active funds
  Future<List<Fund>> getActiveFunds() async {
    try {
      return await _db.getActiveFunds();
    } catch (e) {
      return [];
    }
  }

  /// Get fund statistics
  Future<FundStatistics> getFundStatistics(String fundId) async {
    try {
      final fund = await _db.getFund(fundId);
      if (fund == null) {
        return FundStatistics(
          totalMembers: 0,
          totalBalance: 0.0,
          averageBalance: 0.0,
          progressPercentage: 0.0,
        );
      }

      final totalMembers = fund.memberBalances.length;
      final totalBalance = fund.balance;
      final averageBalance = totalMembers > 0 ? totalBalance / totalMembers : 0.0;
      final progressPercentage = fund.targetAmount > 0 
          ? (totalBalance / fund.targetAmount * 100).clamp(0.0, 100.0)
          : 0.0;

      return FundStatistics(
        totalMembers: totalMembers,
        totalBalance: totalBalance,
        averageBalance: averageBalance,
        progressPercentage: progressPercentage,
        hasReachedTarget: fund.hasReachedTarget,
      );
    } catch (e) {
      return FundStatistics(
        totalMembers: 0,
        totalBalance: 0.0,
        averageBalance: 0.0,
        progressPercentage: 0.0,
      );
    }
  }
}

// Result classes
class FundOperationResult {
  final bool success;
  final String message;
  final Fund? fund;

  FundOperationResult({
    required this.success,
    required this.message,
    this.fund,
  });
}

class FundStatistics {
  final int totalMembers;
  final double totalBalance;
  final double averageBalance;
  final double progressPercentage;
  final bool hasReachedTarget;

  FundStatistics({
    required this.totalMembers,
    required this.totalBalance,
    required this.averageBalance,
    required this.progressPercentage,
    this.hasReachedTarget = false,
  });
}
