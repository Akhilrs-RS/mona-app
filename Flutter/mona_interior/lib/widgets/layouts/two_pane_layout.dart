import 'package:flutter/material.dart';

class TwoPaneLayout extends StatelessWidget {
  final Widget leftPane;
  final Widget rightPane;
  final int leftFlex;
  final int rightFlex;
  final bool isRightPaneActive;
  final VoidCallback? onBackToLeftPane;

  const TwoPaneLayout({
    super.key,
    required this.leftPane,
    required this.rightPane,
    this.leftFlex = 4,
    this.rightFlex = 8,
    this.isRightPaneActive = false,
    this.onBackToLeftPane,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: leftFlex,
            child: leftPane,
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: rightFlex,
            child: rightPane,
          ),
        ],
      );
    } else {
      // Mobile Layout
      if (isRightPaneActive) {
        return Column(
          children: [
            if (onBackToLeftPane != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onBackToLeftPane,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to List'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            Expanded(child: rightPane),
          ],
        );
      } else {
        return leftPane;
      }
    }
  }
}
