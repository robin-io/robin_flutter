class RobinUser {

  String fullName;
  String robinToken;

  RobinUser({
    required this.fullName,
    required this.robinToken,
  });

  factory RobinUser.fromJson(Map<String, dynamic> json) => RobinUser(
    fullName: json["fullName"],
    robinToken: json["robinToken"],
  );

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "robinToken": robinToken,
  };
}