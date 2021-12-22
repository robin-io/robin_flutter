class RobinKeys {

  final List<String> robinToken;
  final List<List<String>> displayName;
  final List<String> profilePicture;

  RobinKeys({
    required this.robinToken,
    required this.displayName,
    required this.profilePicture,
  });

  factory RobinKeys.fromJson(Map<String, dynamic> json) => RobinKeys(
    robinToken: List<String>.from(json["robinToken"].map((x) => x)),
    displayName: List<List<String>>.from(json["displayName"].map((x) => List<String>.from(x.map((x) => x)))),
    profilePicture: List<String>.from(json["profilePicture"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "robinToken": List<dynamic>.from(robinToken.map((x) => x)),
    "displayName": List<dynamic>.from(displayName.map((x) => List<dynamic>.from(x.map((x) => x)))),
    "profilePicture": List<dynamic>.from(profilePicture.map((x) => x)),
  };
}
