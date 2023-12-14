class SgfplibException implements Exception {

  String? message;
  SgfplibException({this.message});
}

class DeviceNotSupportedException extends SgfplibException {
  DeviceNotSupportedException({required message}) : super(message: message);
}

class InitializationFailedException extends SgfplibException {
  InitializationFailedException({required message}) : super(message: message);
}

class SensorNotFoundException extends SgfplibException {
  SensorNotFoundException({required message}) : super(message: message);
}

class SmartCaptureEnabledException extends SgfplibException {
  SmartCaptureEnabledException({required message}) : super(message: message);
}

class OutOfRangeException extends SgfplibException {
  OutOfRangeException({required message}) : super(message: message);
}

class NoFingerprintException extends SgfplibException {
  NoFingerprintException({required message}) : super(message: message);
}

class TemplateInitializationException extends SgfplibException {
  TemplateInitializationException({required message}) : super(message: message);
}

class TemplateMatchingException extends SgfplibException {
  TemplateMatchingException({required message}) : super(message: message);
}
