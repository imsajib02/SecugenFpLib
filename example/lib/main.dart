import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:secugenfplib/secugenfplib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _secugenfplib = Secugenfplib();

  int _timeout_ms = 3000, _quality = 80;

  String? _fingerprintMatchString;
  bool? _isDeviceReady, _isLedOn, _smartCaptureEnabled, _isFingerprintMatched;
  Uint8List? _fpImageBytes, _fpRegisterBytes, _fpVerifyBytes;
  ImageCaptureResult? _firstCaptureResult, _secondCaptureResult;

  @override
  void initState() {
    super.initState();

    _isDeviceReady = false;
    _setControls();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDevice();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Text('Welcome To,\nSecugen Fingerprint SDK Test!!!',
                  style: TextStyle(
                    height: 1.35,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 35,),

                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Expanded(
                      flex: 1,
                      child: _actionButton(
                        btnText: 'OPEN DEVICE',
                        onPressed: _initializeDevice,
                      ),
                    ),

                    SizedBox(width: MediaQuery.of(context).size.width * .07,),

                    Expanded(
                      flex: 1,
                      child: _deviceStatus(),
                    ),
                  ],
                ),

                SizedBox(height: 25,),

                IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Expanded(
                        flex: 1,
                        child: _fingerprintImage(imageBytes: _fpImageBytes),
                      ),

                      SizedBox(width: MediaQuery.of(context).size.width * .07,),

                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            _actionButton(
                              btnText: 'CAPTURE (AUTO ON)',
                              onPressed: () => _isDeviceReady! ? _captureFingerprint(true) : null,
                            ),

                            _actionButton(
                              btnText: 'CAPTURE (AUTO OFF)',
                              onPressed: () => _isDeviceReady! ? _captureFingerprint(false) : null,
                            ),

                            _switchButton(
                              switchVal: _isLedOn!,
                              switchText: 'LED',
                              onSwitch: _isDeviceReady! ? (val) {
                                setState(() => _isLedOn = val);
                                _toggleLed();
                              } : null,
                            ),

                            _switchButton(
                              switchVal: _smartCaptureEnabled!,
                              switchText: 'Smart Capture',
                              onSwitch: _isDeviceReady! ? (val) {
                                setState(() => _smartCaptureEnabled = val);
                                _toggleSmartCapture();
                              } : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30,),

                _fingerprintMatchStatus(),

                SizedBox(height: 10,),

                IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            _fingerprintImage(imageBytes: _fpRegisterBytes),

                            SizedBox(height: 10,),

                            _actionButton(
                              btnText: 'REGISTER FINGER',
                              onPressed: () => _isDeviceReady! ? _captureFirstFinger() : null,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: MediaQuery.of(context).size.width * .07,),

                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            _fingerprintImage(imageBytes: _fpVerifyBytes),

                            SizedBox(height: 10,),

                            _actionButton(
                              btnText: 'VERIFY FINGER',
                              onPressed: () => _isDeviceReady! ? _captureSecondFinger() : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _deviceStatus() {

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          Text('Status:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),

          Text(_isDeviceReady! ? 'READY' : 'NOT READY',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _isDeviceReady! ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fingerprintImage({required Uint8List? imageBytes}) {

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * .25,
      color: Colors.grey[200],
      child: imageBytes == null ? SizedBox() : Image.memory(imageBytes, fit: BoxFit.contain),
    );
  }

  Widget _actionButton({required String btnText, required Function()? onPressed}) {

    return ElevatedButton(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(1),
        backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
      ),
      onPressed: onPressed,
      child: Text(btnText,
        style: TextStyle(
          letterSpacing: .65,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _switchButton({required bool switchVal, required String switchText, required Function(bool)? onSwitch}) {

    return SwitchListTile(
      value: switchVal,
      onChanged: onSwitch,
      dense: true,
      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      title: Text(switchText,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _fingerprintMatchStatus() {

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          Text('Match Status:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),

          Text(_fingerprintMatchString!,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _isFingerprintMatched == null ? Colors.grey : (_isFingerprintMatched! ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _setControls() {

    _fingerprintMatchString = 'NO STATUS AVAILABLE';
    _isFingerprintMatched = _fpImageBytes = _fpRegisterBytes = _fpVerifyBytes = null;

    if(_isDeviceReady!) {
      _isLedOn = false;
      _smartCaptureEnabled = true;
    }
    else {
      _isLedOn = _smartCaptureEnabled = false;
    }

    if(mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeDevice() async {

    try {
      _isDeviceReady = await _secugenfplib.initializeDevice();
    } on SgfplibException catch (e) {
      print(e.message);
      _showAlertDialog(context, e.message!);
    }

    _setControls();
  }

  Future<void> _toggleLed() async {
    _secugenfplib.enableLed(_isLedOn!);
  }

  Future<void> _toggleSmartCapture() async {
    _secugenfplib.enableSmartCapture(_isLedOn!);
  }

  Future<void> _captureFingerprint(bool isAutoOn) async {

    _fpImageBytes = null;

    try {
      final captureResult = await _secugenfplib.captureFingerprint(auto: isAutoOn);
      _fpImageBytes = captureResult!.imageBytes;
    } on SgfplibException catch (e) {
      print(e.message);
      _showAlertDialog(context, e.message!);
    }

    setState(() {});
  }

  Future<void> _captureFirstFinger() async {

    _fpRegisterBytes = _firstCaptureResult = _isFingerprintMatched = null;
    _fingerprintMatchString = 'NO STATUS AVAILABLE';

    try {
      final captureResult = await _secugenfplib.captureFingerprintWithQuality(timeout: _timeout_ms, quality: _quality);
      _fpRegisterBytes = captureResult!.imageBytes;
      _firstCaptureResult = captureResult;
    } on SgfplibException catch (e) {
      print(e.message);
      _showAlertDialog(context, e.message!);
    }

    setState(() {});
  }

  Future<void> _captureSecondFinger() async {

    _fpVerifyBytes = _secondCaptureResult = _isFingerprintMatched = null;
    _fingerprintMatchString = 'NO STATUS AVAILABLE';

    try {
      final captureResult = await _secugenfplib.captureFingerprintWithQuality(timeout: _timeout_ms, quality: _quality);
      _fpVerifyBytes = captureResult!.imageBytes;
      _secondCaptureResult = captureResult;
    } on SgfplibException catch (e) {
      print(e.message);
      _showAlertDialog(context, e.message!);
    }

    setState(() {});

    if(_firstCaptureResult != null && _secondCaptureResult != null) {
      _verifyFingerprints();
    }
  }

  Future<void> _verifyFingerprints() async {

    try {
      final result = await _secugenfplib.verifyFingerprint(firstBytes: _firstCaptureResult!.rawBytes!, secondBytes: _secondCaptureResult!.rawBytes!);
      _isFingerprintMatched = result;
      _fingerprintMatchString = _isFingerprintMatched! ? 'MATCHED' : 'NOT MATCHED';
    } on SgfplibException catch (e) {
      print(e.message);
      _showAlertDialog(context, e.message!);
    }

    setState(() {});
  }

  Future<void> _getScore() async {

    try {
      final result = await _secugenfplib.getMatchingScore(firstBytes: _firstCaptureResult!.rawBytes!, secondBytes: _secondCaptureResult!.rawBytes!);
    } on SgfplibException catch (e) {
      print(e.message);
      _showAlertDialog(context, e.message!);
    }
  }

  void _showAlertDialog(BuildContext context, String message) {

    AlertDialog alert = AlertDialog(
      title: Text("SecuGen Fingerprint SDK"),
      content: Text(message),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
