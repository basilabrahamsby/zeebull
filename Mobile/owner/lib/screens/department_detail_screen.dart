import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class DepartmentDetailScreen extends StatefulWidget {
  final String deptName;
  final Map<String, dynamic> data;

  const DepartmentDetailScreen({
    Key? key,
    required this.deptName,
    required this.data,
  }) : super(key: key);

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> {
  late Map<String, dynamic> _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final freshData = await provider.fetchDepartmentDetails(widget.deptName);
    if (freshData.isNotEmpty && mounted) {
      setState(() {
        _data = freshData;
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: "en_IN", symbol: "₹");
    
    final income = (_data['income'] ?? 0).toDouble();
    final expenses = (_data['expenses'] ?? 0).toDouble(); 
    final assets = (_data['assets'] ?? 0).toDouble();
    
    final regularExp = (_data['regular_expenses'] ?? 0).toDouble();
    final inventoryCons = (_data['inventory_consumption'] ?? 0).toDouble();
    final capitalInv = (_data['capital_investment'] ?? 0).toDouble();
    
    final operatingProfit = income - expenses;
    final profitMargin = income > 0 ? (operatingProfit / income) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deptName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
            if (_isLoading) 
                const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: operatingProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text("Operating Profit", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text(
                      format.format(operatingProfit),
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold,
                        color: operatingProfit >= 0 ? Colors.green[800] : Colors.red[800]
                      )
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        "Margin: ${profitMargin.toStringAsFixed(1)}%",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text("Financial Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            _buildDetailRow("Total Income", income, format, isPositive: true),
            const Divider(),
            _buildDetailRow("Operational Expenses", expenses, format, isNegative: true),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4),
              child: Column(
                children: [
                  _buildSubRow("Billable Expenses", regularExp, format),
                  _buildSubRow("Inventory Consumption", inventoryCons, format),
                ],
              ),
            ),
            const Divider(thickness: 1.5),
            
            const SizedBox(height: 24),
            const Text("Assets & Capital", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow("Fixed Assets", assets, format, color: Colors.blue),
                    const Divider(),
                    _buildDetailRow("Capital Investment (Purchases)", capitalInv, format, color: Colors.purple),
                    const SizedBox(height: 8),
                    Text(
                      "* Capital Investment represents inventory purchases for this department.",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic)
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, double value, NumberFormat fmt, {bool? isPositive, bool? isNegative, Color? color}) {
    Color textColor = Colors.black87;
    if (isPositive == true) textColor = Colors.green;
    if (isNegative == true) textColor = Colors.red;
    if (color != null) textColor = color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(
            fmt.format(value),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSubRow(String label, double value, NumberFormat fmt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            fmt.format(value),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
