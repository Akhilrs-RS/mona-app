import os

def fix_file(filepath):
    if not os.path.exists(filepath):
        return
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Fix _buildHeader Spacer -> Expanded
    if "        Column(\n          crossAxisAlignment: CrossAxisAlignment.start," in content and "const Spacer()," in content:
        # replace Column( with Expanded(child: Column(
        # but only the one in _buildHeader
        lines = content.split('\n')
        in_header = False
        for i in range(len(lines)):
            if "Widget _buildHeader" in lines[i]:
                in_header = True
            if in_header and "        Column(" in lines[i]:
                lines[i] = "        Expanded(child: Column("
            if in_header and "        const Spacer()," in lines[i]:
                lines[i] = "        // const Spacer(),"
                # find the closing bracket of the Column
                # Actually, the easiest is just add ) at the end of the line before Spacer
                lines[i-1] = lines[i-1] + "),"
                in_header = False
                break
        content = '\n'.join(lines)

    # 2. Fix filter row in TableContainer (Row -> Wrap)
    if "          // Filter Area\n          Padding(" in content:
        content = content.replace(
            "            child: Row(\n              children: [",
            "            child: Wrap(\n              spacing: 16,\n              runSpacing: 16,\n              crossAxisAlignment: WrapCrossAlignment.center,\n              children: ["
        )
        # remove Spacer() in Wrap
        content = content.replace("const Spacer(),", "")
        # replace SizedBox(width: 16) with empty or let it be (Wrap will add spacing anyway, but SizedBox adds extra, we can remove it)
        content = content.replace("                const SizedBox(width: 16),", "")
        content = content.replace("                const SizedBox(width: 12),", "")

    with open(filepath, 'w') as f:
        f.write(content)

screens = [
    "lib/screens/dashboard_screen.dart",
    "lib/screens/finance/accounts_screen.dart",
    "lib/screens/finance/expenses_screen.dart",
    "lib/screens/finance/invoices_screen.dart",
    "lib/screens/finance/receipts_screen.dart",
    "lib/screens/finance/billing_screen.dart",
    "lib/screens/hr/attendance_screen.dart",
    "lib/screens/hr/employees_screen.dart",
    "lib/screens/hr/reports_screen.dart",
    "lib/screens/hr/salary_screen.dart",
]

for s in screens:
    fix_file(s)

print("Fixed flex overflows")
