import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:mona_interior/providers/crm_provider.dart';

class QuotationsScreen extends ConsumerStatefulWidget {
  const QuotationsScreen({super.key});

  @override
  ConsumerState<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends ConsumerState<QuotationsScreen> {
  bool _isGst = true;
  final List<Map<String, dynamic>> _items = [
    {
      'section': 'General',
      'product': 'Product',
      'spec': 'Specification',
      'qty': '0',
      'unit': 'Sq.Ft',
      'price': '0.00',
      'disc': '0.00',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildFormGrid(isDark),
                const SizedBox(height: 24),
                _buildLineItemsTable(isDark),
                const SizedBox(height: 16),
                _buildTableControls(isDark),
                const SizedBox(height: 48),
                _buildCalculationFooter(isDark),
              ],
            ),
          ),
          _buildBottomActionBar(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(isDark) {
    return Container(
      height: 48,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
                  border: Border(
                top: BorderSide(color: AppColors.primaryGold, width: 3),
                right: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.file_text, size: 16, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                Text('NEW QUOTE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
                const SizedBox(width: 16),
                Icon(LucideIcons.x, size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus, size: 18, color: AppColors.primaryGold),
            onPressed: () {},
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(LucideIcons.bell, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFormGrid(isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1
        Row(
          children: [
            Expanded(flex: 2, child: _buildTextField(isDark, 'QUOTATION NUMBER', 'QT-040926-0001', isYellow: true)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildTextField(isDark, 'DATE', '04/09/2026', isYellow: true, trailingIcon: LucideIcons.calendar)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildBillTypeToggle(isDark)),
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildTextField(isDark, 'CLIENT NAME', 'Enter client name...')),
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildTextField(isDark, 'EMAIL ID', 'client@example.com')),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2
        Row(
          children: [
            Expanded(flex: 3, child: _buildTextField(isDark, 'MOBILE NO', '+91..')),
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildTextField(isDark, 'CUSTOMER GST', 'GSTIN..')),
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildTextField(isDark, 'DELIVERY TIMELINE', '3 to 4 Weeks')),
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildTextField(isDark, 'ORGANIZATION NAME (OPTIONAL)', 'e.g. Acme Corporation')),
          ],
        ),
        const SizedBox(height: 16),
        // Row 3
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(flex: 4, child: _buildTextField(isDark, 'SITE ADDRESS', 'Work site / project address...')),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: _buildTextField(isDark, 'PROJECT TITLE', 'e.g. 3BHK Apartment Interior')),
            const Spacer(flex: 1),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('SUB TOTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                const Text('₹0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(isDark, String label, String hint, {bool isYellow = false, IconData? trailingIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: isYellow ? (isDark ? Colors.orange.withValues(alpha: 0.2) : Colors.yellow[100]?.withValues(alpha: 0.5)) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
            border: Border.all(color: isYellow ? Colors.orange[300]! : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!)),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 13, fontWeight: isYellow ? FontWeight.bold : FontWeight.normal, color: isYellow ? (isDark ? Colors.orange[200] : Colors.brown[800]) : (isDark ? Colors.white : Colors.black87)),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 16, color: isDark ? Colors.white : Colors.black87),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillTypeToggle(isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BILL TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isGst = true),
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: _isGst ? Colors.orange : Colors.white,
                    border: Border.all(color: _isGst ? Colors.orange : Colors.grey[300]!),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                  ),
                  alignment: Alignment.center,
                  child: Text('GST', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _isGst ? Colors.white : Colors.grey[600])),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isGst = false),
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: !_isGst ? Colors.orange : Colors.white,
                    border: Border.all(color: !_isGst ? Colors.orange : Colors.grey[300]!),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                  ),
                  alignment: Alignment.center,
                  child: Text('NON-GST', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: !_isGst ? Colors.white : Colors.blueGrey)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLineItemsTable(isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header
          Container(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                _buildColHeader('REM', flex: 1),
                _buildColHeader('S#', flex: 1),
                _buildColHeader('SECTION', flex: 2),
                _buildColHeader('PRODUCT', flex: 2),
                _buildColHeader('SPECIFICATION', flex: 4),
                _buildColHeader('QTY', flex: 1, alignRight: true),
                _buildColHeader('UNIT', flex: 1),
                _buildColHeader('UNIT PRICE', flex: 2, alignRight: true),
                _buildColHeader('DISC. PRICE', flex: 2, alignRight: true),
                _buildColHeader('AMOUNT (₹)', flex: 2, alignRight: true),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // Row
          ..._items.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            return Container(
              color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF4F6FB),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 1, child: IconButton(icon: const Icon(LucideIcons.trash_2, size: 16, color: Colors.redAccent), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints())),
                  Expanded(flex: 1, child: Text('${idx + 1}', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  Expanded(flex: 2, child: Text(item['section'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text(item['product'], style: const TextStyle(fontSize: 12))),
                  Expanded(
                    flex: 4, 
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: item['spec'],
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: Text(item['qty'], textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  Expanded(flex: 1, child: Padding(padding: const EdgeInsets.only(left: 12), child: Text(item['unit'], style: const TextStyle(fontSize: 12, color: Colors.grey)))),
                  Expanded(flex: 2, child: Text(item['price'], textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  Expanded(flex: 2, child: Text(item['disc'], textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  Expanded(flex: 2, child: Text(item['price'], textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown[800]))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildColHeader(String text, {required int flex, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildTableControls(isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            border: Border.all(color: Colors.orange[200]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.plus, size: 14, color: Colors.orange[800]),
              const SizedBox(width: 8),
              Text('Add Row', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange[800])),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.settings, size: 14, color: Colors.blueGrey),
              const SizedBox(width: 8),
              const Text('Manage Sections', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationFooter(isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.yellow[100]?.withValues(alpha: 0.5),
                border: Border.all(color: Colors.orange[200]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text('TOTAL QTY: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
                  Text('0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
                ],
              ),
            ),
            const SizedBox(width: 24),
            _buildSmallInput(isDark, 'INSTAL. MAT. (₹)', '0'),
            const SizedBox(width: 16),
            _buildSmallInput(isDark, 'DELIVERY (₹)', '0'),
            const SizedBox(width: 16),
            _buildSmallInput(isDark, 'DISCOUNT (₹)', '0'),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('₹', style: TextStyle(fontSize: 24, color: Colors.orange, fontWeight: FontWeight.w400)),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(color: isDark ? Colors.white : Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('ESTIMATED TOTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const Text('0.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange, height: 1.1)),
                  const Text('+ 18% GST APPLICABLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallInput(isDark, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 28,
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerRight,
          child: Text(value, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
                  border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(isDark, 'Clear', LucideIcons.rotate_cw, Colors.orange),
          const SizedBox(width: 12),
          _buildActionButton(isDark, 'Quotations', LucideIcons.file_text, Colors.blueGrey[600]!),
          const SizedBox(width: 12),
          _buildActionButton(isDark, 'Generate & Print', LucideIcons.printer, Colors.teal),
          const SizedBox(width: 12),
          _buildActionButton(isDark, 'Generate', LucideIcons.file_text, Colors.orange),
          const SizedBox(width: 12),
          _buildActionButton(isDark, 'Convert to Invoice', LucideIcons.arrow_right, Colors.green),
          const SizedBox(width: 12),
          _buildActionButton(isDark, 'Convert to Work Order', LucideIcons.arrow_right, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildActionButton(isDark, String text, IconData icon, Color color) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
