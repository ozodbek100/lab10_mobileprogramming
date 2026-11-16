import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// An error whose message is meant to be shown to the user as it is.
class ImageSourceException implements Exception {
  const ImageSourceException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Camera, gallery and URL. Each method only returns bytes.
/// Classifying happens somewhere else, so there is one shared path.
class ImageSources {
  static const timeout = Duration(seconds: 15);
  static const maxDownloadBytes = 15 * 1024 * 1024; // 15 MB

  final _picker = ImagePicker();

  /// null = the user cancelled. That is not an error.
  Future<Uint8List?> fromCamera() => _pick(ImageSource.camera, 'camera');

  /// null = the user cancelled.
  Future<Uint8List?> fromGallery() => _pick(ImageSource.gallery, 'gallery');

  Future<Uint8List?> _pick(ImageSource source, String name) async {
    try {
      // maxWidth shrinks a 12 MP photo before it reaches Dart. The model only
      // looks at 224x224 pixels, so decoding the full photo would waste time.
      final file = await _picker.pickImage(source: source, maxWidth: 1024);
      return file == null ? null : await file.readAsBytes();
    } on PlatformException catch (e) {
      throw ImageSourceException(
        'Could not open the $name: ${e.message ?? e.code}',
      );
    }
  }

  /// Downloads a picture. Every failure becomes a readable message.
  Future<Uint8List> fromUrl(String address) async {
    final uri = Uri.tryParse(address.trim());
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      throw const ImageSourceException(
        'That is not a valid web address. It must start with https://',
      );
    }

    final http.Response response;
    try {
      response = await http.get(uri, headers: {
        // Some sites answer 403 to the default Dart client.
        'User-Agent': 'Mozilla/5.0 (Lab10 TM Classifier)',
        'Accept': 'image/*',
      }).timeout(timeout);
    } on TimeoutException {
      throw const ImageSourceException(
        'The download took too long and was stopped. Try again.',
      );
    } on SocketException {
      throw const ImageSourceException(
        'No network connection, or that address does not exist.',
      );
    } on HandshakeException {
      throw const ImageSourceException(
        'A secure connection to that site could not be made.',
      );
    } on http.ClientException {
      throw const ImageSourceException(
        'Could not reach that address. Check your internet connection.',
      );
    }

    // Accept the response only when it really is a picture.
    if (response.statusCode != 200) {
      throw ImageSourceException(
        'The server answered ${response.statusCode} instead of a picture.',
      );
    }
    final type = (response.headers['content-type'] ?? '').toLowerCase();
    if (!type.startsWith('image/')) {
      throw const ImageSourceException(
        'That address is a web page, not a picture. Use the direct image '
        'address (right-click the picture, then "Copy image address").',
      );
    }
    if (response.bodyBytes.isEmpty) {
      throw const ImageSourceException('The server sent an empty file.');
    }
    if (response.bodyBytes.length > maxDownloadBytes) {
      throw const ImageSourceException('That picture is too large (over 15 MB).');
    }
    return response.bodyBytes;
  }
}