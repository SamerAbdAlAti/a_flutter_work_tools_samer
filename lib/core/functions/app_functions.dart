import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

class TextEncoder {
  static Pointer<T> textToNative<T extends NativeType>(String string) {
    if (Platform.isWindows) {
      final codeUnits = string.codeUnits;
      final bytes = Uint8List(codeUnits.length * 2 + 2);
      final buffer = bytes.buffer;
      final nativeString = buffer.asUint16List();
      for (var i = 0; i < codeUnits.length; i++) {
        nativeString[i] = codeUnits[i];
      }
      nativeString[codeUnits.length] = 0;
      return Pointer<T>.fromAddress(nativeString.buffer.asByteData().offsetInBytes);
    } else {
      final codeUnits = string.codeUnits;
      final bytes = Uint8List(codeUnits.length + 1);
      final buffer = bytes.buffer;
      final nativeString = buffer.asUint8List();
      for (var i = 0; i < codeUnits.length; i++) {
        final codeUnit = codeUnits[i];
        if (codeUnit <= 0x7F) {
          nativeString[i] = codeUnit;
        } else if (codeUnit <= 0x7FF) {
          nativeString[i] = 0xC0 | (codeUnit >> 6);
          nativeString[i + 1] = 0x80 | (codeUnit & 0x3F);
        } else {
          nativeString[i] = 0xE0 | (codeUnit >> 12);
          nativeString[i + 1] = 0x80 | ((codeUnit >> 6) & 0x3F);
          nativeString[i + 2] = 0x80 | (codeUnit & 0x3F);
        }
      }
      nativeString[codeUnits.length] = 0;
      return Pointer<T>.fromAddress(nativeString.buffer.asByteData().offsetInBytes);
    }
  }
}