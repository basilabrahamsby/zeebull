import 'package:flutter/material.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class MaintenanceDashboard extends StatefulWidget {
  const MaintenanceDashboard({super.key});

  @override
  State<MaintenanceDashboard> createState() => _MaintenanceDashboardState();
}

class _MaintenanceDashboardState extends State<MaintenanceDashboard> {
  String _selectedFilter = 'Pending'; // Pending, In Progress, Completed

  // Mock data for maintenance tasks
  final List<MaintenanceTask> _tasks = [
    MaintenanceTask(
      id: "MT-501",
      location: "Room 305",
      category: "Electronics",
      description: "AC not cooling properly",
      priority: "High",
      status: "Pending",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MaintenanceTask(
      id: "MT-502",
      location: "Lobby",
      category: "Furniture",
      description: "Broken chair leg near reception",
      priority: "Medium",
      status: "In Progress",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MaintenanceTask(
      id: "MT-503",
      location: "Room 102",
      category: "Bathroom",
      description: "Leaking tap in washroom",
      priority: "Urgent",
      status: "Pending",
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  List<MaintenanceTask> get _filteredTasks {
    if (_selectedFilter == 'All') return _tasks;
    return _tasks.where((t) => t.status == _selectedFilter).toList();
  }

  void _updateStatus(MaintenanceTask task, String newStatus) {
    setState(() {
      task.status = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${task.id} marked as $newStatus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Pending', 'In Progress', 'Completed', 'All']
                    .map((filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedFilter = filter);
                            },
                            selectedColor: Colors.blue[800],
                            labelStyle: TextStyle(
                              color: _selectedFilter == filter ? Colors.white : Colors.black87,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          // Task List
          Expanded(
            child: _filteredTasks.isEmpty
                ? const Center(child: Text("No tasks found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return _MaintenanceTaskCard(
                        task: task,
                        onUpdateStatus: _updateStatus,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceTaskCard extends StatelessWidget {
  final MaintenanceTask task;
  final Function(MaintenanceTask, String) onUpdateStatus;

  const _MaintenanceTaskCard({required this.task, required this.onUpdateStatus});

  Color _getPriorityColor() {
    switch (task.priority.toLowerCase()) {
      case 'urgent': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutesAgo = DateTime.now().difference(task.createdAt).inMinutes;
    final timeStr = minutesAgo < 60 ? "$minutesAgo min ago" : "${(minutesAgo / 60).floor()}h ago";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Text(task.location, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.priority,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            subtitle: Text(task.category),
            trailing: Text(timeStr, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (task.status == 'Pending')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => onUpdateStatus(task, 'In Progress'),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Start Task"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        ),
                      ),
                    if (task.status == 'In Progress')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => onUpdateStatus(task, 'Completed'),
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Mark Resolved"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ),
                    if (task.status == 'Completed')
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text("Resolved", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MaintenanceTask {
  final String id;
  final String location;
  final String category;
  final String description;
  final String priority;
  String status;
  final DateTime createdAt;

  MaintenanceTask({
    required this.id,
    required this.location,
    required this.category,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
  });
}
