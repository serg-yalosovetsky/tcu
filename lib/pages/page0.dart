import 'dart:html';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:tcu/widgets/components.dart';
import 'package:tcu/main.dart' show mainBackgroundColor, accentBackgroundColor;

const String title0 = 'Начальная';


class BaseHomePage extends StatefulWidget {
  const BaseHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<BaseHomePage> createState() => _BaseHomePageState();
}

class _BaseHomePageState extends State<BaseHomePage> {
  int _selectedIndex = 0;
  static const _image = 'https://wallpaperaccess.com/full/1431622.jpg';
  static const TextStyle optionStyle =  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static  List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Explore',
      style: optionStyle,
    ),
    Image.network(
        _image,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,),
    // Text(
    //   'Index 2: Favorites',
    //   style: optionStyle,
    // ),
    Text(
      'Index 3: Settings',
      style: optionStyle,
    ),
    Text(
      'Index 4: Account',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {


    var scaffold = Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      drawer: returnMenu(context),
      bottomNavigationBar: returnCurvedNavBar(_onItemTapped, _selectedIndex),
    );

    return scaffold;
  }
}
