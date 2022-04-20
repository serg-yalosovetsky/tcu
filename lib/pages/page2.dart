import 'package:flutter/material.dart';
import 'package:tcu/widgets/components.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_stream_builder_demo/loading_widget.dart';
const String title2 = 'Мероприятия';

class Page2 extends StatefulWidget {
  @override
  _FlutterStreamBuilderState createState() => _FlutterStreamBuilderState();
}

class _FlutterStreamBuilderState extends State<Page2> {
  late double _height;
  late double _width;

  final imgStream = StreamController<Image>();

  int imgCounter = -1;

  final List<Image> imageList = [
    Image.asset(
      'assets/images/resort_1.jpg',
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/images/resort_2.jpg',
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/images/resort_3.jpg',
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/images/resort_4.jpg',
      fit: BoxFit.cover,
    ),
  ];

  @override
  void dispose() {
    imgStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: _height,
        width: _width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder(
                stream: imgStream.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (!snapshot.hasData) {
                    // return Loader();
                  }

                  if (snapshot.connectionState == ConnectionState.done) {}

                  return Container(
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
                }),
            RaisedButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
              onPressed: () {
                // colorStream.sink.add(Colors.blue);

                imgCounter++;

                if (imgCounter < imageList.length) {
                  imgStream.sink.add(imageList[imgCounter]);
                } else {
                  imgStream.close();
                }
              },
              color: Colors.red,
              textColor: Colors.white,
              child: Text("  Click Me  ".toUpperCase(),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }
}