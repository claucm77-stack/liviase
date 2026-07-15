// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

import 'picked_image.dart';

Future<PickedImageBytes?> pickImageBytes() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..click();

  await input.onChange.first;
  final file = input.files?.isNotEmpty == true ? input.files!.first : null;
  if (file == null) return null;

  final reader = html.FileReader()..readAsArrayBuffer(file);
  await reader.onLoad.first;
  final result = reader.result;
  if (result is! ByteBuffer) return null;

  return PickedImageBytes(
    bytes: Uint8List.view(result),
    fileName: file.name,
    mimeType: file.type.isEmpty ? 'image/jpeg' : file.type,
  );
}
