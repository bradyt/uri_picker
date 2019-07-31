import 'dart:async';

import 'package:flutter/services.dart';

// TODO(bradyt): Research if mocking requires a class
// ignore: avoid_classes_with_only_static_members
/// This class provides methods to use Android's Storage Access Framework, and
/// ACTION_OPEN_DOCUMENT, to get persistent read/write access as a client to
/// Document Provider's.
class UriPicker {
  static final MethodChannel _channel =
      MethodChannel('tangential.info/uri_picker');

  /// Uses system UI to pick a URI
  static Future<String> pickUri() async {
    String uri;
    try {
      uri = await _channel.invokeMethod<dynamic>('pickUri') as String;
    } on PlatformException {
      rethrow;
    } on MissingPluginException {
      rethrow;
    }
    return uri;
  }

  /// Get the display name for the URI.
  static Future<String> getDisplayName(String uri) async {
    String displayName;
    try {
      displayName = await _channel
          .invokeMethod<dynamic>('getDisplayName', <String, String>{
        'uri': uri,
      }) as String;
    } on PlatformException {
      rethrow;
    }
    return displayName;
  }

  /// Check if URI is openable.
  static Future<void> isUriOpenable(String uri) async {
    try {
      await _channel.invokeMethod<dynamic>('isUriOpenable', <String, String>{
        'uri': uri,
      });
    } on PlatformException {
      rethrow;
    } on MissingPluginException {
      rethrow;
    }
  }

  /// Get permissions to persist across device reboot.
  static Future<void> takePersistablePermission(String uri) async {
    try {
      await _channel
          .invokeMethod<dynamic>('takePersistablePermission', <String, String>{
        'uri': uri,
      });
    } on PlatformException {
      rethrow;
    } on MissingPluginException {
      rethrow;
    }
  }

  /// Get content from URI.
  static Future<String> readTextFromUri(String uri) async {
    String fileContents;
    try {
      fileContents = await _channel
          .invokeMethod<dynamic>('readTextFromUri', <String, String>{
        'uri': uri,
      }) as String;
    } on PlatformException {
      rethrow;
    }
    return fileContents;
  }

  /// Write content to URI.
  static Future<void> alterDocument(String uri, String newContents) async {
    await isUriOpenable(uri);
    try {
      await _channel.invokeMethod<dynamic>('alterDocument', <String, String>{
        'uri': uri,
        'newContents': newContents,
      });
    } on PlatformException catch (e) {
      print('PlatformException $e');
    }
  }
}
