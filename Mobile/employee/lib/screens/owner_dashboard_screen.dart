import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DashboardProvider>(context, listen: false).fetchKPIData());
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final kpi = dashboardProvider.kpiSummary;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(title: const Text('Executive Dashboard')),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : kpi == null
              ? const Center(child: Text("No data available"))
              : RefreshIndicator(
                  onRefresh: () => dashboardProvider.fetchKPIData(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildKpiCard(
                        'Total Revenue',
                        currencyFormat.format(kpi.totalRevenue),
                        Icons.attach_money,
                        Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard(
                              'Expenses',
                              currencyFormat.format(kpi.totalExpenses),
                              Icons.money_off,
                              Colors.red,
                              small: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildKpiCard(
                              'Net Profit',
                              currencyFormat.format(kpi.netProfit),
                              Icons.trending_up,
                              Colors.blue,
                              small: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildKpiCard(
                        'Checkouts',
                        kpi.totalCheckouts.toString(),
                        Icons.check_circle_outline,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color,
      {bool small = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: small ? 14 : 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: small ? 20 : 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: small ? 20 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
