part of 'client.dart';

abstract class Event {}

class DeviceNotifyEvent extends Event {
  final String? deviceId;
  final Map<String, dynamic>? json;

  DeviceNotifyEvent({this.deviceId, this.json});
}

class GpioReadResultEvent extends Event {
  final String? deviceId;
  final Map<String, dynamic>? json;

  GpioReadResultEvent({this.deviceId, this.json});
}

class DeviceConnectedEvent extends Event {}

class DeviceDisconnectedEvent extends Event {}

class GpioOffEvent extends Event {
  final String? deviceId;
  final Map<String, dynamic>? json;

  GpioOffEvent({this.deviceId, this.json});
}

class GpioOnEvent extends Event {
  final String? deviceId;
  final Map<String, dynamic>? json;

  GpioOnEvent({this.deviceId, this.json});
}

class DeviceWillEvent extends Event {
  final String? deviceId;
  DeviceWillEvent({this.deviceId});
}

class DeviceCheckinEvent extends Event {
  final String? deviceId;
  final Map<String, dynamic>? json;

  DeviceCheckinEvent({this.deviceId, this.json});
}
