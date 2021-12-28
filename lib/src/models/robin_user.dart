class RobinUser {

  String fullName;
  String robinToken;

  RobinUser({
    required this.fullName,
    required this.robinToken,
  });

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "robinToken": robinToken,
  };
}

