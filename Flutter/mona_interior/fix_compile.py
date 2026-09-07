import os
import re

def fix_crm(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Pass isDark down
    content = content.replace("Widget _buildClientsContent(List<Contact> contacts) {", "Widget _buildClientsContent(List<Contact> contacts) {\n    final isDark = Theme.of(context).brightness == Brightness.dark;")
    
    # We also used it in _buildFunnelRow in crm
    # Is isDark passed there? 
    # Yes: _buildFunnelRow('LEADS', leadCount, leadValue, 1.0, isDark)
    
    with open(filepath, 'w') as f:
        f.write(content)

def fix_quotations(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Fix const Text
    content = content.replace("const Text('TOTAL QTY: '", "Text('TOTAL QTY: '")
    content = content.replace("const Text('0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black))", "Text('0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black))")

    # Fix other const Texts
    content = content.replace("const Text('NEW QUOTE'", "Text('NEW QUOTE'")
    content = content.replace("const Text('BILL TYPE'", "Text('BILL TYPE'")
    content = content.replace("const Text('SUB TOTAL'", "Text('SUB TOTAL'")
    
    # Text(label, style: const TextStyle(...)) -> Text(label, style: TextStyle(...))
    content = re.sub(r'const\s+TextStyle\([^)]*color:\s*isDark[^)]*\)', lambda m: m.group(0).replace('const ', ''), content)
    
    with open(filepath, 'w') as f:
        f.write(content)

fix_crm("lib/screens/crm_screen.dart")
fix_quotations("lib/screens/quotations_screen.dart")
