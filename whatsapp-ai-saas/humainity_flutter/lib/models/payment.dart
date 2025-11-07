class Payment {
  final String id;
  final String customerId;
  final double amount;
  final String currency;
  final String? paymentMethod;
  final String paymentStatus;
  final DateTime paymentDate;
  final String? notes;

  Payment({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    required this.paymentStatus,
    required this.paymentDate,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      customerId: json['customer_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'INR',
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentDate: DateTime.parse(json['payment_date']),
      notes: json['notes'],
    );
  }
}