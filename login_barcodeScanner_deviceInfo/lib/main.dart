import 'package:flutter/material.dart';
import 'package:abc/home_page.dart';
import 'package:abc/login_page.dart';
import 'package:abc/device_inpo.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    Barcode.tag: (context) => Barcode(),
    DeviceInpo.tag: (context) => DeviceInpo(),
  };

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito'
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}

