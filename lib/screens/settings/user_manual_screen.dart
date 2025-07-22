import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

class ManualSection {
  final String title;
  final IconData icon;
  final String content;

  ManualSection({
    required this.title,
    required this.icon,
    required this.content,
  });
}

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({super.key});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedSection = 0;

  List<ManualSection> _getSections(AppLocalizations l10n) => [
    ManualSection(
      title: l10n.manualGettingStartedTitle,
      icon: Icons.rocket_launch,
      content: l10n.manualGettingStartedContent,
    ),
    ManualSection(
      title: l10n.manualDashboardTitle,
      icon: Icons.dashboard,
      content: l10n.manualDashboardContent,
    ),
    ManualSection(
      title: l10n.manualMemberManagementTitle,
      icon: Icons.people,
      content: l10n.manualMemberManagementContent,
    ),
    ManualSection(
      title: l10n.manualFundManagementTitle,
      icon: Icons.account_balance,
      content: l10n.manualFundManagementContent,
    ),
    ManualSection(
      title: l10n.manualContributionManagementTitle,
      icon: Icons.payment,
      content: l10n.manualContributionManagementContent,
    ),
    ManualSection(
      title: l10n.manualLoanManagementTitle,
      icon: Icons.credit_card,
      content: l10n.manualLoanManagementContent,
    ),
    ManualSection(
      title: l10n.manualTransactionManagementTitle,
      icon: Icons.receipt_long,
      content: l10n.manualTransactionManagementContent,
    ),
    ManualSection(
      title: l10n.manualPenaltiesManagementTitle,
      icon: Icons.warning,
      content: l10n.manualPenaltiesManagementContent,
    ),
    ManualSection(
      title: l10n.manualSettingsConfigurationTitle,
      icon: Icons.settings,
      content: l10n.manualSettingsConfigurationContent,
    ),
    ManualSection(
      title: l10n.manualTipsAndBestPracticesTitle,
      icon: Icons.lightbulb,
      content: l10n.manualTipsAndBestPracticesContent,
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = _getSections(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userManual),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top navigation bar
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final isSelected = index == _selectedSection;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          _selectedSection = index;
                        });
                        // Scroll to top of content when section changes
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue[100]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Colors.blue[300]!, width: 2)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              section.icon,
                              color: isSelected
                                  ? Colors.blue[700]
                                  : Colors.grey[600],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              section.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.blue[700]
                                    : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Main content area
          Expanded(child: _buildContentArea()),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    final l10n = AppLocalizations.of(context)!;
    final sections = _getSections(l10n);
    final section = sections[_selectedSection];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust padding based on available width
        final padding = constraints.maxWidth < 400 ? 12.0 : 24.0;

        return Container(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              LayoutBuilder(
                builder: (context, constraints) {
                  // Use column layout on very narrow screens
                  if (constraints.maxWidth < 300) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              section.icon,
                              size: 28,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                section.title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            tooltip: l10n.copyToClipboard,
                            onPressed: () => _copyToClipboard(section.content),
                          ),
                        ),
                      ],
                    );
                  }

                  // Use row layout on wider screens
                  return Row(
                    children: [
                      Icon(section.icon, size: 32, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          section.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: l10n.copyToClipboard,
                        onPressed: () => _copyToClipboard(section.content),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Section content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SelectableText(
                      section.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              // Navigation buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectedSection > 0
                        ? () {
                            setState(() {
                              _selectedSection--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.previousSection),
                  ),
                  Text(
                    '${_selectedSection + 1} of ${sections.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _selectedSection < sections.length - 1
                        ? () {
                            setState(() {
                              _selectedSection++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l10n.nextSection),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.searchManual),
        content: TextField(
          decoration: InputDecoration(
            hintText: l10n.searchForTopics,
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.searchFeatureComingSoon)),
              );
            },
            child: Text(l10n.search),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String content) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.sectionContentCopied),
        backgroundColor: Colors.green,
      ),
    );
  }
}
