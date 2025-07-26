import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state_provider.dart';
import '../../models/member.dart';
import '../../models/fund.dart';
import 'edit_member_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  final Member member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Member _currentMember;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentMember = widget.member;
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
        title: Text(_currentMember.fullName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditMember,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'activate':
                  _updateMemberStatus(MemberStatus.active);
                  break;
                case 'suspend':
                  _updateMemberStatus(MemberStatus.suspended);
                  break;
                case 'deactivate':
                  _updateMemberStatus(MemberStatus.inactive);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'activate', child: Text('Activate')),
              const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
              const PopupMenuItem(
                value: 'deactivate',
                child: Text('Deactivate'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Funds'),
            Tab(text: 'Transactions'),
            Tab(text: 'Loans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildFundsTab(),
          _buildTransactionsTab(),
          _buildLoansTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _getStatusColor(_currentMember.status),
                    child: Text(
                      _currentMember.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentMember.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(_getStatusDisplayName(_currentMember.status)),
                    backgroundColor: _getStatusColor(
                      _currentMember.status,
                    ).withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: _getStatusColor(_currentMember.status),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Financial Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFinancialItem(
                          'Total Savings',
                          currencyFormat.format(_currentMember.totalSavings),
                          Icons.savings,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildFinancialItem(
                          'Investments',
                          currencyFormat.format(
                            _currentMember.totalInvestments,
                          ),
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFinancialItem(
                          'Emergency Fund',
                          currencyFormat.format(_currentMember.emergencyFund),
                          Icons.security,
                          Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _buildFinancialItem(
                          'Outstanding Loans',
                          currencyFormat.format(
                            _currentMember.outstandingLoans,
                          ),
                          Icons.money_off,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net Worth',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currencyFormat.format(_currentMember.netWorth),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _currentMember.netWorth >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Personal Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_currentMember.email != null)
                    _buildInfoRow('Email', _currentMember.email!, Icons.email),
                  _buildInfoRow(
                    'Phone',
                    _currentMember.phoneNumber,
                    Icons.phone,
                  ),
                  if (_currentMember.address != null)
                    _buildInfoRow(
                      'Address',
                      _currentMember.address!,
                      Icons.location_on,
                    ),
                  _buildInfoRow(
                    'Age',
                    '${_currentMember.age} years',
                    Icons.cake,
                  ),
                  _buildInfoRow(
                    'Join Date',
                    dateFormat.format(_currentMember.joinDate),
                    Icons.calendar_today,
                  ),
                  if (_currentMember.nationalId != null)
                    _buildInfoRow(
                      'National ID',
                      _currentMember.nationalId!,
                      Icons.badge,
                    ),
                  if (_currentMember.occupation != null)
                    _buildInfoRow(
                      'Occupation',
                      _currentMember.occupation!,
                      Icons.work,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundsTab() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final memberFunds = appState.funds
            .where(
              (fund) =>
                  fund.memberBalances.containsKey(_currentMember.id) &&
                  fund.memberBalances[_currentMember.id]! > 0,
            )
            .toList();

        if (memberFunds.isEmpty) {
          return const Center(child: Text('No fund contributions yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: memberFunds.length,
          itemBuilder: (context, index) {
            final fund = memberFunds[index];
            final balance = fund.getMemberBalance(_currentMember.id);
            final currencyFormat = NumberFormat.currency(symbol: '\$');

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getFundTypeColor(fund.type),
                  child: Icon(_getFundTypeIcon(fund.type), color: Colors.white),
                ),
                title: Text(fund.name),
                subtitle: Text(fund.typeDisplayName),
                trailing: Text(
                  currencyFormat.format(balance),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionsTab() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final memberTransactions = appState.transactions
            .where((transaction) => transaction.memberId == _currentMember.id)
            .toList();

        memberTransactions.sort((a, b) => b.date.compareTo(a.date));

        if (memberTransactions.isEmpty) {
          return const Center(child: Text('No transactions yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: memberTransactions.length,
          itemBuilder: (context, index) {
            final transaction = memberTransactions[index];
            final currencyFormat = NumberFormat.currency(symbol: '\$');
            final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: transaction.isCredit
                      ? Colors.green
                      : Colors.red,
                  child: Icon(
                    transaction.isCredit ? Icons.add : Icons.remove,
                    color: Colors.white,
                  ),
                ),
                title: Text(transaction.typeDisplayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.description),
                    Text(
                      dateFormat.format(transaction.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: Text(
                  currencyFormat.format(transaction.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.isCredit ? Colors.green : Colors.red,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoansTab() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final memberLoans = appState.loans
            .where((loan) => loan.memberId == _currentMember.id)
            .toList();

        if (memberLoans.isEmpty) {
          return const Center(child: Text('No loans yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: memberLoans.length,
          itemBuilder: (context, index) {
            final loan = memberLoans[index];
            final currencyFormat = NumberFormat.currency(symbol: '\$');

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Loan #${loan.id.substring(0, 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Chip(
                          label: Text(loan.statusDisplayName),
                          backgroundColor: _getLoanStatusColor(
                            loan.status,
                          ).withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: _getLoanStatusColor(loan.status),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Purpose: ${loan.purpose}'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount: ${currencyFormat.format(loan.principalAmount)}',
                        ),
                        Text(
                          'Remaining: ${currencyFormat.format(loan.remainingBalance)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(MemberStatus status) {
    switch (status) {
      case MemberStatus.active:
        return Colors.green;
      case MemberStatus.inactive:
        return Colors.grey;
      case MemberStatus.suspended:
        return Colors.red;
      case MemberStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusDisplayName(MemberStatus status) {
    switch (status) {
      case MemberStatus.active:
        return 'Active';
      case MemberStatus.inactive:
        return 'Inactive';
      case MemberStatus.suspended:
        return 'Suspended';
      case MemberStatus.pending:
        return 'Pending';
    }
  }

  Color _getFundTypeColor(FundType type) {
    switch (type) {
      case FundType.savings:
        return Colors.green;
      case FundType.investment:
        return Colors.blue;
      case FundType.emergency:
        return Colors.orange;
      case FundType.loan:
        return Colors.red;
    }
  }

  IconData _getFundTypeIcon(FundType type) {
    switch (type) {
      case FundType.savings:
        return Icons.savings;
      case FundType.investment:
        return Icons.trending_up;
      case FundType.emergency:
        return Icons.security;
      case FundType.loan:
        return Icons.money;
    }
  }

  Color _getLoanStatusColor(dynamic status) {
    // This is a placeholder - you'll need to implement based on your LoanStatus enum
    return Colors.blue;
  }

  Future<void> _updateMemberStatus(MemberStatus newStatus) async {
    try {
      final updatedMember = _currentMember.copyWith(
        status: newStatus,
        lastActivityDate: DateTime.now(),
      );

      await context.read<AppStateProvider>().updateMember(updatedMember);

      // Update the current member state
      setState(() {
        _currentMember = updatedMember;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Member status updated to ${_getStatusDisplayName(newStatus)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToEditMember() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => EditMemberScreen(member: _currentMember),
      ),
    );

    // Handle the result from edit screen
    if (result != null && mounted) {
      if (result == 'deleted') {
        // Member was deleted, go back to the previous screen
        Navigator.pop(context);
      } else if (result is Member) {
        // Member was updated, refresh the current member data
        setState(() {
          _currentMember = result;
        });
      }
    }
  }
}
