import os

filepath = "lib/screens/dashboard_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("icon: const Icon(LucideIcons.bell, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : const Color(0xFF4B5563)),", "icon: Icon(LucideIcons.bell, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : const Color(0xFF4B5563)),")

with open(filepath, 'w') as f:
    f.write(content)
