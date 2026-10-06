import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_child_hub/core/network/api_exception.dart';
import 'package:smart_child_hub/core/repositories/child_repository.dart';
import 'package:smart_child_hub/core/theme/app_theme.dart';
import 'package:smart_child_hub/models/child_model.dart';
import 'package:smart_child_hub/providers/child_provider.dart';
import 'package:smart_child_hub/widgets/common/child_avatar.dart';

const String _photoUrl =
    'http://localhost/Smart-Child-Daily-Activity-Tracking-System/backend/public/uploads/child-abc.png';

/// Records what the provider sent and replays a canned server response.
class _FakeChildRepository extends ChildRepository {
  ApiException? failWith;
  Map<String, dynamic>? lastUpdatePayload;
  Uint8List? lastUploadBytes;
  String? lastUploadFilename;
  String? lastRemovedChildId;
  int updateCalls = 0;

  static ChildModel _child({String photoUrl = '', String name = 'Noah'}) {
    return ChildModel(
      id: 'c-1',
      name: name,
      age: 7,
      grade: 'Grade 2',
      avatarKey: 'sky',
      photoUrl: photoUrl,
    );
  }

  @override
  Future<List<ChildModel>> children() async => [_child(photoUrl: _photoUrl)];

  @override
  Future<ChildModel> update(String id, Map<String, dynamic> payload) async {
    updateCalls++;
    lastUpdatePayload = payload;
    if (failWith != null) throw failWith!;
    return _child(name: payload['name'] as String? ?? 'Noah');
  }

  @override
  Future<ChildModel> uploadPhoto({
    required String childId,
    required Uint8List bytes,
    required String filename,
  }) async {
    lastUploadBytes = bytes;
    lastUploadFilename = filename;
    if (failWith != null) throw failWith!;
    return _child(photoUrl: _photoUrl);
  }

  @override
  Future<ChildModel> removePhoto(String childId) async {
    lastRemovedChildId = childId;
    if (failWith != null) throw failWith!;
    return _child();
  }
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Child photo persistence', () {
    late _FakeChildRepository repository;
    late ChildProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = _FakeChildRepository();
      provider = ChildProvider(repository: repository);
      await provider.load();
    });

    test('a child loaded with a photo exposes the URL', () {
      expect(provider.children.single.photoUrl, _photoUrl);
    });

    test('updateChild never sends photoUrl back to the server', () async {
      await provider.updateChild(provider.children.single.copyWith(name: 'Noah Jr'));

      expect(repository.updateCalls, 1);
      // The photo can only change through the upload/remove endpoints; echoing
      // it back here would let a stale value clobber a newer upload.
      expect(repository.lastUpdatePayload!.containsKey('photoUrl'), isFalse);
      expect(provider.children.single.name, 'Noah Jr');
    });

    test('uploadPhoto stores the returned URL on the child', () async {
      final Uint8List bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
      final ChildModel? updated = await provider.uploadPhoto(
        childId: 'c-1',
        bytes: bytes,
        filename: 'pick.png',
      );

      expect(repository.lastUploadBytes, bytes);
      expect(repository.lastUploadFilename, 'pick.png');
      expect(updated?.photoUrl, _photoUrl);
      expect(provider.children.single.photoUrl, _photoUrl);
      expect(provider.error, isNull);
    });

    test('removePhoto clears the photo so the monogram comes back', () async {
      expect(provider.children.single.photoUrl, _photoUrl);

      final ChildModel? updated = await provider.removePhoto('c-1');

      expect(repository.lastRemovedChildId, 'c-1');
      expect(updated?.photoUrl, '');
      expect(provider.children.single.photoUrl, '');
      expect(provider.error, isNull);
    });

    test('removePhoto is safe when the child has no photo', () async {
      provider.removePhoto('c-1');
      await provider.removePhoto('c-1');

      expect(provider.children.single.photoUrl, '');
      expect(provider.error, isNull);
    });

    test('a failed removal surfaces the server message and keeps the photo', () async {
      repository.failWith = const ApiException(
        ApiErrorKind.validation,
        statusCode: 400,
        message: 'Unsupported image type. Use JPG, PNG or WEBP.',
      );

      final ChildModel? updated = await provider.removePhoto('c-1');

      expect(updated, isNull);
      expect(provider.error, contains('Unsupported image type'));
      expect(provider.children.single.photoUrl, _photoUrl);
    });

    test('a failed upload does not clear the existing photo', () async {
      repository.failWith = const ApiException(
        ApiErrorKind.validation,
        statusCode: 400,
        message: 'The photo must be 5 MB or smaller.',
      );

      final ChildModel? updated = await provider.uploadPhoto(
        childId: 'c-1',
        bytes: Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]),
        filename: 'big.png',
      );

      expect(updated, isNull);
      expect(provider.error, contains('5 MB or smaller'));
      expect(provider.children.single.photoUrl, _photoUrl);
    });
  });

  group('ChildModel photoUrl', () {
    test('defaults to empty when the API omits it', () {
      final ChildModel child = ChildModel.fromJson(const {
        'id': 'c-9',
        'name': 'Ava',
        'age': 6,
        'grade': 'Grade 1',
        'aboutChild': '',
        'avatarKey': 'mint',
        'hasPin': true,
        'coins': 0,
        'streakDays': 0,
        'securityQuestions': <dynamic>[],
      });

      expect(child.photoUrl, '');
    });

    test('round-trips through toJson', () {
      final ChildModel child = ChildModel(
        id: 'c-9',
        name: 'Ava',
        age: 6,
        grade: 'Grade 1',
        avatarKey: 'mint',
        photoUrl: _photoUrl,
      );

      expect(child.toJson()['photoUrl'], _photoUrl);
      expect(ChildModel.fromJson(child.toJson()).photoUrl, _photoUrl);
    });

    test('copyWith keeps the photo when it is not overridden', () {
      final ChildModel child = ChildModel(
        id: 'c-9',
        name: 'Ava',
        age: 6,
        grade: 'Grade 1',
        avatarKey: 'mint',
        photoUrl: _photoUrl,
      );

      expect(child.copyWith(name: 'Ava B').photoUrl, _photoUrl);
      expect(child.copyWith(photoUrl: '').photoUrl, '');
    });
  });

  group('ChildAvatar photo rendering', () {
    testWidgets('shows the monogram when there is no photo', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const ChildAvatar(name: 'Noah', avatarKey: 'sky')));

      expect(find.byType(Image), findsNothing);
      expect(find.text('N'), findsOneWidget);
    });

    testWidgets('shows the monogram for an empty or whitespace URL', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const ChildAvatar(name: 'Noah', avatarKey: 'sky', photoUrl: '   ')),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.text('N'), findsOneWidget);
    });

    testWidgets('refuses to render a local file path', (WidgetTester tester) async {
      // The photo must never be a device path; a local path falls back to the
      // monogram instead of being displayed or persisted.
      await tester.pumpWidget(
        _wrap(
          const ChildAvatar(name: 'Noah', avatarKey: 'sky', photoUrl: r'C:\Users\kid\photo.png'),
        ),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.text('N'), findsOneWidget);
    });

    testWidgets('renders a network image for an absolute http URL', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const ChildAvatar(name: 'Noah', avatarKey: 'sky', photoUrl: _photoUrl)),
      );

      final Image image = tester.widget<Image>(find.byType(Image));
      expect((image.image as NetworkImage).url, _photoUrl);
    });

    testWidgets('declares a monogram fallback for a failed image load', (
      WidgetTester tester,
    ) async {
      // A photo URL can 404 after the file is removed on the server, so the
      // Image must carry an errorBuilder that restores the monogram.
      await tester.pumpWidget(
        _wrap(const ChildAvatar(name: 'Noah', avatarKey: 'sky', photoUrl: _photoUrl)),
      );

      final Image image = tester.widget<Image>(find.byType(Image));
      expect(image.errorBuilder, isNotNull);
      expect(image.gaplessPlayback, isTrue);
    });
  });
}
