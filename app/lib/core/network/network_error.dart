/// Resolves "is this a connection failure?" without importing `dart:io`.
///
/// `dart:io` does not exist in the JavaScript build used by Flutter Web, so
/// naming `SocketException` directly would break `flutter build web`. The
/// conditional export below picks the `dart:io` aware implementation on native
/// platforms and the no-op one on Web.
library;

export 'network_error_stub.dart'
    if (dart.library.io) 'network_error_io.dart';
