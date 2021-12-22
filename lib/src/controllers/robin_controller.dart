import 'package:get/get.dart';
import 'package:robin_flutter/src/utils/core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RobinController extends GetxController {
  late final RobinCore robinCore;
  late final WebSocketChannel robinConnection;
  late final String apiKey;
  late final Map currentUser;
  late final Function getUsers;
  late final Map keys;

  initializeController(String apiKey, Map currentUser, Function getUsers, Map keys) {
    apiKey = apiKey;
    currentUser = currentUser;
    getUsers = getUsers;
    keys = keys;
    robinCore = RobinCore();
    robinConnection = robinCore.connect(apiKey, currentUser['userToken']);
  }
}
