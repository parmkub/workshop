import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workshop/model/device_model.dart';
import 'package:workshop/progress_dialog.dart';

import 'mqtt/client.dart';

class DisplaySensor extends StatefulWidget {
  final DeviceModel? device;
  const DisplaySensor({Key? key, this.device}) : super(key: key);

  @override
  State<DisplaySensor> createState() => _DisplaySensorState();
}

class _DisplaySensorState extends State<DisplaySensor> {
  DeviceClient? client;
  // String deviceId = '906629f7c630';

  double temperature = 0.0;
  double humidity = 0.0;
  int light = 0;
  int soil = 0;
  List<bool> switchs = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  Timer? timer;
  ProgressDialog? pr;

  void timeout(int value) {
    pr!.show();
    timer = Timer(Duration(milliseconds: value), () {
      if (pr!.isShowing()) {
        pr!.hide();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection timout'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void cancelTimer() {
    if (timer != null) {
      if (timer!.isActive) {
        timer!.cancel();
        if (pr!.isShowing()) {
          pr!.hide();
        }
      }
    }
  }

  void digitalWrite(bool value, int index) {
    timeout(3000);
    debugPrint('$value $index');
    Map<String, dynamic> payload = {'index': index};
    String topic = '';
    if (value) {
      topic = 'gpio/${widget.device!.deviceId}/on';
    } else {
      topic = 'gpio/${widget.device!.deviceId}/off';
    }
    client!.publishMessage(topic, json.encode(payload));
  }

  @override
  void dispose() {
    client!.unsubscribe('device/${widget.device!.deviceId}/notify');

    client!.unsubscribe('gpio/${widget.device!.deviceId}/read/result');
    client!.unsubscribe('gpio/${widget.device!.deviceId}/on/result');
    client!.unsubscribe('gpio/${widget.device!.deviceId}/off/result');

    super.dispose();
  }

  @override
  void initState() {
    temperature = widget.device!.datum!.temperature!;
    humidity = widget.device!.datum!.humidity!;
    light = widget.device!.datum!.light!;
    soil = widget.device!.datum!.soil!;
    pr = ProgressDialog(context, isDismissible: false);
    client != null;
    client = DeviceClient();
    client!.subscribe('device/${widget.device!.deviceId}/notify');
    client!.subscribe('device/${widget.device!.deviceId}/will');
    client!.subscribe('device/${widget.device!.deviceId}/checkin');

    client!.subscribe('gpio/${widget.device!.deviceId}/read/result');
    client!.subscribe('gpio/${widget.device!.deviceId}/on/result');
    client!.subscribe('gpio/${widget.device!.deviceId}/off/result');
    // Future.delayed(const Duration(milliseconds: 1000), () {
    //   client!.publishMessage('gpio/${widget.device!.deviceId}/read', '{}');
    // });

    client!.connect().then((value) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        client!.publishMessage('gpio/${widget.device!.deviceId}/read', '{}');
        client!.publishMessage(
            'device/${widget.device!.deviceId}/notify/read', '{}');
      });
    });

    // client!.status.listen((event) {
    //   if (event is DeviceNotifyEvent) {
    //     // debugPrint(json.encode(event.json!));
    //   }
    // });

    // client!.gpioNotify.listen((event) {
    //   debugPrint(json.encode(event.json!));
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var txtStyle = const TextStyle(fontSize: 24);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลจาก Sensor'),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 30, right: 30),
        // color: Colors.amber,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<Event>(
              stream: client!.status,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data is DeviceNotifyEvent) {
                    var dataMap = (snapshot.data! as DeviceNotifyEvent).json!;
                    temperature = dataMap['temperature'].toDouble();
                    humidity = dataMap['humidity'].toDouble();
                    light = dataMap['light'];
                    soil = dataMap['soil'];
                    if (!widget.device!.onlineStatus!) {
                      widget.device!.onlineStatus = true;
                    }
                  }
                  if (snapshot.data is DeviceWillEvent) {
                    widget.device!.onlineStatus = false;
                  }
                  if (snapshot.data is DeviceCheckinEvent) {
                    widget.device!.onlineStatus = true;
                    client!.publishMessage(
                        'gpio/${widget.device!.deviceId}/read', '{}');
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi,
                            size: 64,
                            color: widget.device!.onlineStatus!
                                ? Colors.green
                                : Colors.grey,
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('อุณหภูมิ', style: txtStyle),
                          Text(temperature.toStringAsFixed(1), style: txtStyle),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ความชื้นในอากาศ', style: txtStyle),
                          Text(humidity.toStringAsFixed(1), style: txtStyle),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ความเข้มแสง', style: txtStyle),
                          Text(light.toString(), style: txtStyle),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ความชื้นในดิน', style: txtStyle),
                          Text(soil.toString(), style: txtStyle),
                        ],
                      ),
                    ],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            const SizedBox(
              height: 30,
            ),
            StreamBuilder<GpioReadResultEvent>(
                stream: client!.gpioNotify,
                builder: (context, snapshot) {
                  List<Map<String, dynamic>> list = [];
                  if (snapshot.hasData) {
                    cancelTimer();
                    debugPrint(json.encode(snapshot.data!.json));
                    list = List<Map<String, dynamic>>.from(
                        snapshot.data!.json!['gpios']);
                    // 4CH
                    if (list.length == 4) {
                      for (var item in list) {
                        switchs[item['index']] = item['state'] == 1;
                      }
                    } else {
                      switchs[list[0]['index']] = list[0]['state'] == 1;
                    }
                    // 12 CH
                    if (list.length == 12) {
                      for (var i = 0; i < 12; i++) {
                        var item = list[i];
                        switchs[item['index']] = item['state'] == 1;
                      }
                    } else {
                      switchs[list[0]['index']] = list[0]['state'] == 1;
                    }
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CupertinoSwitch(
                        value: switchs[0],
                        onChanged: (val) {
                          digitalWrite(val, 0);
                        },
                      ),
                      CupertinoSwitch(
                        value: switchs[1],
                        onChanged: (val) {
                          digitalWrite(val, 1);
                        },
                      ),
                      CupertinoSwitch(
                        value: switchs[2],
                        onChanged: (val) {
                          digitalWrite(val, 2);
                        },
                      ),
                      CupertinoSwitch(
                        value: switchs[3],
                        onChanged: (val) {
                          digitalWrite(val, 3);
                        },
                      ),
                    ],
                  );
                })
          ],
        ),
      ),
    );
  }
}
