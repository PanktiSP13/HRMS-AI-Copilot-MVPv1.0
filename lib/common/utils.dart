class Utils {
  // 1. Private constructor
  Utils._();

  // 2. Static private instance
  static final Utils _instance = Utils._();

  // 3. Factory constructor returning the singleton instance
  factory Utils() => _instance;

  Map<String, dynamic> toMap(dynamic data) {
    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  List<Map<String, dynamic>> toList(dynamic data) {
    return (data as List)
        .map(
          (item) => Map<String, dynamic>.from(
            item as Map,
          ),
        )
        .toList();
  }
}
