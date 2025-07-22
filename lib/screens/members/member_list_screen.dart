import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_state_provider.dart';
import '../../models/member.dart';
import 'add_member_screen.dart';
import 'member_detail_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  MemberStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.members),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppStateProvider>().refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchMembers,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Chips
          if (_statusFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      'Status: ${_getStatusDisplayName(_statusFilter!)}',
                    ),
                    onDeleted: () {
                      setState(() {
                        _statusFilter = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Member List
          Expanded(
            child: Consumer<AppStateProvider>(
              builder: (context, appState, child) {
                if (appState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (appState.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${appState.error}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            appState.clearError();
                            appState.refresh();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredMembers = _filterMembers(appState.members);

                if (filteredMembers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _statusFilter != null
                              ? l10n.noMembersFound
                              : l10n.noMembersYet,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _statusFilter != null
                              ? l10n.tryAdjustingFilters
                              : l10n.addFirstMember,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    return _buildMemberCard(member);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMemberScreen()),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  List<Member> _filterMembers(List<Member> members) {
    var filtered = members;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((member) {
        return member.firstName.toLowerCase().contains(query) ||
            member.lastName.toLowerCase().contains(query) ||
            (member.email?.toLowerCase().contains(query) ?? false) ||
            member.phoneNumber.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered
          .where((member) => member.status == _statusFilter)
          .toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.fullName.compareTo(b.fullName));

    return filtered;
  }

  Widget _buildMemberCard(Member member) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(member.status),
          child: Text(
            member.firstName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (member.email != null) Text(member.email!),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(_getStatusDisplayName(member.status)),
                  backgroundColor: _getStatusColor(
                    member.status,
                  ).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: _getStatusColor(member.status),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Balance: ${currencyFormat.format(member.totalBalance)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberDetailScreen(member: member),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(MemberStatus status) {
    switch (status) {
      case MemberStatus.active:
        return Colors.green;
      case MemberStatus.inactive:
        return Colors.grey;
      case MemberStatus.suspended:
        return Colors.red;
      case MemberStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusDisplayName(MemberStatus status) {
    final l10n = AppLocalizations.of(context)!;

    switch (status) {
      case MemberStatus.active:
        return l10n.active;
      case MemberStatus.inactive:
        return l10n.inactive;
      case MemberStatus.suspended:
        return l10n.suspended;
      case MemberStatus.pending:
        return l10n.pending;
    }
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.filterMembers),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.filterByStatus),
            const SizedBox(height: 16),
            ...MemberStatus.values.map(
              (status) => RadioListTile<MemberStatus?>(
                title: Text(_getStatusDisplayName(status)),
                value: status,
                groupValue: _statusFilter,
                onChanged: (value) {
                  setState(() {
                    _statusFilter = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            RadioListTile<MemberStatus?>(
              title: const Text('All'),
              value: null,
              groupValue: _statusFilter,
              onChanged: (value) {
                setState(() {
                  _statusFilter = null;
                });
                Navigator.pop(context);
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
}
