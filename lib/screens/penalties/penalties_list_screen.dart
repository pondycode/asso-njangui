import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/penalty.dart';
import '../../providers/app_state_provider.dart';
import '../../services/penalty_service.dart';
import '../../utils/currency_formatter.dart';
import 'penalty_detail_screen.dart';
import 'apply_penalty_screen.dart';
import 'penalty_rules_screen.dart';

class PenaltiesListScreen extends StatefulWidget {
  final String? memberId;

  const PenaltiesListScreen({super.key, this.memberId});

  @override
  State<PenaltiesListScreen> createState() => _PenaltiesListScreenState();
}

class _PenaltiesListScreenState extends State<PenaltiesListScreen> {
  final PenaltyService _penaltyService = PenaltyService.instance;
  List<Penalty> _penalties = [];
  bool _isLoading = true;
  String _searchQuery = '';
  PenaltyStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadPenalties();
  }

  Future<void> _loadPenalties() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Penalty> penalties;
      if (widget.memberId != null) {
        penalties = await _penaltyService.getPenaltiesForMember(widget.memberId!);
      } else {
        penalties = await _penaltyService.getAllPenalties();
      }

      setState(() {
        _penalties = penalties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading penalties: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Penalty> get _filteredPenalties {
    var filtered = _penalties;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((penalty) {
        final member = context.read<AppStateProvider>().getMemberById(penalty.memberId);
        final memberName = member?.fullName.toLowerCase() ?? '';
        return penalty.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               penalty.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               memberName.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by status
    if (_statusFilter != null) {
      filtered = filtered.where((penalty) => penalty.status == _statusFilter).toList();
    }

    // Sort by applied date (newest first)
    filtered.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memberId != null ? 'Member Penalties' : 'All Penalties'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.rule),
            tooltip: 'Penalty Rules',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PenaltyRulesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPenalties,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          _buildSummaryCard(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPenaltiesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplyPenaltyScreen(memberId: widget.memberId),
            ),
          ).then((_) => _loadPenalties());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search penalties...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _statusFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Active'),
                  selected: _statusFilter == PenaltyStatus.active,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = selected ? PenaltyStatus.active : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Paid'),
                  selected: _statusFilter == PenaltyStatus.paid,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = selected ? PenaltyStatus.paid : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Overdue'),
                  selected: _statusFilter == PenaltyStatus.pending,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = selected ? PenaltyStatus.pending : null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final filteredPenalties = _filteredPenalties;
    final totalAmount = filteredPenalties.fold(0.0, (sum, penalty) => sum + penalty.amount);
    final paidAmount = filteredPenalties.fold(0.0, (sum, penalty) => sum + penalty.paidAmount);
    final outstandingAmount = totalAmount - paidAmount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning,
                  color: Colors.red[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Outstanding',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(outstandingAmount),
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${filteredPenalties.length} penalties',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPenaltiesList() {
    final filteredPenalties = _filteredPenalties;

    if (filteredPenalties.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No penalties found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredPenalties.length,
      itemBuilder: (context, index) {
        final penalty = filteredPenalties[index];
        return _buildPenaltyCard(penalty);
      },
    );
  }

  Widget _buildPenaltyCard(Penalty penalty) {
    final member = context.read<AppStateProvider>().getMemberById(penalty.memberId);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(penalty.status).withValues(alpha: 0.1),
          child: Icon(
            _getStatusIcon(penalty.status),
            color: _getStatusColor(penalty.status),
          ),
        ),
        title: Text(
          penalty.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Member: ${member?.fullName ?? 'Unknown'}'),
            Text('Applied: ${DateFormat('MMM dd, yyyy').format(penalty.appliedDate)}'),
            if (penalty.dueDate != null)
              Text('Due: ${DateFormat('MMM dd, yyyy').format(penalty.dueDate!)}'),
            Text(
              'Status: ${_getStatusText(penalty.status)}',
              style: TextStyle(
                color: _getStatusColor(penalty.status),
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
              CurrencyFormatter.format(penalty.amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (penalty.paidAmount > 0)
              Text(
                'Paid: ${CurrencyFormatter.format(penalty.paidAmount)}',
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PenaltyDetailScreen(penaltyId: penalty.id),
            ),
          ).then((_) => _loadPenalties());
        },
      ),
    );
  }

  Color _getStatusColor(PenaltyStatus status) {
    switch (status) {
      case PenaltyStatus.pending:
        return Colors.orange;
      case PenaltyStatus.active:
        return Colors.red;
      case PenaltyStatus.paid:
        return Colors.green;
      case PenaltyStatus.waived:
        return Colors.blue;
      case PenaltyStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PenaltyStatus status) {
    switch (status) {
      case PenaltyStatus.pending:
        return Icons.pending;
      case PenaltyStatus.active:
        return Icons.warning;
      case PenaltyStatus.paid:
        return Icons.check_circle;
      case PenaltyStatus.waived:
        return Icons.cancel;
      case PenaltyStatus.cancelled:
        return Icons.block;
    }
  }

  String _getStatusText(PenaltyStatus status) {
    switch (status) {
      case PenaltyStatus.pending:
        return 'Pending';
      case PenaltyStatus.active:
        return 'Active';
      case PenaltyStatus.paid:
        return 'Paid';
      case PenaltyStatus.waived:
        return 'Waived';
      case PenaltyStatus.cancelled:
        return 'Cancelled';
    }
  }
}
