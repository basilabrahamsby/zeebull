import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/presentation/providers/kitchen_provider.dart';
import 'package:intl/intl.dart';

class StockRequisitionListScreen extends StatefulWidget {
  const StockRequisitionListScreen({super.key});

  @override
  State<StockRequisitionListScreen> createState() => _StockRequisitionListScreenState();
}

class _StockRequisitionListScreenState extends State<StockRequisitionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitchenProvider>().fetchRequisitions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Stock Requisitions"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<KitchenProvider>(
        builder: (context, kitchen, child) {
          if (kitchen.isLoading && kitchen.requisitions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final pending = kitchen.requisitions.where((r) => r['status'] == 'pending').length;
          final approved = kitchen.requisitions.where((r) => r['status'] == 'approved').length;
          final issued = kitchen.requisitions.where((r) => r['status'] == 'issued').length;

          return Column(
            children: [
              _buildKpiSection(pending, approved, issued),
              Expanded(
                child: kitchen.requisitions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text("No requisitions found", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => kitchen.fetchRequisitions(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: kitchen.requisitions.length,
                          itemBuilder: (context, index) {
                            final req = kitchen.requisitions[index];
                            return _buildRequisitionCard(req);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKpiSection(int pending, int approved, int issued) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _buildKpiCard("Pending", pending.toString(), Colors.orange),
          const SizedBox(width: 8),
          _buildKpiCard("Approved", approved.toString(), Colors.blue),
          const SizedBox(width: 8),
          _buildKpiCard("Issued", issued.toString(), Colors.green),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.6), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequisitionCard(dynamic req) {
    final status = req['status'] ?? 'pending';
    final date = DateTime.parse(req['created_at']);
    final Color statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "REQ #${req['requisition_number'] ?? req['id']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM d, yyyy • hh:mm a').format(date),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const Divider(height: 24),
            ...?((req['details'] as List?)?.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(detail['item_name'] ?? "Item", style: const TextStyle(fontSize: 14)),
                  Text(
                    "${detail['requested_quantity']} ${detail['unit']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ))),
            if (req['notes'] != null && req['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req['notes'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.blue;
      case 'issued': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }
}
