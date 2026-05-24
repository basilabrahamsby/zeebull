import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _fetchTransactions();
    });
  }

  Future<void> _fetchTransactions() async {
     try {
       final provider = Provider.of<DashboardProvider>(context, listen: false);
       final data = await provider.fetchTransactionsList();
       if (mounted) {
         setState(() {
           _transactions = data;
           _isLoading = false;
         });
       }
     } catch (e) {
       if (mounted) {
         setState(() {
           _error = e.toString();
           _isLoading = false;
         });
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: "en_IN", symbol: "₹");

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF064E3B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Business Ledger",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF064E3B),
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF064E3B))) 
          : _error != null 
              ? Center(child: Text("Error: $_error"))
              : _transactions.isEmpty 
                  ? const Center(child: Text("No transactions found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      itemBuilder: (ctx, index) {
                         final item = _transactions[index];
                         final isIncome = item['is_income'] == true;
                         final amount = (item['amount'] ?? 0).toDouble();
                         final dateStr = item['date'] ?? '';
                         DateTime? date;
                         try { date = DateTime.parse(dateStr); } catch (_) {}

                         final statusColor = isIncome ? const Color(0xFF059669) : const Color(0xFFDC2626);
                         final statusBg = isIncome ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);

                         return Container(
                           margin: const EdgeInsets.only(bottom: 12),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(16),
                             border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.01),
                                 blurRadius: 8,
                                 offset: const Offset(0, 3),
                               )
                             ],
                           ),
                           child: Padding(
                             padding: const EdgeInsets.all(16),
                             child: Row(
                               children: [
                                 Container(
                                   padding: const EdgeInsets.all(10),
                                   decoration: BoxDecoration(
                                     color: statusBg,
                                     shape: BoxShape.circle,
                                   ),
                                   child: Icon(
                                     isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                     color: statusColor,
                                     size: 20,
                                   ),
                                 ),
                                 const SizedBox(width: 14),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         item['description'] ?? 'Unknown',
                                         style: const TextStyle(
                                           fontWeight: FontWeight.bold,
                                           fontSize: 14,
                                           color: Color(0xFF1E293B),
                                         ),
                                       ),
                                       const SizedBox(height: 6),
                                       Text(
                                         date != null ? DateFormat('MMM dd, hh:mm a').format(date) : dateStr,
                                         style: const TextStyle(
                                           fontSize: 12,
                                           color: Color(0xFF64748B),
                                           fontWeight: FontWeight.w500,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                                 Text(
                                   "${isIncome ? '+' : '-'} ${format.format(amount)}",
                                   style: TextStyle(
                                     color: statusColor,
                                     fontWeight: FontWeight.w800,
                                     fontSize: 15,
                                     letterSpacing: -0.2,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         );
                      },
                    ),
    );
  }
}
