import 'package:flutter/material.dart';
import 'package:workshop/api/api.dart';
import 'package:workshop/model/device_model.dart';

class DeviceForm extends StatefulWidget {
  final DeviceModel? model;
  const DeviceForm({Key? key, this.model}) : super(key: key);

  @override
  State<DeviceForm> createState() => _DeviceFormState();
}

class _DeviceFormState extends State<DeviceForm> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final formKeyState = GlobalKey<FormState>();

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
      content: const Text('Delete?'),
      actions: [yesButton, noButton],
    );

    return showDialog<bool>(
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  @override
  void initState() {
    if (widget.model != null) {
      idController.text = widget.model!.deviceId!;
      nameController.text = widget.model!.name!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Form'),
        actions: widget.model != null
            ? [
                IconButton(
                    onPressed: () async {
                      var result = await showConfirmDialog(context);
                      if (result == true) {
                        debugPrint('delete device');
                        var model = await Api().deleteDevice(widget.model!);
                        Navigator.of(context).pop(model);
                      }
                    },
                    icon: const Icon(Icons.delete)),
              ]
            : [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/register.png',
                  width: MediaQuery.of(context).size.width * .5,
                ),
                Form(
                  key: formKeyState,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: idController,
                        decoration: const InputDecoration(
                          labelText: 'หมายเลขอุปกรณ์',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณาป้อนหมายเลขอุปกรณ์';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'ชื่ออุปกรณ์',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณาป้อชื่ออุปกรณ์';
                          }
                          return null;
                        },
                      ),
                      // const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: ElevatedButton(
                          onPressed: () async {
                            FocusManager.instance.primaryFocus!.unfocus();
                            if (formKeyState.currentState!.validate()) {
                              DeviceModel model = DeviceModel(
                                id: widget.model != null
                                    ? widget.model!.id
                                    : null,
                                deviceId: idController.text,
                                name: nameController.text,
                              );
                              DeviceModel? result;
                              if (widget.model == null) {
                                result = await Api().postDevice(model);
                              } else {
                                result = await Api().updateDevice(model);
                              }
                              Navigator.of(context).pop(result);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Input Error'),
                                ),
                              );
                            }
                          },
                          child: const Text('บันทึกข้อมูล'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
