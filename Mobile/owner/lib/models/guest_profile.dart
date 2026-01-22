class GuestHistory {
  final int id;
  final String date;
  final String room;
  final double amount;
  final String status;

  GuestHistory({required this.id, required this.date, required this.room, required this.amount, required this.status});
}

class GuestProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String idType;
  final String idNumber;
  final String totalSpent;
  final int visits;
  final String notes;
  final List<GuestHistory> history;

  GuestProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.idType,
    required this.idNumber,
    required this.totalSpent,
    required this.visits,
    required this.notes,
    required this.history
  });

  // Factory for mock/real data
  factory GuestProfile.mock(String name) {
    return GuestProfile(
      id: 1,
      name: name,
      email: "${name.replaceAll(' ', '.').toLowerCase()}@example.com",
      phone: "+91 98765 43210",
      idType: "Aadhar Card",
      idNumber: "XXXX-XXXX-1234",
      totalSpent: "₹45,000",
      visits: 3,
      notes: "Vegetarian. Likes extra pillows. VIP.",
      history: [
        GuestHistory(id: 101, date: "2024-12-01", room: "101", amount: 12000, status: "Checked Out"),
        GuestHistory(id: 102, date: "2024-10-15", room: "205", amount: 8000, status: "Checked Out"),
      ]
    );
  }
}
