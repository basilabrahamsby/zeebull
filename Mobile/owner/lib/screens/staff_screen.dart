import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';
import '../models/employee.dart';
import '../models/leave.dart';
import '../models/working_log.dart';
import '../models/employee_status_overview.dart';
import '../models/monthly_report.dart';
import '../models/staff_history.dart';
import 'staff_summary_tab.dart';
import 'employee_profile_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  int? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<StaffProvider>(context, listen: false);
      await provider.fetchEmployees();
      provider.fetchStatusOverview();

      
      // Auto-select first employee
      if (provider.employees.isNotEmpty && _selectedEmployeeId == null) {
        setState(() {
          _updateSelectedEmployee(provider.employees.first.id);
        });
      }
    });
  }

  void _updateSelectedEmployee(int? id) {
     if (id == null) return;
     setState(() => _selectedEmployeeId = id);
     final provider = Provider.of<StaffProvider>(context, listen: false);
     provider.fetchWorkLogs(id);
     provider.fetchEmployeeLeaves(id);
     // For activity tab
     final emp = provider.employees.firstWhere((e) => e.id == id, orElse: () => Employee(id: 0, name: '', role: '', status: '', isClockedIn: false));
     if (emp.userId != null) provider.fetchUserHistory(emp.userId!);
     // For report tab
     final now = DateTime.now();
     provider.fetchMonthlyReport(id, now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);

    return DefaultTabController(
      length: 6, // Added Dashboard tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Staff Management'),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.brown,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            onTap: (index) {
              final provider = Provider.of<StaffProvider>(context, listen: false);
              final empId = _selectedEmployeeId;
              
              switch (index) {
                case 0: // Dashboard (New)
                  provider.fetchEmployees();
                  provider.fetchStatusOverview();
                  break;
                case 1: // Overview (Selected Employee)
                  if (empId != null) {
                    provider.fetchWorkLogs(empId);
                    provider.fetchEmployeeLeaves(empId);
                    // Fetch history for tasks
                    try {
                        final emp = provider.employees.firstWhere((e) => e.id == empId);
                        if (emp.userId != null) provider.fetchUserHistory(emp.userId!);
                    } catch (_) {}
                  }
                  break;
                case 2: // Directory
                  provider.fetchEmployees();
                  break;
                case 3: // Attendance
                  if (empId != null) provider.fetchWorkLogs(empId);
                  break;
                case 4: // Reports
                   if (empId != null) {
                       final now = DateTime.now();
                       provider.fetchMonthlyReport(empId, now.year, now.month);
                   }
                   break;
                case 5: // Activity
                   if (empId != null) {
                       try {
                           final emp = provider.employees.firstWhere((e) => e.id == empId);
                           if (emp.userId != null) provider.fetchUserHistory(emp.userId!);
                       } catch (_) {}
                   }
                   break;
              }
            },
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Overview'),
              Tab(text: 'Directory'),
              Tab(text: 'Attendance'),
              Tab(text: 'Reports'),
              Tab(text: 'Activity'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Global Employee Selector
            if (provider.employees.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<int>(
                  value: _selectedEmployeeId,
                  decoration: const InputDecoration(
                    labelText: 'Select Employee',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: provider.employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                  onChanged: _updateSelectedEmployee,
                ),
              ),
            
            Expanded(
              child: TabBarView(
                children: [
                   const StaffSummaryTab(), // New Global Dashboard
                   StaffOverviewTab(employeeId: _selectedEmployeeId),
                   const StaffDirectoryTab(), // Directory is global list
                   StaffAttendanceTab(employeeId: _selectedEmployeeId),
                   // StaffLeaveTab(), // Pending leaves are global admin task
                   StaffReportsTab(employeeId: _selectedEmployeeId),
                   StaffActivityTab(employeeId: _selectedEmployeeId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 1. Overview Tab (Replicated from Admin Web Employee Management)
class StaffOverviewTab extends StatelessWidget {
  final int? employeeId;
  const StaffOverviewTab({super.key, this.employeeId});

  @override
  Widget build(BuildContext context) {
    if (employeeId == null) return const Center(child: Text("Select an employee above"));

    return Consumer<StaffProvider>(
      builder: (context, provider, child) {
        // Find selected employee object
        final employee = provider.employees.firstWhere(
            (e) => e.id == employeeId, 
            orElse: () => Employee(id: 0, name: 'Unknown', role: '', status: '', isClockedIn: false));

        final todayStr = DateTime.now().toIso8601String().split('T')[0];
        final todayLogs = provider.workLogs.where((l) => l.date == todayStr);
        final todayHours = todayLogs.fold(0.0, (sum, l) => sum + (l.durationHours ?? 0.0));
        
        // Calculate leave balance
        final approvedLeaves = provider.employeeLeaves.where((l) => l.status == 'approved').length;
        final leaveBalance = 20 - approvedLeaves;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Selector - REMOVED, now global
              // Top Row Cards (Time Record, Calendar, Leave Balance)
              // Use a responsive layout or column for mobile
              _buildTimeRecordCard(employee.isClockedIn, todayHours),
              const SizedBox(height: 16),
              _buildAttendanceCalendarCard(provider.workLogs),
                const SizedBox(height: 16),
                _buildLeaveBalanceCard(leaveBalance, total: provider.monthlyReport?.totalPaidLeavesYear ?? 24),
                const SizedBox(height: 16),
            
                // Weekly Attendance Chart (Mock for now or use fl_chart)
                Container(height: 200, color: Colors.grey.shade100, child: const Center(child: Text("Weekly Attendance Chart Placeholder"))),

                 const SizedBox(height: 24),
                 _buildTimesheetCard(provider.workLogs), // Pass logsTasksCard(provider.userHistory),
            const SizedBox(height: 24),
            _buildTimeOffChartCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeRecordCard(bool isClockedIn, double todayHours) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Time record", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade100, width: 4),
                color: Colors.grey.shade50,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isClockedIn ? 'Clocked in' : 'Clocked out', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text("${todayHours.toStringAsFixed(1)}h",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Location", style: TextStyle(color: Colors.grey)), Text("Office", style: TextStyle(fontWeight: FontWeight.bold))]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null, // Disabled as per requirement
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, foregroundColor: Colors.grey, elevation: 0),
              child: const Text("Clock In"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCalendarCard(List<WorkingLog> logs) {
    
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstDay = DateTime(now.year, now.month, 1);
    final offset = firstDay.weekday - 1; // 0=Mon, ...

    // Extract present dates
    final presentDates = logs.map((l) => l.date).toSet(); // 'YYYY-MM-DD'

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Attendance", style: TextStyle(fontWeight: FontWeight.bold)), 
              Text("${_getMonthName(now.month)} ${now.year}", style: const TextStyle(fontSize: 12, color: Colors.grey))
           ]),
           const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => Text(d, style: const TextStyle(color: Colors.grey, fontSize: 12))).toList(),
            ),
           GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
              itemCount: 35, // Fixed 5 rows for simplicity, or 42
              itemBuilder: (context, index) {
                  final day = index - offset + 1;
                  if (day < 1 || day > daysInMonth) return const SizedBox();
                  
                  final dateKey = "${now.year}-${now.month.toString().padLeft(2,'0')}-${day.toString().padLeft(2,'0')}";
                  final isPresent = presentDates.contains(dateKey);
                  
                  return Container(
                     margin: const EdgeInsets.all(4),
                     decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPresent ? Colors.green.withOpacity(0.2) : Colors.transparent,
                     ),
                     alignment: Alignment.center,
                     child: Text("$day", style: TextStyle(color: isPresent ? Colors.green : Colors.black87, fontSize: 12)),
                  );
              }
           )
        ],
      ),
    );
  }

  String _getMonthName(int m) {
    const list = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (m < 1 || m > 12) return '';
    return list[m - 1];
  }

  String _formatTimeIST(String? timeStr) {
    if (timeStr == null) return 'N/A';
    try {
        // Parse time string "HH:mm:ss.SSSSSS"
        final parts = timeStr.split(':');
        int h = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        
        // Assume input is UTC, convert to IST (+5:30)
        // Creating a dummy date ensuring no overflow issues for display
        var dt = DateTime(2024, 1, 1, h, m).add(const Duration(hours: 5, minutes: 30));
        
        // Format to 12-hour AM/PM
        int hour = dt.hour;
        String ampm = 'AM';
        if (hour >= 12) {
          ampm = 'PM';
          if (hour > 12) hour -= 12;
        }
        if (hour == 0) hour = 12;
        
        return "$hour:${dt.minute.toString().padLeft(2, '0')} $ampm";
    } catch (e) {
      return timeStr.substring(0, 5); // Fallback
    }
  }

  Widget _buildLeaveBalanceCard(int balance, {int total = 24}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          const Align(alignment: Alignment.centerLeft, child: Text("Paid Leave Balance", style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(value: total > 0 ? balance / total : 0, strokeWidth: 8, backgroundColor: Colors.grey.shade200, color: Colors.redAccent),
                Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("$balance", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    Text("/ $total", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text("View Details", style: TextStyle(color: Colors.orange))),
        ],
      ),
    );
  }

  Widget _buildTimesheetCard(List<WorkingLog> logs) {
    final today = DateTime.now();
    final todayLogs = logs.where((l) => l.date != null && 
        DateTime.parse(l.date).year == today.year && 
        DateTime.parse(l.date).month == today.month && 
        DateTime.parse(l.date).day == today.day).toList();
    
    // Default time slots
    final slots = ['8:00 AM', '12:00 PM', '4:00 PM', '8:00 PM'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Timesheet (Today)", style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey), 
              const SizedBox(width: 8),
              Text("${_getMonthName(today.month)} ${today.day}, ${today.year}", style: const TextStyle(fontWeight: FontWeight.w500))
           ]),
          const SizedBox(height: 12),
          if (todayLogs.isEmpty)
             const Padding(padding: EdgeInsets.all(20), child: Text("No records for today", style: TextStyle(color: Colors.grey)))
          else
             Column(
                children: todayLogs.map((log) {
                     return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                           children: [
                              const Icon(Icons.access_time, size: 16, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text("In: ${_formatTimeIST(log.checkInTime)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (log.checkOutTime != null) ...[
                                  const SizedBox(width: 16),
                                  const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.access_time_filled, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text("Out: ${_formatTimeIST(log.checkOutTime)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ] else ...[
                                   const Spacer(),
                                   Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:2), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)), child: const Text("Active", style: TextStyle(color: Colors.white, fontSize: 10)))
                              ]
                           ]
                        )
                     );
                }).toList()
             )
        ],
      ),
    );
  }

  Widget _buildHolidaysCard() {
    final holidays = [
      {'date': 'DEC 25', 'name': 'Christmas', 'day': 'Mon'},
      {'date': 'JAN 01', 'name': 'New Year', 'day': 'Mon'},
      {'date': 'JAN 26', 'name': 'Republic Day', 'day': 'Fri'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("List of holidays", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...holidays.map((h) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Column(children: [Text(h['date']!.split(' ')[0], style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(h['date']!.split(' ')[1], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange))]),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(h['day']!, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(h['name']!, style: const TextStyle(fontWeight: FontWeight.w500))]),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCompletedTasksCard(UserHistory? history) {
    if (history == null || history.activities.isEmpty) {
        return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Tasks Completed", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text("No recent tasks found", style: TextStyle(color: Colors.grey))
            ])
        );
    }

    // Filter for 'Service' type activities which represent tasks
    final tasks = history.activities.where((a) => a.type == 'Service' || a.type == 'Task').take(5).toList();

    if (tasks.isEmpty) {
         return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Tasks Completed", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text("No completed tasks in history", style: TextStyle(color: Colors.grey))
            ])
        );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tasks Completed", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...tasks.map((t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.type, style: const TextStyle(fontWeight: FontWeight.w500)), Text(t.description, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)), child: const Text("Done", style: TextStyle(fontSize: 10, color: Colors.green))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTimeOffChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Time off activities", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Center(child: Text("Chart Placeholder", style: TextStyle(color: Colors.grey))),
            // Implement fl_chart here if package available
          ),
        ],
      ),
    );
  }
}

class GraphQLCalendarGrid extends StatelessWidget {
  final List<WorkingLog> logs;
  const GraphQLCalendarGrid({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: 31,
      itemBuilder: (context, index) {
        final day = index + 1;
        // Mock check if day has log
        // Real implementation would parse date
        final hasWork = index % 3 == 0; // Mock pattern
        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: hasWork ? Colors.green.shade100 : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text("$day", style: TextStyle(fontSize: 10, color: hasWork ? Colors.green.shade800 : Colors.black87))),
        );
      },
    );
  }
}

// 2. Directory Tab (Existing List with FAB)
class StaffDirectoryTab extends StatelessWidget {
  const StaffDirectoryTab({super.key});

  Color _getStatusColor(String status) {
    if (status == 'On Duty') return Colors.green;
    if (status.contains('On Leave')) return Colors.orange;
    return Colors.grey;
  }

  void _showAddStaffModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final joinDateCtrl = TextEditingController(text: DateTime.now().toIso8601String().split('T')[0]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add New Staff", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            Row(children: [
              Expanded(child: TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: "Role (e.g. Manager)"))),
              const SizedBox(width: 16),
              Expanded(child: TextField(controller: salaryCtrl, decoration: const InputDecoration(labelText: "Salary"), keyboardType: TextInputType.number)),
            ]),
            TextField(controller: joinDateCtrl, decoration: const InputDecoration(labelText: "Join Date (YYYY-MM-DD)")),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await Provider.of<StaffProvider>(context, listen: false).addEmployee({
                    'name': nameCtrl.text,
                    'email': emailCtrl.text,
                    'password': passwordCtrl.text,
                    'role': roleCtrl.text,
                    'salary': salaryCtrl.text,
                    'join_date': joinDateCtrl.text,
                  });
                  if (success) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text("Add Employee"),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Consumer<StaffProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.employees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
          itemCount: provider.employees.length,
          itemBuilder: (context, index) {
            final emp = provider.employees[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeProfileScreen(employeeId: emp.id),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade50,
                          child: Text(emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'U', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        if (emp.isClockedIn)
                          Positioned(right: 0, bottom: 0, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(emp.role, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(emp.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor(emp.status).withOpacity(0.3)),
                      ),
                      child: Text(emp.status, style: TextStyle(color: _getStatusColor(emp.status), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            );
          },
        );
      },
    ));
  }
}

// 3. Attendance Tab


// 3. Attendance Tab (Modified for Global Selection)
class StaffAttendanceTab extends StatefulWidget {
  final int? employeeId;
  const StaffAttendanceTab({super.key, this.employeeId});

  @override
  State<StaffAttendanceTab> createState() => _StaffAttendanceTabState();
}

class _StaffAttendanceTabState extends State<StaffAttendanceTab> {
  // Helper to group logs... (same as before)
  List<Map<String, dynamic>> _processAttendanceData(List<WorkingLog> logs) {
      if (logs.isEmpty) return [];

    final Map<String, Map<String, dynamic>> grouped = {};

    for (var log in logs) {
      if (!grouped.containsKey(log.date)) {
        grouped[log.date] = {
          'date': log.date,
          'totalHours': 0.0,
          'logs': <WorkingLog>[],
        };
      }
      grouped[log.date]!['logs'].add(log);
      if (log.durationHours != null) {
        grouped[log.date]!['totalHours'] += log.durationHours!;
      }
    }

    return grouped.entries.map((entry) {
      double totalHours = entry.value['totalHours'] as double;
      bool hasActiveLog = entry.value['logs'].any((l) => l.checkOutTime == null);
      
      // If active, add running duration
      if (hasActiveLog) {
         final now = DateTime.now(); // Assume local, or convert if needed
         // For simplicity, we just mark as Working. Calculation requires rigorous parsing.
         // But let's try to add running time if date is today
         final todayStr = now.toIso8601String().split('T')[0];
         if (entry.key == todayStr) {
             for (var log in entry.value['logs']) {
                 if (log.checkOutTime == null && log.checkInTime != null) {
                      try {
                          final parts = log.checkInTime!.split(':');
                          // Assuming checkInTime is UTC from backend, convert to local or IST?
                          // Backend sends what is stored. Let's assume standard parsing.
                          // Actually, let's just mark status as "Working"
                      } catch (_) {}
                 }
             }
         }
      }

      String status = 'Absent';
      Color color = Colors.red;

      if (hasActiveLog) {
        status = 'Working';
        color = Colors.blue; 
      } else if (totalHours >= 8) {
        status = 'Present';
        color = Colors.green;
      } else if (totalHours >= 4) {
        status = 'Half Day';
        color = Colors.orange;
      } else if (totalHours > 0) {
        status = 'Partial';
        color = Colors.orange.shade300;
      }

      return {
        'date': entry.key,
        'totalHours': totalHours,
        'status': status,
        'color': color,
        'logs': entry.value['logs'],
      };
    }).toList()
      ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.employeeId == null) return const Center(child: Text("Select an employee"));

    final provider = Provider.of<StaffProvider>(context);
    final dailyData = _processAttendanceData(provider.workLogs);

    // Calculate Summary Stats
    int totalDays = dailyData.length;
    int presentDays = dailyData.where((d) => d['status'] == 'Present').length;
    int halfDays = dailyData.where((d) => d['status'] == 'Half Day').length;
    double totalHours = dailyData.fold(0.0, (sum, d) => sum + (d['totalHours'] as double));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Removed DropdownButtonFormField

            // Summary Cards
            if (dailyData.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    _buildSummaryCard("Total Days", "$totalDays", Colors.blue),
                    const SizedBox(width: 8),
                    _buildSummaryCard("Present", "$presentDays", Colors.green),
                    const SizedBox(width: 8),
                    _buildSummaryCard("Half Days", "$halfDays", Colors.orange),
                    const SizedBox(width: 8),
                    _buildSummaryCard("Hours", totalHours.toStringAsFixed(1), Colors.purple),
                  ],
                ),
              ),

            // Detailed List
            Expanded(
              child: dailyData.isEmpty
                  ? const Center(child: Text("No records found"))
                  : ListView.builder(
                      itemCount: dailyData.length,
                      itemBuilder: (context, index) {
                        final data = dailyData[index];
                        final logs = data['logs'] as List<WorkingLog>;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ExpansionTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: (data['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${(data['totalHours'] as double).toStringAsFixed(1)}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: data['color'] as Color),
                                  ),
                                  Text("hrs", style: TextStyle(fontSize: 10, color: data['color'] as Color)),
                                ],
                              ),
                            ),
                            title: Text(data['date'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              data['status'] as String,
                              style: TextStyle(color: data['color'] as Color, fontWeight: FontWeight.w500),
                            ),
                            children: logs.map((log) {
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.access_time, size: 16),
                                title: Text("${log.checkInTime ?? '-'} to ${log.checkOutTime ?? 'Active'}"),
                                trailing: log.durationHours != null
                                    ? Text("${log.durationHours!.toStringAsFixed(2)} hrs")
                                    : const Text("Running", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)), textAlign: TextAlign.center, maxLines: 1),
          ],
        ),
      ),
    );
  }
}


// 4. Leave Tab (Existing)
class StaffLeaveTab extends StatelessWidget {
  const StaffLeaveTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<StaffProvider>(
      builder: (context, provider, child) {
        if (provider.pendingLeaves.isEmpty) {
          return const Center(child: Text("No pending leave requests", style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.pendingLeaves.length,
          itemBuilder: (context, index) {
            final leave = provider.pendingLeaves[index];
            final empName = provider.employees.firstWhere(
                (e) => e.id == leave.employeeId, 
                orElse: () => Employee(id: 0, name: 'Unknown', role: '', status: '', isClockedIn: false, userId: null)
            ).name;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(empName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(leave.leaveType, style: const TextStyle(color: Colors.orange, fontSize: 12)))]),
                    const SizedBox(height: 8),
                    Text("Reason: ${leave.reason}"),
                    const SizedBox(height: 4),
                    Text("${leave.fromDate} to ${leave.toDate}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => provider.updateLeaveStatus(leave.id, 'rejected'), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Reject")),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: () => provider.updateLeaveStatus(leave.id, 'approved'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text("Approve")),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 5. Reports Tab
class StaffReportsTab extends StatefulWidget {
  final int? employeeId;
  const StaffReportsTab({super.key, this.employeeId});
  @override
  State<StaffReportsTab> createState() => _StaffReportsTabState();
}
class _StaffReportsTabState extends State<StaffReportsTab> {
  DateTime selectedDate = DateTime.now();

  void _changeMonth(int months) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + months);
      if (widget.employeeId != null) {
        Provider.of<StaffProvider>(context, listen: false)
            .fetchMonthlyReport(widget.employeeId!, selectedDate.year, selectedDate.month);
      }
    });
  }

  // Refetch when parent selected employee changes
  @override
  void didUpdateWidget(covariant StaffReportsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.employeeId != oldWidget.employeeId && widget.employeeId != null) {
       Provider.of<StaffProvider>(context, listen: false)
          .fetchMonthlyReport(widget.employeeId!, selectedDate.year, selectedDate.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    if (widget.employeeId == null) return const Center(child: Text("Select an employee"));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
              Text("${months[selectedDate.month - 1]} ${selectedDate.year}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.monthlyReport != null) ...[
             Card(
               elevation: 3,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               child: Padding(
                 padding: const EdgeInsets.all(20),
                 child: Column(
                   children: [
                     Text("Performance Summary", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 16),
                     Row(
                       children: [
                         Expanded(child: _buildSummaryItem("Present", "${provider.monthlyReport!.presentDays}", Colors.green)),
                         Expanded(child: _buildSummaryItem("Absent", "${provider.monthlyReport!.absentDays}", Colors.red)),
                         Expanded(child: _buildSummaryItem("Leaves", "${provider.monthlyReport!.paidLeavesTaken + provider.monthlyReport!.sickLeavesTaken}", Colors.orange)),
                       ],
                     ),
                     const Divider(height: 30),
                     _buildRow("Paid Leaves Taken", "${provider.monthlyReport!.paidLeavesTaken}"),
                     _buildRow("Sick Leaves Taken", "${provider.monthlyReport!.sickLeavesTaken}"),
                     _buildRow("Unpaid Leaves", "${provider.monthlyReport!.unpaidLeaves}"),
                     const Divider(height: 30),
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           const Text("Net Salary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                           Text("₹${provider.monthlyReport!.netSalary.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
             )
          ] else if (provider.isLoading) const CircularProgressIndicator()
          else const Text("No report available for this month")
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.grey.shade800)), Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.bold))]),
    );
  }
}


// 6. Status Tab (Categorized List)
class StaffStatusTab extends StatelessWidget {
  const StaffStatusTab({super.key});

  @override
  Widget build(BuildContext context) {
     final provider = Provider.of<StaffProvider>(context);
     final onDuty = provider.employees.where((e) => e.status == 'On Duty').toList();
     final onLeave = provider.employees.where((e) => e.status.contains('Leave')).toList();
     final offDuty = provider.employees.where((e) => e.status != 'On Duty' && !e.status.contains('Leave')).toList();

     return ListView(
       padding: const EdgeInsets.all(16),
       children: [
         _buildSection("🟢 On Duty", onDuty, Colors.green),
         _buildSection("🟠 On Leave", onLeave, Colors.orange),
         _buildSection("⚪ Off Duty", offDuty, Colors.grey),
       ],
     );
  }

  Widget _buildSection(String title, List<Employee> employees, Color color) {
    if (employees.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text("$title (${employees.length})", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
        ...employees.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: color.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: color.withOpacity(0.2))),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white, child: Text(e.name.isNotEmpty ? e.name[0] : '?', style: TextStyle(color: color))),
            title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(e.role),
            trailing: e.isClockedIn ? const Icon(Icons.timer, color: Colors.green, size: 20) : null,
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}

// 7. Activity Tab (Timeline)
class StaffActivityTab extends StatefulWidget {
  final int? employeeId;
  const StaffActivityTab({super.key, this.employeeId});

  @override
  State<StaffActivityTab> createState() => _StaffActivityTabState();
}
class _StaffActivityTabState extends State<StaffActivityTab> {
  // Logic mostly covered by parent update, but just in case
  String _formatTimeIST(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr).add(const Duration(hours: 5, minutes: 30));
      int h = dt.hour;
      String ampm = 'AM';
      if (h >= 12) { ampm = 'PM'; if (h > 12) h -= 12; }
      if (h == 0) h = 12;
      return "$h:${dt.minute.toString().padLeft(2, '0')} $ampm";
    } catch (_) { return ''; }
  }
  
  String _formatDateIST(String? dateTimeStr) {
      if (dateTimeStr == null) return '';
      try {
        final dt = DateTime.parse(dateTimeStr).add(const Duration(hours: 5, minutes: 30));
        return "${dt.day}/${dt.month}";
      } catch (_) { return ''; }
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    
    if (widget.employeeId == null) return const Center(child: Text("Select an employee"));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          
          if (provider.userHistory != null)
             if (provider.userHistory!.activities.isEmpty)
                const Expanded(child: Center(child: Text("No activity history found", style: TextStyle(color: Colors.grey))))
             else
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.userHistory!.activities.length,
                    itemBuilder: (context, index) {
                       final act = provider.userHistory!.activities[index];
                       final isBooking = act.type == 'Booking';
                       final isService = act.type == 'Service';
                       final color = isBooking ? Colors.blue : (isService ? Colors.purple : Colors.grey);
                       
                       return IntrinsicHeight(
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             SizedBox(
                               width: 50,
                               child: Column(
                                 children: [
                                   Text(_formatTimeIST(act.activityDate), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)), // Time
                                   Text(_formatDateIST(act.activityDate), style: const TextStyle(fontSize: 10, color: Colors.grey)), // Date
                                 ],
                               ),
                             ),
                             Column(
                               children: [
                                 Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)])),
                                 Expanded(child: Container(width: 2, color: Colors.grey.shade200)),
                               ],
                             ),
                             const SizedBox(width: 16),
                             Expanded(
                               child: Padding(
                                 padding: const EdgeInsets.only(bottom: 24),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(act.type, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                                     const SizedBox(height: 4),
                                     Text(act.description, style: const TextStyle(fontSize: 14)),
                                     if (act.amount != null)
                                        Text("₹${act.amount}", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
                                   ],
                                 ),
                               ),
                             ),
                           ],
                         ),
                       );
                    },
                  ),
                )
          else if (provider.isLoading) 
             const CircularProgressIndicator()
          else
             const Text("No recent activity or history not found")
        ],
      ),
    );
  }
}
