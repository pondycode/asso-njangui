import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fund_settings_provider.dart';
import '../../utils/currency_formatter.dart';

class FundSettingsScreen extends StatefulWidget {
  const FundSettingsScreen({super.key});

  @override
  State<FundSettingsScreen> createState() => _FundSettingsScreenState();
}

class _FundSettingsScreenState extends State<FundSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _defaultSavingsAmountController = TextEditingController();
  final _defaultInvestmentAmountController = TextEditingController();
  final _defaultEmergencyAmountController = TextEditingController();
  final _defaultLoanAmountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _defaultSavingsAmountController.dispose();
    _defaultInvestmentAmountController.dispose();
    _defaultEmergencyAmountController.dispose();
    _defaultLoanAmountController.dispose();
    super.dispose();
  }

  void _loadCurrentSettings() {
    final provider = context.read<FundSettingsProvider>();
    _defaultSavingsAmountController.text = provider.defaultSavingsAmount
        .toString();
    _defaultInvestmentAmountController.text = provider.defaultInvestmentAmount
        .toString();
    _defaultEmergencyAmountController.text = provider.defaultEmergencyAmount
        .toString();
    _defaultLoanAmountController.text = provider.defaultLoanAmount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSettings,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Consumer<FundSettingsProvider>(
        builder: (context, settingsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildDefaultAmountsCard(settingsProvider),
                  const SizedBox(height: 16),
                  _buildPreviewCard(settingsProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Fund Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure default amounts and settings for fund contributions.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAmountsCard(FundSettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Default Contribution Amounts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAmountField(
              controller: _defaultSavingsAmountController,
              label: 'Default Savings Amount',
              hint: 'Enter default amount for savings contributions',
              icon: Icons.savings,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildAmountField(
              controller: _defaultInvestmentAmountController,
              label: 'Default Investment Amount',
              hint: 'Enter default amount for investment contributions',
              icon: Icons.trending_up,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildAmountField(
              controller: _defaultEmergencyAmountController,
              label: 'Default Emergency Amount',
              hint: 'Enter default amount for emergency contributions',
              icon: Icons.security,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildAmountField(
              controller: _defaultLoanAmountController,
              label: 'Default Loan Amount',
              hint: 'Enter default amount for loan contributions',
              icon: Icons.money_off,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Set to 0 to disable default amounts and let users enter amounts manually.',
                      style: TextStyle(fontSize: 12),
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

  Widget _buildPreviewCard(FundSettingsProvider settingsProvider) {
    final savingsAmount =
        double.tryParse(_defaultSavingsAmountController.text) ?? 0.0;
    final investmentAmount =
        double.tryParse(_defaultInvestmentAmountController.text) ?? 0.0;
    final emergencyAmount =
        double.tryParse(_defaultEmergencyAmountController.text) ?? 0.0;
    final loanAmount =
        double.tryParse(_defaultLoanAmountController.text) ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text(
                  'Preview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'When making contributions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                    icon: Icons.savings,
                    color: Colors.green,
                    label: 'Savings funds: ',
                    amount: savingsAmount,
                  ),
                  const SizedBox(height: 4),
                  _buildPreviewRow(
                    icon: Icons.trending_up,
                    color: Colors.blue,
                    label: 'Investment funds: ',
                    amount: investmentAmount,
                  ),
                  const SizedBox(height: 4),
                  _buildPreviewRow(
                    icon: Icons.security,
                    color: Colors.orange,
                    label: 'Emergency funds: ',
                    amount: emergencyAmount,
                  ),
                  const SizedBox(height: 4),
                  _buildPreviewRow(
                    icon: Icons.money_off,
                    color: Colors.red,
                    label: 'Loan funds: ',
                    amount: loanAmount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixText: '${CurrencyFormatter.symbol} ',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a default amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount < 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewRow({
    required IconData icon,
    required Color color,
    required String label,
    required double amount,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(label),
        Text(
          amount > 0
              ? CurrencyFormatter.format(amount)
              : 'Manual entry required',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amount > 0 ? color : Colors.orange,
          ),
        ),
      ],
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
      final provider = context.read<FundSettingsProvider>();

      final savingsAmount = double.parse(_defaultSavingsAmountController.text);
      final investmentAmount = double.parse(
        _defaultInvestmentAmountController.text,
      );
      final emergencyAmount = double.parse(
        _defaultEmergencyAmountController.text,
      );
      final loanAmount = double.parse(_defaultLoanAmountController.text);

      await Future.wait([
        provider.setDefaultSavingsAmount(savingsAmount),
        provider.setDefaultInvestmentAmount(investmentAmount),
        provider.setDefaultEmergencyAmount(emergencyAmount),
        provider.setDefaultLoanAmount(loanAmount),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fund settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
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
}
