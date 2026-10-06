import 'dart:io';

/// Native (Android/iOS/Windows/macOS/Linux) build: a dropped or refused
/// connection throws a `SocketException`, which must be reported as a friendly
/// "no internet" message rather than an internal error.
bool isNetworkFailure(Object error) => error is SocketException;
