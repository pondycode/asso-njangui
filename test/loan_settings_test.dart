import 'package:flutter_test/flutter_test.dart';
import 'package:asso_njangui/models/loan_settings.dart';
import 'package:asso_njangui/models/loan.dart';

void main() {
  group('Dynamic Interest Rate System Tests', () {
    test('should create default loan settings', () {
      final settings = LoanSettings.defaultSettings();

      expect(settings.defaultMonthlyInterestRate, equals(3150.0));
      expect(settings.minimumInterestRate, equals(1000.0));
      expect(settings.maximumInterestRate, equals(10000.0));
      expect(settings.allowCustomRates, isTrue);
      expect(settings.minimumLoanTermMonths, equals(1));
      expect(settings.maximumLoanTermMonths, equals(60));
      expect(settings.maxLoanToContributionRatio, equals(3.0));
      expect(settings.minimumContributionMonths, equals(6));
    });

    test('should update loan settings with copyWith', () {
      final originalSettings = LoanSettings.defaultSettings();
      final updatedSettings = originalSettings.copyWith(
        defaultMonthlyInterestRate: 4000.0,
        minimumInterestRate: 2000.0,
        maximumInterestRate: 8000.0,
        updatedBy: 'Test',
      );

      expect(updatedSettings.defaultMonthlyInterestRate, equals(4000.0));
      expect(updatedSettings.minimumInterestRate, equals(2000.0));
      expect(updatedSettings.maximumInterestRate, equals(8000.0));
      expect(updatedSettings.updatedBy, equals('Test'));

      // Original should remain unchanged
      expect(originalSettings.defaultMonthlyInterestRate, equals(3150.0));
    });

    test('should serialize and deserialize loan settings', () {
      final originalSettings = LoanSettings.defaultSettings();
      final json = originalSettings.toJson();
      final deserializedSettings = LoanSettings.fromJson(json);

      expect(
        deserializedSettings.defaultMonthlyInterestRate,
        equals(originalSettings.defaultMonthlyInterestRate),
      );
      expect(
        deserializedSettings.minimumInterestRate,
        equals(originalSettings.minimumInterestRate),
      );
      expect(
        deserializedSettings.maximumInterestRate,
        equals(originalSettings.maximumInterestRate),
      );
      expect(
        deserializedSettings.allowCustomRates,
        equals(originalSettings.allowCustomRates),
      );
      expect(
        deserializedSettings.maxLoanToContributionRatio,
        equals(originalSettings.maxLoanToContributionRatio),
      );
    });

    test('should generate repayment schedule with configurable rate', () {
      final schedule = Loan.generateRepaymentSchedule(
        loanId: 'test-loan',
        principalAmount: 60000.0,
        interestRate: 12.0,
        termInMonths: 6,
        startDate: DateTime.now(),
        monthlyInterestAmount: 2500.0, // Custom rate
      );

      expect(schedule.length, equals(6));

      // Each payment should have the custom interest amount
      for (final payment in schedule) {
        expect(payment.interestAmount, equals(2500.0));
        expect(payment.principalAmount, equals(10000.0)); // 60000 / 6
        expect(payment.amount, equals(12500.0)); // 10000 + 2500
      }
    });

    test(
      'should generate repayment schedule with default rate when no custom rate provided',
      () {
        final schedule = Loan.generateRepaymentSchedule(
          loanId: 'test-loan',
          principalAmount: 60000.0,
          interestRate: 12.0,
          termInMonths: 6,
          startDate: DateTime.now(),
          // No monthlyInterestAmount provided - should use default 3150
        );

        expect(schedule.length, equals(6));

        // Each payment should have the default interest amount
        for (final payment in schedule) {
          expect(payment.interestAmount, equals(3150.0));
          expect(payment.principalAmount, equals(10000.0)); // 60000 / 6
          expect(payment.amount, equals(13150.0)); // 10000 + 3150
        }
      },
    );
  });
}
