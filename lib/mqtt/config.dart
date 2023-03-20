part of 'client.dart';

class BrokerConfig {
  String broker = '167.71.223.60';
  int port = 1883;
  String username = 'test-01';
  String passwd = 'pwd01';
  String clientIdentifier = '';

  BrokerConfig() {
    var uuid = const Uuid();
    clientIdentifier = uuid.v4();
    print('[MQTT Client] client id: $clientIdentifier');
  }
}
