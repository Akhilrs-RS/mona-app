import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/widgets/sidebar.dart';
import 'package:mona_interior/main.dart'; // for themeModeProvider

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  bool _isSidebarOpen = true;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    
    // Automatically collapse sidebar on smaller screens
    final showSidebarOpen = isDesktop ? _isSidebarOpen : false;

    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    void toggleTheme() {
      ref.read(themeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark;
    }

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            isOpen: showSidebarOpen,
            toggleSidebar: _toggleSidebar,
            toggleTheme: toggleTheme,
            isDarkMode: isDark,
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
