import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_compressor_frontend/config.dart';

enum ImageActionType {
  idle,
  compress,
  decompress,
  error,
  download,
}

class AppImageProvider extends ChangeNotifier {
  Uint8List? _displayedImageBytes;
  List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'bmp', 'li'];
  String? _imageExtension;
  Uint8List? _downloadableImageBytes;
  Uint8List? _pickedFileBytes;
  ImageActionType _imageActionType = ImageActionType.idle;

  Dio dio = Dio();

  Completer<Uint8List?>? _compressedImageCompleter;
  Completer<Uint8List?>? _decompressedImageCompleter;

  ImageActionType get imageActionType => _imageActionType;

  Uint8List? get displayedImageBytes => _displayedImageBytes;

  Uint8List? get pickedFileBytes => _pickedFileBytes;

  Uint8List? get downloadableImageBytes => _downloadableImageBytes;

  String? get pickedImageExtension => _imageExtension;

  Completer<Uint8List?>? get compressedImageCompleter => _compressedImageCompleter;

  Completer<Uint8List?>? get decompressedImageCompleter => _decompressedImageCompleter;

  set displayedImageBytes(Uint8List? value) {
    _displayedImageBytes = value;
    notifyListeners();
  }

  set imageActionType(ImageActionType value) {
    _imageActionType = value;
    notifyListeners();
  }

  set pickedFileBytes(Uint8List? value) {
    _pickedFileBytes = value;
    notifyListeners();
  }

  set downloadableImageBytes(Uint8List? value) {
    _downloadableImageBytes = value;
    notifyListeners();
  }

  set pickedImageExtension(String? value) {
    _imageExtension = value;
    notifyListeners();
  }

  set compressedImageCompleter(Completer<Uint8List?>? value) {
    _compressedImageCompleter = value;
    notifyListeners();
  }

  set decompressedImageCompleter(Completer<Uint8List?>? value) {
    _decompressedImageCompleter = value;
    notifyListeners();
  }

  Future<void> pickImage({
    Function? onCancelled,
    Function(Uint8List bytes)? onImagePicked,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    // check if the user cancelled the picker
    if (result == null) {
      onCancelled?.call();
      return;
    }
    // check if the file is an image
    if (!allowedExtensions.contains(result.files.single.extension)) {
      return;
    }
    pickedImageExtension = result.files.single.extension;

    if (pickedImageExtension!.toLowerCase() != "li") {
      displayedImageBytes = result.files.single.bytes;
      imageActionType = ImageActionType.compress;
      pickedFileBytes = result.files.single.bytes;
      onImagePicked?.call(pickedFileBytes!);
      return;
    }
    pickedFileBytes = result.files.single.bytes;
    imageActionType = ImageActionType.decompress;
    onImagePicked?.call(pickedFileBytes!);
  }

  void clearImage() {
    displayedImageBytes = null;
  }

  Future<void> decompressImage() async {
    try {
      decompressedImageCompleter = Completer<Uint8List?>();
      final Response<Uint8List> result = await dio.post(
        '${Configuration.apiBaseUrl}/images/decompress',
        data: FormData.fromMap(
          {
            'image': MultipartFile.fromBytes(pickedFileBytes!, filename: 'image.li'),
          },
        ),
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      // get result as string and convert it to bytes
      final decompressedImageBytes = result.data;
      // set completer value
      _decompressedImageCompleter?.complete(decompressedImageBytes);
      // update downloadable image bytes
      downloadableImageBytes = decompressedImageBytes;
      // display the image
      displayedImageBytes = decompressedImageBytes;
    } catch (e, stackTrace) {
      decompressedImageCompleter?.completeError(e, stackTrace);
      print(e);
      print(stackTrace);
    }
  }

  Future<void> compressImage() async {
    try {
      compressedImageCompleter = Completer<Uint8List?>();
      final result = await dio.post(
        '${Configuration.apiBaseUrl}/images/compress',
        data: FormData.fromMap(
          {
            'image': MultipartFile.fromBytes(displayedImageBytes!, filename: 'image.$pickedImageExtension'),
          },
        ),
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      final compressedImageBytes = result.data;
      _compressedImageCompleter?.complete(compressedImageBytes);
      downloadableImageBytes = compressedImageBytes;
    } catch (e, stackTrace) {
      compressedImageCompleter?.completeError(e, stackTrace);
      print(e);
      print(stackTrace);
    }
  }

  Future<void> downloadCompressedImage() async {
    AnchorElement()
      ..href = 'data:application/octet-stream;base64,${base64Encode(downloadableImageBytes!)}'
      ..download = (imageActionType == ImageActionType.compress) ? 'compressed_image.li' : 'decompressed_image.png'
      ..click();
  }
}
