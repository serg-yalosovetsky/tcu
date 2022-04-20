import 'package:flutter/material.dart';
import 'package:tcu/pages/page0.dart';
import 'package:tcu/pages/page1.dart';
import 'package:tcu/pages/page2.dart';

void main() {
  runApp(const TCUapp());
}

const Color mainBackgroundColor = Color(0xFF0A0E21);
const Color accentBackgroundColor = Color(0xFF0A0E40);
class TCUapp extends StatelessWidget {
  const TCUapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        primaryColor: mainBackgroundColor,
        scaffoldBackgroundColor: mainBackgroundColor,
        iconTheme: IconThemeData(color: Colors.white,),
      ),
      // theme: ThemeData(
      //   primaryColor: const Color(0xFF0A0E21),
      //   scaffoldBackgroundColor: const Color(0xFF0A0E21),
      //   colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
      //       .copyWith(secondary: Colors.purple, ),
      // ),
      // home: const BaseHomePage(title: 'Flutter Demo Home Page'),
      initialRoute: '/',
      routes: {
        '/': (context) => BaseHomePage(title: 'home',),
        '/page1': (context) => MQTTScreen(),
        '/page2': (context) => Page2(),
      },

    );
  }
}
