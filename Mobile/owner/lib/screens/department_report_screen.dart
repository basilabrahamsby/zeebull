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
          "Department Overview",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF064E3B),
            letterSpacing: -0.5,
          ),
        ),
      ),
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
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DepartmentDetailScreen(
                        deptName: name,
                        data: data,
                      )));
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name and Net Profit
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name, 
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800, 
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: netProfit >= 0 ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: netProfit >= 0 ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5), width: 1),
                                ),
                                child: Text(
                                  format.format(netProfit), 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 13, 
                                    color: netProfit >= 0 ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                  )
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, color: Color(0xFFF1F5F9)),
                          
                          // Stats Grid
                          Row(
                            children: [
                              Expanded(child: _buildMiniStat("Income", income, format, const Color(0xFF0284C7))),
                              const SizedBox(width: 12),
                              Expanded(child: _buildMiniStat("Expenses", expenses, format, const Color(0xFFEA580C), isNegative: true)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildMiniStat("Assets", assets, format, const Color(0xFF0D9488))),
                              const SizedBox(width: 12),
                              Expanded(child: _buildMiniStat("Capital Inv.", capital, format, const Color(0xFF7C3AED))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildMiniStat(String label, double value, NumberFormat fmt, Color color, {bool isNegative = false}) {
    final displayColor = isNegative && value > 0 ? const Color(0xFFDC2626) : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: const TextStyle(
              fontSize: 11, 
              color: Color(0xFF64748B), 
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fmt.format(value), 
            style: TextStyle(
              fontWeight: FontWeight.w800, 
              fontSize: 14, 
              color: displayColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
