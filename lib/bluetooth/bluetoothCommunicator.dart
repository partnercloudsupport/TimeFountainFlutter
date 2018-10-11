import 'package:flutter_blue/flutter_blue.dart';
import 'package:mutex/mutex.dart';
import 'dart:async';
import './errorCode.dart';

FlutterBlue flutterBlue = FlutterBlue.instance;

class BluetoothCommunicator {
  final BluetoothDevice _device;
  final Function _onError;
  List<Function> _onReceiveFunctions;
  var _deviceConnection;
  var _onValueChangeListener;
  bool _connected;
  Mutex _sendingMutex;
  BluetoothCharacteristic _rxTxCharacteristic;
  String _receivedData;

  BluetoothCommunicator(this._device, this._onError)
      : _connected = false,
        _onReceiveFunctions = new List<Function>(),
        _receivedData = "",
        _sendingMutex = new Mutex();

  void connect(Function onConnected) {
    var _onTimeoutListener =
        Future.delayed(new Duration(seconds: 5)).asStream().listen((val) {
      _onError(ErrorCode.error_timeout, null);
    });
    _deviceConnection = flutterBlue.connect(_device).listen((state) {
      if (state == BluetoothDeviceState.connected) {
        _device.discoverServices().then((services) async {
          _rxTxCharacteristic = null;
          services.forEach((service) {
            service.characteristics.forEach((characteristic) {
              if (characteristic.uuid ==
                  new Guid('0000ffe1-0000-1000-8000-00805f9b34fb')) {
                _rxTxCharacteristic = characteristic;
              }
            });
          });
          if (_rxTxCharacteristic == null) {
            disconnect();
            _onError(ErrorCode.error_characteristic_not_found, null);
            return;
          }
          _onTimeoutListener?.cancel();
          _onTimeoutListener = null;
          _onValueChangeListener =
              _device.onValueChanged(_rxTxCharacteristic).listen(_onData);
          await _device.setNotifyValue(_rxTxCharacteristic, true);
          _connected = true;
          Future.delayed(const Duration(milliseconds: 500))
              .then((val) => onConnected());
        });
      } else if (state == BluetoothDeviceState.disconnected) {
        _connected = false;
        _onError(ErrorCode.error_disconnected, null);
      }
    });
  }

  void disconnect() {
    _connected = false;
    _deviceConnection?.cancel();
    _deviceConnection = null;

    _onValueChangeListener?.cancel();
    _onValueChangeListener = null;
  }

  void send(String message, Function onReceive, [bool popStack = true]) async {
    if (!_connected || _rxTxCharacteristic == null) {
      _onError(ErrorCode.error_not_connected, message);
      return;
    }
    var timeoutFunction =
        Future.delayed(Duration(seconds: 10)).asStream().listen((val) {
      _onError(ErrorCode.error_timeout, null);
    });
    _onReceiveFunctions.add((String response) {
      timeoutFunction?.cancel();
      timeoutFunction = null;
      if (response.startsWith("OK:")) {
        var result = onReceive(response.split(':')[1]);
        if (result != null) {
          _onError(ErrorCode.error_response, "$response\n$result", popStack);
        }
      } else {
        _onError(ErrorCode.error_response, response, popStack);
      }
    });

    if (!message.endsWith('\n')) {
      message += '\n';
    }
    try {
      await _sendingMutex.acquire();

      print(message);

      List<int> data =
          message.split('').map<int>((str) => str.codeUnitAt(0)).toList();

      final tempListSize = 80;
      for (int i = 0;
          i <
              (data.length ~/ tempListSize) +
                  (data.length % tempListSize == 0 ? 0 : 1);
          ++i) {
        int start = i * tempListSize;
        int end = (i + 1) * tempListSize;
        if (end > data.length) {
          end = data.length;
        }

        List<int> tempData = data.sublist(start, end);
        await _device
            .writeCharacteristic(_rxTxCharacteristic, tempData,
                type: CharacteristicWriteType.withResponse)
            .timeout(new Duration(seconds: 5), onTimeout: () {
          _onError(ErrorCode.error_timeout, message);
        });
      }
    } catch (error) {
      _onError(ErrorCode.error_send, "$message\nerror message: $error");
    } finally {
      _sendingMutex.release();
    }
  }

  void _onData(List<int> data) {
    _receivedData += new String.fromCharCodes(data);
    int idx = -1;
    while ((idx = _receivedData.indexOf('\n')) > -1) {
      String response = _receivedData.substring(0, idx).trim();
      _receivedData = _receivedData.substring(idx + 1);
      if (_onReceiveFunctions.length > 0) {
        _onReceiveFunctions.elementAt(0)(response);
        _onReceiveFunctions.removeAt(0);
      } else {
        _onError(ErrorCode.error_no_handler_available, response, false);
      }
    }
  }
}
