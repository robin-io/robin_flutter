class RobinCurrentUser {

  String fullName;
  String robinToken;

  RobinCurrentUser({
    required this.fullName,
    required this.robinToken,
  });

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "robinToken": robinToken,
  };
}

