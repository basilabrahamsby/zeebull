import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class ChartOfAccountsScreen extends StatefulWidget {
  const ChartOfAccountsScreen({super.key});

  @override
  State<ChartOfAccountsScreen> createState() => _ChartOfAccountsScreenState();
}

class _ChartOfAccountsScreenState extends State<ChartOfAccountsScreen> {
  bool _isLoading = true;
  List<dynamic> _groups = [];
  List<dynamic> _ledgers = [];
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final groups = await provider.fetchAccountGroups();
    final ledgers = await provider.fetchAccountLedgers();
    
    if (mounted) {
      setState(() {
        _groups = groups;
        _ledgers = ledgers;
        _isLoading = false;
        if (_groups.isNotEmpty) {
          _selectedGroupId = _groups.first['id'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredLedgers = _selectedGroupId == null
        ? _ledgers
        : _ledgers.where((l) => l['group_id'] == _selectedGroupId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart of Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group Selection (Horizontal Scroll)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                final isSelected = _selectedGroupId == group['id'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(group['name']),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGroupId = group['id'];
                      });
                    },
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: filteredLedgers.isEmpty
                ? const Center(child: Text('No ledgers in this group'))
                : ListView.separated(
                    itemCount: filteredLedgers.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final ledger = filteredLedgers[index];
                      return ListTile(
                        title: Text(ledger['name']),
                        subtitle: Text(ledger['code'] ?? 'No code'),
                        trailing: Text(
                          '₹${ledger['opening_balance']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          // View ledger details or transactions
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddOptions() {
     showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Add Account Group'),
            onTap: () {
              Navigator.pop(context);
              _showAddGroupDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add Account Ledger'),
            onTap: () {
              Navigator.pop(context);
              _showAddLedgerDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showAddGroupDialog() {
    final nameController = TextEditingController();
    String accountType = 'Revenue';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Account Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: accountType,
                items: const [
                  DropdownMenuItem(value: 'Revenue', child: Text('Revenue')),
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'Asset', child: Text('Asset')),
                  DropdownMenuItem(value: 'Liability', child: Text('Liability')),
                  DropdownMenuItem(value: 'Tax', child: Text('Tax')),
                ],
                onChanged: (val) => setDialogState(() => accountType = val!),
                decoration: const InputDecoration(labelText: 'Account Type'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await Provider.of<DashboardProvider>(context, listen: false).createAccountGroup({
                  'name': nameController.text,
                  'account_type': accountType,
                });
                if (success && mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLedgerDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final balanceController = TextEditingController();
    int? groupId = _selectedGroupId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Account Ledger'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ledger Name'),
                ),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Ledger Code'),
                ),
                DropdownButtonFormField<int>(
                  value: groupId,
                  items: _groups.map((g) => DropdownMenuItem(
                    value: g['id'] as int,
                    child: Text(g['name']),
                  )).toList(),
                  onChanged: (val) => setDialogState(() => groupId = val),
                  decoration: const InputDecoration(labelText: 'Account Group'),
                ),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Opening Balance'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (groupId == null) return;
                final success = await Provider.of<DashboardProvider>(context, listen: false).createAccountLedger({
                  'name': nameController.text,
                  'code': codeController.text,
                  'group_id': groupId,
                  'opening_balance': double.tryParse(balanceController.text) ?? 0.0,
                  'balance_type': 'debit',
                });
                if (success && mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
