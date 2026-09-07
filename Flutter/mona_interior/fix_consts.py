import os
import re

files_to_fix = [
    "lib/screens/dashboard_screen.dart",
    "lib/screens/finance/accounts_screen.dart",
    "lib/screens/finance/expenses_screen.dart",
    "lib/screens/finance/invoices_screen.dart",
    "lib/screens/finance/receipts_screen.dart",
    "lib/screens/hr/attendance_screen.dart",
    "lib/screens/hr/employees_screen.dart",
    "lib/screens/hr/reports_screen.dart",
    "lib/screens/hr/salary_screen.dart",
]

for file_path in files_to_fix:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r') as f:
        content = f.read()

    lines = content.split('\n')
    for i in range(len(lines)):
        if "const TextStyle(" in lines[i] or "const  TextStyle(" in lines[i]:
            if "Theme.of(context)" in lines[i] or \
               (i+1 < len(lines) and "Theme.of(context)" in lines[i+1]) or \
               (i+2 < len(lines) and "Theme.of(context)" in lines[i+2]):
                lines[i] = lines[i].replace("const TextStyle(", "TextStyle(")
    
    with open(file_path, 'w') as f:
        f.write('\n'.join(lines))

print("Fixed TextStyle consts")
