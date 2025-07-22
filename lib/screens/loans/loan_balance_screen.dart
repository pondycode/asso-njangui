import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/loan.dart';
import '../../services/loan_service.dart';
import '../../utils/currency_formatter.dart';

class LoanBalanceScreen extends StatefulWidget {
  final Loan loan;

  const LoanBalanceScreen({super.key, required this.loan});

  @override
  State<LoanBalanceScreen> createState() => _LoanBalanceScreenState();
}

class _LoanBalanceScreenState extends State<LoanBalanceScreen> {
  LoanBalanceCalculation? _balanceCalculation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Balance Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _calculateBalance,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _balanceCalculation == null
          ? const Center(child: Text('Error calculating balance'))
          : _buildBalanceDetails(),
    );
  }

  Widget _buildBalanceDetails() {
    final calculation = _balanceCalculation!;
    final dateFormat = DateFormat.yMMMd();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentBalanceCard(calculation),
          const SizedBox(height: 16),
          _buildLoanDetailsCard(dateFormat),
          const SizedBox(height: 16),
          _buildInterestCalculationCard(calculation),
          const SizedBox(height: 16),
          _buildPaymentHistoryCard(dateFormat),
          const SizedBox(height: 16),
          _buildExampleCalculationCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentBalanceCard(LoanBalanceCalculation calculation) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceItem(
                    'Principal Balance',
                    CurrencyFormatter.format(calculation.principalBalance),
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBalanceItem(
                    'Interest Due',
                    CurrencyFormatter.format(
                      3150.0 * calculation.monthsElapsed,
                    ),
                    Icons.percent,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Outstanding',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(calculation.totalBalance),
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetailsCard(DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Original Amount',
              CurrencyFormatter.format(widget.loan.principalAmount),
            ),
            _buildDetailRow(
              'Interest Rate',
              '${widget.loan.interestRate}% per annum',
            ),
            _buildDetailRow('Term', '${widget.loan.termInMonths} months'),
            if (widget.loan.disbursementDate != null)
              _buildDetailRow(
                'Disbursement Date',
                dateFormat.format(widget.loan.disbursementDate!),
              ),
            _buildDetailRow(
              'Monthly Payment',
              CurrencyFormatter.format(widget.loan.monthlyPayment),
            ),
            _buildDetailRow(
              'Months Elapsed',
              '${_balanceCalculation!.monthsElapsed}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestCalculationCard(LoanBalanceCalculation calculation) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interest Calculation',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Monthly Rate', 'CFA 3,150'),
            _buildDetailRow(
              'Calculation Method',
              'Month-by-month accumulation',
            ),
            _buildDetailRow(
              'Interest Structure',
              'CFA 3,150 added each month since loan start',
            ),
            _buildDetailRow(
              'Months Elapsed',
              '${calculation.monthsElapsed} months',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Month-by-Month Interest Model:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('Monthly Interest = Fixed CFA 3,150'),
                  const SizedBox(height: 4),
                  Text(
                    'Total Interest Due = CFA 3,150 × ${calculation.monthsElapsed} months = ${CurrencyFormatter.format(3150.0 * calculation.monthsElapsed)}',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Interest accumulates each month regardless of payments',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryCard(DateFormat dateFormat) {
    final payments =
        widget.loan.repayments.where((r) => r.paidDate != null).toList()
          ..sort((a, b) => b.paidDate!.compareTo(a.paidDate!));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment History',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (payments.isEmpty)
              const Text('No payments made yet')
            else
              Column(
                children: payments.take(5).map((payment) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.payment, color: Colors.white),
                    ),
                    title: Text(CurrencyFormatter.format(payment.amount)),
                    subtitle: Text(
                      'Principal: ${CurrencyFormatter.format(payment.principalAmount)} | '
                      'Interest: ${CurrencyFormatter.format(payment.interestAmount)}',
                    ),
                    trailing: Text(dateFormat.format(payment.paidDate!)),
                  );
                }).toList(),
              ),
            if (payments.length > 5)
              TextButton(
                onPressed: () {
                  // TODO: Show all payments
                },
                child: Text('View all ${payments.length} payments'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCalculationCard() {
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Text(
                  'Example Calculation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'For your loan scenario:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '• Loan: ${CurrencyFormatter.format(31500)} issued on Aug 31, 2024',
            ),
            const Text('• Interest: 10% per month'),
            Text(
              '• Payment: ${CurrencyFormatter.format(8000)} on Sep 24, 2024',
            ),
            const SizedBox(height: 12),
            const Text(
              'Calculation:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('1. Aug 31 - Sep 31: 1 month elapsed'),
            Text(
              '2. Interest: ${CurrencyFormatter.format(31500)} × 10% = ${CurrencyFormatter.format(3150)}',
            ),
            Text(
              '3. Balance before payment: ${CurrencyFormatter.format(34650)}',
            ),
            Text(
              '4. After ${CurrencyFormatter.format(8000)} payment: ${CurrencyFormatter.format(26650)}',
            ),
            Text('5. Sep 24 - Today: Additional interest accrued'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Note: This system calculates interest monthly for more accurate tracking.',
                style: TextStyle(fontSize: 12, color: Colors.amber[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _calculateBalance() {
    setState(() {
      _isLoading = true;
    });

    try {
      final calculation = LoanService.instance.calculateCurrentBalance(
        widget.loan,
      );
      setState(() {
        _balanceCalculation = calculation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _balanceCalculation = null;
        _isLoading = false;
      });
    }
  }
}
