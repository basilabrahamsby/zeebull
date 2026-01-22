import 'package:flutter/material.dart';
import '../models/guest_profile.dart';

class GuestProfileScreen extends StatelessWidget {
  final String guestName;

  const GuestProfileScreen({super.key, required this.guestName});

  @override
  Widget build(BuildContext context) {
    // In a real app, fetch ID from arguments and call API
    final profile = GuestProfile.mock(guestName);

    return Scaffold(
      appBar: AppBar(title: const Text('Guest Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                   const CircleAvatar(
                     radius: 40,
                     backgroundColor: Colors.white,
                     child: Icon(Icons.person, size: 50, color: Colors.blueGrey),
                   ),
                   const SizedBox(height: 16),
                   Text(profile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(Icons.star, color: Colors.amber, size: 18),
                       const SizedBox(width: 4),
                       Text('${profile.visits} Visits • VIP Guest', style: const TextStyle(fontWeight: FontWeight.w600)),
                     ],
                   )
                ],
              ),
            ),
            
            // Stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildStatCard(context, 'Total Spent', profile.totalSpent, Icons.attach_money),
                  const SizedBox(width: 16),
                  _buildStatCard(context, 'Last Visit', profile.history.first.date, Icons.calendar_today),
                ],
              ),
            ),

            // Details
            _buildSectionTitle('Contact Information'),
            ListTile(leading: const Icon(Icons.email), title: Text(profile.email)),
            ListTile(leading: const Icon(Icons.phone), title: Text(profile.phone)),
            ListTile(leading: const Icon(Icons.badge), title: Text('${profile.idType}: ${profile.idNumber}')),

            const Divider(),
            _buildSectionTitle('Preferences & Notes'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(profile.notes, style: TextStyle(color: Colors.brown.shade800)),
              ),
            ),

            const Divider(),
            _buildSectionTitle('Stay History'),
            ...profile.history.map((h) => ListTile(
              leading: const Icon(Icons.hotel),
              title: Text('Room ${h.room}'),
              subtitle: Text(h.date),
              trailing: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   Text('₹${h.amount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                   Text(h.status, style: const TextStyle(fontSize: 12, color: Colors.green)),
                 ],
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0,2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
