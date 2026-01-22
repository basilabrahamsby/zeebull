import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity_log.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ActivityProvider>(context, listen: false).fetchLogs());
  }

  Color _getStatusColor(int code) {
    if (code >= 200 && code < 300) return Colors.green;
    if (code >= 400 && code < 500) return Colors.orange;
    if (code >= 500) return Colors.red;
    return Colors.grey;
  }

  String _formatDate(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('MMM d, hh:mm a').format(date);
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActivityProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Trail & History')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.logs.isEmpty
              ? const Center(child: Text("No activity logs found"))
              : RefreshIndicator(
                  onRefresh: () => provider.fetchLogs(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.logs.length,
                    itemBuilder: (context, index) {
                      final log = provider.logs[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(log.statusCode).withOpacity(0.1),
                            child: Icon(
                              log.statusCode >= 400 ? Icons.warning_amber : Icons.check_circle_outline,
                              color: _getStatusColor(log.statusCode),
                              size: 20,
                            ),
                          ),
                          title: Text(log.path.replaceAll('/api', ''), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text("${log.method} • ${log.userName ?? 'System'} • ${_formatDate(log.timestamp)}"),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Details:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                                    child: Text(log.details.isNotEmpty ? log.details : "No details provided", style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                                  ),
                                  const SizedBox(height: 8),
                                  if (log.userEmail != null)
                                    Text("User: ${log.userName} (${log.userEmail})", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
