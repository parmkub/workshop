// To parse this JSON data, do
//
//     final device = deviceFromJson(jsonString);

import 'dart:convert';

DeviceModel deviceFromJson(String str) =>
    DeviceModel.fromJson(json.decode(str));

String deviceToJson(DeviceModel data) => json.encode(data.toJson());

class DeviceModel {
  DeviceModel({
    this.id,
    this.userId,
    this.deviceId,
    this.name,
    this.status,
    this.onlineStatus,
    this.updateTimestamp,
    this.datum,
  });

  int? id;
  int? userId;
  final String? deviceId;
  final String? name;
  final bool? status;
  bool? onlineStatus;
  final DateTime? updateTimestamp;
  DatumModel? datum;

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
        id: json["id"],
        userId: json["user_id"],
        deviceId: json["device_id"],
        name: json["name"],
        status: json["status"],
        onlineStatus: json["online_status"],
        updateTimestamp: DateTime.parse(json["updateTimestamp"]),
        datum: json["datum"] != null
            ? DatumModel.fromJson(json["datum"])
            : DatumModel(
                id: 0, temperature: 0.0, humidity: 0.0, soil: 0, light: 0),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "device_id": deviceId,
        "name": name,
        // "status": status,
        // "online_status": onlineStatus,
        // "updateTimestamp": updateTimestamp!.toIso8601String(),
        // "datum": datum != null ? datum!.toJson() : null,
      };
}

class DatumModel {
  DatumModel({
    this.id,
    this.temperature,
    this.humidity,
    this.light,
    this.soil,
    this.updateTimestamp,
    this.deviceId,
  });

  final int? id;
  double? temperature;
  double? humidity;
  int? light;
  int? soil;
  final DateTime? updateTimestamp;
  final int? deviceId;

  factory DatumModel.fromJson(Map<String, dynamic> json) => DatumModel(
        id: json["id"],
        temperature: json["temperature"].toDouble(),
        humidity: json["humidity"].toDouble(),
        light: json["light"],
        soil: json["soil"],
        updateTimestamp: DateTime.parse(json["updateTimestamp"]),
        deviceId: json["deviceId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "temperature": temperature,
        "humidity": humidity,
        "light": light,
        "soil": soil,
        "updateTimestamp": updateTimestamp!.toIso8601String(),
        "deviceId": deviceId,
      };
}
