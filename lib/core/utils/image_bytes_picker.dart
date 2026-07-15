import 'picked_image.dart';
import 'image_bytes_picker_stub.dart'
    if (dart.library.html) 'image_bytes_picker_web.dart'
    if (dart.library.io) 'image_bytes_picker_io.dart' as implementation;

Future<PickedImageBytes?> pickImageBytes() => implementation.pickImageBytes();
