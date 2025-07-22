import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/loan.dart';
import '../../models/member.dart';
import '../../providers/app_state_provider.dart';
import 'loan_detail_screen.dart';
import 'loan_application_screen.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  String _searchQuery = '';
  LoanStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loans),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToLoanApplication(),
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appState.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${appState.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => appState.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredLoans = _filterLoans(appState.loans);

          return Column(
            children: [
              _buildSearchAndFilter(),
              _buildLoansSummary(appState),
              Expanded(
                child: filteredLoans.isEmpty
                    ? _buildEmptyState()
                    : _buildLoansList(filteredLoans, appState.members),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search loans...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', LoanStatus.pending),
                const SizedBox(width: 8),
                _buildFilterChip('Approved', LoanStatus.approved),
                const SizedBox(width: 8),
                _buildFilterChip('Active', LoanStatus.active),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', LoanStatus.completed),
                const SizedBox(width: 8),
                _buildFilterChip('Defaulted', LoanStatus.defaulted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, LoanStatus? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
    );
  }

  Widget _buildLoansSummary(AppStateProvider appState) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final totalLoans = appState.loans.length;
    final activeLoans = appState.loans.where((l) => l.isActive).length;
    final totalOutstanding = appState.loans
        .where((l) => l.isActive)
        .fold(0.0, (sum, l) => sum + l.remainingBalance);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Total Loans',
            '$totalLoans',
            Icons.account_balance,
          ),
          _buildSummaryItem('Active', '$activeLoans', Icons.trending_up),
          _buildSummaryItem(
            'Outstanding',
            currencyFormat.format(totalOutstanding),
            Icons.attach_money,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No loans found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Apply for your first loan',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToLoanApplication,
            icon: const Icon(Icons.add),
            label: const Text('Apply for Loan'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoansList(List<Loan> loans, List<Member> members) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        final member = members.firstWhere(
          (m) => m.id == loan.memberId,
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
        return _buildLoanCard(loan, member);
      },
    );
  }

  Widget _buildLoanCard(Loan loan, Member member) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final progressPercentage = loan.principalAmount > 0
        ? ((loan.principalAmount - loan.remainingBalance) /
                  loan.principalAmount *
                  100)
              .clamp(0, 100)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToLoanDetail(loan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLoanStatusIcon(loan.status),
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
                        Text(
                          loan.purpose,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(loan.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(loan.status),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Principal Amount',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        currencyFormat.format(loan.principalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Remaining',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        currencyFormat.format(loan.remainingBalance),
                        style: TextStyle(
                          color: loan.remainingBalance > 0
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Interest: ${loan.interestRate}%',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'Term: ${loan.termInMonths} months',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'Monthly: ${currencyFormat.format(loan.monthlyPayment)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              if (loan.isActive) ...[
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
                const SizedBox(height: 4),
                Text(
                  '${progressPercentage.toStringAsFixed(1)}% repaid',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoanStatusIcon(LoanStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case LoanStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case LoanStatus.approved:
        icon = Icons.check_circle;
        color = Colors.blue;
        break;
      case LoanStatus.active:
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case LoanStatus.completed:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case LoanStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case LoanStatus.defaulted:
        icon = Icons.warning;
        color = Colors.red;
        break;
      case LoanStatus.disbursed:
        icon = Icons.account_balance_wallet;
        color = Colors.blue;
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

  List<Loan> _filterLoans(List<Loan> loans) {
    var filtered = loans;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((loan) {
        return loan.purpose.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            loan.id.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered
          .where((loan) => loan.status == _selectedStatus)
          .toList();
    }

    // Sort by application date (newest first)
    filtered.sort((a, b) => b.applicationDate.compareTo(a.applicationDate));

    return filtered;
  }

  void _navigateToLoanApplication() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoanApplicationScreen()),
    );
  }

  void _navigateToLoanDetail(Loan loan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoanDetailScreen(loan: loan)),
    );
  }
}
