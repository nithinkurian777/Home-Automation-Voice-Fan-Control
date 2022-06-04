import 'package:flutter/cupertino.dart';
import 'package:home_automation/models/message_model.dart';

class MQTTModel with ChangeNotifier {
  var _message = <Messages>[];

  List<Messages> get message => _message;

  void addMessage(Messages message) {
    _message.add(message);
    notifyListeners();
  }

  Messages _log = Messages();

  Messages get log => _log;

  void setMessage(Messages message) {
    _log = message;
    notifyListeners();
  }
}
