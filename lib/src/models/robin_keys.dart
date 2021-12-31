class RobinKeys {
  final List<String> robinToken;
  final List<List<String>> displayName;
  final String? separator;

  RobinKeys({
    required this.robinToken,
    required this.displayName,
    this.separator,
  });

  Map<String, dynamic> toJson() => {
        "robinToken": robinToken,
        "displayName": displayName,
        "separator": separator,
      };
}
