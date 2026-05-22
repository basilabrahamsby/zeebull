import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/staff_provider.dart';
import '../models/kpi_summary.dart';

import 'expense_screen.dart';
import 'pnl_screen.dart';
import 'room_list_screen.dart';
import 'bookings_screen.dart';
import 'food_analytics_screen.dart';
import 'inventory_screen.dart';
import 'services_screen.dart';
import 'staff_screen.dart';
import 'purchase_orders_screen.dart'; // exports PurchaseOrderScreen
import '../providers/branch_provider.dart';
import '../models/branch.dart';
import '../services/api_service.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshAllData();
  }

  void _refreshAllData() {
    Future.microtask(() {
        if (!mounted) return;
        final dash = Provider.of<DashboardProvider>(context, listen: false);
        dash.fetchKPIData();     
        dash.fetchRoomStats();   
        dash.fetchDailyKPIs();   
        dash.fetchChartData();   
        dash.fetchReportsData(); 
        dash.fetchFinancialTrends(); 
        
        Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
        Provider.of<StaffProvider>(context, listen: false).fetchEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final branchProvider = Provider.of<BranchProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Refresh data if branch changes (simple notification approach)
    // In a more robust app, you'd use a listener in the provider or a consumer
    
    final kpi = dashboardProvider.kpiSummary;
    final daily = dashboardProvider.dailyStats;
    final roomStats = dashboardProvider.roomStats;
    final chartData = dashboardProvider.chartData;
    final financialTrends = dashboardProvider.financialTrends;
    final recentActivity = dashboardProvider.recentActivity;
    
    final currencyFormat = NumberFormat.simpleCurrency(name: 'INR', locale: 'en_IN', decimalDigits: 0);

    if (dashboardProvider.isLoading || branchProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (kpi == null) {
      return const Scaffold(body: Center(child: Text("No dashboard data available")));
    }

    // --- Advanced KPI Calculations ---
    int totalRooms = (roomStats['total'] ?? 0) > 0 ? roomStats['total']! : 0;
    int occupiedRooms = roomStats['occupied'] ?? 0;
    double occupancyRate = totalRooms > 0 ? (occupiedRooms / totalRooms) * 100 : 0.0;
    
    double adr = kpi.roomBookings > 0 ? (kpi.totalRevenue / kpi.roomBookings) : 0.0;
    double revpar = totalRooms > 0 ? (kpi.totalRevenue / totalRooms) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF15803D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.dashboard_rounded, color: Color(0xFF15803D), size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        actions: [
          if (branchProvider.branches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: branchProvider.activeBranchId,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                         branchProvider.switchBranch(newValue).then((_) => _refreshAllData());
                      }
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'all',
                        child: Row(
                          children: [
                            Icon(Icons.business_rounded, color: Color(0xFF15803D), size: 16),
                            SizedBox(width: 8),
                            Text('Enterprise', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                          ],
                        ),
                      ),
                      ...branchProvider.branches.map<DropdownMenuItem<String>>((Branch branch) {
                        return DropdownMenuItem<String>(
                          value: branch.id.toString(),
                          child: Row(
                            children: [
                              const Icon(Icons.storefront_rounded, color: Color(0xFF64748B), size: 16),
                              const SizedBox(width: 8),
                              Text(branch.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshAllData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Live Operations (Occupancy & Movement)
              _buildSectionTitle("Live Operations"),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF064E3B).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ]
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Live Room Occupancy",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "${occupancyRate.toStringAsFixed(1)}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Available: ${daily['available_rooms'] ?? roomStats['available'] ?? 0}  •  Occupied: ${roomStats['occupied'] ?? 0}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 26,
                              startDegreeOffset: -90,
                              sections: totalRooms > 0 
                                ? [
                                    PieChartSectionData(
                                      color: Colors.white,
                                      value: occupiedRooms.toDouble(),
                                      radius: 7,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.white.withOpacity(0.2),
                                      value: (totalRooms - occupiedRooms).toDouble(),
                                      radius: 7,
                                      showTitle: false,
                                    ),
                                  ]
                                : [
                                    PieChartSectionData(
                                      color: Colors.white.withOpacity(0.2),
                                      value: 1,
                                      radius: 7,
                                      showTitle: false,
                                    ),
                                  ],
                            ),
                          ),
                        ),
                        Text(
                          "${occupancyRate.toStringAsFixed(0)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Alerts Section
              _buildSectionTitle("Alerts & Critical Tasks"),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildAlertCard("Pending Expenses", "${Provider.of<ExpenseProvider>(context).pendingExpenses.length}", Icons.assignment_late, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen()))),
                    const SizedBox(width: 12),
                    _buildAlertCard("Low Stock Items", "${kpi.lowStockItemsCount}", Icons.warning_amber_rounded, Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()))),
                    const SizedBox(width: 12),
                    _buildAlertCard("Dirty Rooms", "${roomStats['dirty'] ?? 0}", Icons.cleaning_services, Colors.brown, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomListScreen()))),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Health Metrics (Financials)
              _buildSectionTitle("Health Metrics"),
              _buildGrid([
                _kpi("ADR", currencyFormat.format(adr), Icons.show_chart, Colors.purple, subtitle: "Avg Daily Rate", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PnLScreen()))),
                _kpi("RevPAR", currencyFormat.format(revpar), Icons.hotel, Colors.deepOrange, subtitle: "Rev/Avail Room", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PnLScreen()))),
                _kpi("Total Rev", currencyFormat.format(kpi.totalRevenue), Icons.attach_money, Colors.green, subtitle: "All Time", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PnLScreen()))),
                _kpi("Today Rev", currencyFormat.format(daily['food_revenue_today'] ?? 0.0), Icons.today, Colors.teal, subtitle: "Today", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PnLScreen()))),
                _kpi("Net Profit", currencyFormat.format(kpi.netProfit), Icons.pie_chart, Colors.blue, subtitle: "Margin: ${kpi.totalRevenue > 0 ? ((kpi.netProfit / kpi.totalRevenue) * 100).toStringAsFixed(1) : '0'}%", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PnLScreen()))),
                _kpi("Expenses", currencyFormat.format(kpi.totalExpenses), Icons.money_off, Colors.red, subtitle: "Total Spend", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PnLScreen()))),
              ]),

              const SizedBox(height: 24),
              
              // 4. Recent Activity (Arrivals/Departures) - Live Feed
              _buildSectionTitle("Recent Activity"),
              if (recentActivity.isEmpty)
                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text("No recent activity", style: TextStyle(color: Colors.grey))))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentActivity.length > 5 ? 5 : recentActivity.length,
                  itemBuilder: (context, index) {
                    final item = recentActivity[index];
                    final checkInStr = item['check_in'] ?? 'N/A';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF15803D).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, size: 18, color: Color(0xFF15803D)),
                        ),
                        title: Text(
                          item['guest_name'] ?? "Unknown Guest",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Check-in: $checkInStr",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildStatusChip(item['status']),
                            const SizedBox(height: 4),
                            const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
                          ],
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen())),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),
              
              // 5. Bookings & Operations
              _buildSectionTitle("Bookings & Rooms"),
              _buildGrid([
                _kpi("Bookings", "${kpi.totalBookings}", Icons.book_online, Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen()))),
                _kpi("Packages", "${kpi.packageBookings}", Icons.inventory_2, Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen()))),
                _kpi("Rooms Occupied", "${roomStats['occupied'] ?? 0} / ${roomStats['total'] ?? 0}", Icons.bed, Colors.deepPurple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomListScreen()))),
                _kpi("Available", "${daily['available_rooms'] ?? roomStats['available'] ?? 0}", Icons.check_circle, Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomListScreen()))),
                _kpi("In Maintenance", "${roomStats['maintenance'] ?? 0}", Icons.build, Colors.redAccent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomListScreen()))),
                _kpi("Check-outs Today", "${daily['checkouts_today'] ?? 0}", Icons.exit_to_app, Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen()))),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle("F&B & Services"),
              _buildGrid([
                _kpi("Food Orders", "${kpi.foodOrders}", Icons.restaurant, Colors.brown, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodAnalyticsScreen()))),
                _kpi("Services", "${kpi.assignedServices}", Icons.cleaning_services, Colors.blueGrey, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesScreen()))),
                _kpi("Service Rev", currencyFormat.format(kpi.totalServiceRevenue), Icons.receipt, Colors.indigo, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesScreen()))),
                _kpi("Food Items", "${kpi.foodItemsAvailable}", Icons.menu_book, Colors.orangeAccent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodAnalyticsScreen()))),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle("Inventory & Staff"),
              _buildGrid([
                _kpi("Inv Items", "${kpi.inventoryItems}", Icons.category, Colors.amber, subtitle: "${kpi.inventoryCategories} Categories", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()))),
                _kpi("Stock Value", currencyFormat.format(kpi.totalInventoryValue), Icons.inventory, Colors.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()))), 
                _kpi("Purchases", "${kpi.purchaseCount}", Icons.shopping_cart, Colors.deepOrange, subtitle: currencyFormat.format(kpi.totalPurchases), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseOrderScreen()))),
                _kpi("Staff Online", "${kpi.onlineEmployees} / ${kpi.activeEmployees}", Icons.people, Colors.pink, subtitle: "Currently On Duty", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffScreen()))),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle("Analytics"),
              const SizedBox(height: 12),
              
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PnLScreen())),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 220, 
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(20), 
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Weekly Revenue",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15803D).withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF15803D)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildRevenueChart(chartData['weekly_performance'] ?? [])),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 6. Revenue Breakdown (Pie & Modes)
              _buildSectionTitle("Revenue Analysis"),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(20), 
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Sources",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(height: 150, child: _buildSourcePieChart(chartData['revenue_breakdown'] ?? [])),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(20), 
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Payment Modes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (kpi.revenueByMode.isEmpty)
                            const SizedBox(height: 150, child: Center(child: Text("No Data", style: TextStyle(color: Colors.grey))))
                          else
                            Column(
                              children: kpi.revenueByMode.entries.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        e.key,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      Text(
                                        currencyFormat.format(e.value),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 7. Financial Trends
              _buildSectionTitle("Financial Trends (6 Months)"),
              Container(
                height: 260, 
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(20), 
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildLegendItem("Revenue", const Color(0xFF15803D)),
                        const SizedBox(width: 12),
                        _buildLegendItem("Expense", const Color(0xFFEF4444)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: _buildTrendsChart(financialTrends)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 8. Department Performance
              _buildSectionTitle("Department Performance"),
              if (kpi.departmentKpis.isEmpty)
                 const Center(child: Text("No department data available", style: TextStyle(color: Colors.grey)))
              else
                 ListView.builder(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   itemCount: kpi.departmentKpis.length,
                   itemBuilder: (context, index) {
                     final deptName = kpi.departmentKpis.keys.elementAt(index);
                     final data = kpi.departmentKpis[deptName];
                     return Container(
                       margin: const EdgeInsets.only(bottom: 12),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(18),
                         border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.015),
                             blurRadius: 10,
                             offset: const Offset(0, 4),
                           )
                         ]
                       ),
                       child: Padding(
                         padding: const EdgeInsets.all(16),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               children: [
                                 Container(
                                   padding: const EdgeInsets.all(6),
                                   decoration: BoxDecoration(
                                     color: const Color(0xFF15803D).withOpacity(0.08),
                                     borderRadius: BorderRadius.circular(8),
                                   ),
                                   child: const Icon(Icons.business_center_rounded, color: Color(0xFF15803D), size: 16),
                                 ),
                                 const SizedBox(width: 10),
                                 Text(
                                   deptName,
                                   style: const TextStyle(
                                     fontWeight: FontWeight.bold,
                                     fontSize: 15,
                                     color: Color(0xFF1E293B),
                                   ),
                                 ),
                               ],
                             ),
                             const Padding(
                               padding: EdgeInsets.symmetric(vertical: 10),
                               child: Divider(color: Color(0xFFF1F5F9), height: 1),
                             ),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceAround,
                               children: [
                                 _departmentStat("Income", data['income'], const Color(0xFF15803D), currencyFormat),
                                 _departmentStat("Expense", data['expenses'], const Color(0xFFEF4444), currencyFormat),
                                 _departmentStat("Assets", data['assets'], const Color(0xFF3B82F6), currencyFormat),
                               ],
                             )
                           ],
                         ),
                       ),
                     );
                   },
                 ),


            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActionsMenu(context),
        backgroundColor: const Color(0xFF15803D),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    if (status == null) return const SizedBox();
    final s = status.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();
    
    Color bgColor;
    Color textColor;
    String displayLabel = status;
    
    if (s.contains('check in') || s.contains('checked in') || s.contains('active')) {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF15803D);
      displayLabel = 'Checked In';
    } else if (s.contains('checkout') || s.contains('checked out') || s.contains('completed')) {
      bgColor = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF475569);
      displayLabel = 'Checked Out';
    } else if (s.contains('book') || s.contains('confirmed') || s.contains('pending')) {
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1D4ED8);
      displayLabel = 'Booked';
    } else if (s.contains('cancel')) {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFB91C1C);
      displayLabel = 'Cancelled';
    } else {
      bgColor = const Color(0xFFFEF9C3);
      textColor = const Color(0xFFA16207);
      displayLabel = status.toUpperCase();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionItem(
                  context,
                  title: "Approve Expenses",
                  subtitle: "Review pending vendor payments",
                  icon: Icons.payments_rounded,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen()));
                  },
                ),
                _buildActionItem(
                  context,
                  title: "Room Audit",
                  subtitle: "Check occupancy & dirty rooms",
                  icon: Icons.meeting_room_rounded,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomListScreen()));
                  },
                ),
                _buildActionItem(
                  context,
                  title: "Inventory Stock",
                  subtitle: "View requisitions & purchase orders",
                  icon: Icons.inventory_2_rounded,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionItem(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(String title, String count, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 150,
        height: 125,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.15), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                Icon(Icons.arrow_forward_rounded, size: 14, color: color.withOpacity(0.6)),
              ],
            ),
            const Spacer(),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF15803D),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: children,
    );
  }

  Widget _kpi(String title, String value, IconData icon, Color color, {String? subtitle, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(List<dynamic> weeklyData) {
    if (weeklyData.isEmpty) return const Center(child: Text("No data"));
    List<FlSpot> spots = [];
    List<String> titles = [];
    
    for (int i = 0; i < weeklyData.length; i++) {
        double rev = (weeklyData[i]['revenue'] ?? 0).toDouble();
        spots.add(FlSpot(i.toDouble(), rev));
        titles.add(weeklyData[i]['day'].toString());
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFE2E8F0),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                int idx = val.toInt();
                if (idx >= 0 && idx < titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      titles[idx],
                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const Text("");
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF15803D),
            barWidth: 3.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xFF15803D),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF15803D).withOpacity(0.2),
                  const Color(0xFF15803D).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _departmentStat(String label, dynamic value, Color color, NumberFormat fmt) {
    return Column(
      children: [
        Text(fmt.format(value ?? 0), style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSourcePieChart(List<dynamic> data) {
    if (data.isEmpty) return const Center(child: Text("No Data"));
    
    List<PieChartSectionData> sections = [];
    final colors = [
      const Color(0xFF0F766E),
      const Color(0xFF15803D),
      const Color(0xFFF59E0B),
      const Color(0xFF6366F1),
    ];
    
    for (int i = 0; i < data.length; i++) {
        final val = (data[i]['value'] ?? 0).toDouble();
        if (val > 0) {
           sections.add(PieChartSectionData(
             color: colors[i % colors.length],
             value: val,
             title: '${(val/1000).toStringAsFixed(1)}k',
             radius: 26,
             titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
           ));
        }
     }
     
     return PieChart(PieChartData(
        sections: sections,
        centerSpaceRadius: 24,
        sectionsSpace: 2,
     ));
  }

  Widget _buildTrendsChart(List<dynamic> trends) {
    if (trends.isEmpty) return const Center(child: Text("No Data"));
    
    List<FlSpot> revSpots = [];
    List<FlSpot> expSpots = [];
    List<String> titles = [];
    
    for (int i = 0; i < trends.length; i++) {
       titles.add(trends[i]['month'].toString().split(' ')[0]);
       revSpots.add(FlSpot(i.toDouble(), (trends[i]['revenue'] ?? 0).toDouble()));
       expSpots.add(FlSpot(i.toDouble(), (trends[i]['expense'] ?? 0).toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFE2E8F0),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                int idx = val.toInt();
                if (idx >= 0 && idx < titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      titles[idx],
                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const Text("");
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: revSpots,
            color: const Color(0xFF15803D),
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3,
                color: Colors.white,
                strokeWidth: 1.5,
                strokeColor: const Color(0xFF15803D),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF15803D).withOpacity(0.12),
                  const Color(0xFF15803D).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: expSpots,
            color: const Color(0xFFEF4444),
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3,
                color: Colors.white,
                strokeWidth: 1.5,
                strokeColor: const Color(0xFFEF4444),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEF4444).withOpacity(0.08),
                  const Color(0xFFEF4444).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
