import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/transaction.dart';
import '../../models/member.dart';
import '../../models/fund.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/currency_formatter.dart';
import 'edit_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final String? memberId;
  final String? fundId;

  const TransactionListScreen({super.key, this.memberId, this.fundId});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _searchQuery = '';
  TransactionType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle(l10n)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTransactionCount(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  String _getScreenTitle(AppLocalizations l10n) {
    if (widget.memberId != null) return '${l10n.member} ${l10n.transactions}';
    if (widget.fundId != null) return '${l10n.fund} ${l10n.transactions}';
    return l10n.allTransactions;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildTransactionCount() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final transactions = _getFilteredTransactions(appState.transactions);
        final totalTransactions = appState.transactions.length;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getTransactionCountText(
                    transactions.length,
                    totalTransactions,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (_hasActiveFilters()) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Filtered',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getTransactionCountText(int filteredCount, int totalCount) {
    if (filteredCount == totalCount) {
      return '$totalCount transaction${totalCount == 1 ? '' : 's'}';
    } else {
      return '$filteredCount of $totalCount transaction${totalCount == 1 ? '' : 's'}';
    }
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _selectedType != null ||
        _startDate != null ||
        _endDate != null ||
        widget.memberId != null ||
        widget.fundId != null;
  }

  Widget _buildTransactionList() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final transactions = _getFilteredTransactions(appState.transactions);

        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No transactions found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildTotalAmountCard(transactions),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final member = appState.getMemberById(transaction.memberId);
                  final fund = transaction.fundId != null
                      ? appState.getFundById(transaction.fundId!)
                      : null;

                  return _buildTransactionCard(transaction, member, fund);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalAmountCard(List<dynamic> transactions) {
    // Calculate total amount considering transaction direction
    final totalAmount = transactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.effectiveAmount,
    );

    // Calculate positive and negative totals separately
    final positiveTotal = transactions
        .where((t) => t.effectiveAmount > 0)
        .fold(0.0, (sum, t) => sum + t.effectiveAmount);

    final negativeTotal = transactions
        .where((t) => t.effectiveAmount < 0)
        .fold(0.0, (sum, t) => sum + t.effectiveAmount.abs());

    final transactionCount = transactions.length;
    final isPositive = totalAmount >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [Colors.green[600]!, Colors.green[700]!]
              : [Colors.red[600]!, Colors.red[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? Colors.green : Colors.red).withValues(
              alpha: 0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Net Transaction Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${isPositive ? '+' : ''}${CurrencyFormatter.format(totalAmount)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (positiveTotal > 0 && negativeTotal > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.add_circle,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Inflow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(positiveTotal),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.remove_circle,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Outflow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(negativeTotal),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    Transaction transaction,
    Member? member,
    Fund? fund,
  ) {
    final isPositive = transaction.effectiveAmount >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(_getTransactionIcon(transaction.type), color: color),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (member != null) Text('Member: ${member.fullName}'),
            if (fund != null) Text('Fund: ${fund.name}'),
            Text(
              'Date: ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
            ),
            if (transaction.reference != null)
              Text('Ref: ${transaction.reference}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isPositive ? '+' : ''}${CurrencyFormatter.format(transaction.effectiveAmount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            Text(
              _getTransactionTypeLabel(transaction.type),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showTransactionOptions(transaction),
      ),
    );
  }

  List<Transaction> _getFilteredTransactions(
    List<Transaction> allTransactions,
  ) {
    var filtered = allTransactions;

    // Filter by member or fund if specified
    if (widget.memberId != null) {
      filtered = filtered.where((t) => t.memberId == widget.memberId).toList();
    }
    if (widget.fundId != null) {
      filtered = filtered.where((t) => t.fundId == widget.fundId).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.description.toLowerCase().contains(_searchQuery) ||
                (t.reference?.toLowerCase().contains(_searchQuery) ?? false),
          )
          .toList();
    }

    // Filter by type
    if (_selectedType != null) {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      filtered = filtered
          .where(
            (t) =>
                t.date.isAfter(_startDate!.subtract(const Duration(days: 1))),
          )
          .toList();
    }
    if (_endDate != null) {
      filtered = filtered
          .where((t) => t.date.isBefore(_endDate!.add(const Duration(days: 1))))
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  void _showTransactionOptions(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Transaction'),
            onTap: () {
              Navigator.pop(context);
              _editTransaction(transaction);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Transaction',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(transaction);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              _showTransactionDetails(transaction);
            },
          ),
        ],
      ),
    );
  }

  void _editTransaction(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );
  }

  void _showDeleteConfirmation(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to delete this transaction?'),
            const SizedBox(height: 16),
            Text(
              'Amount: ${CurrencyFormatter.format(transaction.amount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Description: ${transaction.description}'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone and will affect member and fund balances.',
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
              _deleteTransaction(transaction);
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

  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      await context.read<AppStateProvider>().deleteTransaction(transaction.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTransactionDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', transaction.id),
              _buildDetailRow(
                'Amount',
                CurrencyFormatter.format(transaction.amount),
              ),
              _buildDetailRow(
                'Effective Amount',
                CurrencyFormatter.format(transaction.effectiveAmount),
              ),
              _buildDetailRow(
                'Type',
                _getTransactionTypeLabel(transaction.type),
              ),
              _buildDetailRow(
                'Date',
                DateFormat('MMM dd, yyyy HH:mm').format(transaction.date),
              ),
              _buildDetailRow('Description', transaction.description),
              if (transaction.reference != null)
                _buildDetailRow('Reference', transaction.reference!),
              if (transaction.receiptNumber != null)
                _buildDetailRow('Receipt', transaction.receiptNumber!),
              _buildDetailRow(
                'Balance Before',
                CurrencyFormatter.format(transaction.balanceBefore),
              ),
              _buildDetailRow(
                'Balance After',
                CurrencyFormatter.format(transaction.balanceAfter),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                ),
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTransactionTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setDialogState(() {
                            _startDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                        ),
                        child: Text(
                          _startDate != null
                              ? DateFormat('MMM dd, yyyy').format(_startDate!)
                              : 'Select date',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setDialogState(() {
                            _endDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                        ),
                        child: Text(
                          _endDate != null
                              ? DateFormat('MMM dd, yyyy').format(_endDate!)
                              : 'Select date',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.contribution:
        return 'Contribution';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.loanDisbursement:
        return 'Loan Disbursement';
      case TransactionType.loanRepayment:
        return 'Loan Repayment';
      case TransactionType.interestPayment:
        return 'Interest Payment';
      case TransactionType.fee:
        return 'Fee';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.contribution:
        return Icons.add_circle;
      case TransactionType.withdrawal:
        return Icons.remove_circle;
      case TransactionType.loanDisbursement:
        return Icons.account_balance;
      case TransactionType.loanRepayment:
        return Icons.payment;
      case TransactionType.interestPayment:
        return Icons.percent;
      case TransactionType.fee:
        return Icons.receipt;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.adjustment:
        return Icons.tune;
    }
  }
}
