class RobinKeys {
  final List<String> robinToken;
  final List<List<String>> displayName;
  final List<String>? profilePicture;

  RobinKeys({
    required this.robinToken,
    required this.displayName,
    this.profilePicture,
  });


  Map<String, dynamic> toJson() => {
        "robinToken": robinToken,
        "displayName": displayName,
        "profilePicture": profilePicture,
      };
}
