import 'package:flutter/material.dart';
import 'package:tcu/widgets/components.dart';

// void main() {
//   runApp(const SettingsPage());
// }
const String settings_title = 'Настройки';
Map settings = {'show_main_title': true,};


class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: settings_title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StateSettingsPage(title: settings_title),
    );
  }
}

class StateSettingsPage extends StatefulWidget {
  const StateSettingsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StateSettingsPage> createState() => _StateSettingsPageState();
}

class _StateSettingsPageState extends State<StateSettingsPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),

          ],
        ),
      ),
      drawer: returnMenu(context),
      // floatingActionButton: returnFloatingButton(_incrementCounter), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}