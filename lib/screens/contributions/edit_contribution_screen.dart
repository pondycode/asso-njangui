import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/contribution.dart';
import '../../models/member.dart';
import '../../models/fund.dart';
import '../../providers/app_state_provider.dart';

class EditContributionScreen extends StatefulWidget {
  final Contribution contribution;

  const EditContributionScreen({super.key, required this.contribution});

  @override
  State<EditContributionScreen> createState() => _EditContributionScreenState();
}

class _EditContributionScreenState extends State<EditContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  late TextEditingController _referenceController;
  late TextEditingController _receiptController;
  late TextEditingController _paymentMethodController;

  late DateTime _selectedDate;
  String? _selectedMemberId;
  Map<String, double> _fundAmounts = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _notesController = TextEditingController(
      text: widget.contribution.notes ?? '',
    );
    _referenceController = TextEditingController(
      text: widget.contribution.reference ?? '',
    );
    _receiptController = TextEditingController(
      text: widget.contribution.receiptNumber ?? '',
    );
    _paymentMethodController = TextEditingController(
      text: widget.contribution.paymentMethod ?? '',
    );

    _selectedDate = widget.contribution.date;
    _selectedMemberId = widget.contribution.memberId;

    // Initialize fund amounts from existing contribution
    for (final fc in widget.contribution.fundContributions) {
      _fundAmounts[fc.fundId] = fc.amount;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _referenceController.dispose();
    _receiptController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contribution'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfoSection(appState),
                  const SizedBox(height: 24),
                  _buildFundContributionsSection(appState),
                  const SizedBox(height: 24),
                  _buildAdditionalInfoSection(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoSection(AppStateProvider appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMemberId,
              decoration: const InputDecoration(
                labelText: 'Member *',
                border: OutlineInputBorder(),
              ),
              items: appState.members.map((member) {
                return DropdownMenuItem(
                  value: member.id,
                  child: Text(member.fullName),
                );
              }).toList(),
              onChanged: widget.contribution.isProcessed
                  ? null
                  : (value) {
                      setState(() {
                        _selectedMemberId = value;
                      });
                    },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a member';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: widget.contribution.isProcessed ? null : _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundContributionsSection(AppStateProvider appState) {
    final activeFunds = appState.funds.where((fund) => fund.isActive).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fund Contributions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.contribution.isProcessed)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This contribution has been processed. Fund amounts cannot be changed.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ...activeFunds.map((fund) {
              final currentAmount = _fundAmounts[fund.id] ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  initialValue: currentAmount > 0
                      ? currentAmount.toString()
                      : '',
                  decoration: InputDecoration(
                    labelText: '${fund.name} Contribution',
                    prefixText: 'XAF ',
                    border: const OutlineInputBorder(),
                    helperText:
                        'Current balance: XAF ${fund.getMemberBalance(_selectedMemberId ?? '').toStringAsFixed(2)}',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  enabled: !widget.contribution.isProcessed,
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0.0;
                    setState(() {
                      if (amount > 0) {
                        _fundAmounts[fund.id] = amount;
                      } else {
                        _fundAmounts.remove(fund.id);
                      }
                    });
                  },
                  validator: (value) {
                    final amount = double.tryParse(value ?? '') ?? 0.0;
                    if (amount < 0) {
                      return 'Amount cannot be negative';
                    }
                    return null;
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'XAF ${_getTotalAmount().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paymentMethodController,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Reference',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _receiptController,
              decoration: const InputDecoration(
                labelText: 'Receipt Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveContribution,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Save Changes', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  double _getTotalAmount() {
    return _fundAmounts.values.fold(0.0, (sum, amount) => sum + amount);
  }

  Future<void> _saveContribution() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fundAmounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one fund contribution'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = context.read<AppStateProvider>();

      // Get fund names and previous balances
      final fundNames = <String, String>{};
      final previousBalances = <String, double>{};

      for (final fundId in _fundAmounts.keys) {
        final fund = appState.getFundById(fundId);
        if (fund != null) {
          fundNames[fundId] = fund.name;
          previousBalances[fundId] = fund.getMemberBalance(_selectedMemberId!);
        }
      }

      final updatedContribution =
          Contribution.create(
            memberId: _selectedMemberId!,
            fundAmounts: _fundAmounts,
            fundNames: fundNames,
            previousBalances: previousBalances,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
            paymentMethod: _paymentMethodController.text.trim().isNotEmpty
                ? _paymentMethodController.text.trim()
                : null,
            reference: _referenceController.text.trim().isNotEmpty
                ? _referenceController.text.trim()
                : null,
            date: _selectedDate,
          ).copyWith(
            id: widget.contribution.id, // Keep the same ID
            isProcessed: widget
                .contribution
                .isProcessed, // Keep the same processed status
            processedDate: widget.contribution.processedDate,
            processedBy: widget.contribution.processedBy,
            receiptNumber: _receiptController.text.trim().isNotEmpty
                ? _receiptController.text.trim()
                : null,
            transactionIds: widget
                .contribution
                .transactionIds, // Keep existing transaction IDs for now
          );

      await appState.updateContribution(
        widget.contribution,
        updatedContribution,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contribution updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating contribution: $e'),
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
}
