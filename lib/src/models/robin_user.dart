class RobinUser {

  String displayName;
  String robinToken;
  String? profilePicture;

  RobinUser({
    required this.displayName,
    required this.robinToken,
    this.profilePicture
  });

  Map<String, dynamic> toJson() => {
    "meta_data": {
      'display_name': displayName
    },
    "user_token": robinToken,
    "profile_picture": profilePicture,
  };
}

