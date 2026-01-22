class KpiSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final int totalCheckouts;

  KpiSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalCheckouts,
  });

  factory KpiSummary.fromJson(Map<String, dynamic> json) {
    // Handling structure from /accounts/auto-report
    final summary = json['summary'] ?? {};
    final revenue = json['revenue'] ?? {};
    final checkouts = revenue['checkouts'] ?? {};
    
    return KpiSummary(
      totalRevenue: (summary['total_revenue'] ?? 0).toDouble(),
      totalExpenses: (summary['total_expenses'] ?? 0).toDouble(),
      netProfit: (summary['net_profit'] ?? 0).toDouble(),
      totalCheckouts: (checkouts['total_checkouts'] ?? 0).toInt(),
    );
  }
}
