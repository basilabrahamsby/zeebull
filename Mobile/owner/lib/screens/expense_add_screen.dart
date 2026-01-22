import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/inventory_provider.dart';

class ExpenseAddScreen extends StatefulWidget {
  const ExpenseAddScreen({super.key});

  @override
  State<ExpenseAddScreen> createState() => _ExpenseAddScreenState();
}

class _ExpenseAddScreenState extends State<ExpenseAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final _payeeController = TextEditingController(); 
  final _otherCategoryController = TextEditingController();
  
  String _selectedCategory = 'Utilities';
  bool _showOtherCategory = false;
  int? _selectedVendorId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _categories = [
    'Utilities', 'Maintenance', 'Salaries', 'F&B Inventory', 'Housekeeping', 'Marketing', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<InventoryProvider>(context, listen: false).fetchVendors();
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _payeeController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final category = _showOtherCategory ? _otherCategoryController.text : _selectedCategory;
    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please specify category')));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'description': _descController.text,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'category': category,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'status': 'Approved',
      'vendor_id': _selectedVendorId,
    };

    final success = await Provider.of<ExpenseProvider>(context, listen: false).addExpense(data);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense Added')));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add expense')));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final vendors = inventoryProvider.vendors; 

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                   setState(() {
                     _selectedCategory = v!;
                     _showOtherCategory = (v == 'Other');
                   });
                },
              ),
              if (_showOtherCategory) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _otherCategoryController,
                  decoration: const InputDecoration(labelText: 'Specify Category', border: OutlineInputBorder()),
                  validator: (v) => _showOtherCategory && (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ],

              const SizedBox(height: 16),
              
              DropdownButtonFormField<int>(
                value: _selectedVendorId,
                decoration: const InputDecoration(labelText: 'Vendor (Optional)', border: OutlineInputBorder()),
                items: [
                   const DropdownMenuItem<int>(value: null, child: Text("None")),
                   ...vendors.map<DropdownMenuItem<int>>((v) {
                      final name = v['name'] ?? 'Unknown';
                      final id = v['id'];
                      return DropdownMenuItem<int>(value: id, child: Text(name));
                   }).toList(),
                ],
                onChanged: (v) => setState(() => _selectedVendorId = v),
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
