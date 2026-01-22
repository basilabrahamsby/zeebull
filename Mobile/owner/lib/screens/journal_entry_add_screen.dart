import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';

class JournalEntryAddScreen extends StatefulWidget {
  const JournalEntryAddScreen({super.key});

  @override
  State<JournalEntryAddScreen> createState() => _JournalEntryAddScreenState();
}

class _JournalEntryAddScreenState extends State<JournalEntryAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  DateTime _entryDate = DateTime.now();
  List<JournalLineItem> _lines = [];
  List<dynamic> _ledgers = [];
  bool _isLoading = false;
  bool _isLedgersLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLedgers();
    // Add two initial empty lines
    _lines.add(JournalLineItem());
    _lines.add(JournalLineItem());
  }

  Future<void> _fetchLedgers() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final ledgers = await provider.fetchAccountLedgers();
    if (mounted) {
      setState(() {
        _ledgers = ledgers;
        _isLedgersLoading = false;
      });
    }
  }

  void _addLine() {
    setState(() {
      _lines.add(JournalLineItem());
    });
  }

  void _removeLine(int index) {
    if (_lines.length > 2) {
      setState(() {
        _lines.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 2 lines are required')),
      );
    }
  }

  double get _totalDebits => _lines
      .where((l) => l.isDebit && l.amount != null)
      .fold(0.0, (sum, l) => sum + l.amount!);

  double get _totalCredits => _lines
      .where((l) => !l.isDebit && l.amount != null)
      .fold(0.0, (sum, l) => sum + l.amount!);

  bool get _isBalanced => (_totalDebits - _totalCredits).abs() < 0.01;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isBalanced) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entries must balance. Difference: ₹${(_totalDebits - _totalCredits).abs().toStringAsFixed(2)}')),
      );
      return;
    }
    if (_totalDebits == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total amount cannot be zero')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> apiLines = _lines.map((l) {
        return {
          'debit_ledger_id': l.isDebit ? l.ledgerId : null,
          'credit_ledger_id': !l.isDebit ? l.ledgerId : null,
          'amount': l.amount,
          'description': l.descriptionController.text.isEmpty ? null : l.descriptionController.text,
        };
      }).toList();

      final data = {
        'entry_date': _entryDate.toIso8601String(),
        'description': _descriptionController.text,
        'lines': apiLines,
        'reference_type': 'MANUAL', // Standard manual entry
      };

      final success = await Provider.of<DashboardProvider>(context, listen: false).createJournalEntry(data);

      if (mounted) {
        if (success) {
          Navigator.pop(context, true); // Return true to refresh list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create entry. Check logs.')),
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Journal Entry')),
      body: _isLedgersLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Header Details
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _entryDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setState(() => _entryDate = picked);
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat('dd MMM yyyy').format(_entryDate)),
                                        const Icon(Icons.calendar_today),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Journal Lines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        
                        // Lines List
                        ..._lines.asMap().entries.map((entry) {
                          final index = entry.key;
                          final line = entry.value;
                                  return Card(
                            key: ObjectKey(line),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<int>(
                                          value: line.ledgerId,
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Ledger',
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          ),
                                          items: _ledgers.map((l) => DropdownMenuItem(
                                            value: l['id'] as int,
                                            child: Text(l['name'] + (l['code'] != null ? ' (${l['code']})' : ''), overflow: TextOverflow.ellipsis),
                                          )).toList(),
                                          onChanged: (val) => setState(() => line.ledgerId = val),
                                          validator: (val) => val == null ? 'Select Ledger' : null,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Debit/Credit Toggle
                                      ToggleButtons(
                                        borderRadius: BorderRadius.circular(8),
                                        constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
                                        isSelected: [line.isDebit, !line.isDebit],
                                        onPressed: (idx) {
                                          setState(() {
                                            line.isDebit = idx == 0;
                                          });
                                        },
                                        children: const [
                                          Text('Dr', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('Cr', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: line.amountController,
                                          decoration: const InputDecoration(labelText: 'Amount'),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (val) {
                                             setState(() => line.amount = double.tryParse(val));
                                          },
                                          validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0 ? 'Invalid' : null,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.grey),
                                        onPressed: () => _removeLine(index),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    controller: line.descriptionController,
                                    decoration: const InputDecoration(labelText: 'Line Note (Optional)'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),

                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Line'),
                          onPressed: _addLine,
                        ),
                      ],
                    ),
                  ),

                  // Footer Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Debit: ₹${_totalDebits.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Text('Total Credit: ₹${_totalCredits.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                         if (!_isBalanced)
                           Text(
                             'Difference: ₹${(_totalDebits - _totalCredits).abs().toStringAsFixed(2)}',
                             style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                           ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.indigo, // Use primary color
                            ),
                            child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : const Text('SAVE ENTRY', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class JournalLineItem {
  int? ledgerId;
  bool isDebit = true;
  double? amount;
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
}
