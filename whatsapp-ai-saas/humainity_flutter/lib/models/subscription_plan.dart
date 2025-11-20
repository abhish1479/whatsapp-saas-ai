class SubscriptionPlan {
  final int id;
  final String name;
  final double price;
  final double pricePerMonth;
  final int credits;
  final int durationDays;
  final String billingCycle;
  final List<String> features;
  final String category;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.pricePerMonth,
    required this.credits,
    required this.durationDays,
    required this.billingCycle,
    required this.features,
    required this.category,
    required this.isPopular,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json["id"],
      name: json["name"] ?? "",
      price: (json["price"] ?? 0).toDouble(),
      pricePerMonth: (json["price_per_month"] ?? 0).toDouble(),
      credits: json["credits"] ?? 0,
      durationDays: json["duration_days"] ?? 0,
      billingCycle: json["billing_cycle"] ?? "",
      features: (json["features"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      category: json['category'] ?? "whatsapp",
      isPopular: json["is_popular"] ?? false,
    );
  }
}
