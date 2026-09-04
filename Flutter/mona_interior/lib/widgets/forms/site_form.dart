import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/site_models.dart';
import 'package:mona_interior/providers/site_provider.dart';
import 'package:mona_interior/theme/app_colors.dart';

class SiteForm extends ConsumerStatefulWidget {
  final Site? site;

  const SiteForm({super.key, this.site});

  @override
  ConsumerState<SiteForm> createState() => _SiteFormState();
}

class _SiteFormState extends ConsumerState<SiteForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _clientController;
  late TextEditingController _orgController;
  late TextEditingController _startDateController;
  late TextEditingController _budgetController;
  late TextEditingController _descController;
  late TextEditingController _addressController;
  
  String _status = 'Pre-Construction';
  bool _isNegotiated = false;
  String? _selectedQuotation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.site?.name ?? '');
    _clientController = TextEditingController(text: widget.site?.clientName ?? '');
    _orgController = TextEditingController(text: widget.site?.organizationName ?? '');
    _status = widget.site?.status ?? 'Pre-Construction';
    _startDateController = TextEditingController(text: widget.site?.startDate ?? DateTime.now().toIso8601String().split('T')[0]);
    _budgetController = TextEditingController(text: widget.site?.budget.toString() ?? '0');
    _descController = TextEditingController(text: widget.site?.description ?? '');
    _addressController = TextEditingController(text: widget.site?.address ?? '');
    _isNegotiated = widget.site?.isNegotiated ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _orgController.dispose();
    _startDateController.dispose();
    _budgetController.dispose();
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final site = Site(
      id: widget.site?.id ?? 0,
      name: _nameController.text.trim(),
      clientName: _clientController.text.trim(),
      organizationName: _orgController.text.trim(),
      assignedTeam: widget.site?.assignedTeam ?? '',
      address: _addressController.text.trim(),
      status: _status,
      startDate: _startDateController.text.trim(),
      budget: double.tryParse(_budgetController.text) ?? 0.0,
      description: _descController.text.trim(),
      isNegotiated: _isNegotiated,
      negotiationDetails: widget.site?.negotiationDetails ?? '',
      isArchived: widget.site?.isArchived ?? false,
      workHistory: widget.site?.workHistory ?? [],
      maintenance: widget.site?.maintenance ?? {},
      media: widget.site?.media ?? [],
    );

    try {
      if (widget.site == null) {
        await ref.read(sitesProvider.notifier).addSite(site);
      } else {
        await ref.read(sitesProvider.notifier).updateSite(site);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Site saved successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 550,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                color: AppColors.primaryGold,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.site == null ? 'Create Work Order' : 'Edit Work Order',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Body
              Padding(
                padding: const EdgeInsets.all(32),
                child: _isLoading 
                    ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
                    : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LOAD FROM QUOTATION
                            _buildLabel('LOAD FROM QUOTATION'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedQuotation,
                              decoration: _inputDecoration(hint: 'Select a quotation to autofill...'),
                              items: const [],
                              onChanged: (val) {},
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blueGrey),
                            ),
                            const SizedBox(height: 16),
                            
                            // PROJECT NAME
                            _buildFormField('PROJECT NAME', _nameController, hintText: 'e.g. Modern Villa Interior', required: true),
                            const SizedBox(height: 16),
                            
                            // CLIENT & ORG
                            Row(
                              children: [
                                Expanded(child: _buildFormField('CLIENT NAME', _clientController, hintText: 'e.g. John Doe')),
                                const SizedBox(width: 16),
                                Expanded(child: _buildFormField('ORG NAME (OPT)', _orgController, hintText: 'e.g. Acme Corp')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // STATUS & DATE
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('INITIAL STATUS'),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: _status,
                                        decoration: _inputDecoration(),
                                        items: ['Pre-Construction', 'Currently working', 'Completed', 'Maintenance']
                                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))))
                                            .toList(),
                                        onChanged: (val) => setState(() => _status = val ?? 'Pre-Construction'),
                                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField('START DATE', _startDateController, suffixIcon: Icons.calendar_today),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // BUDGET & NEGOTIATED
                            Row(
                              children: [
                                Expanded(child: _buildFormField('₹ EST. BUDGET (₹)', _budgetController, hintText: '0', isNumber: true)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 22),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: _isNegotiated,
                                            onChanged: (val) => setState(() => _isNegotiated = val ?? false),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            side: BorderSide(color: Colors.blueGrey[300]!),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildLabel('NEGOTIATED'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // DESCRIPTION
                            _buildFormField('DESCRIPTION', _descController, hintText: 'Short scope...'),
                            const SizedBox(height: 16),
                            
                            // SITE ADDRESS
                            _buildFormField('SITE ADDRESS', _addressController, hintText: 'e.g. Kochi, Kerala'),
                            
                            const SizedBox(height: 32),
                            
                            // Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel', style: TextStyle(color: Colors.blueGrey[400], fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGold,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  ),
                                  child: const Text('SAVE WORK ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[600]),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.blueGrey[300]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.primaryGold),
      ),
      isDense: true,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 16, color: Colors.blueGrey[400]) : null,
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, {bool required = false, String? hintText, IconData? suffixIcon, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: required ? (val) => val == null || val.isEmpty ? 'Required' : null : null,
          decoration: _inputDecoration(hint: hintText, suffixIcon: suffixIcon),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
      ],
    );
  }
}
