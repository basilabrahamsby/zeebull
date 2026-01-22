import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class RequisitionsScreen extends StatefulWidget {
  const RequisitionsScreen({super.key});

  @override
  State<RequisitionsScreen> createState() => _RequisitionsScreenState();
}

class _RequisitionsScreenState extends State<RequisitionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() =>
        Provider.of<InventoryProvider>(context, listen: false).fetchRequisitions());
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
    int totalReq = provider.requisitions.length;
    int pendingReq = provider.requisitions.where((r) => r['status'] == 'pending').length;
    int historyReq = totalReq - pendingReq;

    return Scaffold(
      appBar: AppBar(title: const Text('Requisitions'), elevation: 0),
      body: Column(
        children: [
           // Dashboard
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
             color: Theme.of(context).primaryColor.withOpacity(0.05),
             child: Row(
               children: [
                 Expanded(child: _kpi("Total Requests", "$totalReq", Colors.blueGrey)),
                 const SizedBox(width: 12),
                 Expanded(child: _kpi("Pending", "$pendingReq", Colors.amber)),
                 const SizedBox(width: 12),
                 Expanded(child: _kpi("Completed", "$historyReq", Colors.green)),
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
                 Tab(text: "Pending"),
                 Tab(text: "History"),
               ],
             ),
           ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                 _RequisitionList(statusFilter: "pending"),
                 _RequisitionList(statusFilter: "history"), 
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _kpi(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
           const SizedBox(height: 4),
           Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _RequisitionList extends StatelessWidget {
  final String statusFilter;
  const _RequisitionList({required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    
    // Filter logic
    final requisitions = provider.requisitions.where((req) {
        if (statusFilter == "pending") {
            return req['status'] == 'pending';
        } else {
            return req['status'] != 'pending';
        }
    }).toList();

    if (requisitions.isEmpty) {
      return Center(child: Text("No $statusFilter requisitions"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requisitions.length,
      itemBuilder: (context, index) {
        final req = requisitions[index];
        final details = req['details'] as List<dynamic>;
        
        return Card(
           margin: const EdgeInsets.only(bottom: 12),
           child: ExpansionTile(
             leading: CircleAvatar(
               backgroundColor: req['status'] == 'pending' ? Colors.amber.shade100 : Colors.blue.shade100,
               child: Icon(Icons.assignment, color: req['status'] == 'pending' ? Colors.amber.shade900 : Colors.blue),
             ),
             title: Text(req['requisition_number'], style: const TextStyle(fontWeight: FontWeight.bold)),
             subtitle: Text("Requested by: ${req['requested_by_name'] ?? 'Unknown'}\nStatus: ${req['status'].toUpperCase()}"),
             children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(),
                      ...details.map((d) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(d['item_name'] ?? 'Unknown Item'),
                            Text("${d['requested_quantity']} ${d['unit']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 12),
                      if (statusFilter == "pending")
                        ElevatedButton.icon(
                          onPressed: () async {
                             bool success = await provider.approveRequisition(req['id']);
                             if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Requisition Approved")));
                             }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text("Approve Request"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        )
                    ],
                  ),
                )
             ],
           ),
        );
      },
    );
  }
}
