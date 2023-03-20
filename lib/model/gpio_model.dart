class GpioModel {
  int? id;
  int? userId;
  int? deviceId;
  bool? state;
  int? index;
  final String? title;
  final String? subTitle;
  GpioModel(
      {this.id,
      this.userId,
      this.deviceId,
      this.title,
      this.subTitle,
      this.index,
      this.state});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "deviceId": deviceId,
      "userId": userId,
      "index": index,
      "title": title,
      "subTitle": subTitle,
      "state": state
    };
  }

  factory GpioModel.fromJson(Map<String, dynamic> json) {
    return GpioModel(
      id: json['id'],
      userId: json['user_id'],
      index: json['index'],
      title: json['title'],
      subTitle: json['subTitle'],
      state: json['state'] == 1,
    );
  }
}
