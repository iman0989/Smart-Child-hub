import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_child_hub/core/network/api_exception.dart';
import 'package:smart_child_hub/core/repositories/auth_repository.dart';
import 'package:smart_child_hub/models/child_model.dart';
import 'package:smart_child_hub/providers/auth_provider.dart';
import 'package:smart_child_hub/providers/child_provider.dart';
import 'package:smart_child_hub/screens/child/child_pin_recovery_screen.dart';
import 'package:smart_child_hub/screens/child/child_pin_reset_screen.dart';
import 'package:smart_child_hub/screens/child/child_pin_screen.dart';

/// Records recovery calls and returns canned answers, so the flow can be
/// exercised without a server.
class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository();

  List<String> questionKeys = const <String>['favorite_book', 'pet_name'];
  String? verifyErrorMessage;
  String? questionsErrorMessage;
  String? resetErrorMessage;
  String recoveryToken = 'token-abc';

  Map<String, String>? lastAnswers;
  String? lastRecoveryToken;
  String? lastNewPin;
  String? lastNewPinConfirmation;
  int verifyCalls = 0;
  int resetCalls = 0;

  @override
  Future<ChildRecoveryChallenge> childRecoveryQuestions({
    required String childId,
    String? name,
  }) async {
    if (questionsErrorMessage != null) {
      throw ApiException(ApiErrorKind.validation, message: questionsErrorMessage);
    }
    return ChildRecoveryChallenge(childId: childId, name: name ?? '', questions: questionKeys);
  }

  @override
  Future<ChildRecoveryGrant> verifyChildRecovery({
    required String childId,
    String? name,
    required Map<String, String> answers,
  }) async {
    verifyCalls++;
    lastAnswers = answers;
    if (verifyErrorMessage != null) {
      throw ApiException(ApiErrorKind.validation, message: verifyErrorMessage);
    }
    return ChildRecoveryGrant(childId: childId, recoveryToken: recoveryToken, expiresInMinutes: 15);
  }

  @override
  Future<ChildRecoveryResult> resetChildPin({
    required String recoveryToken,
    required String newPin,
    required String newPinConfirmation,
  }) async {
    resetCalls++;
    lastRecoveryToken = recoveryToken;
    lastNewPin = newPin;
    lastNewPinConfirmation = newPinConfirmation;
    if (resetErrorMessage != null) {
      throw ApiException(ApiErrorKind.validation, message: resetErrorMessage);
    }
    return ChildRecoveryResult(childId: 'c-1', name: 'Mia');
  }
}

void main() {
  final ChildModel mia = ChildModel(
    id: 'c-1',
    name: 'Mia',
    age: 7,
    grade: 'Grade 2',
    avatarKey: 'sunshine',
    hasPin: true,
  );

  Widget wrap(Widget child) => MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ChangeNotifierProvider<ChildProvider>(create: (_) => ChildProvider()),
    ],
    child: MaterialApp(theme: ThemeData(useMaterial3: true), home: child),
  );

  Future<void> pumpRecovery(WidgetTester tester, _FakeAuthRepository repo) async {
    await tester.pumpWidget(wrap(ChildPinRecoveryScreen(child: mia, repository: repo)));
    await tester.pump();
  }

  group('ChildPinRecoveryScreen', () {
    testWidgets('starts with the child name filled in', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository();
      await pumpRecovery(tester, repo);

      expect(find.text('Who needs help?'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Mia'), findsOneWidget);
    });

    testWidgets('shows the configured questions after identifying', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository();
      await pumpRecovery(tester, repo);

      await tester.tap(find.text('Show my questions'));
      await tester.pumpAndSettle();

      expect(find.text('Answer your security questions'), findsOneWidget);
      expect(find.text('What is your favorite book?'), findsOneWidget);
      expect(find.text('What is the name of your pet?'), findsOneWidget);
    });

    testWidgets('surfaces a name that does not match the child', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository()
        ..questionsErrorMessage = 'Child not found. Please check the name and try again.';
      await pumpRecovery(tester, repo);

      await tester.tap(find.text('Show my questions'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Child not found'), findsOneWidget);
      expect(find.text('Answer your security questions'), findsNothing);
    });

    testWidgets('refuses a blank answer', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository();
      await pumpRecovery(tester, repo);
      await tester.tap(find.text('Show my questions'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Please answer every security question.'), findsOneWidget);
      expect(repo.verifyCalls, 0);
    });

    testWidgets('refuses an answer that is too short', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository();
      await pumpRecovery(tester, repo);
      await tester.tap(find.text('Show my questions'));
      await tester.pumpAndSettle();

      final Finder answerFields = find.widgetWithText(TextFormField, 'What is your favorite book?');
      await tester.enterText(answerFields, 'a');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.textContaining('at least 2 characters'), findsOneWidget);
      expect(repo.verifyCalls, 0);
    });

    testWidgets('keeps the child on the screen when an answer is wrong', (
      WidgetTester tester,
    ) async {
      final _FakeAuthRepository repo = _FakeAuthRepository()
        ..verifyErrorMessage = 'That answer does not match. Please try again.';
      await pumpRecovery(tester, repo);
      await tester.tap(find.text('Show my questions'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'What is your favorite book?'),
        'The Hobbit',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'What is the name of your pet?'),
        'Rex',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.textContaining('does not match'), findsOneWidget);
      expect(find.text('Answer your security questions'), findsOneWidget);
      expect(find.byType(ChildPinResetScreen), findsNothing);
      expect(repo.verifyCalls, 1);
    });

    testWidgets('sends both answers and opens the reset screen', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository();
      await pumpRecovery(tester, repo);
      await tester.tap(find.text('Show my questions'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'What is your favorite book?'),
        'The Hobbit',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'What is the name of your pet?'),
        'Rex',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(repo.verifyCalls, 1);
      expect(repo.lastAnswers, <String, String>{'favorite_book': 'The Hobbit', 'pet_name': 'Rex'});
      expect(find.byType(ChildPinResetScreen), findsOneWidget);
    });
  });

  group('ChildPinResetScreen', () {
    Future<void> pumpReset(WidgetTester tester, _FakeAuthRepository repo) async {
      await tester.pumpWidget(
        wrap(ChildPinResetScreen(child: mia, recoveryToken: 'token-abc', repository: repo)),
      );
      await tester.pump();
    }

    testWidgets('requires a 4-digit PIN', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository();
      await pumpReset(tester, repo);

      await tester.enterText(find.byType(TextFormField).at(0), '12');
      await tester.enterText(find.byType(TextFormField).at(1), '12');
      await tester.tap(find.text('Save new PIN'));
      await tester.pump();

      expect(find.text('The PIN must be exactly 4 digits.'), findsOneWidget);
      expect(repo.resetCalls, 0);
    });

    testWidgets('requires the two PINs to match', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository();
      await pumpReset(tester, repo);

      await tester.enterText(find.byType(TextFormField).at(0), '4321');
      await tester.enterText(find.byType(TextFormField).at(1), '1234');
      await tester.tap(find.text('Save new PIN'));
      await tester.pump();

      expect(find.text('The two PINs do not match.'), findsOneWidget);
      expect(repo.resetCalls, 0);
    });

    testWidgets('resets the PIN with the recovery token and confirms', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository();
      await pumpReset(tester, repo);

      await tester.enterText(find.byType(TextFormField).at(0), '4321');
      await tester.enterText(find.byType(TextFormField).at(1), '4321');
      await tester.tap(find.text('Save new PIN'));
      await tester.pumpAndSettle();

      expect(repo.resetCalls, 1);
      expect(repo.lastRecoveryToken, 'token-abc');
      expect(repo.lastNewPin, '4321');
      expect(repo.lastNewPinConfirmation, '4321');
      expect(find.text('New PIN saved'), findsOneWidget);
      expect(find.textContaining('Mia can now use the new PIN'), findsOneWidget);
    });

    testWidgets('reports an expired token without leaving the screen', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository()
        ..resetErrorMessage = 'This recovery link has expired. Please start again.';
      await pumpReset(tester, repo);

      await tester.enterText(find.byType(TextFormField).at(0), '4321');
      await tester.enterText(find.byType(TextFormField).at(1), '4321');
      await tester.tap(find.text('Save new PIN'));
      await tester.pumpAndSettle();

      expect(find.textContaining('expired'), findsOneWidget);
      expect(find.byType(ChildPinResetScreen), findsOneWidget);
    });
  });

  group('ChildPinScreen recovery entry point', () {
    testWidgets('offers a forgot-PIN link', (WidgetTester tester) async {
      final _FakeAuthRepository repo = _FakeAuthRepository();
      await tester.pumpWidget(wrap(ChildPinScreen(child: mia, repository: repo)));
      await tester.pump();

      expect(find.text('Forgot your PIN?'), findsOneWidget);
    });

    testWidgets('opens recovery and clears the boxes once the PIN is reset', (
      WidgetTester tester,
    ) async {
      final _FakeAuthRepository repo = _FakeAuthRepository();
      await tester.pumpWidget(wrap(ChildPinScreen(child: mia, repository: repo)));
      await tester.pump();

      await tester.tap(find.text('Forgot your PIN?'));
      await tester.pumpAndSettle();
      expect(find.byType(ChildPinRecoveryScreen), findsOneWidget);

      await tester.tap(find.text('Show my questions'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'What is your favorite book?'),
        'The Hobbit',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'What is the name of your pet?'),
        'Rex',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '4321');
      await tester.enterText(find.byType(TextFormField).at(1), '4321');
      await tester.tap(find.text('Save new PIN'));
      await tester.pumpAndSettle();

      expect(find.text('New PIN saved'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(ChildPinScreen), findsOneWidget);
      expect(find.byType(ChildPinRecoveryScreen), findsNothing);
      // Back on the PIN screen with empty boxes, ready for the new PIN.
      for (final TextField field in tester.widgetList<TextField>(find.byType(TextField))) {
        expect(field.controller?.text, '');
      }
    });
  });
}
