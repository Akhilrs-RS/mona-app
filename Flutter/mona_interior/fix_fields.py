import os

filepath = "lib/screens/quotations_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Fix container background in _buildTextField
content = content.replace("color: isYellow ? Colors.yellow[100]?.withValues(alpha: 0.5) : Colors.white,", "color: isYellow ? (isDark ? Colors.orange.withValues(alpha: 0.2) : Colors.yellow[100]?.withValues(alpha: 0.5)) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),")

# Fix container border in _buildTextField
content = content.replace("border: Border.all(color: isYellow ? Colors.orange[300]! : Colors.grey[300]!),", "border: Border.all(color: isYellow ? Colors.orange[300]! : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!)),")

# Fix TextField style in _buildTextField
content = content.replace("style: TextStyle(fontSize: 13, fontWeight: isYellow ? FontWeight.bold : FontWeight.normal, color: isYellow ? Colors.brown[800] : Colors.black87),", "style: TextStyle(fontSize: 13, fontWeight: isYellow ? FontWeight.bold : FontWeight.normal, color: isYellow ? (isDark ? Colors.orange[200] : Colors.brown[800]) : (isDark ? Colors.white : Colors.black87)),")

# Fix TextField style in _buildLineItemsTable
content = content.replace("style: const TextStyle(fontSize: 12),", "style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87),")

with open(filepath, 'w') as f:
    f.write(content)
