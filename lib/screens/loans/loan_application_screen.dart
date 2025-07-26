import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../l10n/app_localizations.dart';
import '../../models/loan.dart';
import '../../models/fund.dart';
import '../../models/member.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/loan_settings_provider.dart';
import '../../services/database_service.dart';
import '../../services/loan_service.dart';
import '../../widgets/feature_restriction_widget.dart';

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _termController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _collateralController = TextEditingController();

  Member? _selectedMember;
  Fund? _selectedFund;
  final List<String> _guarantors = [];
  bool _isLoading = false;
  bool _isCheckingEligibility = false;
  String? _eligibilityMessage;
  bool _isEligible = false;

  @override
  void initState() {
    super.initState();
    _termController.text = '12'; // Default to 12 months
    _interestRateController.text = '10'; // Default to 10% per annum
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _termController.dispose();
    _interestRateController.dispose();
    _collateralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Application'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitApplication,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
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
                children: [
                  const TrialLimitationBanner(
                    customMessage:
                        'Trial users can apply for loans up to 50,000 CFA. Upgrade for unlimited loan amounts.',
                  ),
                  _buildMemberSelectionSection(appState),
                  const SizedBox(height: 24),
                  _buildFundSelectionSection(appState),
                  const SizedBox(height: 24),
                  _buildLoanDetailsSection(),
                  const SizedBox(height: 24),
                  _buildEligibilityStatus(),
                  const SizedBox(height: 24),
                  _buildGuarantorsSection(appState),
                  const SizedBox(height: 24),
                  _buildCollateralSection(),
                  const SizedBox(height: 24),
                  _buildLoanSummary(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberSelectionSection(AppStateProvider appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Borrower Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Member>(
              value: _selectedMember,
              decoration: const InputDecoration(
                labelText: 'Select Member',
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
                  _eligibilityMessage = null;
                  _isEligible = false;
                });
                _checkEligibility();
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a member';
                }
                return null;
              },
            ),
            if (_selectedMember != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${_selectedMember!.email}'),
                    Text('Phone: ${_selectedMember!.phoneNumber}'),
                    Text(
                      'Outstanding Loans: \$${_selectedMember!.outstandingLoans.toStringAsFixed(2)}',
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

  Widget _buildFundSelectionSection(AppStateProvider appState) {
    final availableFunds = appState.funds
        .where((fund) => fund.isActive && fund.balance > 0)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fund Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Fund>(
              value: _selectedFund,
              decoration: const InputDecoration(
                labelText: 'Select Fund',
                border: OutlineInputBorder(),
                helperText: 'Choose which fund to borrow from',
              ),
              items: availableFunds.map((fund) {
                return DropdownMenuItem(
                  value: fund,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fund.name),
                      Text(
                        'Available: \$${fund.balance.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (fund) {
                setState(() {
                  _selectedFund = fund;
                  _eligibilityMessage = null;
                  _isEligible = false;
                });
                _checkEligibility();
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a fund';
                }
                return null;
              },
            ),
            if (_selectedFund != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fund: ${_selectedFund!.name}'),
                    Text(
                      'Available Balance: \$${_selectedFund!.balance.toStringAsFixed(2)}',
                    ),
                    Text('Interest Rate: ${_selectedFund!.interestRate}%'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Loan Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                _checkEligibility();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter loan amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (_selectedFund != null && amount > _selectedFund!.balance) {
                  return 'Amount exceeds available fund balance';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose of Loan',
                hintText: 'e.g., Business expansion, Education, Emergency',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the purpose of the loan';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _termController,
              decoration: const InputDecoration(
                labelText: 'Expected Term (Months)',
                suffixText: 'months',
                border: OutlineInputBorder(),
                helperText: 'Interest accumulates monthly regardless of term',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter loan term';
                }
                final term = int.tryParse(value);
                if (term == null || term < 1 || term > 60) {
                  return 'Please enter a valid term (1-60 months)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Consumer<LoanSettingsProvider>(
              builder: (context, loanSettings, child) {
                final monthlyRatePercentage = loanSettings
                    .getCurrentMonthlyInterestRatePercentage();
                return TextFormField(
                  controller: _interestRateController,
                  decoration: InputDecoration(
                    labelText: 'Interest Rate (% per annum)',
                    suffixText: '% per year',
                    border: const OutlineInputBorder(),
                    helperText:
                        'Monthly interest rate: ${monthlyRatePercentage.toStringAsFixed(1)}% of principal',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter interest rate';
                    }
                    final rate = double.tryParse(value);
                    if (rate == null || rate < 0 || rate > 100) {
                      return 'Please enter a valid rate (0-100%)';
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuarantorsSection(AppStateProvider appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Guarantors (Optional)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _addGuarantor(appState),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_guarantors.isEmpty)
              Text(
                'No guarantors added',
                style: TextStyle(color: Colors.grey[600]),
              )
            else
              Column(
                children: _guarantors.map((guarantorId) {
                  final guarantor = appState.members.firstWhere(
                    (m) => m.id == guarantorId,
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
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        '${guarantor.firstName[0]}${guarantor.lastName[0]}',
                      ),
                    ),
                    title: Text('${guarantor.firstName} ${guarantor.lastName}'),
                    subtitle: Text(guarantor.email ?? guarantor.phoneNumber),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeGuarantor(guarantorId),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollateralSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Collateral (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _collateralController,
              decoration: const InputDecoration(
                labelText: 'Collateral Description',
                hintText: 'e.g., Property deed, Vehicle title, Equipment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanSummary() {
    if (_selectedFund == null ||
        _amountController.text.isEmpty ||
        _termController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    final term = int.tryParse(_termController.text) ?? 0;

    if (amount <= 0 || term <= 0) {
      return const SizedBox.shrink();
    }

    return Consumer<LoanSettingsProvider>(
      builder: (context, loanSettings, child) {
        // Calculate using dynamic interest rate
        final monthlyInterestRate = loanSettings
            .getCurrentMonthlyInterestRatePercentage();
        final monthlyInterestAmount = loanSettings.calculateMonthlyInterest(
          amount,
        );
        final monthlyPrincipal = amount / term;
        final monthlyPayment = monthlyPrincipal + monthlyInterestAmount;

        // Note: In the new system, interest accumulates month by month
        // This calculation shows what would happen if paid according to schedule
        final totalScheduledPayment = monthlyPayment * term;
        final totalScheduledInterest = monthlyInterestAmount * term;

        return Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loan Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.interestAccumulatesMonthlyNote,
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(
                  'Principal Amount',
                  '\$${amount.toStringAsFixed(2)}',
                ),
                _buildSummaryRow(
                  'Monthly Interest Rate',
                  '${monthlyInterestRate.toStringAsFixed(1)}% of principal',
                ),
                _buildSummaryRow(
                  'Monthly Interest Amount',
                  '\$${monthlyInterestAmount.toStringAsFixed(2)}',
                ),
                _buildSummaryRow('Term', '$term months'),
                _buildSummaryRow(
                  'Monthly Payment',
                  '\$${monthlyPayment.toStringAsFixed(2)}',
                ),
                _buildSummaryRow(
                  'Total Scheduled Interest',
                  '\$${totalScheduledInterest.toStringAsFixed(2)}',
                ),
                const Divider(),
                _buildSummaryRow(
                  'Total Scheduled Payment',
                  '\$${totalScheduledPayment.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = !_isLoading && _isEligible;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? _submitApplication : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: canSubmit ? null : Colors.grey,
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
                canSubmit ? 'Submit Application' : 'Check Eligibility First',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  void _addGuarantor(AppStateProvider appState) {
    final availableMembers = appState.activeMembers
        .where(
          (m) => m.id != _selectedMember?.id && !_guarantors.contains(m.id),
        )
        .toList();

    if (availableMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available members to add as guarantors'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Guarantor'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableMembers.length,
            itemBuilder: (context, index) {
              final member = availableMembers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${member.firstName[0]}${member.lastName[0]}'),
                ),
                title: Text('${member.firstName} ${member.lastName}'),
                subtitle: Text(member.email ?? member.phoneNumber),
                onTap: () {
                  setState(() {
                    _guarantors.add(member.id);
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
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

  void _removeGuarantor(String guarantorId) {
    setState(() {
      _guarantors.remove(guarantorId);
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final term = int.parse(_termController.text);
      final interestRate = double.parse(_interestRateController.text);

      // Month-by-month interest accumulation using configurable rate
      final loanSettings = context.read<LoanSettingsProvider>();
      final monthlyInterest = loanSettings.calculateMonthlyInterest(amount);
      final monthlyPrincipal = amount / term;
      final monthlyPayment = monthlyPrincipal + monthlyInterest;

      // Note: Interest will accumulate month by month regardless of this term

      final loan = Loan(
        id: const Uuid().v4(),
        memberId: _selectedMember!.id,
        principalAmount: amount,
        interestRate: interestRate,
        termInMonths: term,
        applicationDate: DateTime.now(),
        status: LoanStatus.pending,
        purpose: _purposeController.text.trim(),
        outstandingAmount: amount,
        guarantors: _guarantors,
        collateral: _collateralController.text.trim().isNotEmpty
            ? _collateralController.text.trim()
            : null,
        monthlyPayment: monthlyPayment,
        metadata: {
          'fundId': _selectedFund!.id,
          'fundName': _selectedFund!.name,
        },
      );

      await DatabaseService.instance.saveLoan(loan);

      if (mounted) {
        context.read<AppStateProvider>().initialize();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan application submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting application: $e'),
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

  Widget _buildEligibilityStatus() {
    if (_eligibilityMessage == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: _isEligible ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isEligible ? Icons.check_circle : Icons.error,
              color: _isEligible ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _eligibilityMessage!,
                style: TextStyle(
                  color: _isEligible ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkEligibility() async {
    if (_selectedMember == null ||
        _selectedFund == null ||
        _amountController.text.isEmpty) {
      setState(() {
        _eligibilityMessage = null;
        _isEligible = false;
      });
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _eligibilityMessage = null;
        _isEligible = false;
      });
      return;
    }

    setState(() {
      _isCheckingEligibility = true;
    });

    try {
      final result = await LoanService.instance.checkEligibility(
        memberId: _selectedMember!.id,
        requestedAmount: amount,
        fundId: _selectedFund!.id,
      );

      setState(() {
        _eligibilityMessage = result.reason;
        _isEligible = result.isEligible;
        _isCheckingEligibility = false;
      });
    } catch (e) {
      setState(() {
        _eligibilityMessage = 'Error checking eligibility: $e';
        _isEligible = false;
        _isCheckingEligibility = false;
      });
    }
  }
}
