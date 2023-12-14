const String CHANNEL = 'com.fdxpro.secugenfplib/fingerprintReader';

const String METHOD_INIT = 'initializeDevice';
const String METHOD_TOGGLE_LED = 'toggleLed';
const String METHOD_TOGGLE_SMART_CAPTURE = 'toggleSmartCapture';
const String METHOD_SET_BRIGHTNESS = 'setBrightness';
const String METHOD_CAPTURE_FINGERPRINT = 'captureFingerprint';
const String METHOD_CAPTURE_FINGERPRINT_WITH_QUALITY = 'captureFingerprintWithQuality';
const String METHOD_VERIFY_FINGERPRINT = 'verifyFingerprint';
const String METHOD_GET_MATCHING_SCORE = 'getMatchingScore';

const String ERROR_NOT_SUPPORTED = '101';
const String ERROR_INITIALIZATION_FAILED = '102';
const String ERROR_SENSOR_NOT_FOUND = '103';
const String ERROR_SMART_CAPTURE_ENABLED = '201';
const String ERROR_OUT_OF_RANGE = '202';
const String ERROR_NO_FINGERPRINT = '301';
const String ERROR_TEMPLATE_INITIALIZE_FAILED = '302';
const String ERROR_TEMPLATE_MATCHING_FAILED = '303';