import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/site_models.dart';
import 'package:mona_interior/widgets/forms/site_form.dart';
import 'package:mona_interior/widgets/forms/history_form.dart';
import 'package:mona_interior/widgets/forms/media_form.dart';
import 'package:mona_interior/providers/finance_provider.dart';
import 'package:mona_interior/utils/pdf_generator.dart';

class SiteDetailsScreen extends ConsumerWidget {
  final Site site;

  const SiteDetailsScreen({super.key, required this.site});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeState = ref.watch(financeProvider);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(site.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SiteForm(site: site)));
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Gallery & Timeline'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context, financeState),
                  const SizedBox(height: 16),
                  _buildDetailsCard(context),
                  const SizedBox(height: 16),
                  _buildFinancialsCard(context, financeState),
                ],
              ),
            ),
            
            // Gallery & Timeline Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gallery', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: () {
                          showDialog(context: context, builder: (_) => MediaForm(site: site));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  site.media.isEmpty
                      ? const Text('No media available.')
                      : SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: site.media.length,
                            itemBuilder: (context, index) {
                              final m = site.media[index];
                              return Card(
                                child: Container(
                                  width: 150,
                                  alignment: Alignment.center,
                                  child: m is Map && m['url'] != null
                                    ? Image.network(m['url'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.grey))
                                    : const Icon(Icons.image, size: 50, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Timeline', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showDialog(context: context, builder: (_) => HistoryForm(site: site));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  site.workHistory.isEmpty
                      ? const Text('No history available.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: site.workHistory.length,
                          itemBuilder: (context, index) {
                            final h = site.workHistory[index];
                            return ListTile(
                              leading: const Icon(Icons.history),
                              title: Text(h['desc']?.toString() ?? 'Activity'),
                              subtitle: Text(h['date']?.toString() ?? ''),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, AsyncValue financeState) {
    // Helper to calculate totals for the PDF
    double billed = 0;
    double paid = 0;
    double spent = 0;

    financeState.maybeWhen(
      data: (financeData) {
        final siteId = site.id;
        for (var inv in financeData.invoices) {
          if (inv.status != 'Draft') {
            bool match = false;
            for (var item in inv.items) {
              if (item is Map && item['workOrderId'].toString() == siteId) {
                match = true;
                break;
              }
            }
            if (match) billed += inv.total;
          }
        }
        for (var rec in financeData.receipts) {
          if (rec.siteId == siteId || rec.clientName == site.clientName) {
            paid += rec.amountPaid;
          }
        }
        for (var exp in financeData.expenses) {
          if (exp.clientId == siteId) {
            spent += exp.amount;
          }
        }
      },
      orElse: () {},
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    site.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(site.status, style: const TextStyle(fontSize: 12)),
                  backgroundColor: _getStatusColor(site.status).withOpacity(0.2),
                  side: BorderSide(color: _getStatusColor(site.status)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(site.address, style: const TextStyle(color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    PdfGenerator.printFinalSettlement(site, billed, paid, spent);
                  },
                  icon: const Icon(Icons.print, size: 16),
                  label: const Text('Final Settlement'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    elevation: 0,
                  ),
                ),
                if (site.status == 'Completed')
                  ElevatedButton.icon(
                    onPressed: () {
                      PdfGenerator.printCompletionCertificate(site);
                    },
                    icon: const Icon(Icons.card_membership, size: 16),
                    label: const Text('Certificate'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.green,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      elevation: 0,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Project Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            _buildDetailRow('Client', site.clientName),
            _buildDetailRow('Organization', site.organizationName),
            _buildDetailRow('Team', site.assignedTeam),
            _buildDetailRow('Start Date', site.startDate),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialsCard(BuildContext context, AsyncValue financeState) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Financials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            financeState.maybeWhen(
              data: (financeData) {
                final siteId = site.id;
                
                double billed = 0;
                for (var inv in financeData.invoices) {
                  if (inv.status != 'Draft') {
                    bool match = false;
                    for (var item in inv.items) {
                      if (item is Map && item['workOrderId'].toString() == siteId) {
                        match = true;
                        break;
                      }
                    }
                    if (match) billed += inv.total;
                  }
                }
                
                double paid = 0;
                for (var rec in financeData.receipts) {
                  if (rec.siteId == siteId || rec.clientName == site.clientName) {
                    paid += rec.amountPaid;
                  }
                }
                
                double spent = 0;
                for (var exp in financeData.expenses) {
                  if (exp.clientId == siteId) {
                    spent += exp.amount;
                  }
                }
                
                double balance = (site.budget > 0 ? site.budget : billed) - paid;

                return Column(
                  children: [
                    _buildDetailRow('Budget', '₹\${site.budget.toStringAsFixed(2)}'),
                    _buildDetailRow('Invoiced', '₹\${billed.toStringAsFixed(2)}'),
                    _buildDetailRow('Receipts', '₹\${paid.toStringAsFixed(2)}'),
                    _buildDetailRow('Spent', '₹\${spent.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: balance > 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: balance > 0 ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            balance > 0 ? 'BALANCE DUE' : 'FULLY PAID',
                            style: TextStyle(
                              color: balance > 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '₹\${balance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: balance > 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              orElse: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value.isNotEmpty ? value : 'N/A', style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
      case 'Currently working':
        return Colors.orange;
      case 'Pre-Construction':
      case 'Yet to work':
        return Colors.blue;
      case 'Maintenance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
