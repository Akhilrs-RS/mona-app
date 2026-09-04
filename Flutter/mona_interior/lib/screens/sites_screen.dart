import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:mona_interior/models/site_models.dart';
import 'package:mona_interior/providers/site_provider.dart';
import 'package:mona_interior/providers/finance_provider.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:mona_interior/widgets/layouts/two_pane_layout.dart';
import 'package:mona_interior/widgets/forms/site_form.dart';
import 'package:mona_interior/models/finance_models.dart';

class SitesScreen extends ConsumerStatefulWidget {
  const SitesScreen({super.key});

  @override
  ConsumerState<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends ConsumerState<SitesScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  Site? _selectedSite;

  final List<String> _statuses = ['All', 'Pre-Construction', 'In Progress', 'Completed', 'Maintenance'];

  @override
  Widget build(BuildContext context) {
    final sitesState = ref.watch(sitesProvider);
    final financeState = ref.watch(financeProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.building, color: AppColors.primaryGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Work Orders',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage site operations, financial links, and project progress.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(context: context, builder: (_) => const SiteForm());
                  },
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Create New Work Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: sitesState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (sites) {
                  final filteredSites = sites.where((s) {
                    final matchStatus = _statusFilter == 'All' || s.status == _statusFilter;
                    final matchSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        s.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        s.address.toLowerCase().contains(_searchQuery.toLowerCase());
                    return matchStatus && matchSearch;
                  }).toList();

                  return TwoPaneLayout(
                    isRightPaneActive: _selectedSite != null,
                    onBackToLeftPane: () {
                      setState(() {
                        _selectedSite = null;
                      });
                    },
                    leftPane: _buildLeftPane(filteredSites, financeState),
                    rightPane: _selectedSite == null 
                      ? const Center(child: Text('Select a work order to view details.', style: TextStyle(color: AppColors.textMuted)))
                      : _buildRightPane(_selectedSite!, financeState),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftPane(List<Site> sites, AsyncValue<FinanceState> financeState) {
    return Column(
      children: [
        // Filters
        Card(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            side: BorderSide(color: AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search site, client, location...',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statuses.map((status) {
                      final isSelected = _statusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _statusFilter = status),
                          selectedColor: AppColors.primaryGold.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryGold : AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        // List
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              side: BorderSide(color: AppColors.borderLight),
            ),
            child: ListView.separated(
              itemCount: sites.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (context, index) {
                final site = sites[index];
                final isSelected = _selectedSite?.id == site.id;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSite = site;
                    });
                  },
                  child: Container(
                    color: isSelected ? AppColors.primaryGold.withValues(alpha: 0.1) : null,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${site.id.toString().padLeft(4, '0')} - ${site.name}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                            ),
                            _buildStatusBadge(site.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(child: Text(site.address, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(LucideIcons.user, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(site.clientName.isEmpty ? 'No Client' : site.clientName, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        
                        financeState.maybeWhen(
                          data: (data) {
                            double billed = 0;
                            double paid = 0;
                            
                            for (var inv in data.invoices) {
                              if (inv.status != 'Draft') {
                                bool match = false;
                                for (var item in inv.items) {
                                  if (item is Map && item['workOrderId'].toString() == site.id.toString()) {
                                    match = true; break;
                                  }
                                }
                                if (match) billed += inv.total;
                              }
                            }
                            for (var rec in data.receipts) {
                              if (rec.siteId == site.id.toString()) {
                                paid += rec.amountPaid;
                              }
                            }
                            
                            double balance = (site.budget > 0 ? site.budget : billed) - paid;
                            if (billed == 0 && site.budget == 0) return const SizedBox.shrink();
                            
                            return Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: balance > 0 ? AppColors.danger.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: balance > 0 ? AppColors.danger.withValues(alpha: 0.2) : AppColors.success.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    balance > 0 ? 'BALANCE DUE' : 'FULLY PAID',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                      color: balance > 0 ? AppColors.danger : AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    '₹${balance.abs().toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: balance > 0 ? AppColors.danger : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          orElse: () => const SizedBox.shrink(),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightPane(Site site, AsyncValue<FinanceState> financeState) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(site.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(LucideIcons.edit, size: 16, color: AppColors.primaryGold),
                            onPressed: () {}, // Edit Action
                            style: IconButton.styleFrom(backgroundColor: AppColors.primaryGold.withValues(alpha: 0.1)),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                            onPressed: () {}, // Delete Action
                            style: IconButton.styleFrom(backgroundColor: AppColors.danger.withValues(alpha: 0.1)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, size: 14, color: AppColors.info),
                          const SizedBox(width: 6),
                          Text(site.address, style: const TextStyle(fontSize: 12, color: AppColors.info, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 16),
                          const Text('Client:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(width: 4),
                          Text(site.clientName, style: const TextStyle(fontSize: 12, color: AppColors.info, fontWeight: FontWeight.w600)),
                        ],
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(site.status),
                    const SizedBox(height: 8),
                    Text('Project ID: ${site.id.toString().padLeft(4, '0')}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          
          // Financial Summary
          financeState.maybeWhen(
            data: (data) {
              double billed = 0, paid = 0, spent = 0;
              for (var inv in data.invoices) {
                if (inv.status != 'Draft') {
                  for (var item in inv.items) {
                    if (item is Map && item['workOrderId'].toString() == site.id.toString()) billed += inv.total;
                  }
                }
              }
              for (var rec in data.receipts) {
                if (rec.siteId == site.id.toString()) paid += rec.amountPaid;
              }
              for (var exp in data.expenses) {
                if (exp.clientId == site.id.toString()) spent += exp.amount;
              }
              double balance = site.budget - paid;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    _buildFinanceStat('Invoiced', billed, AppColors.info),
                    _buildFinanceStat('Receipts', paid, AppColors.success),
                    _buildFinanceStat('Balance Due', balance, balance > 0 ? AppColors.danger : AppColors.success),
                    _buildFinanceStat('Spent', spent, AppColors.warning),
                    _buildFinanceStat('Budget', site.budget, AppColors.success),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          
          // Tabs
          const Divider(height: 1, color: AppColors.borderLight),
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    isScrollable: true,
                    labelColor: AppColors.primaryGold,
                    unselectedLabelColor: AppColors.textMuted,
                    indicatorColor: AppColors.primaryGold,
                    tabs: [
                      Tab(icon: Icon(LucideIcons.camera, size: 16), text: 'Gallery'),
                      Tab(icon: Icon(LucideIcons.history, size: 16), text: 'Timeline'),
                      Tab(icon: Icon(LucideIcons.wrench, size: 16), text: 'Maintenance'),
                      Tab(icon: Icon(LucideIcons.indianRupee, size: 16), text: 'Financials'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        const Center(child: Text('Gallery Content')),
                        const Center(child: Text('Timeline Content')),
                        const Center(child: Text('Maintenance Content')),
                        const Center(child: Text('Financials Content')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFinanceStat(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.borderLight)),
        ),
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    if (status == 'Completed') color = AppColors.success;
    else if (status == 'In Progress' || status == 'Currently working') color = AppColors.warning;
    else if (status == 'Pre-Construction' || status == 'Yet to work') color = AppColors.info;
    else if (status == 'Maintenance') color = AppColors.danger;
    else color = AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          color: color,
        ),
      ),
    );
  }
}
