import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fund.dart';
import '../../models/member.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/contribution_settings_provider.dart';
import '../../providers/fund_settings_provider.dart';
import '../../services/contribution_service.dart';
import '../../utils/currency_formatter.dart';
import '../settings/contribution_settings_screen.dart';

class ContributionScreen extends StatefulWidget {
  final Fund? selectedFund;
  final Member? selectedMember;

  const ContributionScreen({super.key, this.selectedFund, this.selectedMember});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  Member? _selectedMember;
  Fund? _selectedFund;
  Member? _selectedHost;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Bulk payment mode
  bool _isBulkMode = false;
  final Map<String, TextEditingController> _bulkAmountControllers = {};
  final Map<String, double> _bulkAmounts = {};

  @override
  void initState() {
    super.initState();
    _selectedFund = widget.selectedFund;
    _selectedMember = widget.selectedMember;

    // Set default amount for pre-selected Savings funds from settings
    if (_selectedFund != null && _selectedFund!.type == FundType.savings) {
      final fundSettings = Provider.of<FundSettingsProvider>(
        context,
        listen: false,
      );
      final defaultAmount = fundSettings.getDefaultAmountForFund(
        _selectedFund!,
      );
      if (defaultAmount > 0) {
        _amountController.text = defaultAmount.toString();
      }
    }

    _initializeBulkControllers();
    _loadDefaultSettings();
  }

  void _loadDefaultSettings() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<ContributionSettingsProvider>(
        context,
        listen: false,
      );
      final appState = Provider.of<AppStateProvider>(context, listen: false);

      // Load default date
      setState(() {
        _selectedDate = settingsProvider.effectiveDefaultDate;
      });

      // Load default host
      final defaultHost = settingsProvider.getDefaultHost(appState.members);
      if (defaultHost != null) {
        setState(() {
          _selectedHost = defaultHost;
        });
      }
    });
  }

  void _initializeBulkControllers() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final fundSettings = Provider.of<FundSettingsProvider>(
      context,
      listen: false,
    );
    final activeFunds = appState.funds.where((fund) => fund.isActive).toList();

    for (final fund in activeFunds) {
      final controller = TextEditingController();
      // Set default amount from fund settings
      final defaultAmount = fundSettings.getDefaultAmountForFund(fund);
      if (defaultAmount > 0) {
        controller.text = defaultAmount.toString();
        _bulkAmounts[fund.id] = defaultAmount;
      } else {
        _bulkAmounts[fund.id] = 0.0;
      }
      _bulkAmountControllers[fund.id] = controller;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    for (final controller in _bulkAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isBulkMode ? l10n.bulkContribution : l10n.makeContribution,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isBulkMode = !_isBulkMode;
                // When switching to single mode, set default amount for Savings fund
                if (!_isBulkMode &&
                    _selectedFund != null &&
                    _selectedFund!.type == FundType.savings) {
                  _amountController.text = '3500';
                }
              });
            },
            icon: Icon(_isBulkMode ? Icons.person : Icons.group),
            tooltip: _isBulkMode ? 'Single Contribution' : 'Bulk Contribution',
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : (_isBulkMode
                      ? _processBulkContribution
                      : _processContribution),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isBulkMode ? 'Contribute All' : 'Contribute'),
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _isBulkMode
                    ? _buildBulkModeContent(appState)
                    : _buildSingleModeContent(appState),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSingleModeContent(AppStateProvider appState) {
    return [
      _buildMemberSelectionSection(appState),
      const SizedBox(height: 16),
      _buildDefaultsInfoBanner(),
      const SizedBox(height: 24),
      _buildFundSelectionSection(appState),
      const SizedBox(height: 24),
      _buildContributionDetailsSection(),
      const SizedBox(height: 24),
      _buildContributionSummary(),
      const SizedBox(height: 32),
      _buildContributeButton(),
    ];
  }

  List<Widget> _buildBulkModeContent(AppStateProvider appState) {
    return [
      _buildMemberSelectionSection(appState),
      const SizedBox(height: 24),
      _buildBulkTotalAmountCard(),
      const SizedBox(height: 24),
      _buildBulkFundsSection(appState),
      const SizedBox(height: 24),
      _buildBulkSummaryCard(),
      const SizedBox(height: 32),
    ];
  }

  Widget _buildMemberSelectionSection(AppStateProvider appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Member',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Member>(
              value: _selectedMember,
              decoration: const InputDecoration(
                labelText: 'Member',
                border: OutlineInputBorder(),
              ),
              items: appState.activeMembers.map((member) {
                return DropdownMenuItem(
                  value: member,
                  child: Text('${member.firstName} ${member.lastName}'),
                );
              }).toList(),
              onChanged: (member) {
                setState(() {
                  _selectedMember = member;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a member';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date Selection
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Transaction Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Host Selection
            DropdownButtonFormField<Member>(
              value: _selectedHost,
              decoration: const InputDecoration(
                labelText: 'Host (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_pin),
                helperText: 'Select the member hosting this transaction',
              ),
              items: appState.activeMembers.map((member) {
                return DropdownMenuItem(
                  value: member,
                  child: Text('${member.firstName} ${member.lastName}'),
                );
              }).toList(),
              onChanged: (member) {
                setState(() {
                  _selectedHost = member;
                });
              },
            ),

            if (_selectedMember != null) ...[
              const SizedBox(height: 16),
              _buildMemberInfoCard(_selectedMember!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemberInfoCard(Member member) {
    final totalBalance =
        member.totalSavings + member.totalInvestments + member.emergencyFund;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email: ${member.email}'),
          Text('Total Balance: ${CurrencyFormatter.format(totalBalance)}'),
          Text(
            'Outstanding Loans: ${CurrencyFormatter.format(member.outstandingLoans)}',
          ),
          Text('Member since: ${DateFormat.yMMMd().format(member.joinDate)}'),
        ],
      ),
    );
  }

  Widget _buildDefaultsInfoBanner() {
    return Consumer<ContributionSettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (!settingsProvider.hasDefaults) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Using default settings',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Date and host are pre-filled from your preferences',
                      style: TextStyle(color: Colors.green[600], fontSize: 11),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContributionSettingsScreen(),
                    ),
                  );
                },
                child: Text(
                  'Settings',
                  style: TextStyle(color: Colors.green[700], fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFundSelectionSection(AppStateProvider appState) {
    final availableFunds = appState.funds
        .where((fund) => fund.isActive)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Fund', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<Fund>(
              value: _selectedFund,
              decoration: const InputDecoration(
                labelText: 'Fund',
                border: OutlineInputBorder(),
              ),
              items: availableFunds.map((fund) {
                return DropdownMenuItem(
                  value: fund,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fund.name),
                      Text(
                        'Min: \$${fund.minimumContribution.toStringAsFixed(2)} | Balance: \$${fund.balance.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (fund) {
                setState(() {
                  _selectedFund = fund;
                  // Set default amount of 3500 for Savings funds
                  if (fund != null && fund.type == FundType.savings) {
                    _amountController.text = '3500';
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a fund';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contribution Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Contribution Amount',
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
                helperText: _selectedFund != null
                    ? 'Min: \$${_selectedFund!.minimumContribution.toStringAsFixed(2)}'
                    : null,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contribution amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any notes about this contribution',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionSummary() {
    if (_selectedFund == null || _amountController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contribution Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Member', _selectedMember!.fullName),
            _buildSummaryRow('Fund', _selectedFund!.name),
            _buildSummaryRow('Amount', CurrencyFormatter.format(amount)),
            _buildSummaryRow('Type', 'Standard Contribution'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildContributeButton() {
    final canContribute =
        !_isLoading &&
        _selectedMember != null &&
        _selectedFund != null &&
        _amountController.text.isNotEmpty &&
        (double.tryParse(_amountController.text) ?? 0) > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canContribute ? _processContribution : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: canContribute ? null : Colors.grey,
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text(
                'Process Contribution',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _processContribution() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check for duplicate contributions on the same date
    final hasDuplicate = await _checkForDuplicateContribution();
    if (hasDuplicate) {
      final shouldProceed = await _showDuplicateContributionDialog();
      if (!shouldProceed) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text.trim();

      final result = await ContributionService.instance.processContribution(
        memberId: _selectedMember!.id,
        fundAmounts: {_selectedFund!.id: amount},
        contributionType: ContributionType.standard,
        notes: notes.isNotEmpty ? notes : null,
        paymentMethod: 'Cash',
        transactionDate: _selectedDate,
        hostId: _selectedHost?.id,
      );

      if (mounted) {
        if (result.success) {
          context.read<AppStateProvider>().initialize();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
        } else {
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
            content: Text('Error processing contribution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBulkFundsSection(AppStateProvider appState) {
    final activeFunds = appState.funds.where((fund) => fund.isActive).toList();

    if (activeFunds.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Active Funds Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'There are currently no active funds to contribute to.',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Contribute to Active Funds',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Enter different amounts for each fund you want to contribute to:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ...activeFunds.map((fund) => _buildBulkFundItem(fund)),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkFundItem(Fund fund) {
    final controller = _bulkAmountControllers[fund.id]!;
    final currentBalance = fund.getMemberBalance(_selectedMember?.id ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getFundTypeColor(fund.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFundTypeIcon(fund.type),
                    color: _getFundTypeColor(fund.type),
                    size: 20,
                  ),
                ),
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
                        fund.typeDisplayName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        CurrencyFormatter.format(currentBalance),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Min. Contribution',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        CurrencyFormatter.format(fund.minimumContribution),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Contribution Amount',
                prefixText: 'XAF ',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                helperText: fund.minimumContribution > 0
                    ? 'Minimum: ${CurrencyFormatter.format(fund.minimumContribution)}'
                    : null,
              ),
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                setState(() {
                  _bulkAmounts[fund.id] = amount;
                });
              },
              validator: (value) {
                final amount = double.tryParse(value ?? '') ?? 0;
                if (amount < 0) return 'Invalid amount';
                if (amount > 0 && amount < fund.minimumContribution) {
                  return 'Min: ${CurrencyFormatter.format(fund.minimumContribution)}';
                }
                if (amount > fund.maximumContribution) {
                  return 'Max: ${CurrencyFormatter.format(fund.maximumContribution)}';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getFundTypeColor(FundType type) {
    switch (type) {
      case FundType.savings:
        return Colors.blue;
      case FundType.investment:
        return Colors.green;
      case FundType.emergency:
        return Colors.orange;
      case FundType.loan:
        return Colors.purple;
    }
  }

  IconData _getFundTypeIcon(FundType type) {
    switch (type) {
      case FundType.savings:
        return Icons.savings;
      case FundType.investment:
        return Icons.trending_up;
      case FundType.emergency:
        return Icons.emergency;
      case FundType.loan:
        return Icons.account_balance;
    }
  }

  Widget _buildBulkTotalAmountCard() {
    final totalAmount = _bulkAmounts.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final fundsWithContributions = _bulkAmounts.entries
        .where((entry) => entry.value > 0)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                      'Total Contribution Amount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalAmount > 0
                          ? CurrencyFormatter.format(totalAmount)
                          : 'XAF 0.00',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (totalAmount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$fundsWithContributions fund${fundsWithContributions != 1 ? 's' : ''} selected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (totalAmount == 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Enter amounts below to see total',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBulkSummaryCard() {
    final totalAmount = _bulkAmounts.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final fundsWithContributions = _bulkAmounts.entries
        .where((entry) => entry.value > 0)
        .length;

    if (totalAmount == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Ready to Contribute',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance,
                            color: Colors.green[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text('Funds selected:'),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$fundsWithContributions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.green[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text('Total amount:'),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.format(totalAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Tap "Contribute All" to process all contributions',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Future<void> _processBulkContribution() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMember == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a member')));
      return;
    }

    final contributionsToMake = _bulkAmounts.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (contributionsToMake.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one contribution amount'),
        ),
      );
      return;
    }

    // Check for duplicate contributions on the same date
    final hasDuplicate = await _checkForDuplicateContribution();
    if (hasDuplicate) {
      final shouldProceed = await _showDuplicateBulkContributionDialog();
      if (!shouldProceed) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Process as a single bulk contribution
      final fundAmounts = Map<String, double>.fromEntries(contributionsToMake);

      // Process all contributions without eligibility checks
      final contributionType = ContributionType.standard;

      // Process the bulk contribution
      final result = await ContributionService.instance.processContribution(
        memberId: _selectedMember!.id,
        fundAmounts: fundAmounts,
        contributionType: contributionType,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        paymentMethod: 'Cash',
        transactionDate: _selectedDate,
        hostId: _selectedHost?.id,
      );

      if (mounted) {
        if (result.success) {
          // Clear all amounts
          for (final fundId in fundAmounts.keys) {
            _bulkAmountControllers[fundId]!.clear();
            _bulkAmounts[fundId] = 0.0;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Bulk contribution successful! Contributed to ${fundAmounts.length} funds.',
              ),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bulk contribution failed: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing bulk contributions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  /// Check if there's already a contribution for the selected member on the selected date
  Future<bool> _checkForDuplicateContribution() async {
    if (_selectedMember == null) return false;

    final appState = context.read<AppStateProvider>();
    final existingContributions = appState.contributions.where((contribution) {
      return contribution.memberId == _selectedMember!.id &&
          contribution.date.year == _selectedDate.year &&
          contribution.date.month == _selectedDate.month &&
          contribution.date.day == _selectedDate.day;
    }).toList();

    return existingContributions.isNotEmpty;
  }

  /// Show dialog to confirm proceeding with duplicate contribution
  Future<bool> _showDuplicateContributionDialog() async {
    final existingContributions = context
        .read<AppStateProvider>()
        .contributions
        .where((contribution) {
          return contribution.memberId == _selectedMember!.id &&
              contribution.date.year == _selectedDate.year &&
              contribution.date.month == _selectedDate.month &&
              contribution.date.day == _selectedDate.day;
        })
        .toList();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text('Duplicate Contribution Detected'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedMember!.fullName} already has ${existingContributions.length} contribution${existingContributions.length > 1 ? 's' : ''} on ${DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate)}:',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: existingContributions.map((contribution) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt,
                              size: 16,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${contribution.fundNames.join(', ')}: ${CurrencyFormatter.format(contribution.totalAmount)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Do you want to proceed with this additional contribution?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Proceed Anyway'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show dialog to confirm proceeding with duplicate bulk contribution
  Future<bool> _showDuplicateBulkContributionDialog() async {
    final existingContributions = context
        .read<AppStateProvider>()
        .contributions
        .where((contribution) {
          return contribution.memberId == _selectedMember!.id &&
              contribution.date.year == _selectedDate.year &&
              contribution.date.month == _selectedDate.month &&
              contribution.date.day == _selectedDate.day;
        })
        .toList();

    final contributionsToMake = _bulkAmounts.entries
        .where((entry) => entry.value > 0)
        .toList();

    final appState = context.read<AppStateProvider>();
    final fundNames = contributionsToMake.map((entry) {
      final fund = appState.funds.firstWhere((f) => f.id == entry.key);
      return '${fund.name}: ${CurrencyFormatter.format(entry.value)}';
    }).toList();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text('Duplicate Bulk Contribution Detected'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedMember!.fullName} already has ${existingContributions.length} contribution${existingContributions.length > 1 ? 's' : ''} on ${DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate)}:',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Existing Contributions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...existingContributions.map((contribution) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.receipt,
                                size: 14,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${contribution.fundNames.join(', ')}: ${CurrencyFormatter.format(contribution.totalAmount)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      const Text(
                        'New Bulk Contribution:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...fundNames.map((fundInfo) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle,
                                size: 14,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  fundInfo,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Do you want to proceed with this additional bulk contribution?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Proceed Anyway'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
