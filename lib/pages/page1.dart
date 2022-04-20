import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tcu/widgets/components.dart';
// import 'dart:html';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:tcu/mqtt2.dart' as mqtt;
import 'package:tcu/mqtt3.dart' as mqtt3;
import 'package:tcu/mqtt3.dart' show topicStream, publishStream;

import '../mqtt2.dart';
// import 'package:tcu/mqtt.dart' show get_notifications;

// void main() {
//   runApp(const Page1());
// }

const String title1 = "mqtt";
var client ;

class MQTTScreen extends StatefulWidget {
  const MQTTScreen({Key? key }) : super(key: key);


  @override
  _MQTTScreenState createState() => _MQTTScreenState();
}

class _MQTTScreenState extends State<MQTTScreen> {
  final bool _running = true;
  List notifications = [];
  var item;
  Stream<String> _clock() async* {
    // This loop will run forever because _running is always true
    while (_running) {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // await  mqtt3.client.updates!.single.whenComplete(() => null) ;
      // DateTime _now = DateTime.now();
      // This will be displayed on the screen as current time
      // mqtt3.client.updates!.listen((c) {notifications.add('${c[0].topic}'); });
      mqtt3.client.updates!.listen((c) async
            { final recMess = c[0].payload as MqttPublishMessage;
              notifications = await [
                  '${c[0].topic}',
                  '${MqttPublishPayload.bytesToStringAsString(recMess.payload.message)}'
                                ]; });
      yield " topic: ${notifications[0]} \n\n message: ${notifications[1]}";
    }
  }
  String? user_todo;
  List todo_list = [];
  String broker           = 'abc.cloudmqtt.com';
  int port                = 13372;
  String username         = 'seu_username';
  String passwd           = 'seu_password';
  String clientIdentifier = 'android';
  double _temp = 20;
  late var connectionState;
  // MqttClient client;
  // MqttConnectionState connectionState;
  // StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    // box = Hive.box('messages');
    //box.clear();
    // mqttSubscribe();
  }

  @override
  Widget build(BuildContext context) {
  bool work = false;

    void _connect() {
      mqtt3.main();
      // connectionState = await client.connectionState;
    }
    var notifications = '0';

    void _subscript() {
      setState(() {
        mqtt3.topicStream!.listen(
                (data) {
              // final recMess = data![0].payload as MqttPublishMessage;
              //  var message =
              // MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
                notifications = '${data[0].topic} ';
            }
        );
        mqtt3.subscript();
      });
          // connectionState = await client.connectionState;
    }

    void _publish() {setState(() {
       mqtt3.publish();});}
    void _unsubscribe() {setState(() {
       mqtt3.unsubscribe() ;}
    );}
    void _disconnect() {setState(() {
      mqtt3.disconnect() ;
      work = true;
    }
    );}


    // var widgets = <Widget>[
    //   Text(
    //     notifications.toString(),
    //   ),
    // ];

    var add_button = FloatingActionButton(
      // onPressed: show_dialog,
      onPressed: _connect,
      tooltip: 'Connect',
      heroTag: 'add_button',
      child: Icon(
        Icons.add_box,
      ),
    );
    var connect_button = FloatingActionButton(
      onPressed: _subscript,
      tooltip: 'subscript',
      heroTag: 'connect_button',
      child: const Icon(Icons.connect_without_contact),
    );

    var subscribe_button = FloatingActionButton(
      onPressed: _unsubscribe,
      tooltip: 'unsubscribe',
      heroTag: 'subscribe_button',
      child: const Icon(Icons.unsubscribe),
    );
    var disconnect_button = FloatingActionButton(
      onPressed: _disconnect,
      tooltip: 'disconnect',
      heroTag: 'disconnect_button',
      child: const Icon(Icons.cast_connected),
    );
    var publish_button = FloatingActionButton(
      onPressed: _publish,
      tooltip: 'publish',
      heroTag: 'publish_button',
      child: const Icon(Icons.publish),
    );
    AlertDialog build_add_widget (BuildContext context) {
      void text_change (String value) {
        user_todo = value;
      }

      var commit_text = Text('add');

      var _actions = [
        ElevatedButton(
            onPressed: _connect,
            child: commit_text)
      ];

      var alertDialog = AlertDialog(
        title: Text('add element'),
        content: TextField(
          onChanged: text_change,
        ),
        actions: _actions,
      );

      return alertDialog;
    }


    var remove_icon = Icon(
          Icons.delete_sweep,
          color: Colors.deepOrangeAccent
      );





    final imgStream = StreamController<Image>();

    var listView = StreamBuilder(
        stream: imgStream.stream,
        builder:
            (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  print('no data');
                }

                 if (snapshot.connectionState == ConnectionState.done) {}
          var container = Container(
            height: 220,
            width: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            //  color: snapshot.data,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: snapshot.data,
            ),
          );
          return container;
        });

    //    ListView.builder(
    //       // itemCount: todo_list.length,
    //         itemCount: notifications.length,
    //         itemBuilder: item_builder
    //     );

    void menu_buttons(_route)  {
      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(context, _route, (route) => false );
    }

    void _menuOpen () {
      var menu_button = ElevatedButton(
        onPressed: () => menu_buttons('/todo'),
        child: Text('on main'),
      );
      var mqtt_button = ElevatedButton(
        onPressed: () => menu_buttons('/'),
        child: Text('on mqtt'),
      );

      List<Widget> body_rows = [
        menu_button,
        mqtt_button,
        Padding(padding: EdgeInsets.only(left: 15)),
        Text('main menu')
      ];

      var _scaffold = Scaffold(
          appBar: AppBar(
            title: Text('menu'),
          ),
          body: Row(children: body_rows)

      );

      // Scaffold menu_bilder (BuildContext context) => scaffold;
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => _scaffold)
      );

    }
    Stream<List> createAsyncGenerator(int n) async* {
      int k = 0;
      while (k < n) yield [k++];
    }

    var scaffold = Scaffold(
      appBar: AppBar(
        // Here we take the value from the MQTTScreen object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('widget.title'),
        // centerTitle: true,
        // actions: [
        //   IconButton(
        //       onPressed: _menuOpen,
        //       icon: Icon(
        //         Icons.menu
        //       )
        //   )
        // ],

      ),
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child:
          // Text('$notifications')
          // Text('${mqtt3.notifications.last}')
          StreamBuilder(
            stream: _clock(), //mqtt3.createAsyncGenerator(work),
            initialData: ['',''],
            builder: (
                BuildContext context,
                AsyncSnapshot snapshot,
                ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Visibility(
                        visible: snapshot.hasData,
                        child: Text(
                          'no data',
                          style: const TextStyle(color: Colors.black, fontSize: 24),
                        ),
                      ),
                    ],
                );
              } else
                    if (snapshot.connectionState == ConnectionState.active
                        || snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasError)
                                  return const Text('Error');
                            else if (snapshot.hasData && snapshot.data != null)
                              return Text(
                                        '${snapshot.data ?? '' }',
                                        style: const TextStyle(color: Colors.teal, fontSize: 20)
                                         );
                           else
                                return const Text('Empty data');
                    }
                    else
                        return Text('streamState: ${snapshot.connectionState}');

            },
          ),

        ),
      ),
    // );
      // body: Text(notifications.toString()),
      // floatingActionButton: [add_button, refresh_button],
      persistentFooterButtons: [add_button, connect_button, publish_button,
         subscribe_button, disconnect_button],

      // This trailing comma makes auto-formatting nicer for build methods.
    );

    return scaffold;
  }


}
