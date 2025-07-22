import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/fund.dart';
import '../../providers/app_state_provider.dart';
import '../../services/database_service.dart';

class CreateFundScreen extends StatefulWidget {
  const CreateFundScreen({super.key});

  @override
  State<CreateFundScreen> createState() => _CreateFundScreenState();
}

class _CreateFundScreenState extends State<CreateFundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _minimumContributionController = TextEditingController();
  final _maximumContributionController = TextEditingController();
  final _contributionFrequencyController = TextEditingController();

  FundType _selectedType = FundType.investment;
  bool _hasMaximumLimit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contributionFrequencyController.text = '30'; // Default to monthly
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _interestRateController.dispose();
    _minimumContributionController.dispose();
    _maximumContributionController.dispose();
    _contributionFrequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Fund'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveFund,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildFundTypeSection(),
              const SizedBox(height: 24),
              _buildFinancialSection(),
              const SizedBox(height: 24),
              _buildContributionRulesSection(),
              const SizedBox(height: 32),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Fund Name',
                hintText: 'Enter fund name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a fund name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter fund description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fund Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: FundType.values.map((type) {
                return ChoiceChip(
                  label: Text(_getFundTypeLabel(type)),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _getFundTypeDescription(_selectedType),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetAmountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount (Optional)',
                hintText: '0.00',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _interestRateController,
              decoration: const InputDecoration(
                labelText: 'Interest Rate (%)',
                hintText: '0.0',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an interest rate';
                }
                final rate = double.tryParse(value);
                if (rate == null || rate < 0 || rate > 100) {
                  return 'Please enter a valid interest rate (0-100)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionRulesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contribution Rules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minimumContributionController,
              decoration: const InputDecoration(
                labelText: 'Minimum Contribution',
                hintText: '0.00',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter minimum contribution';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount < 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _hasMaximumLimit,
                  onChanged: (value) {
                    setState(() {
                      _hasMaximumLimit = value ?? false;
                      if (!_hasMaximumLimit) {
                        _maximumContributionController.clear();
                      }
                    });
                  },
                ),
                const Text('Set maximum contribution limit'),
              ],
            ),
            if (_hasMaximumLimit) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _maximumContributionController,
                decoration: const InputDecoration(
                  labelText: 'Maximum Contribution',
                  hintText: '0.00',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (_hasMaximumLimit) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter maximum contribution';
                    }
                    final maxAmount = double.tryParse(value);
                    final minAmount = double.tryParse(
                      _minimumContributionController.text,
                    );
                    if (maxAmount == null || maxAmount < 0) {
                      return 'Please enter a valid amount';
                    }
                    if (minAmount != null && maxAmount <= minAmount) {
                      return 'Maximum must be greater than minimum';
                    }
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _contributionFrequencyController,
              decoration: const InputDecoration(
                labelText: 'Contribution Frequency (Days)',
                hintText: '30',
                suffixText: 'days',
                border: OutlineInputBorder(),
                helperText:
                    'How often members can contribute (e.g., 30 for monthly)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contribution frequency';
                }
                final days = int.tryParse(value);
                if (days == null || days < 1) {
                  return 'Please enter a valid number of days';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveFund,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Create Fund', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  String _getFundTypeLabel(FundType type) {
    switch (type) {
      case FundType.investment:
        return 'Investment';
      case FundType.emergency:
        return 'Emergency';
      case FundType.savings:
        return 'Savings';
      case FundType.loan:
        return 'Loan';
    }
  }

  String _getFundTypeDescription(FundType type) {
    switch (type) {
      case FundType.investment:
        return 'For long-term investments and wealth building';
      case FundType.emergency:
        return 'For emergency situations and unexpected expenses';
      case FundType.savings:
        return 'For general savings and short-term goals';
      case FundType.loan:
        return 'For lending to members with interest';
    }
  }

  Future<void> _saveFund() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fund = Fund(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        targetAmount: double.tryParse(_targetAmountController.text) ?? 0.0,
        interestRate: double.parse(_interestRateController.text),
        createdDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        minimumContribution: double.parse(_minimumContributionController.text),
        maximumContribution: _hasMaximumLimit
            ? double.parse(_maximumContributionController.text)
            : double.infinity,
        contributionFrequencyDays: int.parse(
          _contributionFrequencyController.text,
        ),
      );

      await DatabaseService.instance.saveFund(fund);

      if (mounted) {
        context.read<AppStateProvider>().initialize();
        Navigator.pop(context, fund);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fund created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating fund: $e'),
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
