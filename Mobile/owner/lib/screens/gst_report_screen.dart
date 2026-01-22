import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kpi_summary.dart';

class GstReportScreen extends StatelessWidget {
  final KpiSummary kpi;

  const GstReportScreen({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: "en_IN", symbol: "₹");
    final netLiability = kpi.totalOutputTax - kpi.totalInputTax;

    return Scaffold(
      appBar: AppBar(title: const Text("GST Liability Report")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryCard("Output GST (Collected)", kpi.totalOutputTax, Colors.red, format, "Liability"),
            const SizedBox(height: 16),
            _buildSummaryCard("Input GST (ITC Available)", kpi.totalInputTax, Colors.green, format, "Asset"),
            const SizedBox(height: 24),
            _buildNetLiabilityCard(netLiability, format),
            const SizedBox(height: 32),
            const Text(
              "Note: This is an estimated report based on Checkout and Purchase records. For filing, please verify with official ledgers.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, NumberFormat fmt, String type) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(type == "Liability" ? Icons.arrow_upward : Icons.arrow_downward, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(fmt.format(amount), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  Widget _buildNetLiabilityCard(double amount, NumberFormat fmt) {
    final isPayable = amount > 0;
    return Card(
      color: isPayable ? Colors.orange[50] : Colors.green[50], // Subtle tint
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Net GST Payable", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              fmt.format(amount.abs()),
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: isPayable ? Colors.red : Colors.green
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPayable ? "You need to pay this amount" : "You have excess credit",
              style: TextStyle(fontWeight: FontWeight.bold, color: isPayable ? Colors.red[800] : Colors.green[800]),
            ),
          ],
        ),
      ),
    );
  }
}
