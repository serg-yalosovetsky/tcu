
import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'mqtt2.dart';

/// An annotated simple subscribe/publish usage example for mqtt_server_client. Please read in with reference
/// to the MQTT specification. The example is runnable, also refer to test/mqtt_client_broker_test...dart
/// files for separate subscribe/publish tests.
/// First create a client, the client is constructed with a broker name, client identifier
/// and port if needed. The client identifier (short ClientId) is an identifier of each MQTT
/// client connecting to a MQTT broker. As the word identifier already suggests, it should be unique per broker.
/// The broker uses it for identifying the client and the current state of the client. If you don’t need a state
/// to be hold by the broker, in MQTT 3.1.1 you can set an empty ClientId, which results in a connection without any state.
/// A condition is that clean session connect flag is true, otherwise the connection will be rejected.
/// The client identifier can be a maximum length of 23 characters. If a port is not specified the standard port
/// of 1883 is used.
/// If you want to use websockets rather than TCP see below.
String base_server = '10.80.39.78';
String base_port = '';
late var client = MqttServerClient(base_server, base_port);
List<List<String>> list_notifications = [['','']];
List<String> notifications = [];

var pongCount = 0; // Pong counter
const topic = 'house/#'; // Not a wildcard topic
const pubTopic = 'Dart/Mqtt_client/testtopic';
const pubMessage = 'Hello from mqtt_client';
const client_id = 'Mqtt_MyClientUniqueId';
const will_topic = 'willtopic';
const will_message = 'My Will message';


Future<int> to_connect([
                        String? _server,
                        String? _port,
                        String? _client_id,
                        String? _will_topic,
                        String? _will_message,
                                              ]) async {

  if (_server == null || _server == '')
     _server = base_server;
  if (_port == null || _port == '')
    _port = base_port;
  if (_client_id == null || _client_id == '')
    _client_id = client_id;
  if (_will_topic == null || _will_topic == '')
    _will_topic = will_topic;
  if (_will_message == null || _will_message == '')
    _will_message = will_message;

  if (_server != base_server  ||  _port != base_port) {
    client = MqttServerClient(_server, _port);
    print('change client to $_server $_port');
  }
  client.logging(on: false);

  client.setProtocolV311();

  client.keepAlivePeriod = 20;

  client.onDisconnected = onDisconnected;

  client.onConnected = onConnected;

  client.onSubscribed = onSubscribed;

  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier(_client_id)
      .withWillTopic(_will_topic) // If you set this you must set a will message
      .withWillMessage(_will_message)
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
  print('EXAMPLE::Mosquitto client connecting....');
  client.connectionMessage = connMess;

  try {
    await client.connect(username, password);
  } on NoConnectionException catch (e) {
    print('EXAMPLE::client exception - $e');
    client.disconnect();
  } on SocketException catch (e) {
    print('EXAMPLE::socket exception - $e');
    client.disconnect();
  }

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('EXAMPLE::Mosquitto client connected');
  } else {
    print(
        'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    exit(-1);
  }

  return 0;
}



// Stream<List<String>> createAsyncGenerator(var work) async* {
//   String message = '';
//   String topic = '';
//   while (work) {
//     try{
//           client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//           final recMess = c![0].payload as MqttPublishMessage;
//           final pt =
//           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
//
//           print(
//               'asyncgen::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
//           print('');
//           // if (client.connectionStatus!.state == MqttConnectionState.connected) {
//             topic = c[0].topic;
//             message = pt;
//           });
//     }
//     catch (e) {
//       print('error');
//     }
//     yield [topic, message];
//   }
// }
//
var topicStream = client.updates;
// // final mystream = NumberCreator().stream()
//
// Stream<List<String>> publishStream() async* {
//
//   yield* StreamT ;
// }

Future<int> subscript([String topic = '/house/#']) async {

  /// Ok, lets try a subscription
  if (topic == '')
    topic = 'house/#';
  print('EXAMPLE::Subscribing to the $topic topic');
  client.subscribe(topic, MqttQos.atMostOnce);

  // / The client has a change notifier object(see the Observable class) which we then listen to to get
  // / notifications of published updates to each subscribed topic.
  //

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print(
        'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    print('');
    list_notifications.add([c[0].topic, pt]);
  });

  return 0;
}


Future<int> publish([String? _topic, String? _message]) async {
  _topic ??= pubTopic as String;
  _message ??= 'Hello from mqtt_client' as String;

  /// If needed you can listen for published messages that have completed the publishing
  /// handshake which is Qos dependant. Any message received on this stream has completed its
  /// publishing handshake with the broker.

  if (client.published != null)
  client.published!.listen((MqttPublishMessage message) {
    print(
        'EXAMPLE::Published notification:: topic is ${message.variableHeader!
            .topicName}, with Qos ${message.header!.qos}');
  });

  /// Lets publish to our topic
  /// Use the payload builder rather than a raw buffer
  /// Our known topic to publish to
  final builder = MqttClientPayloadBuilder();
  builder.addString(_message);

  /// Subscribe to it
  print('EXAMPLE::Subscribing to the $_topic topic');
  client.subscribe(_topic, MqttQos.exactlyOnce);

  /// Publish it
  print('EXAMPLE::Publishing our topic');
  client.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);

  /// Ok, we will now sleep a while, in this gap you will see ping request/response
  /// messages being exchanged by the keep alive mechanism.
  print('EXAMPLE::Sleeping....');
  await MqttUtilities.asyncSleep(60);

  return 0;
}

Future<int> unsubscribe() async {

  /// Finally, unsubscribe and exit gracefully
  print('EXAMPLE::Unsubscribing');
  client.unsubscribe(topic);

  /// Wait for the unsubscribe message from the broker if you wish.
  await MqttUtilities.asyncSleep(2);
  print('EXAMPLE::Disconnecting');
  return 0;
}


Future<int> disconnect() async {
  print('EXAMPLE::Disconnecting');
  client.disconnect();
  print('EXAMPLE::Exiting normally');
  return 0;
}


// Stream<String> _clock() async* {
//   // This loop will run forever because _running is always true
//   while (true) {
//     await Future<void>.delayed(const Duration(milliseconds: 100));
//
//     client.updates!.listen((c) async
//     { final recMess = c[0].payload as MqttPublishMessage;
//     notifications = await [
//       '${c[0].topic}',
//       '${MqttPublishPayload.bytesToStringAsString(recMess.payload.message)}'
//     ]; });
//     yield " topic: ${notifications[0]} \n\n message: ${notifications[1]}";
//   }
// }
//










/// The subscribed callback
void onSubscribed(String topic) {
  print('EXAMPLE::Subscription confirmed for topic $topic');
}

/// The unsolicited disconnect callback
void onDisconnected() {
  print('EXAMPLE::OnDisconnected client callback - Client disconnection');
  if (client.connectionStatus!.disconnectionOrigin ==
      MqttDisconnectionOrigin.solicited) {
    print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
  } else {
    print(
        'EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
    exit(-1);
  }
  if (pongCount == 3) {
    print('EXAMPLE:: Pong count is correct');
  } else {
    print('EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
  }
}

/// The successful connect callback
void onConnected() {
  print(
      'EXAMPLE::OnConnected client callback - Client connection was successful');
}

/// Pong callback
void pong() {
  print('EXAMPLE::Ping response client callback invoked');
  pongCount++;
}