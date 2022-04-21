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
  final myController = TextEditingController();
  final subscribeCtrl = TextEditingController();
  final publishTopicCtrl = TextEditingController();
  final publishMsgCtrl = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    subscribeCtrl.dispose();
    publishTopicCtrl.dispose();
    publishMsgCtrl.dispose();
    super.dispose();
  }

  bool connected = false;
  bool subscribed = false;
  void _connect() {
    mqtt3.main();
    setState(() {
      connected = true;
    });
    // connectionState = await client.connectionState;
  }
  void _subscript([String? topic]) {
    setState(() {
      mqtt3.subscript(topic);
      subscribed = true;
    });
    // connectionState = await client.connectionState;
  }
  void _unsubscribe() {
    mqtt3.unsubscribe();
    setState(() {
      subscribed = false;
    });
  }

  void _publish([String? topic, String? message]){
    setState(() {
      mqtt3.publish(topic, message);
    });
  }

  void _disconnect() {
    mqtt3.disconnect() ;
    setState(() {
      connected = false;
      subscribed = false;
    });
  }

  List<Widget> persistentFooterButtons = [];

  @override
  Widget build(BuildContext context) {

   final connect_button = returnFloatingButton(_connect, parameters:{
                  'tooltip': 'connect', 'icons': Icons.cast_connected} );

   showSubscribeDialog (BuildContext context) {
     var _actions = [
       ElevatedButton(
           onPressed: ()
             {
                _subscript(subscribeCtrl.text);
                Navigator.of(context).pop();
            },
           child: const Text('Subscribe')
       )
     ];

     AlertDialog subscribeDialog = AlertDialog(
       title: Text('Enter a subscribe topic'),
       content: TextField(
         controller: subscribeCtrl,
         decoration: InputDecoration(
           border: OutlineInputBorder(),
           hintText: 'house/#',
         ),
       ),
       actions: _actions,
     );

     showDialog(
       context: context,
       builder: (BuildContext context) {
         return subscribeDialog;
       },
     );
   }

   showPublishDialog (BuildContext context) {
     var _actions = [
       ElevatedButton(
           onPressed: ()
           {
             _publish(publishTopicCtrl.text,publishMsgCtrl.text);
             Navigator.of(context).pop();
           },
           child: const Text('Publish')
       )
     ];
     var topicTextField = TextField(
       controller: publishTopicCtrl,
       decoration: InputDecoration(
         border: OutlineInputBorder(),
         hintText: 'house/#',
       ),
     );
     var messageTextField = TextField(
       controller: publishMsgCtrl,
       decoration: InputDecoration(
         border: OutlineInputBorder(),
         hintText: 'hello house!)',
       ),
     );
     
     AlertDialog publishDialog = AlertDialog(
       title: Text('Enter a publish message'),
       content: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           topicTextField,
           messageTextField,
         ],
       ),
       actions: _actions,
     );

     showDialog(
       context: context,
       builder: (BuildContext context) {
         return publishDialog;
       },
     );
   }

   final subscribe_button = returnFloatingButton(() {
       showSubscribeDialog(context);
      }, parameters:{
        'tooltip': 'subscribe', 'icons': Icons.subscriptions} );
   final unsubscribe_button = returnFloatingButton(_unsubscribe, parameters:{
     'tooltip': 'unsubscribe', 'icons': Icons.unsubscribe} );
   final disconnect_button = returnFloatingButton(_disconnect, parameters:{
     'tooltip': 'disconnect', 'icons': Icons.cancel} );
   final publish_button = returnFloatingButton(() {
         showPublishDialog(context);
         print('click');
     }, parameters:{
        'tooltip': 'publish', 'icons': Icons.publish} );

  List<Widget> get_fabs_list() {
    if (connected && subscribed)
      return([ publish_button, unsubscribe_button, disconnect_button]);
    else if (connected && !(subscribed))
      return ([subscribe_button, publish_button, disconnect_button]);
    else
      return([connect_button]);
  }

    // var remove_icon = Icon(
    //       Icons.delete_sweep,
    //       color: Colors.deepOrangeAccent
    //   );





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
    var _streamwidget = StreamBuilder(
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
    );

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

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _streamwidget,
              TextField(
                  controller: myController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a topic',
                  ),
              ),
            ],
          )
          // Text('$notifications')
          // Text('${mqtt3.notifications.last}')

        ),
      ),
    // );
      // body: Text(notifications.toString()),
      // floatingActionButton: [connect_button, refresh_button],
      persistentFooterButtons: get_fabs_list(),

      // This trailing comma makes auto-formatting nicer for build methods.
    );

    return scaffold;
  }


}
