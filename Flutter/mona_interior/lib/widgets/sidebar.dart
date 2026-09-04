import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:mona_interior/theme/app_colors.dart';

class Sidebar extends StatefulWidget {
  final bool isOpen;
  final VoidCallback toggleSidebar;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const Sidebar({
    super.key,
    required this.isOpen,
    required this.toggleSidebar,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final List<dynamic> menuItems = [
    {'path': '/', 'name': 'Dashboard', 'icon': LucideIcons.layoutDashboard},
    {'path': '/crm', 'name': 'CRM', 'icon': LucideIcons.users},
    {'path': '/quotations', 'name': 'Quotations', 'icon': LucideIcons.clipboardList},
    
    {'type': 'header', 'name': 'PROJECTS'},
    {'path': '/sites', 'name': 'Work Orders', 'icon': LucideIcons.mapPin},
    
    {'type': 'header', 'name': 'FINANCE'},
    {'path': '/billing', 'name': 'Billing', 'icon': LucideIcons.fileText},
    {'path': '/invoices', 'name': 'History', 'icon': LucideIcons.copy}, // using copy for stack
    {'path': '/receipts', 'name': 'Payment Receipts', 'icon': LucideIcons.receipt},
    {'path': '/expenses', 'name': 'Expenses & credits', 'icon': LucideIcons.receipt},
    {'path': '/accounts', 'name': 'Accounts', 'icon': LucideIcons.landmark},
    
    {'type': 'header', 'name': 'HUMAN RESOURCES'},
    {'path': '/employees', 'name': 'Employees', 'icon': LucideIcons.briefcase},
    {'path': '/attendance', 'name': 'Attendance', 'icon': LucideIcons.mapPin},
    {'path': '/salary', 'name': 'Payroll', 'icon': LucideIcons.wallet},
    {'path': '/reports', 'name': 'Reports', 'icon': LucideIcons.barChart2},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    
    final bgSidebar = isDark ? const Color(0xFF0F172A).withValues(alpha: 0.8) : const Color(0xFF111827);
    final textSidebar = isDark ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9);
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF1E293B);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isOpen ? 256 : 80,
      decoration: BoxDecoration(
        color: bgSidebar,
        border: Border(right: BorderSide(color: borderCol)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          )
        ]
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: widget.toggleSidebar,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderCol)),
              ),
              child: Row(
                mainAxisAlignment: widget.isOpen ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  if (widget.isOpen)
                    const Icon(LucideIcons.chevronLeft, color: AppColors.primaryGold, size: 22)
                  else
                    const Icon(LucideIcons.home, color: AppColors.primaryGold, size: 22),
                  if (widget.isOpen) ...[
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mona Interior',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF93C5FD) : Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'STUDIO',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Navigation
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                if (item['type'] == 'header') {
                  if (widget.isOpen) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12, top: 20, bottom: 8),
                      child: Text(
                        item['name'],
                        style: TextStyle(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Divider(color: borderCol, height: 1),
                    );
                  }
                }

                final isActive = GoRouterState.of(context).uri.toString() == item['path'];
                
                Color itemColor;
                Color itemBg;
                
                if (isActive) {
                  itemBg = isDark ? AppColors.primaryGold.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.1);
                  itemColor = isDark ? Colors.white : AppColors.primaryGold;
                } else {
                  itemBg = Colors.transparent;
                  itemColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      context.go(item['path']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: itemBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: widget.isOpen ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'], color: itemColor, size: 20),
                          if (widget.isOpen) ...[
                            const SizedBox(width: 12),
                            Text(
                              item['name'],
                              style: TextStyle(
                                color: itemColor,
                                fontSize: 15,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderCol)),
            ),
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.toggleTheme,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: widget.isOpen ? MainAxisAlignment.center : MainAxisAlignment.center,
                      children: [
                        Icon(isDark ? LucideIcons.sun : LucideIcons.moon, color: textSidebar, size: 20),
                        if (widget.isOpen) ...[
                          const SizedBox(width: 12),
                          Text(
                            isDark ? 'Light Mode' : 'Dark Mode',
                            style: TextStyle(color: textSidebar, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                if (widget.isOpen) ...[
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 Mona Interior',
                    style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
