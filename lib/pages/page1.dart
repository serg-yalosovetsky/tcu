import 'package:flutter/material.dart';
import 'package:tcu/widgets/components.dart';

// void main() {
//   runApp(const Page1());
// }
const String title1 = 'Учебные материалы';
const String text1 = '''Вже багато років при турклубі “Університет” працює Школа передпохідної підготовки (ШПП). Протягом навчального року (з вересня до травня) її слухачі опановують туристську мудрість та навички – від вибору оптимального спорядження та
              догляду за ним до складання харчових розкладок та аптечок, грамотної побудови маршрутів, розведення вогню в будь-яких умовах та в’язання вузлів. Заняття проходять раз на тиждень у лекційному форматі, а також у походах вихідного дня,
            де відпрацьовуються практичні навички. ''';

class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title1,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StatePage1(title: title1),
    );
  }
}

class StatePage1 extends StatefulWidget {
  const StatePage1({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StatePage1> createState() => _StatePage1State();
}

class _StatePage1State extends State<StatePage1> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              text1,
            ),

          ],
        ),
      ),
      drawer: returnMenu(context),
      // floatingActionButton: returnFloatingButton(_incrementCounter), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}