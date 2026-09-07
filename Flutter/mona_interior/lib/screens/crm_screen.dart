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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Row(
            children: [
              _buildTabBtn('contacts', 'Clients', LucideIcons.user),
              _buildTabBtn('deals', 'Pipeline', LucideIcons.briefcase),
              _buildTabBtn('activities', 'Schedule', LucideIcons.calendar),
              _buildTabBtn('insights', 'Insights', LucideIcons.chart_bar),
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
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = contacts.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Client Directory', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: isDark ? AppColors.textLight : AppColors.textDark)),
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
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
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
                            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
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
                          shadowColor: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.black.withValues(alpha: 0.1),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight)),
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
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _buildScheduleActionCard('Follow-up Call', LucideIcons.phone_call, Colors.blue),
              const SizedBox(width: 24),
              _buildScheduleActionCard('Site Visit', LucideIcons.map_pin, const Color(0xFF1F2937)),
              const SizedBox(width: 24),
              _buildScheduleActionCard('Send Quotation', LucideIcons.dollar_sign, Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 16, color: Colors.blueGrey[400]),
                      const SizedBox(width: 8),
                      Text(
                        'UPCOMING SCHEDULE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleActionCard(String title, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor = (isDark && color == const Color(0xFF1F2937)) ? AppColors.textLight : color;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: displayColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: displayColor.withValues(alpha: 0.2)),
                  ),
                  child: Icon(icon, size: 20, color: displayColor),
                ),
                const SizedBox(width: 16),
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : const Color(0xFF111827))),
              ],
            ),
            Icon(LucideIcons.plus, size: 20, color: Colors.blueGrey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsContent(List<Deal> deals, List<Activity> activities) {
    double totalPipeline = 0;
    double closedRevenue = 0;
    int activeProjects = 0;
    
    int leadCount = 0;
    int contactedCount = 0;
    int proposalCount = 0;
    int negotiatingCount = 0;
    int wonCount = 0;

    double leadValue = 0;
    double contactedValue = 0;
    double proposalValue = 0;
    double negotiatingValue = 0;
    double wonValue = 0;

    for (var d in deals) {
      totalPipeline += d.value;
      if (d.stage == 'WON') {
        closedRevenue += d.value;
        wonCount++;
        wonValue += d.value;
      } else if (d.stage != 'LOST') {
        activeProjects++;
        if (d.stage == 'LEAD') { leadCount++; leadValue += d.value; }
        else if (d.stage == 'PROPOSAL') { proposalCount++; proposalValue += d.value; }
        else if (d.stage == 'NEGOTIATION') { negotiatingCount++; negotiatingValue += d.value; }
        else { contactedCount++; contactedValue += d.value; }
      }
    }

    double winRate = totalPipeline > 0 ? (closedRevenue / totalPipeline) * 100 : 0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textLight : const Color(0xFF1F2937);
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TOP STATS CARDS
          Row(
            children: [
              _buildInsightCard(
                title: 'TOTAL PIPELINE',
                icon: LucideIcons.dollar_sign,
                value: '₹${(totalPipeline / 100000).toStringAsFixed(2)}L',
                subtitle: 'All Deals Pipeline Value',
                bgColor: cardBg,
                textColor: textColor,
                iconColor: Colors.blueGrey[400]!,
                pillBg: Colors.transparent,
                borderColor: borderColor,
              ),
              const SizedBox(width: 24),
              _buildInsightCard(
                title: 'CLOSED REVENUE',
                icon: LucideIcons.percent,
                value: '₹${(closedRevenue / 100000).toStringAsFixed(2)}L',
                subtitle: 'Revenue successfully closed',
                bgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F7F0), 
                textColor: const Color(0xFF10B981), 
                iconColor: const Color(0xFF10B981),
                pillBg: isDark ? const Color(0xFF065F46) : const Color(0xFFD1F4E0),
                borderColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F7F0),
              ),
              const SizedBox(width: 24),
              _buildInsightCard(
                title: 'ACTIVE PROJECTS',
                icon: LucideIcons.activity,
                value: '$activeProjects',
                subtitle: 'Currently in pipeline',
                bgColor: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                textColor: const Color(0xFFF59E0B),
                iconColor: const Color(0xFFF59E0B),
                pillBg: isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
                borderColor: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // BOTTOM SECTION
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: SALES FUNNEL
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.filter_alt_outlined, size: 18, color: textColor),
                            const SizedBox(width: 8),
                            Text('Sales Funnel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFunnelRow('LEADS', leadCount, leadValue, 1.0, isDark),
                              _buildFunnelRow('CONTACTED', contactedCount, contactedValue, 0.8, isDark),
                              _buildFunnelRow('PROPOSALS', proposalCount, proposalValue, 0.6, isDark),
                              _buildFunnelRow('NEGOTIATING', negotiatingCount, negotiatingValue, 0.4, isDark),
                              _buildFunnelRow('CLOSED WON', wonCount, wonValue, 0.2, isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 24),

                // RIGHT: LEAD SOURCES & WIN RATE
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Lead Sources
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.pie_chart_outline, size: 18, color: textColor),
                                const SizedBox(width: 8),
                                Text('Lead Sources', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Website', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
                                    ),
                                    child: Text('2 Clients', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Win Rate
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37), // Solid Gold
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('WIN RATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
                              const SizedBox(height: 8),
                              Text('${winRate.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0)),
                              const SizedBox(height: 12),
                              const Text('Of total pipeline value successfully closed.', style: TextStyle(fontSize: 12, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required IconData icon,
    required String value,
    required String subtitle,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
    required Color pillBg,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 6),
                Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: iconColor)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor)),
            const SizedBox(height: 8),
            pillBg == Colors.transparent
                ? Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.blueGrey[400]))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(12)),
                    child: Text(subtitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnelRow(String title, int count, double value, double widthRatio, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$title ($count)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey[400])),
            Text('₹${(value / 100000).toStringAsFixed(2)}L', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey[300])),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 12,
              width: constraints.maxWidth * widthRatio,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
            );
          },
        ),
      ],
    );
  }
}
