import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:tcu/pages/page0.dart' show title0;
import 'package:tcu/pages/page1.dart' show title1;
import 'package:tcu/pages/page2.dart' show title2;
import 'package:tcu/main.dart' show mainBackgroundColor, accentBackgroundColor;


const Map default_fab_parameters = { 'tooltip':'Increment', 'icons': Icons.add };
const _items = <Widget>[
  Icon(Icons.home, size: 30, color: Colors.blue,),
  Icon(Icons.search, size: 30, color: Colors.blue,),
  Icon(Icons.favorite, size: 30, color: Colors.blue,),
  Icon(Icons.settings, size: 30, color: Colors.blue,),
  Icon(Icons.person, size: 30, color: Colors.blue,),
  // Icon(Icons.manage_accounts, size: 30, color: Colors.blue,),
];

const String menu_title = 'Menu';


Drawer returnMenu(BuildContext context) {

  Drawer menu = Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(menu_title),
        ),
        ListTile(
          title: const Text(title0),
          onTap: () {
            // Update the state of the app
            // ...
            // Then close the drawer
            // Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              '/',
            );
          },
        ),
        ListTile(
          title: const Text(title1),
          onTap: () {
            // Update the state of the app
            // ...
            // Then close the drawer
            // Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              '/page1',
            );
          },
        ),
        ListTile(
          title: const Text(title2),
          onTap: () {
            // Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              '/page2',
            );
          },
        ),
      ],
    ),
  );
  return menu;
}

FloatingActionButton returnFloatingButton(var fun,
                                  {var parameters = default_fab_parameters }) {
  FloatingActionButton FAB = FloatingActionButton(
    onPressed: fun,
    tooltip: parameters['tooltip'],
    child: Icon(parameters['icons']),
  );
  return FAB;
}


CurvedNavigationBar returnCurvedNavBar(var fun, int index, {var items = _items }) {

   return CurvedNavigationBar(
    items: items,
    height: 60,
    color: accentBackgroundColor,
    buttonBackgroundColor: accentBackgroundColor,
    backgroundColor: Colors.transparent,
    animationDuration: Duration(microseconds: 300),
    index: index,
    onTap: fun,
  );

}