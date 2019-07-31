// ignore_for_file: public_member_api_docs
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uri_picker/uri_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> _sharedPreferences;

  @override
  void initState() {
    _sharedPreferences = SharedPreferences.getInstance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _sharedPreferences,
      builder: (_, snapshot) =>
          (snapshot.hasData) ? YourApp(snapshot.data) : Container(),
    );
  }
}

class YourApp extends StatefulWidget {
  const YourApp(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  @override
  _YourAppState createState() => _YourAppState();
}

class _YourAppState extends State<YourApp> {
  String _contents;

  set _uri(String uri) => widget.sharedPreferences.setString('uri', uri);

  String get _uri => widget.sharedPreferences.getString('uri');

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> performFileSearch() async {
    String uri;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      uri = await UriPicker.performFileSearch();
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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> createFile() async {
    String uri;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      uri = await UriPicker.createFile();
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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> readTextFromUri() async {
    String contents;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      contents = await UriPicker.readTextFromUri(_uri);
    } on PlatformException {
      contents = 'Failed to get contents.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _contents = contents;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> appendTimestamp() async {
    String contents;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await UriPicker.appendToFile(_uri, '${DateTime.now().toString()}\n');
    } on PlatformException {
      contents = 'Failed to write contents.';

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      setState(() {
        _contents = contents;
      });
    }
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
                if (_contents != null)
                  Text('Last line of contents is')
                else
                  Text('No contents yet'),
                if (_contents != null)
                  Text('"${_contents.trim().split('\n').last}"'),
                RaisedButton(
                  onPressed: () async {
                    await performFileSearch();
                  },
                  child: Text('Perform file search'),
                ),
                RaisedButton(
                  onPressed: () async {
                    await createFile();
                  },
                  child: Text('Create file'),
                ),
                RaisedButton(
                  onPressed: () async {
                    await readTextFromUri();
                  },
                  child: Text('Read text from URI'),
                ),
                RaisedButton(
                  onPressed: () async {
                    await appendTimestamp();
                  },
                  child: Text('Append timestamp'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
