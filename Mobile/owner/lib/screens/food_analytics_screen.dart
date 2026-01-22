import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/food_provider.dart';

class FoodAnalyticsScreen extends StatefulWidget {
  const FoodAnalyticsScreen({super.key});

  @override
  State<FoodAnalyticsScreen> createState() => _FoodAnalyticsScreenState();
}

class _FoodAnalyticsScreenState extends State<FoodAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<FoodProvider>(context, listen: false).fetchAnalyticsData());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FoodProvider>(context);
    final currency = NumberFormat.simpleCurrency(name: 'INR');
    
    if (provider.isAnalyticsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculations
    double profitMargin = provider.totalRevenue > 0 ? (provider.totalProfit / provider.totalRevenue) * 100 : 0;
    double costRatio = provider.totalCOGS > 0 ? provider.totalRevenue / provider.totalCOGS : 0;
    double avgCost = provider.totalCompletedOrders > 0 ? provider.totalCOGS / provider.totalCompletedOrders : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Row (Placeholder for now, implementation matches Web layout)
          // const Text("Filters", style: TextStyle(fontWeight: FontWeight.bold)),
          // const SizedBox(height: 8),
          
          // 1. KPI Cards Row 1
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildKpiCard("Total Revenue", currency.format(provider.totalRevenue), Colors.green, Icons.attach_money),
              _buildKpiCard("Total Orders", "${provider.totalCompletedOrders}", Colors.blue, Icons.shopping_bag),
              _buildKpiCard("Completed", "${provider.totalCompletedOrders}", Colors.purple, Icons.check_circle), // Web shows "Completed Orders"
              _buildKpiCard("Items Sold", "${provider.totalItemsSold}", Colors.orange, Icons.fastfood),
            ],
          ),
          const SizedBox(height: 12),
          
          // 2. KPI Cards Row 2 (Profitability)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildKpiCard("Total Profit", currency.format(provider.totalProfit), Colors.teal, Icons.trending_up),
              _buildKpiCard("Total COGS", currency.format(provider.totalCOGS), Colors.red, Icons.inventory),
              _buildKpiCard("Avg Order Value", currency.format(provider.avgOrderValue), Colors.cyan, Icons.analytics),
              _buildKpiCard("Avg Profit", currency.format(provider.avgProfitPerOrder), Colors.amber, Icons.monetization_on),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 3. Sales Trend (Line Chart)
          const Text("Sales Trend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
            child: provider.salesTrend.isEmpty 
               ? const Center(child: Text("No trend data"))
               : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 1000)), // Approximate interval
                    ),
                    borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getTrendSpots(provider.salesTrend),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                      ),
                    ],
                  ),
                ),
          ),

          const SizedBox(height: 24),

          // 4. Order Status Distribution (Chart + Legend)
          const Text("Order Status Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (provider.orderStatusDist.isNotEmpty)
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: _getPieSections(provider.orderStatusDist),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: provider.orderStatusDist.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(width: 12, height: 12, color: _getStatusColor(e.key)),
                            const SizedBox(width: 8),
                            Text("${e.key}: ${e.value}", style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      )).toList(),
                    ),
                  )
                ],
              ),
            )
          else
            const Text("No status data"),

          const SizedBox(height: 24),

          // 5. Profitability Analysis
          const Text("Profitability Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAnalysisCard("Profit Margin", "${profitMargin.toStringAsFixed(1)}%", "Overall margin", Colors.green.shade50, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildAnalysisCard("Rev/Cost", "${costRatio.toStringAsFixed(2)}x", "For every ₹1 cost", Colors.blue.shade50, Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnalysisCard("Avg Cost per Order", currency.format(avgCost), "Average COGS", Colors.purple.shade50, Colors.purple),

          const SizedBox(height: 24),

          // 6. Top Employee Performance
          const Text("Top Employee Performance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          provider.employeePerformance.isEmpty
              ? const Text("No employee data")
              : Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.employeePerformance.take(5).length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final emp = provider.employeePerformance[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text("${index + 1}")),
                        title: Text(emp['name']),
                        subtitle: Text("${emp['orders']} Orders"),
                        trailing: Text(currency.format(emp['revenue']), style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),

          const SizedBox(height: 24),

          // 7. Top Selling Items
          const Text("Top 10 Selling Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
          provider.topItems.isEmpty 
              ? const Text("No sales data available.") 
              : Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.topItems.take(10).length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = provider.topItems[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber.withOpacity(0.2),
                        child: Text("#${index + 1}", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text("${item['quantity']} sold", style: const TextStyle(fontSize: 14)),
                    );
                  },
                ),
              ),

          const SizedBox(height: 24),

          // 8. Inventory Usage
          const Text("Inventory Usage Report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("Based on recipe ingredients (Cost Analysis)", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),

          provider.inventoryUsage.isEmpty 
              ? const Text("No usage calculated.") 
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                     itemCount: provider.inventoryUsage.take(10).length,
                     separatorBuilder: (_, __) => const Divider(height: 1),
                     itemBuilder: (context, index) {
                       final item = provider.inventoryUsage[index];
                       return ListTile(
                         visualDensity: VisualDensity.compact,
                         leading: const Icon(Icons.inventory_2, color: Colors.blueGrey, size: 20),
                         title: Text(item['name']),
                         trailing: Text("${(item['quantity'] as num).toStringAsFixed(1)} units", style: const TextStyle(fontWeight: FontWeight.w500)),
                       );
                     },
                  ),
                ),
           const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(title, style: TextStyle(fontSize: 12, color: color.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String value, String subtitle, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 10)),
        ],
      ),
    );
  }

  List<FlSpot> _getTrendSpots(Map<DateTime, double> trend) {
    if (trend.isEmpty) return [];
    final sortedKeys = trend.keys.toList()..sort();
    return List.generate(sortedKeys.length, (index) {
      return FlSpot(index.toDouble(), trend[sortedKeys[index]]!);
    });
  }

  List<PieChartSectionData> _getPieSections(Map<String, int> dist) {
    int total = dist.values.fold(0, (sum, val) => sum + val);
    return dist.entries.map((e) {
      final isLarge = e.value / total > 0.2;
      return PieChartSectionData(
        color: _getStatusColor(e.key),
        value: e.value.toDouble(),
        title: '${(e.value / total * 100).toStringAsFixed(0)}%',
        radius: isLarge ? 50 : 40,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ordered': return Colors.blue;
      case 'preparing': return Colors.orange;
      case 'ready': return Colors.green;
      case 'delivered': return Colors.purple; // Completed
      case 'completed': return Colors.purple;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
