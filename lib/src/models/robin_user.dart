class RobinUser {

  String displayName;
  String robinToken;

  RobinUser({
    required this.displayName,
    required this.robinToken,
  });

  Map<String, dynamic> toJson() => {
    "displayName": displayName,
    "robinToken": robinToken,
  };
}

