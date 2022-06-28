import 'dart:async';
// import 'dart:math';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:tcu/widgets/components.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tcu/mqtt3.dart' as mqtt3;
import 'package:uuid/uuid.dart';
import 'dart:developer';

var uuid = Uuid();

const String title1 = "mqtt";
Map<String,bool> buttons_state = {};

class MQTTScreen extends StatefulWidget {
  const MQTTScreen({Key? key }) : super(key: key);

  @override
  _MQTTScreenState createState() => _MQTTScreenState();
}


class _MQTTScreenState extends State<MQTTScreen> {
  final bool _running = true;
  List notifications = [];
  List<Widget> persistentFooterButtons = [];
  bool connected = false;
  bool subscribed = false;
  late var connectionState;
  final subscribeCtrl = TextEditingController();
  final subscrTopicCtrl = TextEditingController();
  final subscrMsgCtrl = TextEditingController();
  final subscrMsgOffCtrl = TextEditingController();
  final publishTopicCtrl = TextEditingController();
  final publishMsgCtrl = TextEditingController();
  final publishMsgOffCtrl = TextEditingController();
  final connectServerCtrl = TextEditingController();
  final connectPortCtrl = TextEditingController();
  final connectClientCtrl = TextEditingController();
  final connectTopicCtrl = TextEditingController();
  final connectMessageCtrl = TextEditingController();



  bool isSwitched = false;
  bool _switch = false;
  List button_parameters = [];
  List<Function> listenersFunction = [];


  Stream<String> _clock() async* {
    while (_running) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      mqtt3.client.updates!.listen((c) async
            { final recMess = c[0].payload as MqttPublishMessage;
              notifications = await [
                  '${c[0].topic}',
                  '${MqttPublishPayload.bytesToStringAsString(recMess.payload.message)}'
                                ];
              setState(() {
                // for (var fun in listenersFunction)
                //   fun();
                listenersFunction.forEach((element) {element(); });
              });
            }
        );
      yield " topic: ${notifications[0]} \n\n message: ${notifications[1]}";
    }
  }


  void _connect([String? _server,
                 String? _port,
                 String? _client_id,
                 String? _will_topic,
                 String? _will_message]){
    mqtt3.to_connect(_server, _port, _client_id, _will_message, _will_topic);
    setState(() {
      connected = true;
    });
    // connectionState = await client.connectionState;
  }
  void _subscript([String topic = 'house/#']) {
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
      mqtt3.publish(topic, message);
  }

  void _disconnect() {
    mqtt3.disconnect() ;
    setState(() {
      connected = false;
      subscribed = false;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    subscribeCtrl.dispose();
    publishTopicCtrl.dispose();
    publishMsgCtrl.dispose();

    super.dispose();
  }
  Map<String,Widget> buttons = {};
  List<Widget> buttons_dynamic = [];

  Map<String, bool> buttons_switches = {};
  var subscribed_buttons = [];
  var button_parameters_map = {};
  // var _button2;
  @override
  Widget build(BuildContext context) {

    var _colors = _switch ? Colors.red : Colors.green;


    showConnectDialog (BuildContext context) {
      var _actions = [
        ElevatedButton(
            onPressed: ()
            {
              _connect(connectServerCtrl.text,connectPortCtrl.text,
          connectClientCtrl.text, connectTopicCtrl.text,connectMessageCtrl.text);
              Navigator.of(context).pop();
            },
            child: const Text('Connect')
        )
      ];
      var serverTextField = TextField(
        controller: connectServerCtrl,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: mqtt3.base_server,
        ),
      );
      var portTextField = TextField(
        controller: connectPortCtrl,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: mqtt3.base_port,
        ),
      );

      var clientTextField = TextField(
        controller: connectClientCtrl,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: mqtt3.client_id,
        ),
      );
      var topicTextField = TextField(
        controller: connectTopicCtrl,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: mqtt3.will_topic,
        ),
      );
      var messageTextField = TextField(
        controller: connectMessageCtrl,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: mqtt3.will_message,
        ),
      );

      AlertDialog publishDialog = AlertDialog(
        title: Text('Enter a publish message'),
        content: ListView(
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          children: [
            serverTextField,
            portTextField,
            divider,
            clientTextField,
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




    execute_set_switch(String id, String topic, String on, String off){
      setState(() {
        buttons_state[id] = ! (buttons_state[id] as bool);
        _switch = buttons_state[id] as bool;

        if (_switch)
          _publish(topic, on);
        else
          _publish(topic, off);
      });

      print('button $id ${buttons_state[id]} $_switch ');
      print(buttons_state);
    }

    final ButtonStyle style = ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20));


    publist_button_onpress (String topic, String on, String off, String id) {
      // print('button $id ${buttons_state[id]} ${buttons_switches[id]!} ');
      bool _b = true;
      if (buttons_switches[id] == null) {
        buttons_switches[id] = true;
        print('button status was null');
      } else {
        buttons_switches[id] = !(buttons_switches[id] as bool);

      }
      // _colors = buttons_switches[id]! ? Colors.red : Colors.green;
      if (buttons_switches[id]!)
        _publish(topic, on);
      else
        _publish(topic, off);
      setState(() {
        print('button_colors $id ${_colors} ');
        _colors = buttons_switches[id]! ? Colors.red : Colors.green;
      });

      print('button_colors $id ${_colors} ');

    }


    _create_button(String topic, String on, String off) {
      String id = uuid.v4();
      print('create button $id');

      buttons_switches[id] = true;
      Widget _button =  ElevatedButton(
          style: style,
          onPressed: () {
            publist_button_onpress (topic, on, off, id);
          },

          child:
              Row( mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('$topic хз'),
                    Icon(Icons.circle, color: _colors),
                  ]
              )
          );
      return _button;
    }

    showAddButtonDialog (BuildContext context) {
      var _actions = [
        ElevatedButton(
            onPressed: ()
            {
              setState(() {
                var _button = _create_button(publishTopicCtrl.text,
                    publishMsgCtrl.text, publishMsgOffCtrl.text);
                buttons_dynamic.add(_button);
                subscribed_buttons.add(publishTopicCtrl.text);
                button_parameters_map[publishTopicCtrl.text] = [
                                  publishMsgCtrl.text, publishMsgOffCtrl.text];
              });

              Navigator.of(context).pop();
            },
            child: const Text('Publish')
        )
      ];
      var topicTextField = returnTextField(publishTopicCtrl,
                parameters:{ 'hintText': 'house/#'});
      var onTextField = returnTextField(publishMsgCtrl,
          parameters:{ 'hintText': 'on'});
      var offTextField = returnTextField(publishMsgOffCtrl,
          parameters:{ 'hintText': 'off'});

      var topicSubscrTextField = returnTextField(subscrTopicCtrl,
          parameters:{ 'hintText': 'dart/example'});
      var onSubscrTextField = returnTextField(subscrMsgCtrl,
          parameters:{ 'hintText': 'on'});
      var offSubscrTextField = returnTextField(subscrMsgOffCtrl,
          parameters:{ 'hintText': 'off'});


      AlertDialog publishDialog = AlertDialog(
        title: Text('Enter a topic and on/off text'),
        content:
            ListView(
              shrinkWrap: true,

              padding: const EdgeInsets.all(8),
                children: [
                          topicTextField,
                          onTextField,
                          offTextField,
                          divider,
                          Text('if you want duplex link:'),
                          topicSubscrTextField,
                          onSubscrTextField,
                          offSubscrTextField,
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
       content: ListView(
         shrinkWrap: true,

         padding: const EdgeInsets.all(8),
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



   final connect_button = returnLongFloatingButton(_connect, parameters:{
     'longpress':() { showConnectDialog(context);},
     'tooltip': 'connect2', 'icons': Icons.cast_connected} );
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

   final plus_button = returnFloatingButton((){
     showAddButtonDialog(context);
     }, parameters:{
     'tooltip': 'add_button', 'icons': Icons.add_circle_outline} );












  List<Widget> get_fabs_list() {
    if (connected && subscribed)
      return([plus_button,  publish_button, unsubscribe_button, disconnect_button]);
    else if (connected && !(subscribed))
      return ([plus_button, subscribe_button, publish_button, disconnect_button]);
    else
      return([plus_button, connect_button]);
  }

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

    var _text_expanded = '';
    Widget expanded_widget_function(_text) {

      return new Expanded(
        flex: 1,
        child: new SingleChildScrollView(
          scrollDirection: Axis.vertical,//.horizontal
          child: new Text(
            _text,
            style: new TextStyle(
              fontSize: 16.0, color: Colors.white,
            ),
          ),
        ),
      );
    }
    var last_index_topic = 0;

    var _streamwidget = StreamBuilder(
      stream: _clock(), //mqtt3.createAsyncGenerator(work),
      initialData: ['',''],
      builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
          ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView(
            shrinkWrap: true,

            padding: const EdgeInsets.all(8),
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
            return const Text('');
          else if (snapshot.hasData && snapshot.data != null) {
            var _text = '${snapshot.data ?? ''}';
            var texts = '';
            for (var topic in subscribed_buttons) {

              if (_text.contains('topic: $topic', last_index_topic)) {
                log('contain Change notification:: topic is $topic');

                 last_index_topic = _text.lastIndexOf(topic);
                if (last_index_topic > 0)
                {
                  var contain = _text.contains('message: ${button_parameters_map[topic][0]}', last_index_topic);
                  if (contain) {
                    log('contain 0');
                    texts = 'contain ${button_parameters_map[topic][0]}';
                    _text_expanded = 'contain ${button_parameters_map[topic][0]}';
                  }

                  var contain1 = _text.contains('message: ${button_parameters_map[topic][1]}', last_index_topic);
                  if (contain1) {
                    log('contain 1');
                    texts = 'contain ${button_parameters_map[topic][1]}';
                    _text_expanded = 'contain ${button_parameters_map[topic][1]}';
                  }
                }
              }
              // texts += topic;
              // log('topic added: $topic');
            }

            // [publishTopicCtrl.text] = true;

            // return expanded_widget_function(_text_expanded);
            return expanded_widget_function(_text);

            // Text(texts,
              //   style: const TextStyle(color: Colors.teal, fontSize: 20));
          } else {
            return const Text('Empty data');
          }
        }
        else
          return Text('streamState: ${snapshot.connectionState}');

      },
    );
    List<Widget> get_buttons(){
      buttons_dynamic.add(_streamwidget);
      // List<Widget> _butt = [_streamwidget,];
      buttons_dynamic.addAll(buttons.values);
      return buttons_dynamic;
    }
    buttons_dynamic.add(_streamwidget);


    var scaffold = Scaffold(
      appBar: AppBar(
        // Here we take the value from the MQTTScreen object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('mqtt'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child:

          Column(
            // padding: const EdgeInsets.all(8),
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            // children: get_buttons(),
            children: buttons_dynamic,
          )
        ),
      ),
      persistentFooterButtons: get_fabs_list(),
    );

    return scaffold;
  }

}

