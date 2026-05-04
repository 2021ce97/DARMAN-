class Payment {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String currency;
  final String status; // pending, completed, failed, refunded
  final String paymentMethod; // hesabpay, cash, card
  final String? transactionId;
  final String? hesabpayOrderId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    this.currency = 'AFN',
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    this.hesabpayOrderId,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'AFN',
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'hesabpay',
      transactionId: json['transactionId'],
      hesabpayOrderId: json['hesabpayOrderId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'hesabpayOrderId': hesabpayOrderId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';
}

class PaymentIntent {
  final String orderId;
  final String paymentUrl;
  final double amount;
  final String currency;
  final DateTime expiresAt;

  PaymentIntent({
    required this.orderId,
    required this.paymentUrl,
    required this.amount,
    required this.currency,
    required this.expiresAt,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      orderId: json['orderId'] ?? '',
      paymentUrl: json['paymentUrl'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'AFN',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(Duration(minutes: 30)),
    );
  }
}
