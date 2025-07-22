import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fund.dart';
import '../../providers/app_state_provider.dart';
import '../../services/fund_service.dart';
import '../../utils/currency_formatter.dart';
import 'fund_detail_screen.dart';
import 'create_fund_screen.dart';
import '../contributions/contribution_screen.dart';

class FundListScreen extends StatefulWidget {
  const FundListScreen({super.key});

  @override
  State<FundListScreen> createState() => _FundListScreenState();
}

class _FundListScreenState extends State<FundListScreen> {
  String _searchQuery = '';
  FundType? _selectedType;

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
        title: Text(l10n.investmentFunds),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateFund(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'bulk_contribute',
                child: ListTile(
                  leading: Icon(Icons.group_add),
                  title: Text('Bulk Contribution'),
                  subtitle: Text('Contribute to multiple funds'),
                ),
              ),
              const PopupMenuItem(
                value: 'export_data',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Fund Data'),
                  subtitle: Text('Download fund information'),
                ),
              ),
              const PopupMenuItem(
                value: 'fund_analytics',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Fund Analytics'),
                  subtitle: Text('View performance metrics'),
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_operations',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Bulk Operations'),
                  subtitle: Text('Manage multiple funds'),
                ),
              ),
              const PopupMenuItem(
                value: 'fund_settings',
                child: ListTile(
                  leading: Icon(Icons.tune),
                  title: Text('Fund Settings'),
                  subtitle: Text('Configure fund defaults'),
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh Data'),
                  subtitle: Text('Update fund information'),
                ),
              ),
            ],
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

          final filteredFunds = _filterFunds(appState.funds);

          return Column(
            children: [
              _buildSearchAndFilter(),
              _buildFundsSummary(appState),
              Expanded(
                child: filteredFunds.isEmpty
                    ? _buildEmptyState()
                    : _buildFundsList(filteredFunds),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: l10n.searchFunds,
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
                _buildFilterChip(l10n.all, null),
                const SizedBox(width: 8),
                _buildFilterChip(l10n.investment, FundType.investment),
                const SizedBox(width: 8),
                _buildFilterChip(l10n.emergency, FundType.emergency),
                const SizedBox(width: 8),
                _buildFilterChip(l10n.savings, FundType.savings),
                const SizedBox(width: 8),
                _buildFilterChip(l10n.loan, FundType.loan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, FundType? type) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
    );
  }

  Widget _buildFundsSummary(AppStateProvider appState) {
    final totalFunds = appState.funds.length;
    final activeFunds = appState.funds.where((f) => f.isActive).length;
    final totalBalance = appState.funds.fold(0.0, (sum, f) => sum + f.balance);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Total Funds',
            '$totalFunds',
            Icons.account_balance,
          ),
          _buildSummaryItem('Active', '$activeFunds', Icons.check_circle),
          _buildSummaryItem(
            'Total Value',
            CurrencyFormatter.format(totalBalance),
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
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.noFundsFound,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(l10n.createFirstFund, style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateFund,
            icon: const Icon(Icons.add),
            label: Text(l10n.createFund),
          ),
        ],
      ),
    );
  }

  Widget _buildFundsList(List<Fund> funds) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: funds.length,
      itemBuilder: (context, index) {
        final fund = funds[index];
        return _buildFundCard(fund);
      },
    );
  }

  Widget _buildFundCard(Fund fund) {
    final progressPercentage = fund.targetAmount > 0
        ? (fund.balance / fund.targetAmount * 100).clamp(0, 100)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToFundDetail(fund),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        Text(
                          fund.description,
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
                      color: fund.isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      fund.isActive ? 'Active' : 'Inactive',
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
                        'Current Balance',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        CurrencyFormatter.format(fund.balance),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  if (fund.targetAmount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Target: ${CurrencyFormatter.format(fund.targetAmount)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${progressPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (fund.targetAmount > 0) ...[
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
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  List<Fund> _filterFunds(List<Fund> funds) {
    var filtered = funds;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((fund) {
        return fund.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            fund.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedType != null) {
      filtered = filtered.where((fund) => fund.type == _selectedType).toList();
    }

    return filtered;
  }

  void _navigateToCreateFund() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateFundScreen()),
    );
  }

  void _navigateToFundDetail(Fund fund) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FundDetailScreen(fund: fund)),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'bulk_contribute':
        _navigateToBulkContribution();
        break;
      case 'export_data':
        _exportFundData();
        break;
      case 'fund_analytics':
        _showFundAnalytics();
        break;
      case 'bulk_operations':
        _showBulkOperations();
        break;
      case 'fund_settings':
        _showFundSettings();
        break;
      case 'refresh':
        _refreshData();
        break;
    }
  }

  void _navigateToBulkContribution() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContributionScreen()),
    );
  }

  void _exportFundData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Fund Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose export format:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV Format'),
              subtitle: const Text('Spreadsheet compatible'),
              onTap: () {
                Navigator.pop(context);
                _exportToCSV();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('PDF Report'),
              subtitle: const Text('Formatted document'),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportToCSV() {
    // TODO: Implement CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV export feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportToPDF() {
    // TODO: Implement PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showFundAnalytics() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final funds = appState.funds;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fund Analytics'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnalyticsItem(
                'Total Funds',
                '${funds.length}',
                Icons.account_balance,
                Colors.blue,
              ),
              _buildAnalyticsItem(
                'Active Funds',
                '${funds.where((f) => f.isActive).length}',
                Icons.check_circle,
                Colors.green,
              ),
              _buildAnalyticsItem(
                'Total Value',
                CurrencyFormatter.format(
                  funds.fold(0.0, (sum, f) => sum + f.balance),
                ),
                Icons.attach_money,
                Colors.orange,
              ),
              _buildAnalyticsItem(
                'Average Fund Size',
                CurrencyFormatter.format(
                  funds.isNotEmpty
                      ? funds.fold(0.0, (sum, f) => sum + f.balance) /
                            funds.length
                      : 0.0,
                ),
                Icons.trending_up,
                Colors.purple,
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

  Widget _buildAnalyticsItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBulkOperations() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final funds = appState.funds;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Operations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: const Text('Activate All Funds'),
              subtitle: Text(
                '${funds.where((f) => !f.isActive).length} inactive funds',
              ),
              onTap: () {
                Navigator.pop(context);
                _bulkActivateFunds();
              },
            ),
            ListTile(
              leading: const Icon(Icons.pause, color: Colors.orange),
              title: const Text('Deactivate All Funds'),
              subtitle: Text(
                '${funds.where((f) => f.isActive).length} active funds',
              ),
              onTap: () {
                Navigator.pop(context);
                _bulkDeactivateFunds();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate, color: Colors.blue),
              title: const Text('Recalculate Balances'),
              subtitle: const Text('Update all fund balances'),
              onTap: () {
                Navigator.pop(context);
                _recalculateAllBalances();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFundSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fund Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Default Currency'),
              subtitle: const Text('XAF (Central African Franc)'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement currency settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Currency settings coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.percent),
              title: const Text('Default Interest Rate'),
              subtitle: const Text('Set default rate for new funds'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement interest rate settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Interest rate settings coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Contribution Frequency'),
              subtitle: const Text('Default contribution schedule'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement frequency settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Frequency settings coming soon'),
                  ),
                );
              },
            ),
          ],
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

  void _refreshData() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fund data refreshed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _bulkActivateFunds() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final inactiveFunds = appState.funds.where((f) => !f.isActive).toList();

    if (inactiveFunds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All funds are already active')),
      );
      return;
    }

    try {
      int successCount = 0;
      for (final fund in inactiveFunds) {
        final result = await FundService.instance.activateFund(fund.id);
        if (result.success && result.fund != null) {
          await appState.updateFund(result.fund!);
          successCount++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Activated $successCount funds'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error activating funds: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _bulkDeactivateFunds() async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Deactivation'),
        content: const Text(
          'Are you sure you want to deactivate all active funds? This will prevent new contributions to these funds.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Deactivate All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final activeFunds = appState.funds.where((f) => f.isActive).toList();

    try {
      int successCount = 0;
      for (final fund in activeFunds) {
        final result = await FundService.instance.deactivateFund(
          fund.id,
          reason: 'Bulk deactivation',
        );
        if (result.success && result.fund != null) {
          await appState.updateFund(result.fund!);
          successCount++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deactivated $successCount funds'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deactivating funds: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _recalculateAllBalances() {
    // TODO: Implement balance recalculation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Balance recalculation feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
