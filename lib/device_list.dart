import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:workshop/device_form.dart';
import 'package:workshop/display_sensor.dart';
import 'package:workshop/model/device_model.dart';
import 'package:workshop/mqtt/client.dart';
import 'api/api.dart';
import 'package:location/location.dart';

import 'login.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({Key? key}) : super(key: key);

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  DeviceClient? client;
  // 4a7401363b53fcc52892b4ece69c8b36
  final String weatherApiKey = '26dc1660f742cf14655c7ccf6bfe854c';
  final StreamController<Weather> _weatherNotify =
      StreamController<Weather>.broadcast();
  late WeatherFactory wf;

  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  bool? _serviceEnable;
  Location location = Location();

  final Map<String, Image> _weatherIcon = {
    "01d": Image.asset('assets/01d.png'),
    '02d': Image.asset('assets/02d.png'),
    "03d": Image.asset('assets/03d.png'),
    '04d': Image.asset('assets/04d.png'),
    '09d': Image.asset('assets/09d.png'),
    '10d': Image.asset('assets/10d.png'),
    '11d': Image.asset('assets/11d.png'),
    '01n': Image.asset('assets/01n.png'),
    '02n': Image.asset('assets/02n.png'),
    '03n': Image.asset('assets/03n.png'),
    '04n': Image.asset('assets/04n.png'),
    '09n': Image.asset('assets/09n.png'),
    '10n': Image.asset('assets/10n.png'),
    '11n': Image.asset('assets/11n.png')
  };

  Future<void> getLoaction() async {
    _serviceEnable = await location.serviceEnabled();
    if (!_serviceEnable!) {
      _serviceEnable = await location.requestService();
      if (!_serviceEnable!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }

  void queryWeather() async {
    try {
      await getLoaction();
      if (_permissionGranted == PermissionStatus.granted) {
        Weather weather = await wf.currentWeatherByLocation(
            _locationData!.latitude!, _locationData!.longitude!);
        debugPrint(weather.toString());
        _weatherNotify.add(weather);
      } else {
        debugPrint('Weather query error');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool?> showConfirmDialog(BuildContext context) {
    Widget yesButton = TextButton(
        onPressed: () {
          Navigator.of(context).pop(true);
        },
        child: const Text('YES'));

    Widget noButton = TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: const Text('NO'));

    AlertDialog dialog = AlertDialog(
      title: const Text('Confirm'),
      content: const Text('Logout?'),
      actions: [yesButton, noButton],
    );

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return dialog;
      },
    );
  }

  @override
  void initState() {
    wf = WeatherFactory(weatherApiKey, language: Language.THAI);
    queryWeather();
    Timer.periodic(const Duration(minutes: 5), (timer) {
      queryWeather();
    });
    client = DeviceClient();
    super.initState();
  }

  Future<List<DeviceModel>?> _get() async {
    var list = await Api().getDevices();
    await client!.connect();

    for (var model in list!) {
      client!.subscribe('device/${model.deviceId}/will');
      client!.subscribe('device/${model.deviceId}/checkin');
      // nn
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการอุปกรณ์'),
        actions: [
          IconButton(
            onPressed: () async {
              var result = await showConfirmDialog(context);
              if (result == true) {
                if (await Api().clear()) {
                  Navigator.of(context).pushReplacement(LoginPage.route());
                }
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .23,
            child: StreamBuilder<Weather>(
                stream: _weatherNotify.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _weatherIcon[snapshot.data!.weatherIcon!]!,
                            Column(
                              children: [
                                Text(snapshot.data!.areaName!,
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white)),
                                Text(
                                    snapshot.data!.temperature!.celsius!
                                        .toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 28,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                Text(snapshot.data!.weatherDescription!,
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white)),
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                const Text('Humidity',
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                  snapshot.data!.humidity!.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Temp (min)',
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                  snapshot.data!.tempMin!.celsius!
                                      .toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Temp (max)',
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                  snapshot.data!.tempMax!.celsius!
                                      .toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Wind Speed',
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                  snapshot.data!.windSpeed.toString(),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white),
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }),
          ),
          Expanded(
            child: FutureBuilder<List<DeviceModel>?>(
              future: _get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      var model = snapshot.data![index];
                      return StreamBuilder<Event>(
                          stream: client!.status,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var e = snapshot.data;
                              if (e is DeviceWillEvent) {
                                if (e.deviceId == model.deviceId) {
                                  model.onlineStatus = false;
                                }
                              }
                              if (e is DeviceCheckinEvent) {
                                if (e.deviceId == model.deviceId) {
                                  model.onlineStatus = true;
                                }
                              }
                            }

                            return ListTile(
                              title: Text(model.name!),
                              subtitle: Text(model.deviceId!),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DisplaySensor(device: model),
                                  ),
                                );
                              },
                              onLongPress: () async {
                                var result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DeviceForm(model: model),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {});
                                }
                              },
                              trailing: model.onlineStatus!
                                  ? const Icon(Icons.check)
                                  : const Icon(Icons.close),
                            );
                          });
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const DeviceForm()));
          if (result != null) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
