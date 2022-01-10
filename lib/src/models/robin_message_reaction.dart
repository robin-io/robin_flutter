class RobinMessageReaction {
  late final String id;
  late final String type;

  RobinMessageReaction.fromJson(Map json) {
    id = json['_id'];
    type = json['reaction'];
  }
}
