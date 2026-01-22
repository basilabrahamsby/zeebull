import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import 'journal_entry_add_screen.dart';

class JournalEntriesScreen extends StatefulWidget {
  const JournalEntriesScreen({super.key});

  @override
  State<JournalEntriesScreen> createState() => _JournalEntriesScreenState();
}

class _JournalEntriesScreenState extends State<JournalEntriesScreen> {
  bool _isLoading = true;
  List<dynamic> _entries = [];
  final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final entries = await provider.fetchJournalEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEntryScreen(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(child: Text('No journal entries found'))
              : ListView.separated(
                  itemCount: _entries.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final date = DateTime.parse(entry['entry_date']);
                    return ListTile(
                      title: Text('Entry #${entry['entry_number']}'),
                      subtitle: Text('${DateFormat('dd MMM yyyy').format(date)}\n${entry['description']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            format.format(entry['total_amount']),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          entry['reference_type'] != null
                              ? Text(
                                  '${entry['reference_type']} #${entry['reference_id']}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      onTap: () => _viewEntryDetails(entry),
                    );
                  },
                ),
    );
  }

  void _viewEntryDetails(dynamic entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Journal Entry Detail', style: Theme.of(context).textTheme.headlineSmall),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: (entry['lines'] as List).length,
                  itemBuilder: (context, idx) {
                    final line = entry['lines'][idx];
                    return Card(
                      child: ListTile(
                        title: Text(line['description'] ?? 'No description'),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(line['debit_ledger']?['name'] ?? line['credit_ledger']?['name'] ?? 'Unknown'),
                            Text(
                              line['debit_ledger_id'] != null ? 'DR' : 'CR',
                              style: TextStyle(
                                  color: line['debit_ledger_id'] != null ? Colors.blue : Colors.orange,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: Text(format.format(line['amount'])),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEntryScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JournalEntryAddScreen()),
    );
    
    if (result == true) {
      _loadData(); // Refresh list if entry created
    }
  }
}

