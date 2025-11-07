class SavedFilterList {
  final String id;
  final String name;
  final Map<String, dynamic> filters;
  final int customerCount;

  SavedFilterList({
    required this.id,
    required this.name,
    required this.filters,
    required this.customerCount,
  });

  factory SavedFilterList.fromJson(Map<String, dynamic> json) {
    return SavedFilterList(
      id: json['id'],
      name: json['name'],
      filters: json['filters'] as Map<String, dynamic>,
      customerCount: (json['customer_count'] as num?)?.toInt() ?? 0,
    );
  }
}