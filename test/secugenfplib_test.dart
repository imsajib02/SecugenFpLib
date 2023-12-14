import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:secugenfplib/secugenfplib.dart';
import 'package:secugenfplib/secugenfplib_platform_interface.dart';
import 'package:secugenfplib/secugenfplib_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSecugenfplibPlatform
    with MockPlatformInterfaceMixin
    implements SecugenfplibPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool?> initializeDevice() {
    // TODO: implement initializeDevice
    throw UnimplementedError();
  }

  @override
  Future toggleLed(bool val) {
    // TODO: implement toggleLed
    throw UnimplementedError();
  }

  @override
  Future<ImageCaptureResult?> captureFingerprint(bool auto) {
    // TODO: implement captureFingerprint
    throw UnimplementedError();
  }

  @override
  Future<ImageCaptureResult?> captureFingerprintWithQuality(int timeout, int quality, bool auto) {
    // TODO: implement captureFingerprintWithQuality
    throw UnimplementedError();
  }

  @override
  Future<void> enableLed(bool val) {
    // TODO: implement enableLed
    throw UnimplementedError();
  }

  @override
  Future<void> enableSmartCapture(bool val) {
    // TODO: implement enableSmartCapture
    throw UnimplementedError();
  }

  @override
  Future<void> setBrightness(int val) {
    // TODO: implement setBrightness
    throw UnimplementedError();
  }

  @override
  Future<bool?> verifyFingerprint(Uint8List firstBytes, Uint8List secondBytes) {
    // TODO: implement verifyFingerprint
    throw UnimplementedError();
  }

  @override
  Future<int?> getMatchingScore(Uint8List firstBytes, Uint8List secondBytes) {
    // TODO: implement getMatchingScore
    throw UnimplementedError();
  }
}

void main() {
  final SecugenfplibPlatform initialPlatform = SecugenfplibPlatform.instance;

  test('$MethodChannelSecugenfplib is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSecugenfplib>());
  });

  test('getPlatformVersion', () async {
    Secugenfplib secugenfplibPlugin = Secugenfplib();
    MockSecugenfplibPlatform fakePlatform = MockSecugenfplibPlatform();
    SecugenfplibPlatform.instance = fakePlatform;

    expect(await secugenfplibPlugin.initializeDevice(), '42');
  });
}
