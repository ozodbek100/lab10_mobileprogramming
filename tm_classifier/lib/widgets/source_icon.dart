import 'package:flutter/material.dart';

IconData sourceIcon(String source) => switch (source) {
      'Camera' => Icons.photo_camera,
      'Gallery' => Icons.photo_library,
      'Download' => Icons.cloud_download,
      _ => Icons.image,
    };