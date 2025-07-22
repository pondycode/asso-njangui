import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/loan.dart';
import '../../models/member.dart';
import '../../models/fund.dart';
import '../../providers/app_state_provider.dart';
import '../../services/database_service.dart';
import '../../services/loan_service.dart';
import 'loan_repayment_screen.dart';
import 'loan_balance_screen.dart';
import 'edit_loan_screen.dart';

class LoanDetailScreen extends StatefulWidget {
  final Loan loan;

  const LoanDetailScreen({super.key, required this.loan});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Loan _currentLoan;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentLoan = widget.loan;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loan #${_currentLoan.id.substring(0, 8)}'),
        actions: [
          if (_currentLoan.status == LoanStatus.pending)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'approve',
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Approve'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: ListTile(
                    leading: Icon(Icons.cancel, color: Colors.red),
                    title: Text('Reject'),
                  ),
                ),
              ],
            ),
          if (_currentLoan.status == LoanStatus.approved)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'disburse',
                  child: ListTile(
                    leading: Icon(Icons.send, color: Colors.blue),
                    title: Text('Disburse'),
                  ),
                ),
              ],
            ),
          if (_currentLoan.isActive)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'payment',
                  child: ListTile(
                    leading: Icon(Icons.payment, color: Colors.green),
                    title: Text('Record Payment'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'balance',
                  child: ListTile(
                    leading: Icon(Icons.calculate, color: Colors.blue),
                    title: Text('View Balance Details'),
                  ),
                ),
              ],
            ),
          // General menu for edit and delete
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Loan'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'Delete Loan',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Repayments'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildRepaymentsTab(),
          _buildDocumentsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final member = appState.members.firstWhere(
          (m) => m.id == _currentLoan.memberId,
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

        final fund = appState.funds.firstWhere(
          (f) => f.id == _currentLoan.metadata['fundId'],
          orElse: () => Fund(
            id: '',
            name: 'Unknown Fund',
            description: '',
            type: FundType.investment,
            createdDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLoanStatusCard(),
              const SizedBox(height: 16),
              _buildBorrowerCard(member),
              const SizedBox(height: 16),
              _buildFundSourceCard(fund),
              const SizedBox(height: 16),
              _buildLoanDetailsCard(),
              const SizedBox(height: 16),
              _buildFinancialSummaryCard(),
              if (_currentLoan.guarantors.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildGuarantorsCard(appState.members),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoanStatusCard() {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final progressPercentage = _currentLoan.principalAmount > 0
        ? ((_currentLoan.principalAmount - _currentLoan.remainingBalance) /
                  _currentLoan.principalAmount *
                  100)
              .clamp(0, 100)
        : 0.0;

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
                  'Loan Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_currentLoan.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusLabel(_currentLoan.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
                    currencyFormat.format(_currentLoan.principalAmount),
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Remaining',
                    currencyFormat.format(_currentLoan.remainingBalance),
                    Icons.trending_down,
                    _currentLoan.remainingBalance > 0
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
            if (_currentLoan.isActive) ...[
              const SizedBox(height: 16),
              Text(
                'Repayment Progress: ${progressPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressPercentage / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressPercentage == 100
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowerCard(Member member) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Borrower Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Text(
                  '${member.firstName[0]}${member.lastName[0]}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                '${member.firstName} ${member.lastName}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${member.email}'),
                  Text('Phone: ${member.phoneNumber}'),
                  Text(
                    'Member since: ${DateFormat.yMMMd().format(member.joinDate)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundSourceCard(Fund fund) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fund Source', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFundTypeIcon(fund.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fund.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(fund.description),
                      Text(
                        'Available Balance: ${currencyFormat.format(fund.balance)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetailsCard() {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loan Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildDetailRow('Purpose', _currentLoan.purpose),
            _buildDetailRow('Interest Rate', '${_currentLoan.interestRate}%'),
            _buildDetailRow('Term', '${_currentLoan.termInMonths} months'),
            _buildDetailRow(
              'Monthly Payment',
              currencyFormat.format(_currentLoan.monthlyPayment),
            ),
            _buildDetailRow(
              'Application Date',
              DateFormat.yMMMd().format(_currentLoan.applicationDate),
            ),
            if (_currentLoan.approvalDate != null)
              _buildDetailRow(
                'Approval Date',
                DateFormat.yMMMd().format(_currentLoan.approvalDate!),
              ),
            if (_currentLoan.disbursementDate != null)
              _buildDetailRow(
                'Disbursement Date',
                DateFormat.yMMMd().format(_currentLoan.disbursementDate!),
              ),
            if (_currentLoan.collateral != null)
              _buildDetailRow('Collateral', _currentLoan.collateral!),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard() {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final totalInterest =
        (_currentLoan.monthlyPayment * _currentLoan.termInMonths) -
        _currentLoan.principalAmount;
    final totalPayment =
        _currentLoan.monthlyPayment * _currentLoan.termInMonths;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Interest',
                    currencyFormat.format(totalInterest),
                    Icons.percent,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Payment',
                    currencyFormat.format(totalPayment),
                    Icons.payment,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Paid Amount',
                    currencyFormat.format(_currentLoan.paidAmount),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Outstanding',
                    currencyFormat.format(_currentLoan.outstandingAmount),
                    Icons.schedule,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuarantorsCard(List<Member> allMembers) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guarantors', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Column(
              children: _currentLoan.guarantors.map((guarantorId) {
                final guarantor = allMembers.firstWhere(
                  (m) => m.id == guarantorId,
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
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      '${guarantor.firstName[0]}${guarantor.lastName[0]}',
                    ),
                  ),
                  title: Text('${guarantor.firstName} ${guarantor.lastName}'),
                  subtitle: Text(guarantor.email ?? guarantor.phoneNumber),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepaymentsTab() {
    if (_currentLoan.repayments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No repayments recorded'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentLoan.repayments.length,
      itemBuilder: (context, index) {
        final repayment = _currentLoan.repayments[index];
        return _buildRepaymentCard(repayment);
      },
    );
  }

  Widget _buildDocumentsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Document management coming soon'),
        ],
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepaymentCard(LoanRepayment repayment) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: const Icon(Icons.payment, color: Colors.white),
        ),
        title: Text(currencyFormat.format(repayment.amount)),
        subtitle: Text(
          repayment.paidDate != null
              ? DateFormat.yMMMd().add_jm().format(repayment.paidDate!)
              : 'Due: ${DateFormat.yMMMd().format(repayment.dueDate)}',
        ),
        trailing: repayment.isOverdue
            ? const Icon(Icons.warning, color: Colors.orange)
            : const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }

  Widget _buildFundTypeIcon(FundType type) {
    IconData icon;
    Color color;

    switch (type) {
      case FundType.investment:
        icon = Icons.trending_up;
        color = Colors.blue;
        break;
      case FundType.emergency:
        icon = Icons.security;
        color = Colors.red;
        break;
      case FundType.savings:
        icon = Icons.savings;
        color = Colors.green;
        break;
      case FundType.loan:
        icon = Icons.account_balance;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.pending:
        return Colors.orange;
      case LoanStatus.approved:
        return Colors.blue;
      case LoanStatus.active:
        return Colors.green;
      case LoanStatus.completed:
        return Colors.green;
      case LoanStatus.cancelled:
        return Colors.red;
      case LoanStatus.defaulted:
        return Colors.red;
      case LoanStatus.disbursed:
        return Colors.blue;
    }
  }

  String _getStatusLabel(LoanStatus status) {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.cancelled:
        return 'Cancelled';
      case LoanStatus.defaulted:
        return 'Defaulted';
      case LoanStatus.disbursed:
        return 'Disbursed';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'approve':
        _approveLoan();
        break;
      case 'reject':
        _rejectLoan();
        break;
      case 'disburse':
        _disburseLoan();
        break;
      case 'payment':
        _recordPayment();
        break;
      case 'balance':
        _viewBalanceDetails();
        break;
      case 'edit':
        _editLoan();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _approveLoan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Loan'),
        content: const Text('Are you sure you want to approve this loan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await LoanService.instance.approveLoan(
          loanId: _currentLoan.id,
          approvedBy: 'System', // TODO: Get current user
          notes: 'Approved via mobile app',
        );

        if (mounted) {
          if (result.success) {
            setState(() {
              _currentLoan = result.loan!;
            });
            context.read<AppStateProvider>().initialize();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Loan approved successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${result.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error approving loan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _rejectLoan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Loan'),
        content: const Text(
          'Are you sure you want to reject this loan? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final rejectedLoan = _currentLoan.copyWith(
          status: LoanStatus.cancelled,
          metadata: {
            ..._currentLoan.metadata,
            'rejectedBy': 'System', // TODO: Get current user
            'rejectedDate': DateTime.now().toIso8601String(),
            'rejectionReason': 'Rejected via mobile app',
          },
        );

        await DatabaseService.instance.saveLoan(rejectedLoan);

        if (mounted) {
          setState(() {
            _currentLoan = rejectedLoan;
          });
          context.read<AppStateProvider>().initialize();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loan rejected'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error rejecting loan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _disburseLoan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disburse Loan'),
        content: Text(
          'Are you sure you want to disburse \$${_currentLoan.principalAmount.toStringAsFixed(2)} to the borrower?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disburse'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await LoanService.instance.disburseLoan(
          loanId: _currentLoan.id,
          disbursedBy: 'System', // TODO: Get current user
          notes: 'Disbursed via mobile app',
        );

        if (mounted) {
          if (result.success) {
            setState(() {
              _currentLoan = result.loan!;
            });
            context.read<AppStateProvider>().initialize();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Loan disbursed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${result.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error disbursing loan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _recordPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoanRepaymentScreen(loan: _currentLoan),
      ),
    ).then((updatedLoan) {
      if (updatedLoan != null) {
        setState(() {
          _currentLoan = updatedLoan;
        });
      }
    });
  }

  void _viewBalanceDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoanBalanceScreen(loan: _currentLoan),
      ),
    );
  }

  void _editLoan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLoanScreen(loan: _currentLoan),
      ),
    ).then((updatedLoan) {
      if (updatedLoan != null) {
        setState(() {
          _currentLoan = updatedLoan;
        });
      }
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this loan?'),
            const SizedBox(height: 16),
            Text(
              'Loan Amount: ${NumberFormat.currency(symbol: 'XAF ').format(_currentLoan.principalAmount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Status: ${_getStatusLabel(_currentLoan.status)}'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone. Only pending or rejected loans can be deleted.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLoan();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLoan() async {
    try {
      await context.read<AppStateProvider>().deleteLoan(_currentLoan.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Return to loan list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting loan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
