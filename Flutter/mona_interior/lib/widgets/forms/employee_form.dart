import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/hr_models.dart';
import 'package:mona_interior/providers/hr_provider.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class EmployeeForm extends ConsumerStatefulWidget {
  final Employee? employee;

  const EmployeeForm({super.key, this.employee});

  @override
  ConsumerState<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends ConsumerState<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _salaryController;
  late TextEditingController _govIdController;
  late TextEditingController _bankDetailsController;
  
  String _role = 'Select Job Role';
  String _status = 'Active';
  String _salaryType = 'Monthly';
  
  final List<String> _roles = ['Select Job Role', 'Interior Designer', 'Project Manager', 'Site Supervisor', 'Carpenter', 'Painter', 'Electrician', 'Plumber', 'Helper'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?.name ?? '');
    _phoneController = TextEditingController(text: widget.employee?.phone ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _addressController = TextEditingController(text: widget.employee?.address ?? '');
    _salaryController = TextEditingController(text: widget.employee?.salary.toString() ?? '');
    _govIdController = TextEditingController(text: widget.employee?.govId ?? '');
    _bankDetailsController = TextEditingController(text: widget.employee?.bankDetails ?? '');
    
    if (widget.employee != null && widget.employee!.role.isNotEmpty) {
      if (_roles.contains(widget.employee!.role)) {
        _role = widget.employee!.role;
      } else {
        _roles.add(widget.employee!.role);
        _role = widget.employee!.role;
      }
    }
    
    if (widget.employee != null) {
      _status = widget.employee!.status;
      _salaryType = widget.employee!.salaryType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    _govIdController.dispose();
    _bankDetailsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_role == 'Select Job Role') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a valid job role.')));
      return;
    }

    setState(() => _isLoading = true);

    final emp = Employee(
      id: widget.employee?.id ?? 0,
      name: _nameController.text.trim(),
      role: _role,
      department: widget.employee?.department ?? 'General',
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      salary: double.tryParse(_salaryController.text.trim()) ?? 0.0,
      joinDate: widget.employee?.joinDate ?? DateTime.now().toIso8601String().split('T')[0],
      status: _status,
      address: _addressController.text.trim(),
      advanceBalance: widget.employee?.advanceBalance ?? 0.0,
      bankDetails: _bankDetailsController.text.trim(),
      govId: _govIdController.text.trim(),
      salaryType: _salaryType,
      workerId: widget.employee?.workerId ?? 'W-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );

    try {
      if (widget.employee == null) {
        await ref.read(hrProvider.notifier).addEmployee(emp);
      } else {
        await ref.read(hrProvider.notifier).updateEmployee(emp);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee profile saved successfully!')));
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 760,
        padding: const EdgeInsets.all(32),
        child: _isLoading
            ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.employee == null ? 'Register New Staff' : 'Edit Staff Profile', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, size: 20, color: Colors.blueGrey[400]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Main Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Personal Information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PERSONAL INFORMATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                              const SizedBox(height: 16),
                              _buildTextField(_nameController, 'Full Name', required: true),
                              const SizedBox(height: 16),
                              _buildTextField(_phoneController, 'Phone Number', keyboardType: TextInputType.phone, required: true),
                              const SizedBox(height: 16),
                              _buildTextField(_emailController, 'Email Address (Optional)', keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 16),
                              _buildTextField(_addressController, 'Home Address'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Right Column: Job & Payroll
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('JOB & PAYROLL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _role,
                                items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(fontSize: 13, fontWeight: r == 'Select Job Role' ? FontWeight.normal : FontWeight.bold, color: const Color(0xFF1F2937))))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _role = val);
                                },
                                decoration: _inputDecoration(),
                                icon: const Icon(LucideIcons.chevron_down, size: 16),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _status,
                                      items: ['Active', 'Inactive', 'On Leave'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _status = val);
                                      },
                                      decoration: _inputDecoration(),
                                      icon: const Icon(LucideIcons.chevron_down, size: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _salaryType,
                                      items: ['Monthly', 'Daily', 'Hourly', 'Weekly'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _salaryType = val);
                                      },
                                      decoration: _inputDecoration(),
                                      icon: const Icon(LucideIcons.chevron_down, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _salaryController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _inputDecoration(hintText: 'Base Salary Amount', prefixText: '₹ '),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Bottom Section: Verification & Banking
                    Text('VERIFICATION & BANKING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_govIdController, 'Govt ID (e.g. Aadhar / PAN)'),
                        ),
                        const SizedBox(width: 32), // Aligning with the center gap of the grid above
                        Expanded(
                          child: _buildTextField(_bankDetailsController, 'Bank Details (Bank Name, Acc No, IFSC)'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(widget.employee == null ? 'Create Profile' : 'Save Changes', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool required = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: required ? (val) => val == null || val.isEmpty ? 'Required' : null : null,
      decoration: _inputDecoration(hintText: hint),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? prefixText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 13, color: Colors.blueGrey[400], fontWeight: FontWeight.bold),
      prefixText: prefixText,
      prefixStyle: const TextStyle(fontSize: 13, color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    );
  }
}
