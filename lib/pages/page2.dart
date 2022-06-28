import 'package:flutter/material.dart';
import 'package:tcu/widgets/components.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_stream_builder_demo/loading_widget.dart';
import 'dart:math';

import 'package:flutter/material.dart';

const String title2 = 'Мероприятия';

// void main() {
//   runApp(const MyApp());
// }

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);
  @override
  Page2State createState() => Page2State();
}
class Page2State extends State<Page2> {
  final myController = TextEditingController();

  var buttons = 0;
  var buttons_state = {};
  List<Widget> buttons_array = [];
  Map<String, bool> buttons_switches = {};
  bool _switch = false;
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

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var text = 'def';
    var _colors = _switch ? Colors.red : Colors.green;

    buttons_array = [Row(mainAxisSize: MainAxisSize.min,
        children: [
          returnExpandedTextField(myController),
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.blue),
            child: Text('create'),
            onPressed: () => setState(() {
              buttons ++;
              buttons_state[buttons] = myController.text;
            }),
          )
        ]
      )];
    buttons_array = [];
    for (int i =1; i<=buttons; i++){
      String _text = buttons_state[i] ?? 'None';
      buttons_array.addAll([SizedBox(height: 16),ClickyBuilder(text:_text),]);
    }

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
      if (buttons_switches[id]!) {
        print('${topic} ${on}');
      } else {
        print('${topic} ${on}');
      }

      setState(() {
        print('button_colors $id ${_colors} ');
        _colors = buttons_switches[id]! ? Colors.red : Colors.green;
      });

      print('button_colors $id ${_colors} ');

    }

    _create_button(String topic, String on, String off) {
      var id = '${topic}_${on}_${off}';
      Widget _button =  ElevatedButton(
          style: style,
          onPressed: () {
            publist_button_onpress(topic, on, off, id);
          },

          child:
          Row( mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('$topic хз'),
                Icon(Icons.circle, color: Colors.blue),
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
                // buttons_dynamic.add(_button);
                // subscribed_buttons.add(publishTopicCtrl.text);
                // button_parameters_map[publishTopicCtrl.text] = [
                //   publishMsgCtrl.text, publishMsgOffCtrl.text];
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

    final plus_button = returnFloatingButton((){
      showAddButtonDialog(context);
    }, parameters:{
      'tooltip': 'add_button', 'icons': Icons.add_circle_outline} );


    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Rebuild only when necessary'),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // children: buttons_array,
            children: [],
          ),
        ),
          persistentFooterButtons: [plus_button],
      ),
    );
  }
}


class ClickyBuilder extends StatefulWidget {
  const ClickyBuilder({Key? key, String this.text='_'}) : super(key: key);
  final String text ;
  @override
  _ClickyBuilderState createState() => _ClickyBuilderState();
}

class _ClickyBuilderState extends State<ClickyBuilder> {
  Color color = Colors.blue;

  String pad(int i) => i.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(primary: color),
        child: Text(widget.text),
        onPressed: () => setState(() {
          color = getRandomColor();
        }),
      ),
      Expanded(
        child: TextField(
            onChanged: (text) {
              print('First text field: $text');
              setState(() {
                if (text == 'blue')
                  color = Colors.blue;
                if (text == 'black')
                  color = Colors.black;
              });

            },
          )
      ),
    ]);
  }
}

final rng = Random();

const randomColors = [
  Colors.blue,
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.indigo,
  Colors.deepPurple,
  Colors.white10,
];

Color getRandomColor() {
  return randomColors[rng.nextInt(randomColors.length)];
}
