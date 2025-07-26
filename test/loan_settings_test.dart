import 'package:flutter_test/flutter_test.dart';
import 'package:asso_njangui/models/loan_settings.dart';
import 'package:asso_njangui/models/loan.dart';

void main() {
  group('Dynamic Interest Rate System Tests', () {
    test('should create default loan settings', () {
      final settings = LoanSettings.defaultSettings();

      expect(settings.monthlyInterestRatePercentage, equals(5.0));
      expect(settings.minimumInterestRatePercentage, equals(1.0));
      expect(settings.maximumInterestRatePercentage, equals(20.0));
      expect(settings.allowCustomRates, isTrue);
      expect(settings.minimumLoanTermMonths, equals(1));
      expect(settings.maximumLoanTermMonths, equals(60));
      expect(settings.maxLoanToContributionRatio, equals(3.0));
      expect(settings.minimumContributionMonths, equals(6));
    });

    test('should update loan settings with copyWith', () {
      final originalSettings = LoanSettings.defaultSettings();
      final updatedSettings = originalSettings.copyWith(
        monthlyInterestRatePercentage: 8.0,
        minimumInterestRatePercentage: 2.0,
        maximumInterestRatePercentage: 15.0,
        updatedBy: 'Test',
      );

      expect(updatedSettings.monthlyInterestRatePercentage, equals(8.0));
      expect(updatedSettings.minimumInterestRatePercentage, equals(2.0));
      expect(updatedSettings.maximumInterestRatePercentage, equals(15.0));
      expect(updatedSettings.updatedBy, equals('Test'));

      // Original should remain unchanged
      expect(originalSettings.monthlyInterestRatePercentage, equals(5.0));
    });

    test('should serialize and deserialize loan settings', () {
      final originalSettings = LoanSettings.defaultSettings();
      final json = originalSettings.toJson();
      final deserializedSettings = LoanSettings.fromJson(json);

      expect(
        deserializedSettings.monthlyInterestRatePercentage,
        equals(originalSettings.monthlyInterestRatePercentage),
      );
      expect(
        deserializedSettings.minimumInterestRatePercentage,
        equals(originalSettings.minimumInterestRatePercentage),
      );
      expect(
        deserializedSettings.maximumInterestRatePercentage,
        equals(originalSettings.maximumInterestRatePercentage),
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

    test('should calculate monthly interest correctly', () {
      final settings = LoanSettings.defaultSettings(); // 5% rate

      expect(
        settings.calculateMonthlyInterest(100000.0),
        equals(5000.0),
      ); // 5% of 100000
      expect(
        settings.calculateMonthlyInterest(50000.0),
        equals(2500.0),
      ); // 5% of 50000
      expect(settings.calculateMonthlyInterest(0.0), equals(0.0)); // 5% of 0

      // Test with custom rate
      final customSettings = settings.copyWith(
        monthlyInterestRatePercentage: 10.0,
      );
      expect(
        customSettings.calculateMonthlyInterest(100000.0),
        equals(10000.0),
      ); // 10% of 100000
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
      'should generate repayment schedule with provided monthly interest amount',
      () {
        final schedule = Loan.generateRepaymentSchedule(
          loanId: 'test-loan',
          principalAmount: 60000.0,
          interestRate: 12.0,
          termInMonths: 6,
          startDate: DateTime.now(),
          monthlyInterestAmount: 3000.0, // 5% of 60000
        );

        expect(schedule.length, equals(6));

        // Each payment should have the provided interest amount
        for (final payment in schedule) {
          expect(payment.interestAmount, equals(3000.0));
          expect(payment.principalAmount, equals(10000.0)); // 60000 / 6
          expect(payment.amount, equals(13000.0)); // 10000 + 3000
        }
      },
    );
  });
}
