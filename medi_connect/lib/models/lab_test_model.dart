class LabTest {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String duration; // e.g., "2-3 hours"
  final String reportTime; // e.g., "Same day"
  final bool homeCollection;
  final String preparation; // fasting requirements etc.
  final List<String> includes;

  LabTest({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.duration,
    required this.reportTime,
    this.homeCollection = false,
    this.preparation = '',
    this.includes = const [],
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? '',
      reportTime: json['reportTime'] ?? '',
      homeCollection: json['homeCollection'] ?? false,
      preparation: json['preparation'] ?? '',
      includes: List<String>.from(json['includes'] ?? []),
    );
  }
}

class LabTestBooking {
  final String id;
  final String labId;
  final String labName;
  final String testId;
  final String testName;
  final String patientId;
  final String date;
  final String timeSlot;
  final bool homeCollection;
  final String address;
  final double amount;
  final String status;
  final DateTime createdAt;

  LabTestBooking({
    required this.id,
    required this.labId,
    required this.labName,
    required this.testId,
    required this.testName,
    required this.patientId,
    required this.date,
    required this.timeSlot,
    required this.homeCollection,
    required this.address,
    required this.amount,
    required this.status,
    required this.createdAt,
  });
}
