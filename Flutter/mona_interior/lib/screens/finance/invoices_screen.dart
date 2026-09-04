import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildKPICards(),
          const SizedBox(height: 24),
          _buildTableContainer(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.history, color: AppColors.primaryGold, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(height: 2),
            Text('All invoices and quotations in one place.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
          ],
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.file_text, size: 14, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Invoices', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(LucideIcons.file_text, size: 14, color: Colors.blueGrey[300]),
                    const SizedBox(width: 8),
                    Text('Quotations', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Icon(LucideIcons.bell, size: 18, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildKPICards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.indian_rupee, size: 14, color: Colors.blueGrey[400]),
                    const SizedBox(width: 6),
                    Text('TOTAL INVOICED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('₹0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                const SizedBox(height: 4),
                Text('0 invoices total', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey[300])),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AMOUNT COLLECTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                    const SizedBox(height: 12),
                    const Text('₹0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.green)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.trending_up, color: Colors.green, size: 28),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 320,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(LucideIcons.search, size: 14, color: Colors.blueGrey[300]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by client or invoice no...',
                            hintStyle: TextStyle(fontSize: 12, color: Colors.blueGrey[300]),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.only(bottom: 2), // Align text vertically
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Table Headers
          Container(
            color: const Color(0xFFF9FAFB),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _buildColHeader('INVOICE NO.', flex: 2),
                _buildColHeader('DATE', flex: 2),
                _buildColHeader('CLIENT', flex: 3),
                _buildColHeader('GRAND TOTAL', flex: 2, alignCenter: true),
                _buildColHeader('COLLECTED', flex: 2, alignCenter: true),
                _buildColHeader('ACTIONS', flex: 2, alignRight: true),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          
          // Empty State Body
          Container(
            height: 350, 
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_alt_outlined, size: 48, color: Colors.blueGrey[100]),
                const SizedBox(height: 16),
                Text('NO INVOICES YET. GENERATE FROM THE BILLING PAGE.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[300])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColHeader(String text, {required int flex, bool alignRight = false, bool alignCenter = false}) {
    TextAlign align = TextAlign.left;
    if (alignRight) align = TextAlign.right;
    if (alignCenter) align = TextAlign.center;

    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400]),
      ),
    );
  }
}
