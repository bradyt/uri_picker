import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uri_picker/uri_picker.dart';

void main() {
  final channel = MethodChannel('info.tangential/uri_picker');

  setUp(() {
    channel.setMockMethodCallHandler((methodCall) async => '42');
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await UriPicker.performFileSearch(), '42');
  });
}
