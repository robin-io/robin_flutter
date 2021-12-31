class RobinUser {

  String displayName;
  String robinToken;

  RobinUser({
    required this.displayName,
    required this.robinToken,
  });

  Map<String, dynamic> toJson() => {
    "meta_data": {
      'display_name': displayName
    },
    "user_token": robinToken,
  };
}

