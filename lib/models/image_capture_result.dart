import 'dart:typed_data';

class ImageCaptureResult {

  Uint8List? rawBytes;
  Uint8List? imageBytes;
  int? quality;

  ImageCaptureResult({this.rawBytes, this.imageBytes, this.quality});
}