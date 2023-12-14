import 'dart:typed_data';

import 'secugenfplib_platform_interface.dart';
import 'utils/barrels.dart';

export 'utils/sgfplib_exception.dart';
export 'utils/barrels.dart';

class Secugenfplib {

  Future<bool?> initializeDevice() {
    return SecugenfplibPlatform.instance.initializeDevice();
  }

  Future<void> enableLed(bool val) async {
    SecugenfplibPlatform.instance.enableLed(val);
  }

  Future<void> enableSmartCapture(bool val) async {
    SecugenfplibPlatform.instance.enableSmartCapture(val);
  }

  Future<void> setBrightness(int val) async {
    return SecugenfplibPlatform.instance.setBrightness(val);
  }

  Future<ImageCaptureResult?> captureFingerprint({bool auto = false}) async {
    return SecugenfplibPlatform.instance.captureFingerprint(auto);
  }

  Future<ImageCaptureResult?> captureFingerprintWithQuality({required int timeout, required int quality, bool auto = false}) async {
    return SecugenfplibPlatform.instance.captureFingerprintWithQuality(timeout, quality, auto);
  }

  Future<bool?> verifyFingerprint({required Uint8List firstBytes, required Uint8List secondBytes}) async {
    return SecugenfplibPlatform.instance.verifyFingerprint(firstBytes, secondBytes);
  }

  Future<int?> getMatchingScore({required Uint8List firstBytes, required Uint8List secondBytes}) async {
    return SecugenfplibPlatform.instance.getMatchingScore(firstBytes, secondBytes);
  }
}
