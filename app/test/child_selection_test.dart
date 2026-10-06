import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_child_hub/core/repositories/child_repository.dart';
import 'package:smart_child_hub/core/theme/app_theme.dart';
import 'package:smart_child_hub/models/child_model.dart';
import 'package:smart_child_hub/providers/auth_provider.dart';
import 'package:smart_child_hub/providers/child_provider.dart';
import 'package:smart_child_hub/providers/dummy_data.dart';
import 'package:smart_child_hub/routes/app_routes.dart';
import 'package:smart_child_hub/screens/child/child_shell.dart';
import 'package:smart_child_hub/widgets/common/nav_shell.dart';

class _FakeChildRepository extends ChildRepository {
  @override
  Future<List<ChildModel>> children() async => DummyData.children();

  @override
  Future<ChildModel> create(Map<String, dynamic> payload) async => ChildModel(
    id: 'c-new',
    name: payload['name'] as String? ?? 'New child',
    age: payload['age'] as int? ?? 7,
    grade: payload['grade'] as String? ?? '',
    aboutChild: payload['aboutChild'] as String? ?? '',
    avatarKey: payload['avatarKey'] as String? ?? 'fox',
    pin: payload['pin'] as String? ?? '',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChildProvider explicit selection', () {
    late ChildProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = ChildProvider(repository: _FakeChildRepository());
    });

    test('load() does not auto-select the first child', () async {
      await provider.load();

      expect(provider.hasLoaded, isTrue);
      expect(provider.children, isNotEmpty);
      expect(provider.selectedChildId, isNull);
      expect(provider.selectedChild, isNull);
      expect(provider.hasSelection, isFalse);
    });

    test('addChild() adds without changing the selection', () async {
      await provider.load();
      provider.selectChild(provider.children.first.id);

      final ChildModel? created = await provider.addChild(
        ChildModel(id: 'ignored', name: 'Noah', age: 6, grade: 'Grade 1', avatarKey: 'fox'),
      );

      expect(created, isNotNull);
      expect(provider.children.any((ChildModel c) => c.id == 'c-new'), isTrue);
      expect(provider.selectedChildId, provider.children.first.id);
    });

    test('seedChild() adopts the signed-in child as the selection', () async {
      provider.seedChild(DummyData.children().first);

      expect(provider.selectedChildId, DummyData.children().first.id);
      expect(provider.hasSelection, isTrue);
    });

    test('clearSelection() keeps children but drops the selection', () async {
      await provider.load();
      provider.selectChild(provider.children.first.id);

      provider.clearSelection();

      expect(provider.children, isNotEmpty);
      expect(provider.hasSelection, isFalse);
      expect(provider.selectedChild, isNull);
    });

    test('load() drops a selection that no longer exists', () async {
      await provider.load();
      provider.selectChild('c-deleted');

      await provider.load();

      expect(provider.selectedChildId, isNull);
    });

    test('ensureSelection() focuses the first child (parent zone only)', () async {
      await provider.load();

      provider.ensureSelection();

      expect(provider.selectedChildId, provider.children.first.id);
    });

    test('ensureSelection() never overrides an explicit selection', () async {
      await provider.load();
      final String second = provider.children[1].id;
      provider.selectChild(second);

      provider.ensureSelection();

      expect(provider.selectedChildId, second);
    });

    test('ensureSelection() is a no-op with no children', () async {
      provider.ensureSelection();

      expect(provider.selectedChildId, isNull);
    });
  });

  testWidgets('ChildShell redirects to the picker when nothing is selected', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final ChildProvider childProvider = ChildProvider(repository: _FakeChildRepository());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider()
              ..updateUser(DummyData.parentUser())
              ..setMode(AppMode.child),
          ),
          ChangeNotifierProvider<ChildProvider>.value(value: childProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          onGenerateRoute: (RouteSettings settings) => MaterialPageRoute<void>(
            builder: (_) => settings.name == AppRoutes.childShell
                ? const ChildShell()
                : Text('route:${settings.name}'),
            settings: settings,
          ),
          initialRoute: AppRoutes.childShell,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(childProvider.hasSelection, isFalse);
    expect(find.text('route:${AppRoutes.chooseProfile}'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });
}
