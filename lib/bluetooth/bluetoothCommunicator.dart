import 'package:flutter_blue/flutter_blue.dart';

class BluetoothCommunicator {
  Function _onErrorOrDisconnect;
  List<Function> _onReceiveFunctions;

  BluetoothCommunicator(this._onErrorOrDisconnect);

  void connect(BluetoothDevice device) {

  }

  void disconnect() {

  }

  void pause() {

  }

  void resume() {
    
  }

  void send(String data, Function onReceive) {

  }
}