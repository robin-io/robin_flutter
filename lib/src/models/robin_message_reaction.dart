class RobinMessageReaction {
  late final String id;
  late final String userToken;
  late final String type;
  int number = 1;

  RobinMessageReaction.fromJson(Map json) {
    id = json['_id'];
    userToken = json['user_token'];
    type = json['reaction'];
  }
}
