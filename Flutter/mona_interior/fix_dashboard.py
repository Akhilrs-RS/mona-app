import os

filepath = "lib/screens/dashboard_screen.dart"
if not os.path.exists(filepath):
    print("File not found")
else:
    with open(filepath, 'r') as f:
        content = f.read()

    # Pass isDark flag and fix colors
    content = content.replace("backgroundColor: const Color(0xFFF3F4F6),", "backgroundColor: Theme.of(context).scaffoldBackgroundColor,")
    
    # In _buildHeader controls icon button background
    content = content.replace("color: Colors.white,\n            shape: BoxShape.circle,", "color: Theme.of(context).cardColor,\n            shape: BoxShape.circle,")
    
    # We can also dynamically pass isDark into methods, or just use Theme.of(context).brightness
    # Let's fix specific hardcoded text colors in _buildHeader
    content = content.replace("color: Color(0xFF4B5563)", "color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : const Color(0xFF4B5563)")
    
    # In _buildHeader, Dropdown button color and text:
    # Actually DropdownButton is inside a Container which already has Theme.of(context).cardColor
    
    # Check _buildActionTile colors
    # No hardcoded background colors there except cardColor

    # We also need to fix text colors inside _buildLegend if needed, but it uses black by default. Let's make it adapt.
    content = content.replace("Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),", "Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),")

    with open(filepath, 'w') as f:
        f.write(content)
    print("Fixed dashboard_screen.dart")
