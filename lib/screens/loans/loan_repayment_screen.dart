import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/loan.dart';
import '../../models/member.dart';
import '../../providers/app_state_provider.dart';
import '../../services/loan_service.dart';
import '../../utils/currency_formatter.dart';

class LoanRepaymentScreen extends StatefulWidget {
  final Loan loan;

  const LoanRepaymentScreen({super.key, required this.loan});

  @override
  State<LoanRepaymentScreen> createState() => _LoanRepaymentScreenState();
}

class _LoanRepaymentScreenState extends State<LoanRepaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  LoanBalanceCalculation? _currentBalance;

  @override
  void initState() {
    super.initState();
    // Calculate current balance with interest
    _currentBalance = LoanService.instance.calculateCurrentBalance(widget.loan);
    // Pre-fill with monthly payment amount
    _amountController.text = widget.loan.monthlyPayment.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Payment'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _recordPayment,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Record'),
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final member = appState.members.firstWhere(
            (m) => m.id == widget.loan.memberId,
            orElse: () => Member(
              id: '',
              firstName: 'Unknown',
              lastName: 'Member',
              email: '',
              phoneNumber: '',
              address: '',
              dateOfBirth: DateTime.now(),
              joinDate: DateTime.now(),
              status: MemberStatus.inactive,
              lastActivityDate: DateTime.now(),
            ),
          );

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLoanSummaryCard(member),
                  const SizedBox(height: 24),
                  _buildPaymentDetailsCard(),
                  const SizedBox(height: 24),
                  _buildPaymentHistoryCard(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorCard(),
                  ],
                  const SizedBox(height: 32),
                  _buildRecordButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoanSummaryCard(Member member) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loan Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Text(
                    '${member.firstName[0]}${member.lastName[0]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${member.firstName} ${member.lastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(widget.loan.purpose),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Principal',
                    CurrencyFormatter.format(widget.loan.principalAmount),
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Outstanding',
                    CurrencyFormatter.format(
                      _currentBalance?.totalBalance ??
                          widget.loan.outstandingAmount,
                    ),
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Principal Balance',
                    CurrencyFormatter.format(
                      _currentBalance?.principalBalance ??
                          widget.loan.principalAmount - widget.loan.paidAmount,
                    ),
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Accrued Interest',
                    CurrencyFormatter.format(
                      _currentBalance?.interestAccrued ?? 0,
                    ),
                    Icons.percent,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Monthly Payment',
                    CurrencyFormatter.format(widget.loan.monthlyPayment),
                    Icons.payment,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Paid So Far',
                    CurrencyFormatter.format(widget.loan.paidAmount),
                    Icons.check_circle,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                helperText: 'Enter the amount being paid',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payment amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                final totalOutstanding =
                    _currentBalance?.totalBalance ??
                    widget.loan.outstandingAmount;
                if (amount > totalOutstanding) {
                  return 'Amount exceeds total outstanding balance of \$${totalOutstanding.toStringAsFixed(2)}';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _amountController.text = widget.loan.monthlyPayment
                          .toStringAsFixed(2);
                    },
                    child: Text(
                      'Monthly Payment\n${CurrencyFormatter.format(widget.loan.monthlyPayment)}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final totalOutstanding =
                          _currentBalance?.totalBalance ??
                          widget.loan.outstandingAmount;
                      _amountController.text = totalOutstanding.toStringAsFixed(
                        2,
                      );
                    },
                    child: Text(
                      'Full Payment\n${CurrencyFormatter.format(_currentBalance?.totalBalance ?? widget.loan.outstandingAmount)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any notes about this payment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryCard() {
    if (widget.loan.repayments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Payment History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Text('No payments recorded yet'),
            ],
          ),
        ),
      );
    }

    final recentPayments =
        widget.loan.repayments.where((r) => r.paidDate != null).take(5).toList()
          ..sort((a, b) => b.paidDate!.compareTo(a.paidDate!));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Payments',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${widget.loan.repayments.length} total',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: recentPayments.map((payment) {
                return _buildPaymentTile(payment);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(LoanRepayment payment) {
    final isOverdue =
        payment.paidDate != null && payment.paidDate!.isAfter(payment.dueDate);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isOverdue ? Colors.orange : Colors.green,
        child: Icon(
          isOverdue ? Icons.warning : Icons.check,
          color: Colors.white,
        ),
      ),
      title: Text(CurrencyFormatter.format(payment.amount)),
      subtitle: Text(
        payment.paidDate != null
            ? 'Paid: ${DateFormat.yMMMd().add_jm().format(payment.paidDate!)}'
            : 'Due: ${DateFormat.yMMMd().format(payment.dueDate)}',
      ),
      trailing: isOverdue
          ? const Text('Late', style: TextStyle(color: Colors.orange))
          : const Text('On Time', style: TextStyle(color: Colors.green)),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _recordPayment,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Record Payment', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text.trim();

      final result = await LoanService.instance.recordRepayment(
        loanId: widget.loan.id,
        amount: amount,
        recordedBy: 'System', // TODO: Get current user
        notes: notes.isNotEmpty ? notes : null,
      );

      if (mounted) {
        if (result.success) {
          context.read<AppStateProvider>().initialize();
          Navigator.pop(context, result.loan);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment recorded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage = result.message;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error recording payment: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
