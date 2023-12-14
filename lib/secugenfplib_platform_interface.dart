import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'utils/barrels.dart';
import 'secugenfplib_method_channel.dart';

abstract class SecugenfplibPlatform extends PlatformInterface {

  SecugenfplibPlatform() : super(token: _token);

  static final Object _token = Object();

  static SecugenfplibPlatform _instance = MethodChannelSecugenfplib();
  static SecugenfplibPlatform get instance => _instance;

  static set instance(SecugenfplibPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> initializeDevice() {
    throw UnimplementedError('initializeDevice() has not been implemented.');
  }

  Future<void> enableLed(bool val) {
    throw UnimplementedError('toggleLed() has not been implemented.');
  }

  Future<void> enableSmartCapture(bool val) {
    throw UnimplementedError('enableSmartCapture() has not been implemented.');
  }

  Future<void> setBrightness(int val) {
    throw UnimplementedError('setBrightness() has not been implemented.');
  }

  Future<ImageCaptureResult?> captureFingerprint(bool auto) {
    throw UnimplementedError('captureFingerprint() has not been implemented.');
  }

  Future<ImageCaptureResult?> captureFingerprintWithQuality(int timeout, int quality, bool auto) {
    throw UnimplementedError('captureFingerprintWithQuality() has not been implemented.');
  }

  Future<bool?> verifyFingerprint(Uint8List firstBytes, Uint8List secondBytes) {
    throw UnimplementedError('verifyFingerprint() has not been implemented.');
  }

  Future<int?> getMatchingScore(Uint8List firstBytes, Uint8List secondBytes) {
    throw UnimplementedError('getMatchingScore() has not been implemented.');
  }
}
