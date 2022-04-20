import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:mqtt_client/mqtt_browser_client.dart';

// import 'mqtt.dart';
late MqttServerClient client;
const userId = "user1";
const channelId = "28bfbcce-228a-42a0-8344-0720bd606db7";
const mqttHost = "192.168.1.39";
const mqttPort = 1883;
const mqttClientId = "client-bdf08da3";
String username = 'igor';
String password = 'p29041971';

external void log(
    String message, {
      DateTime? time,
      int? sequenceNumber,
      int level = 0,
      String name = '',
      Object? error,
      StackTrace? stackTrace,
    });

// connection succeeded
void onConnected() {
  print('\n\n\nConnected|');
}

// unconnected
void onDisconnected() {
  print('\n\n\nDisconnected|');
}

// subscribe to topic succeeded
void onSubscribed(String topic) {
  print('\n\n\nSubscribed topic: $topic|');
}

// subscribe to topic failed
void onSubscribeFail(String topic) {
  print('\n\n\nFailed to subscribe $topic|');
}

// unsubscribe succeeded
void onUnsubscribed(String? topic) {
  print('\n\n\nUnsubscribed topic: $topic|');
  // return('Unsubscribed topic: $topic');
}

// PING response received
void pong() {
  print('\n\n\nPing response client callback invoked|');
}

subscribe() async {
  client.subscribe("home/#", MqttQos.atLeastOnce);
}

unsubscribe() async {
  client.unsubscribe('home/#');
}

disconnect() async {
  client.disconnect();
}

publish() async {
  const pubTopic = 'home/#';
  final builder = MqttClientPayloadBuilder();
  builder.addString('Hello MQTT');
  client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);
}

Future<MqttServerClient> connect3() async {
  MqttServerClient client =
  MqttServerClient.withPort('broker.emqx.io', 'flutter_client', 1883);
  client.logging(on: true);
  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;
  client.onUnsubscribed = onUnsubscribed;
  client.onSubscribed = onSubscribed;
  client.onSubscribeFail = onSubscribeFail;
  client.pongCallback = pong;

  final connMessage = MqttConnectMessage()
      .authenticateAs('username', 'password')
      .keepAliveFor(60)
      .withWillTopic('willtopic')
      .withWillMessage('Will message')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMessage;
  try {
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    // final MqttPublishMessage message = c![0].payload;
    // final payload =
    // MqttPublishPayload.bytesToStringAsString(message.payload.message);

    print('Received message:payload from topic: ${c[0].topic}>');
  });

  return client;
}

connect2() async {
  print('connect2');
  client.logging(on: true);

  client.keepAlivePeriod = 60;

  client.onDisconnected = onDisconnected;

  client.onConnected = onConnected;

  client.onSubscribed = onSubscribed;

  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier('mqttx_498239')
  // .withWillTopic('house') // If you set this you must set a will message
  // .withWillMessage('1')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
  print('Mosquitto client connecting....');
  client.connectionMessage = connMess;
  String error_message = 'client exception - ';
  try {
    await client.connect(username, password);
  } on NoConnectionException catch (e) {
    // Raised by the client when connection fails.
    print('$error_message $e');
    client.disconnect();
  } on SocketException catch (e) {
    // Raised by the socket layer
    print('$error_message $e');
    client.disconnect();
  }

  /// Check we are connected
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('Mosquitto client connected');
  } else {
    /// Use status here rather than state if you also want the broker return code.
    print(
        'ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    // exit(-1);
  }

  /// Ok, lets try a subscription
  print('Subscribing to the house/cabinet/lamp/command0 topic');
  const topic = ' house/cabinet/lamp/command0'; // Not a wildcard topic
  client.subscribe(topic, MqttQos.atMostOnce);

  /// The client has a change notifier object(see the Observable class) which we then listen to to get
  /// notifications of published updates to each subscribed topic.
  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    String message = 'Change notification:: topic is ${c[0].topic}, payload is $pt';
    print(message);
    print('');
    // notifications.add(message);
  });

  print('Sleeping.....');
  await MqttUtilities.asyncSleep(120);

}


connect() async {
  print('first');

  MqttServerClient client =
  MqttServerClient('10.80.39.78', 'flutter_client');
  // final MqttServerClient client = MqttServerClient('ws://test.mosquitto.org', '');
  print('first2');
  client.logging(on: true);
  client.setProtocolV311();
  print('first3');
  client.onConnected = onConnected;
  print('first4');
  client.onDisconnected = onDisconnected;
  print('first5');
  client.onUnsubscribed = onUnsubscribed as UnsubscribeCallback?;
  print('first6');
  client.onSubscribed = onSubscribed;
  print('first7');
  client.onSubscribeFail = onSubscribeFail;
  print('first8');
  client.pongCallback = pong;
  print('first9');
  client.keepAlivePeriod = 60;
  print('first0');

  final connMessage = MqttConnectMessage()
      .authenticateAs('igor', 'p29041971')
      // .keepAliveFor(60)
      .withClientIdentifier('Mqtt_MyClientUniqueId')
      // .withWillTopic('home')
      // .withWillMessage('home')
      // .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  print('second0');
  client.connectionMessage = connMessage;
  print('second1');
  try {
    await client.connect(username, password);
  } on NoConnectionException catch (e) {
    // Raised by the client when connection fails.
    print('error_message $e');
    client.disconnect();
  } on SocketException catch (e) {
    // Raised by the socket layer
    print('error_message $e');
    client.disconnect();
  }

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    print('second4');
    final recMessage = c![0].payload as MqttPublishMessage;
    // final MqttPublishMessage publishMessage =  c[0].payload;
    final payload =
    MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
    // final ppayload =    MqttPublishPayload.bytesToStringAsString(publishMessage.payload.message);


    print('Received message:$payload from topic: ${c[0].topic}>');
  });

  // return client;
}


mqttSubscribe() async {
  client = MqttServerClient.withPort(mqttHost, mqttClientId, mqttPort);
  client.keepAlivePeriod = 30;
  client.autoReconnect = true;
  await client.connect().onError((error, stackTrace) {
    log("error -> " + error.toString());
  });

  client.onConnected = () {
    log('MQTT connected');
  };

  client.onDisconnected = () {
    log('MQTT disconnected');
  };

  client.onSubscribed = (String topic) {
    log('MQTT subscribed to $topic');
  };

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    client.subscribe("chat/#", MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      log("message payload => " + pt);

      // var box = Hive.box('messages');
      var doc = json.decode(utf8.decode(pt.codeUnits));
      // add to hivedb
      var message =
          '{"message" : "${doc["message"]}", "from" : "${doc["from"]}" ,"timeStamp" : "${doc["timeStamp"]}" }';
      // box.put(doc["timeStamp"], message);
    });
  }
}

mqttPublish({required String message}) async {
  final builder = MqttClientPayloadBuilder();
  var timeStamp = DateTime.now().microsecondsSinceEpoch.toString();
  var messagsString = '{"message" : "$message", "from" : "$userId" ,"timeStamp" : "$timeStamp" }';
  builder.addUTF8String(messagsString);
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    client.publishMessage('chat/$timeStamp', MqttQos.exactlyOnce, builder.payload!, retain: true);
  }
}