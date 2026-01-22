import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'package:intl/intl.dart';
import 'purchase_order_detail_screen.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key});

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
       final p = Provider.of<InventoryProvider>(context, listen: false);
       p.fetchPendingPOs();
       p.fetchPurchaseHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    // Calculate KPIs
    double pendingValue = provider.pendingPOs.fold(0, (sum, item) => sum + item.totalAmount);
    double historyValue = provider.purchaseHistory.fold(0, (sum, item) => sum + item.totalAmount);
    // Calculate Today's Spending
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    double todayValue = provider.purchaseHistory
        .where((p) => p.date.startsWith(today))
        .fold(0, (sum, item) => sum + item.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        elevation: 0,
      ),
      body: Column(
        children: [
           // KPI Section
           Container(
             padding: const EdgeInsets.all(16),
             color: Theme.of(context).primaryColor.withOpacity(0.05),
             child: Row(
               children: [
                 Expanded(child: _kpiCard("Pending Approval", "₹${pendingValue.toStringAsFixed(0)}", provider.pendingPOs.length.toString(), Colors.orange)),
                 const SizedBox(width: 12),
                 Expanded(child: _kpiCard("Total Spent", "₹${historyValue.toStringAsFixed(0)}", "All Time", Colors.blue)),
                 const SizedBox(width: 12),
                 Expanded(child: _kpiCard("Today", "₹${todayValue.toStringAsFixed(0)}", "Spending", Colors.green)),
               ],
             ),
           ),
           
           // Tabs
           Container(
             color: Colors.white,
             child: TabBar(
               controller: _tabController,
               labelColor: Theme.of(context).primaryColor,
               unselectedLabelColor: Colors.grey,
               indicatorColor: Theme.of(context).primaryColor,
               tabs: const [
                 Tab(text: "Pending Approval"),
                 Tab(text: "History"),
               ],
             ),
           ),
           
           // List
           Expanded(
             child: TabBarView(
               controller: _tabController,
               children: const [
                  _PendingPOList(),
                  _HistoryPOList(),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _kpiCard(String title, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0,2))],
        border: Border.all(color: color.withOpacity(0.2))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
        ],
      ),
    );
  }
}

class _PendingPOList extends StatelessWidget {
  const _PendingPOList();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    
    if (provider.pendingPOs.isEmpty) {
      return const Center(child: Text("No pending orders"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.pendingPOs.length,
      itemBuilder: (context, index) {
        final po = provider.pendingPOs[index];
        return Card(
           child: ListTile(
             contentPadding: const EdgeInsets.all(16),
             leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: const Icon(Icons.pending_actions, color: Colors.orange)),
             title: Text("${po.purchaseNumber} • ${po.vendorName}"),
             subtitle: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const SizedBox(height: 4),
                 Text("₹${po.totalAmount.toStringAsFixed(2)} • ${po.itemCount} Items"),
                 Text("Created: ${po.date}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
               ],
             ),
             trailing: ElevatedButton(
               onPressed: () async {
                  await provider.approvePO(po.id);
                  if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PO Approved")));
                  }
               },
               style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
               child: const Text("Approve"),
             ),
           ),
        );
      },
    );
  }
}

class _HistoryPOList extends StatelessWidget {
  const _HistoryPOList();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    
    if (provider.purchaseHistory.isEmpty) {
      return const Center(child: Text("No purchase history"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.purchaseHistory.length,
      itemBuilder: (context, index) {
        final po = provider.purchaseHistory[index];
        return Card(
           child: ListTile(
             contentPadding: const EdgeInsets.all(16),
             leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.check_circle, color: Colors.blue)),
             title: Text("${po.purchaseNumber} • ${po.vendorName}"),
             subtitle: Text("₹${po.totalAmount.toStringAsFixed(2)} • ${po.itemCount} Items\nStatus: ${po.status.toUpperCase()}"),
             isThreeLine: true,
             trailing: const Icon(Icons.chevron_right),
             onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PurchaseOrderDetailScreen(purchase: po.toJson())),
                );
             },
           ),
        );
      },
    );
  }
}
