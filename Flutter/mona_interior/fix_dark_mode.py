import os

def fix_quotations(filepath):
    if not os.path.exists(filepath):
        return
    with open(filepath, 'r') as f:
        content = f.read()

    # Get isDark context
    content = content.replace("  Widget build(BuildContext context) {", "  Widget build(BuildContext context) {\n    final isDark = Theme.of(context).brightness == Brightness.dark;")
    
    # Replace Colors.white for Scaffold background
    content = content.replace("backgroundColor: Colors.white,", "backgroundColor: Theme.of(context).scaffoldBackgroundColor,")
    
    # Pass isDark to _buildHeader, _buildFormGrid, etc.
    content = content.replace("_buildHeader()", "_buildHeader(isDark)")
    content = content.replace("_buildFormGrid()", "_buildFormGrid(isDark)")
    content = content.replace("_buildLineItemsTable()", "_buildLineItemsTable(isDark)")
    content = content.replace("_buildTableControls()", "_buildTableControls(isDark)")
    content = content.replace("_buildCalculationFooter()", "_buildCalculationFooter(isDark)")
    content = content.replace("_buildBottomActionBar()", "_buildBottomActionBar(isDark)")

    # Update method signatures
    content = content.replace("Widget _buildHeader() {", "Widget _buildHeader(bool isDark) {")
    content = content.replace("Widget _buildFormGrid() {", "Widget _buildFormGrid(bool isDark) {")
    content = content.replace("Widget _buildLineItemsTable() {", "Widget _buildLineItemsTable(bool isDark) {")
    content = content.replace("Widget _buildTableControls() {", "Widget _buildTableControls(bool isDark) {")
    content = content.replace("Widget _buildCalculationFooter() {", "Widget _buildCalculationFooter(bool isDark) {")
    content = content.replace("Widget _buildBottomActionBar() {", "Widget _buildBottomActionBar(bool isDark) {")
    
    # Update _buildTextField and _buildBillTypeToggle calls inside _buildFormGrid
    content = content.replace("_buildTextField(", "_buildTextField(isDark, ")
    content = content.replace("_buildBillTypeToggle()", "_buildBillTypeToggle(isDark)")
    
    content = content.replace("Widget _buildTextField(String label, String hint, {bool isYellow = false, IconData? trailingIcon}) {", "Widget _buildTextField(bool isDark, String label, String hint, {bool isYellow = false, IconData? trailingIcon}) {")
    content = content.replace("Widget _buildBillTypeToggle() {", "Widget _buildBillTypeToggle(bool isDark) {")
    
    content = content.replace("_buildSmallInput(", "_buildSmallInput(isDark, ")
    content = content.replace("Widget _buildSmallInput(String label, String value) {", "Widget _buildSmallInput(bool isDark, String label, String value) {")
    
    content = content.replace("_buildActionButton(", "_buildActionButton(isDark, ")
    content = content.replace("Widget _buildActionButton(String text, IconData icon, Color color) {", "Widget _buildActionButton(bool isDark, String text, IconData icon, Color color) {")
    
    # Fix Colors.white inside components
    content = content.replace("color: const Color(0xFFF8F9FA)", "color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA)")
    content = content.replace("color: const Color(0xFFF4F6FB)", "color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF4F6FB)")
    content = content.replace("color: Colors.white,", "color: Theme.of(context).cardColor,")
    # Fix borders
    content = content.replace("color: Colors.grey[200]!", "color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!")
    content = content.replace("color: Colors.grey[300]!", "color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!")
    # Fix text colors
    content = content.replace("color: Colors.black87", "color: isDark ? Colors.white : Colors.black87")
    content = content.replace("color: Colors.black", "color: isDark ? Colors.white : Colors.black")

    with open(filepath, 'w') as f:
        f.write(content)

def fix_crm(filepath):
    if not os.path.exists(filepath):
        return
    with open(filepath, 'r') as f:
        content = f.read()

    # Get isDark
    content = content.replace("  Widget build(BuildContext context) {", "  Widget build(BuildContext context) {\n    final isDark = Theme.of(context).brightness == Brightness.dark;")
    
    # Fix cardTheme.color -> cardColor
    content = content.replace("Theme.of(context).cardTheme.color", "Theme.of(context).cardColor")
    
    # Fix BorderSide for Card
    content = content.replace("side: const BorderSide(color: AppColors.borderLight),", "side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),")
    
    # Fix TextTheme for _buildClientsContent
    content = content.replace("Text('Client Directory', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))", "Text('Client Directory', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: isDark ? AppColors.textLight : AppColors.textDark))")
    
    content = content.replace("color: const Color(0xFF111827)", "color: isDark ? AppColors.textLight : const Color(0xFF111827)")
    
    # Pass isDark down if needed, but we can just use `Theme.of(context).brightness`
    # Let's fix specific hardcoded borders in search bar
    content = content.replace("borderSide: const BorderSide(color: AppColors.borderLight)", "borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight)")
    
    with open(filepath, 'w') as f:
        f.write(content)

fix_quotations("lib/screens/quotations_screen.dart")
fix_crm("lib/screens/crm_screen.dart")

print("Fixed quotations and crm screens")
