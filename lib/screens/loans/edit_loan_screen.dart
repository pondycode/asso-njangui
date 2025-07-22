import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/loan.dart';
import '../../models/member.dart';
import '../../providers/app_state_provider.dart';

class EditLoanScreen extends StatefulWidget {
  final Loan loan;

  const EditLoanScreen({super.key, required this.loan});

  @override
  State<EditLoanScreen> createState() => _EditLoanScreenState();
}

class _EditLoanScreenState extends State<EditLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _principalController;
  late TextEditingController _interestRateController;
  late TextEditingController _termController;
  late TextEditingController _purposeController;
  late TextEditingController _collateralController;

  late DateTime _applicationDate;
  String? _selectedMemberId;
  List<String> _guarantors = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _principalController = TextEditingController(
      text: widget.loan.principalAmount.toString(),
    );
    _interestRateController = TextEditingController(
      text: widget.loan.interestRate.toString(),
    );
    _termController = TextEditingController(
      text: widget.loan.termInMonths.toString(),
    );
    _purposeController = TextEditingController(text: widget.loan.purpose);
    _collateralController = TextEditingController(
      text: widget.loan.collateral ?? '',
    );

    _applicationDate = widget.loan.applicationDate;
    _selectedMemberId = widget.loan.memberId;
    _guarantors = List.from(widget.loan.guarantors);
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _termController.dispose();
    _purposeController.dispose();
    _collateralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Loan'),
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
                  _buildLoanDetailsSection(),
                  const SizedBox(height: 24),
                  _buildMemberSection(appState),
                  const SizedBox(height: 24),
                  _buildGuarantorsSection(appState),
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
              controller: _principalController,
              decoration: const InputDecoration(
                labelText: 'Principal Amount *',
                prefixText: 'XAF ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the principal amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              enabled: widget.loan.status == LoanStatus.pending,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _interestRateController,
              decoration: const InputDecoration(
                labelText: 'Interest Rate (%) *',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the interest rate';
                }
                final rate = double.tryParse(value);
                if (rate == null || rate < 0) {
                  return 'Please enter a valid interest rate';
                }
                return null;
              },
              enabled: widget.loan.status == LoanStatus.pending,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _termController,
              decoration: const InputDecoration(
                labelText: 'Term (Months) *',
                suffixText: 'months',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the loan term';
                }
                final term = int.tryParse(value);
                if (term == null || term <= 0) {
                  return 'Please enter a valid term';
                }
                return null;
              },
              enabled: widget.loan.status == LoanStatus.pending,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: widget.loan.status == LoanStatus.pending
                  ? _selectApplicationDate
                  : null,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Application Date *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(_applicationDate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberSection(AppStateProvider appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Member Information',
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
              onChanged: widget.loan.status == LoanStatus.pending
                  ? (value) {
                      setState(() {
                        _selectedMemberId = value;
                      });
                    }
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a member';
                }
                return null;
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
                  'Guarantors',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (widget.loan.status == LoanStatus.pending)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addGuarantor(appState),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_guarantors.isEmpty)
              const Text(
                'No guarantors added',
                style: TextStyle(color: Colors.grey),
              )
            else
              ..._guarantors.map((guarantorId) {
                final member = appState.getMemberById(guarantorId);
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(member?.fullName ?? 'Unknown Member'),
                  trailing: widget.loan.status == LoanStatus.pending
                      ? IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeGuarantor(guarantorId),
                        )
                      : null,
                );
              }).toList(),
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
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the loan purpose';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _collateralController,
              decoration: const InputDecoration(
                labelText: 'Collateral',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
        onPressed: _isLoading ? null : _saveLoan,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Save Changes', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<void> _selectApplicationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _applicationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _applicationDate = date;
      });
    }
  }

  void _addGuarantor(AppStateProvider appState) {
    final availableMembers = appState.members
        .where((m) => m.id != _selectedMemberId && !_guarantors.contains(m.id))
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
        title: const Text('Add Guarantor'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableMembers.length,
            itemBuilder: (context, index) {
              final member = availableMembers[index];
              return ListTile(
                title: Text(member.fullName),
                subtitle: Text(member.phoneNumber),
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

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final principalAmount = double.parse(_principalController.text);
      final interestRate = double.parse(_interestRateController.text);
      final termInMonths = int.parse(_termController.text);

      // Calculate monthly payment
      final monthlyInterestRate = interestRate / 100 / 12;
      final monthlyPayment = monthlyInterestRate == 0
          ? principalAmount / termInMonths
          : principalAmount *
                (monthlyInterestRate *
                    pow(1 + monthlyInterestRate, termInMonths)) /
                (pow(1 + monthlyInterestRate, termInMonths) - 1);

      final updatedLoan = widget.loan.copyWith(
        memberId: _selectedMemberId!,
        principalAmount: principalAmount,
        interestRate: interestRate,
        termInMonths: termInMonths,
        applicationDate: _applicationDate,
        purpose: _purposeController.text.trim(),
        guarantors: _guarantors,
        collateral: _collateralController.text.trim().isNotEmpty
            ? _collateralController.text.trim()
            : null,
        monthlyPayment: monthlyPayment,
        outstandingAmount: principalAmount, // Reset if principal changed
      );

      await context.read<AppStateProvider>().updateLoan(updatedLoan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedLoan);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating loan: $e'),
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
