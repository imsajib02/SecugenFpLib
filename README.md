# Secugen Fingerprint Reader

A plugin that allows you to use the native Secugen FDx Pro SDK to capture and verify fingerprints using
Secugen external USB device.

## Platform Support

| Android |
| :-----: |
|   ✅    |

## Currently supported features

* Initializing USB fingerprint device
* Led control (On/Off)
* Smart capture control (Enable/Disable)
* Brightness control (Only when **Smart capture** is disabled)
* Capture fingerprint
* Capture fingerprint with **Timeout** and **Quality**
* Auto capture fingerprint
* Fingerprint verification
* Fingerprint matching score

## How to use

You can import the package with:
```dart
import 'package:secugenfplib/secugenfplib.dart';
```

#### Plugin Initialization

```dart
final _secugenfplib = Secugenfplib();
```

#### Initialize the Device

The Secugen USB device must be initialized before it can be used. When initializing, the USB device
must be connected to the Android device through USB. The `android.permission.USB_PERMISSION` usb
permission is requested to access the usb device during device initialization. Custom `SgfplibException`
exception might be thrown during initialization if device is not supported or sensor not found etc.

```dart
try {
  bool? isDeviceReady = await _secugenfplib.initializeDevice();
} on SgfplibException catch (e) {
  //handle the exception
}
```

#### Led Control

The `enableLed()` function controls the led light of the USB device. It takes `bool` **true/false**
as parameter to enable and disable the led light.

```dart
_secugenfplib.enableLed(bool val);
```

#### Smart Capture

The Secugen device drivers use Smart Capture technology to dynamically adjust brightness to ensure
the best image quality. Smart Capture is enabled by default during device initialization. To manually
enable or disable Smart Capture use `enableSmartCapture()` function with a `bool` type parameter.

```dart
_secugenfplib.enableSmartCapture(bool val);
```

#### Brightness Control

To manually control the quality of a captured image, the image brightness should be adjusted by
changing the brightness setting using `setBrightness()` function. This function is ignored if
Smart Capture is enabled. `SgfplibException` exception might be thrown if Smart Capture is enabled
or brightness level value is not between `0` to `100`.

```dart
try {
  await _secugenfplib.setBrightness(int brightnessLevel); // Set from 0 to 100
} on SgfplibException catch (e) {
  //handle the exception
}
```

#### Capture Fingerprint

The `captureFingerprint()` function is used to capture fingerprint image. It captures an image without
checking for the image quality.

```dart
try {
  final captureResult = await _secugenfplib.captureFingerprint();
} on SgfplibException catch (e) {
  //handle the exception
}
```

The `captureFingerprintWithQuality()` captures fingerprint images continuously for the given time period,
checks the image quality against a specified given quality value and ignores if the quality of the
fingerprint is not acceptable. The `timeout` parameter accepts an `int` value in milliseconds.

```dart
try {
  final captureResult = await _secugenfplib.captureFingerprintWithQuality(timeout: TIMEOUT_IN_MS, quality: QUALITY);
} on SgfplibException catch (e) {
  //handle the exception
}
```

Both the `captureFingerprint()` and `captureFingerprintWithQuality()` functions return an object of type
`ImageCaptureResult`. The `ImageCaptureResult` has three properties - `rawBytes` as (`Uint8List` original
fingerprint bytes), `imageBytes` as (`Uint8List` image representable bytes) and `quality` as (`int`
quality of the image). `SgfplibException` exception might be thrown if no fingerprint is present.

#### Auto Capture

The `captureFingerprint()` and `captureFingerprintWithQuality()` both functions support auto capture.
If auto capture is on, the attached fingerprint device continuously checks for the presence of a finger.
An image is returned if any fingerprint is detected.

```dart
final captureResult = await _secugenfplib.captureFingerprint(auto: bool isAutoOn);
```

```dart
final captureResult = await _secugenfplib.captureFingerprintWithQuality(timeout: TIMEOUT_IN_MS, quality: QUALITY, auto: bool isAutoOn);
```

#### Fingerprint Verification

The `verifyFingerprint()` function uses two raw bytes from two different fingerprint `ImageCaptureResult`
for verification. It creates a template for each fingerprint bytes and uses these templates for matching.

```dart
try {
  bool? isMatch = await _secugenfplib.verifyFingerprint(firstBytes: FIRST_RAW_BYTES, secondBytes: SECOND_RAW_BYTES);
} on SgfplibException catch (e) {
  //handle the exception
}
```

#### Fingerprint Matching Score

To manually determine the verification of two fingerprints, a matching score can be used. The `getMatchingScore()`
function returns a score comparing two raw fingerprint bytes of `ImageCaptureResult`. The score can be between
`0` to `200`. The higher the score, the higher the matching accuracy is.

```dart
try {
  int? score = await _secugenfplib.getMatchingScore(firstBytes: FIRST_RAW_BYTES, secondBytes: SECOND_RAW_BYTES);
} on SgfplibException catch (e) {
  //handle the exception
}
```

## Example App

![DemoAndroid](https://github.com/imsajib02/SecugenFpLib/blob/main/example/screenshots/android_example.gif)

## Additional Configuration

Add the configuration below to your Android `manifest`, if you want your app to open automatically
whenever the USB device is connected. If USB permission is granted, this configuration allows your app
to open immediately after the USB device is connected to the Android device.

Inside the `<activity></activity>` tag, add:

```xml
<intent-filter>
    <action android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED" />
</intent-filter>

<meta-data android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED"
    android:resource="@xml/device_filter" />
```

Next, inside the `app` >> `src` >> `main` >> `res` >> `xml` directory, add an `xml` file name `device_filter.xml`.
Copy and paste the `xml` code below in the `device_filter.xml` file:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!--SecuGen SDU03P 0x1162 0x1000-->
    <usb-device vendor-id="4450" product-id="4096" />
    <!--SecuGen SDU04P  0x1162 0x2000-->
    <usb-device vendor-id="4450" product-id="8192" />
    <!--SecuGen U20  0x1162 0x2200-->
    <usb-device	vendor-id="4450" product-id="8704" />
    <!--SecuGen U20-2  0x1162 0x22BA-->
    <usb-device	vendor-id="4450" product-id="8890" />
    <!--SecuGen UPx  0x1162 0x2201-->
    <usb-device	vendor-id="4450" product-id="8705" />
    <!--SecuGen U10  0x1162 0x2203-->
    <usb-device	vendor-id="4450" product-id="8707" />
    <!--SecuGen U20-AP  0x1162 0x2220-->
    <usb-device	vendor-id="4450" product-id="8736" />
    <!--SecuGen U20-A  0x1162 0x2240-->
    <usb-device	vendor-id="4450" product-id="8768" />
    <!--SecuGen U20-AP-A  0x1162 0x2360-->
    <usb-device	vendor-id="4450" product-id="9056" />
    <!--SecuGen U30-A  0x1162 0x2410-->
    <usb-device	vendor-id="4450" product-id="9232" />
    <!--SecuGen U-AIR  0x1162 0x2500-->
    <usb-device	vendor-id="4450" product-id="9472" />
</resources>
```