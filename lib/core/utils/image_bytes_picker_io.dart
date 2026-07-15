import 'package:flutter/services.dart';

import 'picked_image.dart';

const _channel = MethodChannel('liviase/image_picker');

Future<PickedImageBytes?> pickImageBytes() async {
  final result = await _channel.invokeMapMethod<String, Object?>('pickImage');
  if (result == null) return null;

  final bytes = result['bytes'];
  if (bytes is! Uint8List) return null;

  return PickedImageBytes(
    bytes: bytes,
    fileName: (result['fileName'] as String?) ?? 'micronegocio.jpg',
    mimeType: (result['mimeType'] as String?) ?? 'image/jpeg',
  );
}
