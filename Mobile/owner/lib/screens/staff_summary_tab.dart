import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';

class StaffSummaryTab extends StatelessWidget {
  const StaffSummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    final employees = provider.employees;
    
    // Calculate Metrics
    final totalStaff = employees.length;
    final activeStaff = employees.where((e) => e.isClockedIn).length;
    final totalSalary = employees.fold(0.0, (sum, e) => sum + (e.salary ?? 0));
    final avgSalary = totalStaff > 0 ? totalSalary / totalStaff : 0.0;
    
    // Group by Role
    final roleDistribution = <String, int>{};
    for (var e in employees) {
      roleDistribution[e.role] = (roleDistribution[e.role] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Organization Dashboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Stats Row 1
          Row(
            children: [
               _buildStatCard("Total Staff", "$totalStaff", Colors.blue, Icons.people),
               const SizedBox(width: 12),
               _buildStatCard("On Duty", "$activeStaff", Colors.green, Icons.work),
            ],
          ),
          const SizedBox(height: 12),
          // Stats Row 2
          Row(
            children: [
               _buildStatCard("Total Payroll", "₹${(totalSalary/1000).toStringAsFixed(1)}k", Colors.orange, Icons.attach_money),
               const SizedBox(width: 12),
               _buildStatCard("Avg Salary", "₹${(avgSalary/1000).toStringAsFixed(1)}k", Colors.purple, Icons.bar_chart),
            ],
          ),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Department Distribution", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (roleDistribution.isEmpty) const Text("No data") else ...roleDistribution.entries.map((e) => _buildBar(e.key, e.value, totalStaff)).toList(),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text("Employee Performance (Salary)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
           _buildTopPerformersList(employees),
           
          const SizedBox(height: 24),
          // Placeholder for Tasks as requested
          _buildTasksOverviewCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
                   const SizedBox(height: 4),
                   Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, int count, int total) {
     final pct = total > 0 ? count / total : 0.0;
     return Padding(
       padding: const EdgeInsets.only(bottom: 12),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
               Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
               Text("$count", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: pct, backgroundColor: Colors.grey.shade100, color: Colors.blueAccent, minHeight: 6, borderRadius: BorderRadius.circular(4)),
         ],
       ),
     );
  }

  Widget _buildTopPerformersList(List<dynamic> employees) {
     final sorted = List.from(employees)..sort((a, b) => (b.salary ?? 0).compareTo(a.salary ?? 0));
     final top5 = sorted.take(5).toList();
     
     return Container(
       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
       child: Column(
         children: top5.map((e) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Text(e.name.isNotEmpty ? e.name[0] : '?', style: TextStyle(color: Colors.blue.shade700))),
            title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(e.role, style: const TextStyle(fontSize: 12)),
            trailing: Text("₹${e.salary}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
         )).toList(),
       ),
     );
  }
  
  Widget _buildTasksOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.shade50.withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.withOpacity(0.2))),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Tasks Completed", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              SizedBox(height: 4),
              Text("Based on recent activity", style: TextStyle(fontSize: 12, color: Colors.grey)),
           ]),
           Text("0", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
        ],
      ),
    );
  }
}
