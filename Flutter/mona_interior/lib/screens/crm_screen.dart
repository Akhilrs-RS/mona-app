import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:mona_interior/providers/crm_provider.dart';
import 'package:mona_interior/models/crm_models.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:mona_interior/widgets/forms/client_form.dart';
import 'package:mona_interior/widgets/forms/deal_form.dart';
import 'package:mona_interior/widgets/forms/activity_form.dart';

class CrmScreen extends ConsumerStatefulWidget {
  const CrmScreen({super.key});

  @override
  ConsumerState<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends ConsumerState<CrmScreen> {
  String _activeTab = 'contacts';
  String _searchQuery = '';
  String _monthFilter = 'All';

  void _showAddMenu(BuildContext context) {
    if (_activeTab == 'contacts') {
      showDialog(context: context, builder: (_) => const ClientForm());
    } else if (_activeTab == 'deals') {
      showDialog(context: context, builder: (_) => const DealForm());
    } else if (_activeTab == 'activities') {
      showDialog(context: context, builder: (_) => const ActivityForm());
    }
  }

  @override
  Widget build(BuildContext context) {
    final crmState = ref.watch(crmProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGold.withValues(alpha: 0.1),
                backgroundBlendMode: BlendMode.screen,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header & Tabs row
                _buildHeader(),
                
                const SizedBox(height: 16),
                
                // Content Area
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                      side: const BorderSide(color: AppColors.borderLight),
                    ),
                    child: crmState.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (data) {
                        if (_activeTab == 'contacts') {
                          return _buildClientsContent(data.contacts);
                        } else if (_activeTab == 'deals') {
                          return _buildDealsContent(data.deals, data.contacts);
                        } else if (_activeTab == 'activities') {
                          return _buildActivitiesContent(data.activities, data.contacts);
                        } else {
                          return _buildInsightsContent(data.deals, data.activities);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              _buildTabBtn('contacts', 'Clients', LucideIcons.user),
              _buildTabBtn('deals', 'Pipeline', LucideIcons.briefcase),
              _buildTabBtn('activities', 'Schedule', LucideIcons.calendar),
              _buildTabBtn('insights', 'Insights', LucideIcons.bar_chart_2),
            ],
          ),
        ),
        
        // Search & Add
        Row(
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search $_activeTab...',
                  prefixIcon: const Icon(LucideIcons.search, size: 16),
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddMenu(context),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add New'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTabBtn(String id, String label, IconData icon) {
    final isActive = _activeTab == id;
    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppColors.textMuted,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildClientsContent(List<Contact> contacts) {
    final filtered = contacts.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Client Directory', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.download, size: 16),
                label: const Text('Export PDF'),
              )
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderLight),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final c = filtered[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    // Profile
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              Text('ID: ${c.id}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1)),
                            ],
                          )
                        ],
                      ),
                    ),
                    // Project
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(c.project.isEmpty ? 'No Project' : c.project, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // Source
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          const Icon(LucideIcons.list_filter, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(c.source.isEmpty ? 'Unknown' : c.source, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    // Contact details
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.phone, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(c.phone, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(LucideIcons.mail, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(c.email.isEmpty ? 'N/A' : c.email, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                            ],
                          )
                        ],
                      ),
                    ),
                    // Actions
                    Row(
                      children: [
                        IconButton(icon: const Icon(LucideIcons.pen, size: 16, color: AppColors.textMuted), onPressed: () {}),
                        IconButton(icon: const Icon(LucideIcons.trash_2, size: 16, color: AppColors.danger), onPressed: () {}),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDealsContent(List<Deal> deals, List<Contact> contacts) {
    final stages = ['LEAD', 'CONTACTED', 'PROPOSAL', 'NEGOTIATION', 'WON'];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: stages.map((stage) {
          final stageDeals = deals.where((d) => d.stage == stage && d.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(stage, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('${stageDeals.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: stageDeals.length,
                      itemBuilder: (ctx, i) {
                        final d = stageDeals[i];
                        final contact = contacts.where((c) => c.id == d.contactId).firstOrNull;
                        return Card(
                          elevation: 4,
                          shadowColor: Colors.black.withValues(alpha: 0.1),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      width: 20, height: 20,
                                      decoration: BoxDecoration(color: AppColors.primaryGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                      alignment: Alignment.center,
                                      child: Text(contact?.name[0].toUpperCase() ?? '?', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primaryGold)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(contact?.name ?? 'Unknown', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.success.withValues(alpha: 0.2))),
                                  child: Text('₹${(d.value / 100000).toStringAsFixed(2)}L', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivitiesContent(List<Activity> activities, List<Contact> contacts) {
    return const Center(child: Text('Schedule Layout - Work in Progress'));
  }

  Widget _buildInsightsContent(List<Deal> deals, List<Activity> activities) {
    return const Center(child: Text('Insights Layout - Work in Progress'));
  }
}
