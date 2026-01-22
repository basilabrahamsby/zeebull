import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AttendanceProvider>(context, listen: false).fetchStatus());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Digital Clock Display
            Text(
              DateFormat('hh:mm a').format(now),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            Text(
              DateFormat('EEEE, MMMM d, y').format(now),
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 48),

            // Big Clock In/Out Button
            GestureDetector(
              onTap: provider.isLoading ? null : () => provider.toggleAttendance(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: provider.isClockedIn ? Colors.red.shade400 : Colors.green.shade400,
                  boxShadow: [
                    BoxShadow(
                      color: (provider.isClockedIn ? Colors.red : Colors.green).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      provider.isClockedIn ? Icons.exit_to_app : Icons.login,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.isClockedIn ? 'CLOCK OUT' : 'CLOCK IN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Status Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: provider.isLoading 
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        Text(
                          provider.isClockedIn ? 'Currently On Duty' : 'Currently Off Duty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: provider.isClockedIn ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                        ),
                        if (provider.isClockedIn && provider.clockInTime != null)
                          Text(
                            'Since ${DateFormat('hh:mm a').format(provider.clockInTime!)}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
