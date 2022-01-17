import 'package:flutter/material.dart';
import 'package:tcu/widgets/components.dart';

// void main() {
//   runApp(const Page2());
// }
const String title2 = 'Мероприятия';


class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title2,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StatePage2(title: title2),
    );
  }
}

class StatePage2 extends StatefulWidget {
  const StatePage2({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StatePage2> createState() => _StatePage2State();
}

class _StatePage2State extends State<StatePage2> {


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