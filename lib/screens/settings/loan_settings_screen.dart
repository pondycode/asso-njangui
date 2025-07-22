import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/loan_settings_provider.dart';
import '../../utils/currency_formatter.dart';

class LoanSettingsScreen extends StatefulWidget {
  const LoanSettingsScreen({super.key});

  @override
  State<LoanSettingsScreen> createState() => _LoanSettingsScreenState();
}

class _LoanSettingsScreenState extends State<LoanSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _defaultRateController = TextEditingController();
  final _minRateController = TextEditingController();
  final _maxRateController = TextEditingController();
  final _minTermController = TextEditingController();
  final _maxTermController = TextEditingController();
  final _maxLoanRatioController = TextEditingController();
  final _minContributionController = TextEditingController();

  bool _allowCustomRates = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _defaultRateController.dispose();
    _minRateController.dispose();
    _maxRateController.dispose();
    _minTermController.dispose();
    _maxTermController.dispose();
    _maxLoanRatioController.dispose();
    _minContributionController.dispose();
    super.dispose();
  }

  void _loadCurrentSettings() {
    final settings = context.read<LoanSettingsProvider>().settings;
    
    _defaultRateController.text = settings.defaultMonthlyInterestRate.toString();
    _minRateController.text = settings.minimumInterestRate.toString();
    _maxRateController.text = settings.maximumInterestRate.toString();
    _minTermController.text = settings.minimumLoanTermMonths.toString();
    _maxTermController.text = settings.maximumLoanTermMonths.toString();
    _maxLoanRatioController.text = settings.maxLoanToContributionRatio.toString();
    _minContributionController.text = settings.minimumContributionMonths.toString();
    _allowCustomRates = settings.allowCustomRates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Settings'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSettings,
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
      body: Consumer<LoanSettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInterestRateSection(),
                const SizedBox(height: 24),
                _buildLoanTermSection(),
                const SizedBox(height: 24),
                _buildLoanLimitsSection(),
                const SizedBox(height: 24),
                _buildActionsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInterestRateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interest Rate Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _defaultRateController,
              decoration: const InputDecoration(
                labelText: 'Default Monthly Interest Rate',
                hintText: 'Enter amount (e.g., 3150)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter default interest rate';
                }
                final rate = double.tryParse(value);
                if (rate == null || rate < 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minRateController,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Rate',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate < 0) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxRateController,
                    decoration: const InputDecoration(
                      labelText: 'Maximum Rate',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate < 0) {
                        return 'Invalid number';
                      }
                      final minRate = double.tryParse(_minRateController.text);
                      if (minRate != null && rate < minRate) {
                        return 'Must be ≥ min rate';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Allow Custom Interest Rates'),
              subtitle: const Text('Allow setting different rates for individual loans'),
              value: _allowCustomRates,
              onChanged: (value) {
                setState(() {
                  _allowCustomRates = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanTermSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Term Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minTermController,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Term (months)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final term = int.tryParse(value);
                      if (term == null || term < 1) {
                        return 'Must be ≥ 1';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxTermController,
                    decoration: const InputDecoration(
                      labelText: 'Maximum Term (months)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final term = int.tryParse(value);
                      if (term == null || term < 1) {
                        return 'Must be ≥ 1';
                      }
                      final minTerm = int.tryParse(_minTermController.text);
                      if (minTerm != null && term < minTerm) {
                        return 'Must be ≥ min term';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanLimitsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Limits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxLoanRatioController,
              decoration: const InputDecoration(
                labelText: 'Max Loan to Contribution Ratio',
                hintText: 'e.g., 3.0 means 3x member contributions',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter loan ratio';
                }
                final ratio = double.tryParse(value);
                if (ratio == null || ratio <= 0) {
                  return 'Please enter a positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minContributionController,
              decoration: const InputDecoration(
                labelText: 'Minimum Contribution Period (months)',
                hintText: 'e.g., 6 months before eligible for loan',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter minimum contribution period';
                }
                final months = int.tryParse(value);
                if (months == null || months < 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _resetToDefaults,
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Defaults'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<LoanSettingsProvider>();
      
      final success = await provider.updateSettings(
        defaultMonthlyInterestRate: double.parse(_defaultRateController.text),
        minimumInterestRate: double.parse(_minRateController.text),
        maximumInterestRate: double.parse(_maxRateController.text),
        allowCustomRates: _allowCustomRates,
        minimumLoanTermMonths: int.parse(_minTermController.text),
        maximumLoanTermMonths: int.parse(_maxTermController.text),
        maxLoanToContributionRatio: double.parse(_maxLoanRatioController.text),
        minimumContributionMonths: int.parse(_minContributionController.text),
        updatedBy: 'Admin', // TODO: Get current user
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loan settings saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
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

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'Are you sure you want to reset all loan settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final provider = context.read<LoanSettingsProvider>();
        final success = await provider.resetToDefaults(updatedBy: 'Admin');

        if (mounted) {
          if (success) {
            _loadCurrentSettings();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings reset to defaults'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${provider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error resetting settings: $e'),
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
}
