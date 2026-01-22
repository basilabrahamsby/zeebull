import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class TrialBalanceScreen extends StatefulWidget {
  const TrialBalanceScreen({super.key});

  @override
  State<TrialBalanceScreen> createState() => _TrialBalanceScreenState();
}

class _TrialBalanceScreenState extends State<TrialBalanceScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _trialBalance;
  final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final data = await provider.fetchTrialBalance();
    if (mounted) {
      setState(() {
        _trialBalance = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trial Balance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trialBalance == null || (_trialBalance!['ledgers'] as List? ?? []).isEmpty
              ? const Center(child: Text('No trial balance data available'))
              : Column(
                  children: [
                    // Summary Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: (_trialBalance!['is_balanced'] ?? false) 
                                  ? [Colors.green.shade700, Colors.green.shade900]
                                  : [Colors.red.shade700, Colors.red.shade900],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                            BoxShadow(color: ((_trialBalance!['is_balanced'] ?? false) ? Colors.green : Colors.red).withOpacity(0.3), 
                            blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                (_trialBalance!['is_balanced'] ?? false) ? Icons.check_circle : Icons.error,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (_trialBalance!['is_balanced'] ?? false) ? 'Balanced' : 'Out of Balance',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem('Total Dr', _trialBalance!['total_debits'] ?? 0),
                              _buildSummaryItem('Total Cr', _trialBalance!['total_credits'] ?? 0),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text('Ledger', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Debit', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                          Expanded(child: Text('Credit', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    const Divider(),
                    
                    Expanded(
                      child: ListView.separated(
                        itemCount: (_trialBalance!['ledgers'] as List? ?? []).length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final ledger = _trialBalance!['ledgers'][index];
                          final balance = ledger['balance'] as double;
                          final isDebit = ledger['balance_type'] == 'debit';
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ledger['ledger_name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                                      Text(ledger['ledger_id'].toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    isDebit ? format.format(balance.abs()) : '-',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(color: isDebit ? Colors.green.shade800 : Colors.black),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    !isDebit ? format.format(balance.abs()) : '-',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(color: !isDebit ? Colors.orange.shade800 : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummaryItem(String label, dynamic amount) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(
          format.format(amount),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
