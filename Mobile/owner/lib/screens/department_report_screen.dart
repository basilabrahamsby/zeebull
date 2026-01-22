import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kpi_summary.dart';
import 'department_detail_screen.dart';

class DepartmentReportScreen extends StatelessWidget {
  final KpiSummary kpi;

  const DepartmentReportScreen({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: "en_IN", symbol: "₹", decimalDigits: 2);
    
    // Convert Map to List for display
    final List<MapEntry<String, dynamic>> departments = kpi.departmentKpis.entries.toList();

    // Sort: negative net profit first (attention needed), then by magnitude of activity
    departments.sort((a, b) {
      final profitA = (a.value['income'] ?? 0) - (a.value['expenses'] ?? 0);
      final profitB = (b.value['income'] ?? 0) - (b.value['expenses'] ?? 0);
      return profitA.compareTo(profitB); // Lower profit (more negative) first
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Department Overview")),
      body: departments.isEmpty 
        ? const Center(child: Text("No department data available"))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final entry = departments[index];
              final name = entry.key;
              final data = entry.value as Map<String, dynamic>;
              
              final income = (data['income'] ?? 0).toDouble();
              final expenses = (data['expenses'] ?? 0).toDouble();
              final assets = (data['assets'] ?? 0).toDouble();
              final capital = (data['capital_investment'] ?? 0).toDouble();
              final netProfit = income - expenses;
              
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DepartmentDetailScreen(
                      deptName: name,
                      data: data,
                    )));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Name and Net Profit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: netProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: netProfit >= 0 ? Colors.green.shade200 : Colors.red.shade200)
                              ),
                              child: Text(
                                format.format(netProfit), 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 14, 
                                  color: netProfit >= 0 ? Colors.green[800] : Colors.red[800]
                                )
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        
                        // Stats Grid
                        Row(
                          children: [
                            Expanded(child: _buildMiniStat("Income", income, format, Colors.blue)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMiniStat("Expenses", expenses, format, Colors.orange, isNegative: true)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildMiniStat("Assets", assets, format, Colors.teal)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMiniStat("Capital Inv.", capital, format, Colors.purple)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildMiniStat(String label, double value, NumberFormat fmt, Color color, {bool isNegative = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Very subtle background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            fmt.format(value), 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 13, 
              color: isNegative && value > 0 ? Colors.red : color // If explicitly marked as negative flow, show red
            )
          ),
        ],
      ),
    );
  }
}
