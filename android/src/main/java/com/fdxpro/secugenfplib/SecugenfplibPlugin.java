package com.fdxpro.secugenfplib;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;

import SecuGen.FDxSDKPro.JSGFPLib;
import SecuGen.FDxSDKPro.SGAutoOnEventNotifier;
import SecuGen.FDxSDKPro.SGFDxConstant;
import SecuGen.FDxSDKPro.SGFDxDeviceName;
import SecuGen.FDxSDKPro.SGFDxErrorCode;
import SecuGen.FDxSDKPro.SGFDxSecurityLevel;
import SecuGen.FDxSDKPro.SGFDxTemplateFormat;
import SecuGen.FDxSDKPro.SGFingerInfo;
import SecuGen.FDxSDKPro.SGFingerPresentEvent;
import SecuGen.FDxSDKPro.SGImpressionType;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;

public class SecugenfplibPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, SGFingerPresentEvent {

  private static final String TAG = "SecuGen Lib";
  private static final String CHANNEL = "com.fdxpro.secugenfplib/fingerprintReader";

  private static int IMAGE_CAPTURE_TIMEOUT_MS = 5000;
  private static int IMAGE_CAPTURE_QUALITY = 70;

  private MethodChannel channel;
  private Activity activity;
  private LifeCycleObserver observer;
  private Lifecycle lifecycle;
  private Application application;
  private FlutterPluginBinding pluginBinding;

  private JSGFPLib sgfplib;
  private boolean isDeviceInitialized = false;
  private boolean smartCaptureEnabled;
  private boolean captureWithQuality;
  private int mImageWidth;
  private int mImageHeight;
  private SGAutoOnEventNotifier autoOn;

  private byte[] mRegisterTemplate;
  private byte[] mVerifyTemplate;

  private MethodChannel.Result initializeResult;
  private MethodChannel.Result captureResult;

  private final String METHOD_INIT = "initializeDevice";
  private final String METHOD_TOGGLE_LED = "toggleLed";
  private final String METHOD_TOGGLE_SMART_CAPTURE = "toggleSmartCapture";
  private final String METHOD_SET_BRIGHTNESS = "setBrightness";
  private final String METHOD_CAPTURE_FINGERPRINT = "captureFingerprint";
  private final String METHOD_CAPTURE_FINGERPRINT_WITH_QUALITY = "captureFingerprintWithQuality";
  private final String METHOD_VERIFY_FINGERPRINT = "verifyFingerprint";
  private final String METHOD_GET_MATCHING_SCORE = "getMatchingScore";

  private final static String ERROR_NOT_SUPPORTED = "101";
  private final static String ERROR_INITIALIZATION_FAILED = "102";
  private final static String ERROR_SENSOR_NOT_FOUND = "103";
  private final static String ERROR_SMART_CAPTURE_ENABLED = "201";
  private final static String ERROR_OUT_OF_RANGE = "202";
  private final static String ERROR_NO_FINGERPRINT = "301";
  private final static String ERROR_TEMPLATE_INITIALIZE_FAILED = "302";
  private final static String ERROR_TEMPLATE_MATCHING_FAILED = "303";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.pluginBinding = flutterPluginBinding;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

    if(this.activity == null) {
      result.error("no_activity", "No foreground activity!", null);
      return;
    }

    if(call.method == null || call.method.isEmpty()) {
      result.notImplemented();
      return;
    }

    switch(call.method) {

      case METHOD_INIT:
        initializeResult = result;
        initializeDevice();
        break;

      case METHOD_TOGGLE_LED:
        toggleLed((Boolean) call.arguments);
        break;

      case METHOD_TOGGLE_SMART_CAPTURE:
        toggleSmartCapture((Boolean) call.arguments);
        break;

      case METHOD_SET_BRIGHTNESS:
        setBrightness(result, (int) call.arguments);
        break;

      case METHOD_CAPTURE_FINGERPRINT:
      case METHOD_CAPTURE_FINGERPRINT_WITH_QUALITY:
        handleFingerprintCapturing(result, call.arguments);
        break;

      case METHOD_VERIFY_FINGERPRINT:
        verifyFingerPrint(result, call.arguments);
        break;

      case METHOD_GET_MATCHING_SCORE:
        getMatchingScore(result, call.arguments);
        break;

      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    this.pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(final ActivityPluginBinding binding) {
    setup(this.pluginBinding.getBinaryMessenger(), (Application) this.pluginBinding.getApplicationContext(),
            binding.getActivity(), null, binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(final ActivityPluginBinding binding) {
    this.onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    tearDown();
  }

  public static void registerWith(final io.flutter.plugin.common.PluginRegistry.Registrar registrar) {

    if(registrar.activity() == null) {
      return;
    }

    final Activity activity = registrar.activity();
    Application application = null;

    if(registrar.context() != null) {
      application = (Application) (registrar.context().getApplicationContext());
    }

    final SecugenfplibPlugin plugin = new SecugenfplibPlugin();
    plugin.setup(registrar.messenger(), application, activity, registrar, null);
  }

  private void setup(final BinaryMessenger messenger, final Application application, final Activity activity,
                     final PluginRegistry.Registrar registrar, final ActivityPluginBinding activityBinding) {

    this.activity = activity;
    this.application = application;

    this.channel = new MethodChannel(messenger, CHANNEL);
    this.channel.setMethodCallHandler(this);

    this.observer = new LifeCycleObserver(activity);

    if(registrar != null) {
      application.registerActivityLifecycleCallbacks(this.observer);
    }
    else {
      this.lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(activityBinding);
      this.lifecycle.addObserver(this.observer);
    }
  }

  private void tearDown() {

    if(this.observer != null) {
      this.lifecycle.removeObserver(this.observer);
      this.application.unregisterActivityLifecycleCallbacks(this.observer);
    }

    this.lifecycle = null;
    this.application = null;
    this.channel.setMethodCallHandler(null);
    this.channel = null;
  }

  private class LifeCycleObserver implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {

    private final Activity thisActivity;

    LifeCycleObserver(final Activity activity) {
      this.thisActivity = activity;
    }

    @Override
    public void onCreate(@NonNull final LifecycleOwner owner) {}

    @Override
    public void onStart(@NonNull final LifecycleOwner owner) {}

    @Override
    public void onResume(@NonNull final LifecycleOwner owner) {
      this.onActivityResumed(this.thisActivity);
    }

    @Override
    public void onPause(@NonNull final LifecycleOwner owner) {
      this.onActivityPaused(this.thisActivity);
    }

    @Override
    public void onStop(@NonNull final LifecycleOwner owner) {
      this.onActivityStopped(this.thisActivity);
    }

    @Override
    public void onDestroy(@NonNull final LifecycleOwner owner) {
      this.onActivityDestroyed(this.thisActivity);
    }

    @Override
    public void onActivityCreated(final Activity activity, final Bundle savedInstanceState) {}

    @Override
    public void onActivityStarted(final Activity activity) {}

    @Override
    public void onActivityResumed(final Activity activity) {

      if(!isDeviceInitialized && initializeResult != null) {
        initializeDevice();
      }
    }

    @Override
    public void onActivityPaused(final Activity activity) {

      try {
        if(isDeviceInitialized) {
          autoOn.stop();
          sgfplib.CloseDevice();
          isDeviceInitialized = false;
        }
      }
      catch (Exception e) {
        e.printStackTrace();
      }
    }

    @Override
    public void onActivitySaveInstanceState(final Activity activity, final Bundle outState) {}

    @Override
    public void onActivityDestroyed(final Activity activity) {

      try {
        sgfplib.CloseDevice();
        sgfplib.Close();

        if(this.thisActivity == activity && activity.getApplicationContext() != null) {
          ((Application) activity.getApplicationContext()).unregisterActivityLifecycleCallbacks(this);
        }
      }
      catch (Exception e) {
        e.printStackTrace();
      }
    }

    @Override
    public void onActivityStopped(final Activity activity) {}
  }

  @SuppressLint("UnspecifiedImmutableFlag")
  private void initializeDevice() {

    try {
      sgfplib = new JSGFPLib(activity.getApplicationContext(), (UsbManager) activity.getApplicationContext().getSystemService(Context.USB_SERVICE));
      autoOn = new SGAutoOnEventNotifier(sgfplib, this);

      PendingIntent mPermissionIntent;
      String ACTION_USB_PERMISSION = "com.fdxpro.secugenfplib.USB_PERMISSION";

      if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        mPermissionIntent = PendingIntent.getBroadcast(activity.getApplicationContext(), 0, new Intent(ACTION_USB_PERMISSION), PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
      else
        mPermissionIntent = PendingIntent.getBroadcast(activity.getApplicationContext(), 0, new Intent(ACTION_USB_PERMISSION), 0);

      captureResult = null;
      mRegisterTemplate = null;
      mVerifyTemplate = null;
      isDeviceInitialized = false;
      smartCaptureEnabled = false;
      captureWithQuality = false;

      long error = sgfplib.Init(SGFDxDeviceName.SG_DEV_AUTO);

      if(error != SGFDxErrorCode.SGFDX_ERROR_NONE) {

        String errorCode, errorMsg;

        if(error == SGFDxErrorCode.SGFDX_ERROR_DEVICE_NOT_FOUND) {
          errorCode = ERROR_NOT_SUPPORTED;
          errorMsg = "The attached fingerprint device is not supported!";
        }
        else {
          errorCode = ERROR_INITIALIZATION_FAILED;
          errorMsg = "Fingerprint device initialization failed!";
        }

        Log.e(TAG, errorMsg);
        initializeResult.error(errorCode, errorMsg, null);
        return;
      }

      UsbDevice usbDevice = sgfplib.GetUsbDevice();

      if(usbDevice == null) {

        String errorMsg = "SecuGen fingerprint sensor not found!";

        Log.e(TAG, errorMsg);
        initializeResult.error(ERROR_SENSOR_NOT_FOUND, errorMsg, null);
        return;
      }

      boolean hasPermission = sgfplib.GetUsbManager().hasPermission(usbDevice);

      if(!hasPermission) {
        Log.e(TAG, "Requesting USB Permission");
        sgfplib.GetUsbManager().requestPermission(usbDevice, mPermissionIntent);
        return;
      }

      Log.e(TAG, "Opening SecuGen Device");

      error = sgfplib.OpenDevice(0);

      if(error == SGFDxErrorCode.SGFDX_ERROR_NONE) {

        isDeviceInitialized = true;
        SecuGen.FDxSDKPro.SGDeviceInfoParam deviceInfo = new SecuGen.FDxSDKPro.SGDeviceInfoParam();
        sgfplib.GetDeviceInfo(deviceInfo); //getting secugen usb device info

        //getting image width, height, dpi by the device
        mImageWidth = deviceInfo.imageWidth;
        mImageHeight= deviceInfo.imageHeight;

        sgfplib.SetTemplateFormat(SGFDxTemplateFormat.TEMPLATE_FORMAT_ISO19794);

        int[] mMaxTemplateSize = new int[1];
        sgfplib.GetMaxTemplateSize(mMaxTemplateSize);

        mRegisterTemplate = new byte [(int) mMaxTemplateSize[0]];
        mVerifyTemplate = new byte [(int) mMaxTemplateSize[0]];

        sgfplib.WriteData(SGFDxConstant.WRITEDATA_COMMAND_ENABLE_SMART_CAPTURE, (byte)1); //smart capture enabled
        smartCaptureEnabled = true;

        Log.e(TAG, "SecuGen Device Ready");
        initializeResult.success(true); //sending device ready alert through method channel
        return;
      }

      Log.e(TAG, "Waiting for USB Permission");
    }
    catch (Exception e) {
      //result already returned
    }
  }

  private void toggleLed(boolean val) {
    sgfplib.SetLedOn(val);
    Log.e(TAG, "LED ----- " + (val ? "On" : "Off"));
  }

  private void toggleSmartCapture(boolean isEnabled) {

    smartCaptureEnabled = isEnabled;

    if(smartCaptureEnabled)
      sgfplib.WriteData(SGFDxConstant.WRITEDATA_COMMAND_ENABLE_SMART_CAPTURE, (byte)1);
    else
      sgfplib.WriteData(SGFDxConstant.WRITEDATA_COMMAND_ENABLE_SMART_CAPTURE, (byte)0);

    Log.e(TAG, "Smart Capture ----- " + (smartCaptureEnabled ? "Enabled" : "Disabled"));
  }

  private void setBrightness(MethodChannel.Result result, int val) {

    if(smartCaptureEnabled) {
      result.error(ERROR_SMART_CAPTURE_ENABLED, "Smart capture is enabled!", null);
      return;
    }

    if(!(val >= 0 && val <= 100)) {
      result.error(ERROR_OUT_OF_RANGE, "Level is out of range!", null);
      return;
    }

    sgfplib.SetBrightness(val);
    Log.e(TAG, "Brightness ----- " + val);
  }

  private void handleFingerprintCapturing(MethodChannel.Result result, Object arguments) {

    captureResult = result;

    if(arguments instanceof Boolean) {

      captureWithQuality = false;

      if((Boolean) arguments) {
        autoOn.start();
        return;
      }

      captureFingerPrint();
      return;
    }

    if(arguments instanceof ArrayList) {

      IMAGE_CAPTURE_TIMEOUT_MS = (int) ((ArrayList<?>) arguments).get(0);
      IMAGE_CAPTURE_QUALITY = (int) ((ArrayList<?>) arguments).get(1);
      captureWithQuality = true;

      if((Boolean) ((ArrayList<?>) arguments).get(2)) {
        autoOn.start();
        return;
      }

      captureFingerPrint();
    }
  }

  private void captureFingerPrint() {

    byte[] bytes = new byte[mImageWidth * mImageHeight];

    if(!captureWithQuality)
      sgfplib.GetImage(bytes);
    else
      sgfplib.GetImageEx(bytes, IMAGE_CAPTURE_TIMEOUT_MS, IMAGE_CAPTURE_QUALITY);

    sgfplib.SetTemplateFormat(SecuGen.FDxSDKPro.SGFDxTemplateFormat.TEMPLATE_FORMAT_ISO19794);

    int[] quality = new int[1];
    sgfplib.GetImageQuality(mImageWidth, mImageHeight, bytes, quality);

    if(quality[0] == 0) {
      captureResult.error(ERROR_NO_FINGERPRINT, "No fingerprint!", null);
      return;
    }

    byte[] imageBytes = getImageBytes(bytes);

    ArrayList<Object> results = new ArrayList<>();
    results.add(bytes);
    results.add(imageBytes);
    results.add(quality[0]);

    captureResult.success(results);
    captureResult = null;
  }

  private byte[] getImageBytes(byte[] buffer) {

    byte[] Bits = new byte[buffer.length * 4];

    for(int i = 0; i < buffer.length; i++) {
      Bits[i * 4] = Bits[i * 4 + 1] = Bits[i * 4 + 2] = buffer[i]; // Invert the source bits
      Bits[i * 4 + 3] = -1; // 0xff, that's the alpha.
    }

    Bitmap bitmap = Bitmap.createBitmap(mImageWidth, mImageHeight, Bitmap.Config.ARGB_8888);
    bitmap.copyPixelsFromBuffer(ByteBuffer.wrap(Bits)); //converting image bytes into bitmap

    ByteArrayOutputStream stream = new ByteArrayOutputStream();
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
    byte[] byteArray = stream.toByteArray(); //converting image bitmap into presentable image bytes
    bitmap.recycle();

    return byteArray;
  }

  private void verifyFingerPrint(MethodChannel.Result result, Object arguments) {

    if(!createTemplate(result, (byte[]) ((ArrayList<?>) arguments).get(0), mRegisterTemplate))
      return;

    if(!createTemplate(result, (byte[]) ((ArrayList<?>) arguments).get(1), mVerifyTemplate))
      return;

    boolean[] matched = new boolean[1];
    long matchResult = sgfplib.MatchTemplate(mRegisterTemplate, mVerifyTemplate, SGFDxSecurityLevel.SL_NORMAL, matched);

    if(matchResult != SGFDxErrorCode.SGFDX_ERROR_NONE) {
      result.error(ERROR_TEMPLATE_MATCHING_FAILED, "Template matching failed!", null);
      return;
    }

    result.success(matched[0]);
  }

  private void getMatchingScore(MethodChannel.Result result, Object arguments) {

    if(!createTemplate(result, (byte[]) ((ArrayList<?>) arguments).get(0), mRegisterTemplate))
      return;

    if(!createTemplate(result, (byte[]) ((ArrayList<?>) arguments).get(1), mVerifyTemplate))
      return;

    int[] score = new int[1];
    long matchResult = sgfplib.GetMatchingScore(mRegisterTemplate, mVerifyTemplate, score);

    if(matchResult != SGFDxErrorCode.SGFDX_ERROR_NONE) {
      result.error(ERROR_TEMPLATE_MATCHING_FAILED, "Template matching failed!", null);
      return;
    }

    result.success(score[0]);
  }

  private boolean createTemplate(MethodChannel.Result result, byte[] rawImageBytes, byte[] templateBytes) {

    int[] quality = new int[1];
    sgfplib.GetImageQuality(mImageWidth, mImageHeight, rawImageBytes, quality);

    Arrays.fill(templateBytes, (byte) 0);
    long firstTemplateResult = sgfplib.CreateTemplate(getFingerInfo(quality), rawImageBytes, templateBytes);

    if(firstTemplateResult != SGFDxErrorCode.SGFDX_ERROR_NONE) {
      result.error(ERROR_TEMPLATE_INITIALIZE_FAILED, "Template initialize failed!", null);
      return false;
    }

    return true;
  }

  private SGFingerInfo getFingerInfo(int[] quality) {

    SGFingerInfo fpInfo = new SGFingerInfo();
    fpInfo.FingerNumber = 1;
    fpInfo.ImageQuality = quality[0];
    fpInfo.ImpressionType = SGImpressionType.SG_IMPTYPE_LP;
    fpInfo.ViewNumber = 1;

    return fpInfo;
  }

  @Override
  public void SGFingerPresentCallback() {
    autoOn.stop();
    fingerDetectedHandler.sendMessage(new Message());
  }

  @SuppressLint("HandlerLeak")
  public Handler fingerDetectedHandler = new Handler() {

    public void handleMessage(Message msg) {
      captureFingerPrint();
    }
  };
}
