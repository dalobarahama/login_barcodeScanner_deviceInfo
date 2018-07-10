import 'dart:async';
import 'dart:convert';

import 'package:abc/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abc/device_inpo.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart';

void main() {
  runApp(new Barcode());
}

class Barcode extends StatefulWidget {
  @override
  _Barcode createState() => new _Barcode();

  //connectivity
  Barcode({Key key, this.title}) : super(key: key);
  final String title;
  //

  static String tag = 'barcode';
}

class _Barcode extends State<Barcode> {
  String barcode = "";

  //getIPAddress
  var _ipAddress = 'Unknown';
  final httpClient = new Client();
  final url = 'https://httpbin.org/ip';

  //connectivity
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  //void
  @override
  initState() {
    super.initState();

    //connectivity
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() => _connectionStatus = result.toString());
    });
    //
  }

  //connectivity
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  //

  //getIPAddress
  _getIPAddressUsingFuture() {
    Future<Response> respone = httpClient.get(url);
    respone.then((value) {
      setState(() {
        _ipAddress = JSON.decode(value.body)['origin'];
      });
    }).catchError((error) => print(error));
  }

  final userLogo = Hero(
      tag: 'user',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/batman.png'),
      ),
    );

  @override
  Widget build(BuildContext context) {
    final scanButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: scan,
          color: Colors.lightBlueAccent,
          child: Text(
            'Scan',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );

    final infoButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () {
            Navigator.of(context).pushNamed(DeviceInpo.tag);
          },
          color: Colors.lightBlueAccent,
          child: Text(
            'Device Info',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );

    final ipButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: (){
            _getIPAddressUsingFuture();
          },
          color: Colors.lightBlueAccent,
          child: Text(
            'Get IP Address',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: new Text('Scanner & Device Info'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            userLogo,
            scanButton,
            new Text(barcode),
            SizedBox(
              height: 24.0,
            ),
            infoButton,
            ipButton,
            new Text('Your current IP Address is:\n$_ipAddress\n'),
            new Text('Connection status:\n$_connectionStatus'),
          ],
        ),
      ),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() =>
          this.barcode = 'You pressed back button before scanning anything');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  //connectivity
  Future<Null> initConnectivity() async {
    String connectionStatus;

    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
  }
}
