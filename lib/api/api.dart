// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/gpio_model.dart';
import '../model/device_model.dart';

// const API_BASE_URL = '167.71.223.60:3002';
const API_BASE_URL = '10.2.1.55:3000';
// const API_BASE_URL = '188.166.220.211:8082';
const API_VERSION = '/v1';
String? jwtToken;
int? userId;
String? fullName = '';
SharedPreferences? prefs;

class Api {
  static final Api _singleton = Api._internal();
  static const String TOKEN_KEY = 'TOKEN';
  static const String USER_KEY = 'U_ID';
  static const String NAME_KEY = 'NAME_ID';
  factory Api() => _singleton;
  Api._internal() {
    // print('-----------> Api._internal');
  }

  bool hasToken() {
    bool _has = jwtToken != null;
    return _has;
  }

  Future<bool> clear() async {
    await prefs!.clear();
    return true;
  }

  Future<bool> getToken() async {
    prefs = await SharedPreferences.getInstance();
    jwtToken = prefs!.getString(TOKEN_KEY);
    userId = prefs!.getInt(USER_KEY);
    fullName = prefs!.getString(NAME_KEY);
    return jwtToken != null;
  }

  Future<void> pushToken(Map<String, dynamic> json) async {
    prefs ??= await SharedPreferences.getInstance();
    jwtToken = json['token'];
    userId = json['id'];
    fullName = '${json['first_name']} ${json['last_name']}';
    await prefs!.setInt(USER_KEY, userId!);
    await prefs!.setString(TOKEN_KEY, jwtToken!);
    await prefs!.setString(NAME_KEY, fullName!);
  }

  Future<bool> login(String userName, String password) async {
    try {
      var body = json.encode({"email": userName, "password": password});
      var url = Uri.http(API_BASE_URL, '$API_VERSION/login');
      final response = await http.post(url, body: body, headers: {
        'Content-type': 'application/json; charset=utf-8',
        'Accept': 'application/json'
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> _json = json.decode(response.body)['data'];
        debugPrint(_json.toString());
        await pushToken(_json);
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception('Failed to login user $userName');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<bool> register(String firstName, String lastName, String userName,
      String password) async {
    try {
      var body = json.encode({
        "first_name": firstName,
        "last_name": lastName,
        "email": userName,
        "password": password
      });
      var url = Uri.http(API_BASE_URL, '$API_VERSION/register');
      final response = await http.post(url, body: body, headers: {
        'Content-type': 'application/json; charset=utf-8',
        'Accept': 'application/json'
      });
      if (response.statusCode == 201) {
        Map<String, dynamic> _json = json.decode(response.body);
        // print(_json);
        return _json['result'];
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception('Failed to register user $userName');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<List<DeviceModel>?> getDevices() async {
    var url = Uri.http(API_BASE_URL, '$API_VERSION/devices/$userId');
    var _headers = {
      'Content-type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'x-access-token': jwtToken!
    };
    final response = await http.get(url, headers: _headers);
    Map<String, dynamic> _dataMap;
    if (response.statusCode == 200) {
      debugPrint(response.body);

      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);

      List<DeviceModel> innerList =
          list.map((e) => DeviceModel.fromJson(e)).toList();

      return innerList;
    } else if (response.statusCode == 403) {
      _dataMap = Map<String, dynamic>.from(json.decode(response.body));
      debugPrint(_dataMap['data']);
      throw Exception(_dataMap['data']);
    }

    return [];
  }

  Future<List<GpioModel>> getGpios(int deviceId) async {
    var url = Uri.http(API_BASE_URL, '$API_VERSION/gpios/$deviceId');
    var _headers = {
      'Content-type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'x-access-token': jwtToken!
    };
    final response = await http.get(url, headers: _headers);
    Map<String, dynamic> _dataMap;
    if (response.statusCode == 200) {
      debugPrint(response.body);

      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);

      List<GpioModel> innerList =
          list.map((e) => GpioModel.fromJson(e)).toList();
      return innerList;
    } else if (response.statusCode == 403) {
      _dataMap = Map<String, dynamic>.from(json.decode(response.body));
      debugPrint(_dataMap['data']);
      throw Exception(_dataMap['data']);
    }

    return [];
  }

  Future<GpioModel?> postGpio(int deviceId, GpioModel gpio) async {
    var url = Uri.http(API_BASE_URL, '$API_VERSION/gpio');
    var _headers = {
      'Content-type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'x-access-token': jwtToken!
    };
    gpio.userId = userId;
    gpio.deviceId = deviceId;
    var body = jsonEncode(gpio.toJson());
    final response = await http.post(url, body: body, headers: _headers);
    Map<String, dynamic>? _dataMap =
        Map<String, dynamic>.from(json.decode(response.body));
    if (response.statusCode == 201) {
      if (_dataMap['result'] == true) {
        return GpioModel.fromJson(_dataMap['data']);
      }
    } else if (response.statusCode == 400) {
      debugPrint(_dataMap['data']);
      throw Exception(_dataMap['data']);
    } else if (response.statusCode == 500) {
      debugPrint(_dataMap['data']);
      throw Exception(_dataMap['data']);
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateGpio(GpioModel gpio) async {
    var url = Uri.http(API_BASE_URL, '$API_VERSION/gpio');
    var _headers = {
      'Content-type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'x-access-token': jwtToken!
    };

    var body = json.encode(gpio.toJson());
    debugPrint(body);
    final response = await http.put(url, body: body, headers: _headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> _dataMap =
          Map<String, dynamic>.from(json.decode(response.body));
      return _dataMap;
    }
    return null;
  }

  // น้ำหยด
  Future<Map<String, dynamic>?> deleteGpio(GpioModel gpio) async {
    var url = Uri.http(API_BASE_URL, '$API_VERSION/gpio');
    var _headers = {
      'Content-type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'x-access-token': jwtToken!
    };
    var body = json.encode({'user_id': userId, 'id': gpio.id!});
    debugPrint(body);
    final response = await http.delete(url, body: body, headers: _headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> _dataMap =
          Map<String, dynamic>.from(json.decode(response.body));
      return _dataMap;
    }
    return null;
  }

  Future<DeviceModel?> postDevice(DeviceModel device) async {
    var url = Uri.http(API_BASE_URL, '$API_VERSION/device');
    var _headers = {
      'Content-type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'x-access-token': jwtToken!
    };
    device.userId = userId;
    var body = jsonEncode(device.toJson());
    final response = await http.post(url, body: body, headers: _headers);
    Map<String, dynamic>? _dataMap =
        Map<String, dynamic>.from(json.decode(response.body));
    if (response.statusCode == 201) {
      if (_dataMap['result'] == true) {
        return DeviceModel.fromJson(_dataMap['data']);
      }
    } else if (response.statusCode == 400) {
      debugPrint(_dataMap['data']);
      throw Exception(_dataMap['data']);
    } else if (response.statusCode == 500) {
      debugPrint(_dataMap['data']);
      throw Exception(_dataMap['data']);
    }
    return null;
  }

  Future<DeviceModel?> updateDevice(DeviceModel device) async {
    var url = Uri.http(API_BASE_URL, '$API_VERSION/device');
    var _headers = {
      'Content-type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'x-access-token': jwtToken!
    };

    var body = json.encode(device.toJson());
    final response = await http.put(url, body: body, headers: _headers);
    if (response.statusCode == 200) {
      DeviceModel _dataMap =
          DeviceModel.fromJson(json.decode(response.body)['data']);
      return _dataMap;
    }
    return null;
  }

  Future<Map<String, dynamic>?> deleteDevice(DeviceModel device) async {
    var url = Uri.http(API_BASE_URL, '$API_VERSION/device');
    var _headers = {
      'Content-type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'x-access-token': jwtToken!
    };
    var body = json.encode(device);
    final response = await http.delete(url, body: body, headers: _headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> _dataMap =
          Map<String, dynamic>.from(json.decode(response.body));
      return _dataMap;
    }
    return null;
  }
}
