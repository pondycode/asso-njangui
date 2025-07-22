import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/fund.dart';
import '../../models/member.dart';
import '../../models/transaction.dart';
import '../../providers/app_state_provider.dart';
import '../../services/fund_service.dart';
import '../../utils/currency_formatter.dart';
import 'edit_fund_screen.dart';
import '../contributions/contribution_screen.dart';

class FundDetailScreen extends StatefulWidget {
  final Fund fund;

  const FundDetailScreen({super.key, required this.fund});

  @override
  State<FundDetailScreen> createState() => _FundDetailScreenState();
}

class _FundDetailScreenState extends State<FundDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Fund _currentFund;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentFund = widget.fund;
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
        title: Text(_currentFund.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editFund),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'contribute',
                child: ListTile(
                  leading: Icon(Icons.add_circle),
                  title: Text('Add Contribution'),
                ),
              ),
              const PopupMenuItem(
                value: 'withdraw',
                child: ListTile(
                  leading: Icon(Icons.remove_circle),
                  title: Text('Withdraw Funds'),
                ),
              ),
              const PopupMenuItem(
                value: 'loan',
                child: ListTile(
                  leading: Icon(Icons.account_balance),
                  title: Text('Request Loan'),
                ),
              ),
              PopupMenuItem(
                value: _currentFund.isActive ? 'deactivate' : 'activate',
                child: ListTile(
                  leading: Icon(
                    _currentFund.isActive ? Icons.pause : Icons.play_arrow,
                  ),
                  title: Text(
                    _currentFund.isActive ? 'Deactivate' : 'Activate',
                  ),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'Delete Fund',
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
            Tab(text: 'Members'),
            Tab(text: 'Transactions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMembersTab(),
          _buildTransactionsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final progressPercentage = _currentFund.targetAmount > 0
        ? (_currentFund.balance / _currentFund.targetAmount * 100).clamp(0, 100)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fund Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildFundTypeIcon(_currentFund.type),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentFund.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _currentFund.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _currentFund.isActive
                              ? Colors.green
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _currentFund.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
                          'Current Balance',
                          CurrencyFormatter.format(_currentFund.balance),
                          Icons.account_balance_wallet,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Target Amount',
                          CurrencyFormatter.format(_currentFund.targetAmount),
                          Icons.flag,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  if (_currentFund.targetAmount > 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Progress: ${progressPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fund Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fund Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Interest Rate',
                    '${_currentFund.interestRate}%',
                  ),
                  _buildDetailRow(
                    'Minimum Contribution',
                    CurrencyFormatter.format(_currentFund.minimumContribution),
                  ),
                  _buildDetailRow(
                    'Maximum Contribution',
                    _currentFund.maximumContribution == double.infinity
                        ? 'No limit'
                        : CurrencyFormatter.format(
                            _currentFund.maximumContribution,
                          ),
                  ),
                  _buildDetailRow(
                    'Contribution Frequency',
                    '${_currentFund.contributionFrequencyDays} days',
                  ),
                  _buildDetailRow(
                    'Created Date',
                    DateFormat.yMMMd().format(_currentFund.createdDate),
                  ),
                  _buildDetailRow(
                    'Last Updated',
                    DateFormat.yMMMd().format(_currentFund.lastUpdated),
                  ),
                  _buildDetailRow(
                    'Total Members',
                    '${_currentFund.memberBalances.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Financial Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Contributions',
                          CurrencyFormatter.format(
                            _currentFund.totalContributions,
                          ),
                          Icons.add_circle,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Total Withdrawals',
                          CurrencyFormatter.format(
                            _currentFund.totalWithdrawals,
                          ),
                          Icons.remove_circle,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final members = appState.members.where((member) {
          return _currentFund.memberBalances.containsKey(member.id);
        }).toList();

        if (members.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No members in this fund'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final balance = _currentFund.memberBalances[member.id] ?? 0.0;
            return _buildMemberCard(member, balance);
          },
        );
      },
    );
  }

  Widget _buildTransactionsTab() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final transactions =
            appState.transactions
                .where((t) => t.fundId == _currentFund.id)
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));

        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No transactions found'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionCard(transaction);
          },
        );
      },
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 32),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Member member, double balance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            '${member.firstName[0]}${member.lastName[0]}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('${member.firstName} ${member.lastName}'),
        subtitle: Text(member.email ?? member.phoneNumber),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(balance),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Balance',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isCredit =
        transaction.type == TransactionType.contribution ||
        transaction.type == TransactionType.loanRepayment;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit ? Colors.green : Colors.red,
          child: Icon(isCredit ? Icons.add : Icons.remove, color: Colors.white),
        ),
        title: Text(transaction.description),
        subtitle: Text(DateFormat.yMMMd().add_jm().format(transaction.date)),
        trailing: Text(
          '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
          style: TextStyle(
            color: isCredit ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _editFund() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFundScreen(fund: _currentFund),
      ),
    ).then((updatedFund) {
      if (updatedFund != null) {
        setState(() {
          _currentFund = updatedFund;
        });
      }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'contribute':
        _showContributeDialog();
        break;
      case 'withdraw':
        _showWithdrawDialog();
        break;
      case 'loan':
        _showLoanRequestDialog();
        break;
      case 'activate':
      case 'deactivate':
        _toggleFundStatus();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showContributeDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContributionScreen(selectedFund: _currentFund),
      ),
    );
  }

  void _showWithdrawDialog() {
    // TODO: Implement withdrawal dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Withdrawal feature coming soon')),
    );
  }

  void _showLoanRequestDialog() {
    // TODO: Implement loan request dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loan request feature coming soon')),
    );
  }

  void _toggleFundStatus() {
    final isActivating = !_currentFund.isActive;
    final action = isActivating ? 'activate' : 'deactivate';
    final actionTitle = isActivating ? 'Activate' : 'Deactivate';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionTitle Fund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to $action "${_currentFund.name}"?'),
            const SizedBox(height: 16),
            if (!isActivating) ...[
              const Text(
                'Deactivating this fund will:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Prevent new contributions'),
              const Text('• Keep existing balances intact'),
              const Text('• Allow withdrawals to continue'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Reason for deactivation (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  // Store reason for deactivation
                },
              ),
            ] else ...[
              const Text(
                'Activating this fund will allow members to make contributions again.',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _performFundStatusToggle(),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActivating ? Colors.green : Colors.orange,
            ),
            child: Text(actionTitle),
          ),
        ],
      ),
    );
  }

  Future<void> _performFundStatusToggle() async {
    Navigator.pop(context); // Close dialog

    try {
      final result = await FundService.instance.toggleFundStatus(
        _currentFund.id,
      );

      if (!mounted) return;

      if (result.success && result.fund != null) {
        setState(() {
          _currentFund = result.fund!;
        });

        // Update the fund in the app state
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        await appState.updateFund(result.fund!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error toggling fund status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${_currentFund.name}"?'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone. The fund will be permanently deleted.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: Funds with existing transactions or contributions cannot be deleted.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
              _deleteFund();
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

  Future<void> _deleteFund() async {
    try {
      await context.read<AppStateProvider>().deleteFund(_currentFund.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fund deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Return to fund list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting fund: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
