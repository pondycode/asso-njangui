import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/contribution.dart';
import '../../models/member.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/currency_formatter.dart';
import 'edit_contribution_screen.dart';

class ContributionListScreen extends StatefulWidget {
  final String? memberId;

  const ContributionListScreen({super.key, this.memberId});

  @override
  State<ContributionListScreen> createState() => _ContributionListScreenState();
}

class _ContributionListScreenState extends State<ContributionListScreen> {
  String _searchQuery = '';
  bool? _processedFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.memberId != null
              ? 'Member Contributions'
              : 'All Contributions',
        ),
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
          _buildFilterChips(),
          Expanded(child: _buildContributionList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search by member name, fund, receipt, notes...',
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

  Widget _buildFilterChips() {
    final hasActiveFilters =
        _processedFilter != null ||
        _startDate != null ||
        _endDate != null ||
        _searchQuery.isNotEmpty;

    if (!hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Active Filters:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _processedFilter = null;
                    _startDate = null;
                    _endDate = null;
                    _searchQuery = '';
                  });
                },
                child: const Text('Clear All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (_searchQuery.isNotEmpty) ...[
                  FilterChip(
                    avatar: const Icon(Icons.search, size: 16),
                    label: Text(
                      'Search: "${_searchQuery.length > 15 ? '${_searchQuery.substring(0, 15)}...' : _searchQuery}"',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[50],
                    selectedColor: Colors.blue[100],
                    onSelected: (selected) {},
                    onDeleted: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                if (_processedFilter != null) ...[
                  FilterChip(
                    avatar: Icon(
                      _processedFilter! ? Icons.check_circle : Icons.pending,
                      size: 16,
                    ),
                    label: Text(
                      _processedFilter! ? 'Processed' : 'Pending',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _processedFilter!
                        ? Colors.green[50]
                        : Colors.orange[50],
                    selectedColor: _processedFilter!
                        ? Colors.green[100]
                        : Colors.orange[100],
                    onSelected: (selected) {},
                    onDeleted: () {
                      setState(() {
                        _processedFilter = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                if (_startDate != null || _endDate != null) ...[
                  FilterChip(
                    avatar: const Icon(Icons.date_range, size: 16),
                    label: Text(
                      _getDateRangeLabel(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.purple[50],
                    selectedColor: Colors.purple[100],
                    onSelected: (selected) {},
                    onDeleted: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionList() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final contributions = _getFilteredContributions(appState.contributions);

        if (contributions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No contributions found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildTotalAmountCard(contributions),
            Expanded(
              child: ListView.builder(
                itemCount: contributions.length,
                itemBuilder: (context, index) {
                  final contribution = contributions[index];
                  final member = appState.getMemberById(contribution.memberId);

                  return _buildContributionCard(contribution, member);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalAmountCard(List<Contribution> contributions) {
    final totalAmount = contributions.fold(
      0.0,
      (sum, contribution) => sum + contribution.totalAmount,
    );
    final contributionCount = contributions.length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
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
                        'Total Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(totalAmount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$contributionCount contribution${contributionCount != 1 ? 's' : ''}',
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
          ),
        ),
      ),
    );
  }

  Widget _buildContributionCard(Contribution contribution, Member? member) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: contribution.isProcessed
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          child: Icon(
            contribution.isProcessed ? Icons.check_circle : Icons.pending,
            color: contribution.isProcessed ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          member?.fullName ?? 'Unknown Member',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Funds: ${contribution.fundNames.join(', ')}'),
            Text(
              'Date: ${DateFormat('MMM dd, yyyy').format(contribution.date)}',
            ),
            if (contribution.receiptNumber != null)
              Text('Receipt: ${contribution.receiptNumber}'),
            Text(
              'Status: ${contribution.isProcessed ? 'Processed' : 'Pending'}',
              style: TextStyle(
                color: contribution.isProcessed ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(contribution.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${contribution.fundCount} fund${contribution.fundCount > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showContributionOptions(contribution),
      ),
    );
  }

  List<Contribution> _getFilteredContributions(
    List<Contribution> allContributions,
  ) {
    var filtered = allContributions;

    // Filter by member if specified
    if (widget.memberId != null) {
      filtered = filtered.where((c) => c.memberId == widget.memberId).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        // Get member information for name search
        final member = context.read<AppStateProvider>().getMemberById(
          c.memberId,
        );
        final memberName = member?.fullName.toLowerCase() ?? '';

        return (c.notes?.toLowerCase().contains(_searchQuery) ?? false) ||
            (c.receiptNumber?.toLowerCase().contains(_searchQuery) ?? false) ||
            (c.reference?.toLowerCase().contains(_searchQuery) ?? false) ||
            memberName.contains(_searchQuery) ||
            c.fundNames.any(
              (fundName) => fundName.toLowerCase().contains(_searchQuery),
            );
      }).toList();
    }

    // Filter by processed status
    if (_processedFilter != null) {
      filtered = filtered
          .where((c) => c.isProcessed == _processedFilter)
          .toList();
    }

    // Filter by date range
    if (_startDate != null) {
      filtered = filtered
          .where(
            (c) =>
                c.date.isAfter(_startDate!.subtract(const Duration(days: 1))),
          )
          .toList();
    }
    if (_endDate != null) {
      filtered = filtered
          .where((c) => c.date.isBefore(_endDate!.add(const Duration(days: 1))))
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  void _showContributionOptions(Contribution contribution) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Contribution'),
            onTap: () {
              Navigator.pop(context);
              _editContribution(contribution);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Contribution',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(contribution);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              _showContributionDetails(contribution);
            },
          ),
        ],
      ),
    );
  }

  void _editContribution(Contribution contribution) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditContributionScreen(contribution: contribution),
      ),
    );
  }

  void _showDeleteConfirmation(Contribution contribution) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contribution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to delete this contribution?'),
            const SizedBox(height: 16),
            Text(
              'Amount: ${CurrencyFormatter.format(contribution.totalAmount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Funds: ${contribution.fundNames.join(', ')}'),
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
              _deleteContribution(contribution);
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

  Future<void> _deleteContribution(Contribution contribution) async {
    try {
      await context.read<AppStateProvider>().deleteContribution(
        contribution.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contribution deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting contribution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showContributionDetails(Contribution contribution) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contribution Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', contribution.id),
              _buildDetailRow(
                'Total Amount',
                CurrencyFormatter.format(contribution.totalAmount),
              ),
              _buildDetailRow(
                'Date',
                DateFormat('MMM dd, yyyy HH:mm').format(contribution.date),
              ),
              _buildDetailRow(
                'Status',
                contribution.isProcessed ? 'Processed' : 'Pending',
              ),
              if (contribution.receiptNumber != null)
                _buildDetailRow('Receipt', contribution.receiptNumber!),
              if (contribution.reference != null)
                _buildDetailRow('Reference', contribution.reference!),
              if (contribution.notes != null)
                _buildDetailRow('Notes', contribution.notes!),
              if (contribution.paymentMethod != null)
                _buildDetailRow('Payment Method', contribution.paymentMethod!),
              const SizedBox(height: 16),
              const Text(
                'Fund Contributions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...contribution.fundContributions.map(
                (fc) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fc.fundName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Amount: ${CurrencyFormatter.format(fc.amount)}'),
                      Text(
                        'Previous Balance: ${CurrencyFormatter.format(fc.previousBalance)}',
                      ),
                      Text(
                        'New Balance: ${CurrencyFormatter.format(fc.newBalance)}',
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
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
        title: const Text('Filter Contributions'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<bool>(
                value: _processedFilter,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: true, child: Text('Processed')),
                  DropdownMenuItem(value: false, child: Text('Pending')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    _processedFilter = value;
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
                _processedFilter = null;
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

  String _getDateRangeLabel() {
    if (_startDate != null && _endDate != null) {
      return '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}';
    } else if (_startDate != null) {
      return 'From ${DateFormat('MMM dd').format(_startDate!)}';
    } else if (_endDate != null) {
      return 'Until ${DateFormat('MMM dd').format(_endDate!)}';
    }
    return '';
  }
}
