// ignore_for_file: public_member_api_docs
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uri_picker/uri_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _uri;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> pickUri() async {
    String uri;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      uri = await UriPicker.pickUri();
    } on PlatformException {
      uri = 'Failed to get uri.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _uri = uri;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Uri Picker example app'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(_uri ?? 'No uri yet'),
                RaisedButton(
                  onPressed: () async {
                    await pickUri();
                  },
                  child: Text('Pick URI'),
                ),
                RaisedButton(
                  onPressed: () async {
                    await pickUri();
                  },
                  child: Text('Pick URI'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
