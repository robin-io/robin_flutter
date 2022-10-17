class RobinKeys {
  final List<String> robinToken;
  final List<List<String>> displayName;
  final String? separator;
  final List<String>? profilePicture;

  RobinKeys(
      {required this.robinToken,
      required this.displayName,
      this.separator,
      this.profilePicture});

  Map<String, dynamic> toJson() => {
        "robinToken": robinToken,
        "displayName": displayName,
        "separator": separator,
        "profilePicture": profilePicture,
      };
}
