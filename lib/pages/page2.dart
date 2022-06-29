import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tcu/widgets/components.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:tcu/mqtt3.dart' as mqtt3;

import 'package:flutter/material.dart';

import 'package:tcu/mqtt3.dart';

import 'page1.dart';


const String title2 = 'Мероприятия';


class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);
  @override
  Page2State createState() => Page2State();
}
class Page2State extends State<Page2> {
  final myController = TextEditingController();
  final bool _running = true;
  List notifications = [];
  var buttons = 0;
  var buttons_state = {};
  List<Widget> buttons_array = [];
  bool subscribed = false;
  bool connected = false;

  void _connect([String? _server,
                String? _port,
                String? _client_id,
                String? _will_topic,
                String? _will_message]) {

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
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    Stream<String> stream_clock() async* {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      client.updates!.listen((c) async{
        final recMess = c[0].payload as MqttPublishMessage;
        notifications = await [
          '${c[0].topic}',
          '${MqttPublishPayload.bytesToStringAsString(recMess.payload.message)}'
        ];
      }
      );
      yield " topic: ${notifications[0]} \n\n message: ${notifications[1]}";
    }
    Widget _streamwidget = StreamBuilder(
      stream: stream_clock(), //mqtt3.createAsyncGenerator(work),
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
          }
          else
              if (snapshot.connectionState == ConnectionState.active
                  || snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError)
                      return const Text('');
                  else
                    if (snapshot.hasData && snapshot.data != null) {
                      var _text = '${snapshot.data ?? ''}';
                      log('in _streamwidget');
                        buttons_state.forEach((key, value) {
                          log('Key: $key');
                          log('Value: $value');
                          log('------------------------------');
                        });
                      log('in _streamwidget');

                      return Text(_text);
                      // return Expanded(
                      //   flex: 2,
                      //   child: Scrollbar(
                      //     // scrollDirection: Axis.vertical,//.horizontal
                      //       child: Text(_text)
                      //   ),
                      // );

                    }

                  else return const Text('Empty data');
              }
          else
              return Text('streamState: ${snapshot.connectionState}');

      },
    );


    buttons_array = [
        _streamwidget,
        // Expanded(
        //     flex: 2,
        //     child: Scrollbar(
        //         // scrollDirection: Axis.vertical,//.horizontal
        //         child: _streamwidget
        //     ),
        // )
    ];
    for (int i =1; i<=buttons; i++){
      buttons_array.addAll([
            SizedBox(height: 16),
            ClickyBuilder(button_state: buttons_state[i]),
      ]);
    }


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


    showAddButtonDialog (BuildContext context) {
      var _actions = [
        ElevatedButton(
            onPressed: ()
            {
              print('notifications');
              print(notifications);

              setState(() {
                buttons ++;
                String id = '${publishTopicCtrl.text}_${publishMsgCtrl.text}_${publishMsgOffCtrl.text}_${subscrTopicCtrl.text}_${subscrMsgCtrl.text}_${subscrMsgOffCtrl.text}';

                String publishTopicCtrl_text = 'house/e';
                if (publishTopicCtrl.text != '')
                    publishTopicCtrl_text = publishTopicCtrl.text;
                String publishMsgCtrl_text = 'on';
                if (publishMsgCtrl.text != '')
                    publishTopicCtrl_text = publishMsgCtrl.text;
                String publishMsgOffCtrl_text = 'off';
                if (publishMsgOffCtrl.text != '')
                    publishMsgOffCtrl_text = publishMsgOffCtrl.text;
                String subscrTopicCtrl_text = publishTopicCtrl_text;
                if (publishMsgCtrl.text != '')
                    publishTopicCtrl_text = subscrTopicCtrl.text;
                String subscrMsgCtrl_text = publishMsgCtrl_text;
                if (publishMsgCtrl.text != '')
                  subscrMsgCtrl_text = subscrMsgCtrl.text;
                String subscrMsgOffCtrl_text = publishMsgOffCtrl_text;
                if (publishMsgCtrl.text != '')
                  subscrMsgOffCtrl_text = subscrMsgOffCtrl.text;

                buttons_state[buttons] = {
                  'publish_topic': publishTopicCtrl_text,
                  'publish_message_on': publishMsgCtrl_text,
                  'publish_message_off': publishMsgOffCtrl_text,
                  'subscr_topic': subscrTopicCtrl_text,
                  'subscr_message_on': subscrMsgCtrl_text,
                  'subscr_message_off': subscrMsgOffCtrl_text,
                };
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

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Rebuild only when necessary'),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: buttons_array,
            // children: [],
          ),
        ),
          persistentFooterButtons: get_fabs_list(),
      ),
    );
  }
}


class ClickyBuilder extends StatefulWidget {
  const ClickyBuilder({Key? key, required Map this.button_state}) : super(key: key);
  final Map button_state;

  @override
  _ClickyBuilderState createState() => _ClickyBuilderState();
}

class _ClickyBuilderState extends State<ClickyBuilder> {
  Color color = Colors.blue;
  Map<String, bool> buttons_switches = {};
  final now = DateTime.now();
  String pad(int i) => i.toString().padLeft(2, '0');

  void _subscript([String topic = 'house/#']) {
    setState(() {
      mqtt3.subscript(topic);
      subscribed = true;
    });
    // connectionState = await client.connectionState;
  }
  void _publish([String? topic, String? message]){
    mqtt3.publish(topic, message);
  }

  @override
  Widget build(BuildContext context) {
    final String publish_topic = widget.button_state['publish_topic'] ?? '';
    final String publish_message_on = widget.button_state['publish_message_on'] ?? '';
    final String publish_message_off = widget.button_state['publish_message_off'] ?? '';
    final String subscr_topic = widget.button_state['subscr_topic'] ?? '';
    final String subscr_message_on = widget.button_state['subscr_message_on'] ?? '';
    final String subscr_message_off = widget.button_state['subscr_message_off'] ?? '';

    var id = '${publish_topic}_${publish_message_on}_${publish_message_off}_${subscr_topic}_${subscr_message_on}_${subscr_message_off}';

    return Row(mainAxisSize: MainAxisSize.min, children: [
      ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.blue),
          onPressed: () {
            if (buttons_switches[id] == null) {
              buttons_switches[id] = true;
              print('button status was null');
            } else {
              buttons_switches[id] = !(buttons_switches[id] as bool);
            }
            // _colors = buttons_switches[id]! ? Colors.red : Colors.green;
            if (buttons_switches[id]!) {
              print('Button ${publish_topic} is switched to on ${publish_message_on}');
            } else {
              print('Button ${publish_topic} is switched to off ${publish_message_off}');
            }
            _subscript(subscr_topic);
            if (!buttons_switches[id]!)
                _publish(publish_topic, publish_message_on);
            else
                _publish(publish_topic, publish_message_off);

            setState(() {

              color = buttons_switches[id]! ? Colors.red : Colors.green;
            });
          },
          child:
              Row( mainAxisSize: MainAxisSize.min,
                   children: <Widget>[
                      Text('$publish_topic  '),
                      Icon(Icons.circle, color: color),
                  ]
              )
      ),
    ]);
  }
}
