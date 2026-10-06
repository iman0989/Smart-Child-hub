import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_child_hub/core/constants/child_profile_rules.dart';
import 'package:smart_child_hub/models/child_model.dart';
import 'package:smart_child_hub/screens/child/child_form_dialog.dart';

void main() {
  group('age rules', () {
    test('accepts the inclusive 4-14 range', () {
      expect(ChildProfileRules.isValidAge(4), isTrue);
      expect(ChildProfileRules.isValidAge(10), isTrue);
      expect(ChildProfileRules.isValidAge(14), isTrue);
    });

    test('rejects ages outside 4-14', () {
      expect(ChildProfileRules.isValidAge(3), isFalse);
      expect(ChildProfileRules.isValidAge(15), isFalse);
      expect(ChildProfileRules.isValidAge(0), isFalse);
      expect(ChildProfileRules.isValidAge(null), isFalse);
    });

    test('reports the allowed range in the validation message', () {
      expect(ChildProfileRules.validateAge(''), 'Please enter the age');
      expect(ChildProfileRules.validateAge('seven'), 'Please enter a valid age');
      expect(ChildProfileRules.validateAge('3'), contains('between 4 and 14'));
      expect(ChildProfileRules.validateAge('15'), contains('between 4 and 14'));
      expect(ChildProfileRules.validateAge('4'), isNull);
      expect(ChildProfileRules.validateAge(' 10 '), isNull);
    });
  });

  group('grade rules', () {
    test('offers exactly Grade 1 to Grade 9', () {
      expect(ChildProfileRules.grades, hasLength(9));
      expect(ChildProfileRules.grades.first, 'Grade 1');
      expect(ChildProfileRules.grades.last, 'Grade 9');
    });

    test('normalizes shorthand to the canonical label', () {
      expect(ChildProfileRules.normalizeGrade('3'), 'Grade 3');
      expect(ChildProfileRules.normalizeGrade('grade 3'), 'Grade 3');
      expect(ChildProfileRules.normalizeGrade('GRADE 3'), 'Grade 3');
      expect(ChildProfileRules.normalizeGrade('g4'), 'Grade 4');
      expect(ChildProfileRules.normalizeGrade('  9  '), 'Grade 9');
      expect(ChildProfileRules.normalizeGrade('Grade 1'), 'Grade 1');
    });

    test('rejects Grade 0, Grade 10, Kindergarten and empty values', () {
      expect(ChildProfileRules.normalizeGrade('0'), isNull);
      expect(ChildProfileRules.normalizeGrade('Grade 0'), isNull);
      expect(ChildProfileRules.normalizeGrade('10'), isNull);
      expect(ChildProfileRules.normalizeGrade('Grade 10'), isNull);
      expect(ChildProfileRules.normalizeGrade('Kindergarten'), isNull);
      expect(ChildProfileRules.normalizeGrade('Pre-school'), isNull);
      expect(ChildProfileRules.normalizeGrade(''), isNull);
      expect(ChildProfileRules.normalizeGrade(null), isNull);
    });

    test('validateGrade asks for a choice when empty and explains the range', () {
      expect(ChildProfileRules.validateGrade(''), 'Please choose a grade');
      expect(ChildProfileRules.validateGrade('Grade 10'), contains('Grade 1'));
      expect(ChildProfileRules.validateGrade('Grade 10'), contains('Grade 9'));
      expect(ChildProfileRules.validateGrade('Grade 5'), isNull);
    });

    test('gradeNumber mirrors the backend normalization', () {
      expect(ChildProfileRules.gradeNumber('g7'), 7);
      expect(ChildProfileRules.gradeNumber('Kindergarten'), isNull);
    });
  });

  group('child model', () {
    test('carries aboutChild and omits the PIN from the payload', () {
      final ChildModel child = ChildModel(
        id: 'c-1',
        name: 'Mia',
        age: 7,
        grade: 'Grade 2',
        aboutChild: 'Loves drawing',
        avatarKey: 'sunshine',
        pin: '1234',
      );

      final Map<String, dynamic> json = child.toJson();
      expect(json['aboutChild'], 'Loves drawing');
      expect(json.containsKey('school'), isFalse);
      expect(json.containsKey('pin'), isFalse);
    });
  });

  group('ChildFormDialog', () {
    /// Opens the dialog and records the ChildModel it pops with, if any.
    Future<ChildModel?> openDialog(
      WidgetTester tester, {
      ChildModel? child,
      void Function(ChildModel? result)? onResult,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () async {
                  final ChildModel? result = await showDialog<ChildModel>(
                    context: context,
                    builder: (_) => ChildFormDialog(child: child),
                  );
                  onResult?.call(result);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return null;
    }

    testWidgets('shows the 4-14 age hint', (WidgetTester tester) async {
      await openDialog(tester);
      expect(find.text(ChildProfileRules.ageHint), findsOneWidget);
      expect(ChildProfileRules.ageHint, contains('4'));
      expect(ChildProfileRules.ageHint, contains('14'));
    });

    testWidgets('shows exactly the Grade 1-9 chips', (WidgetTester tester) async {
      await openDialog(tester);

      for (final String grade in ChildProfileRules.grades) {
        expect(find.text(grade), findsWidgets, reason: 'missing $grade');
      }
      expect(find.text('Kindergarten'), findsNothing);
      expect(find.text('Grade 0'), findsNothing);
      expect(find.text('Grade 10'), findsNothing);
    });

    testWidgets('has an About child field and no School field', (WidgetTester tester) async {
      await openDialog(tester);
      expect(find.text('About child (optional)'), findsOneWidget);
      expect(find.textContaining('School', findRichText: true), findsNothing);
    });

    testWidgets('refuses to save without a grade', (WidgetTester tester) async {
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'Mia');
      await tester.enterText(find.byType(TextFormField).at(1), '7');
      await tester.enterText(find.byType(TextFormField).at(3), '1234');
      await tester.tap(find.text('Add child'));
      await tester.pump();

      expect(find.text('Please choose a grade'), findsWidgets);
    });

    testWidgets('refuses an out-of-range age', (WidgetTester tester) async {
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'Mia');
      await tester.enterText(find.byType(TextFormField).at(1), '15');
      await tester.enterText(find.byType(TextFormField).at(3), '1234');
      await tester.ensureVisible(find.text('Grade 2'));
      await tester.tap(find.text('Grade 2'));
      await tester.pump();
      await tester.tap(find.text('Add child'));
      await tester.pump();

      expect(find.textContaining('between 4 and 14'), findsOneWidget);
    });

    testWidgets('saves with a valid age, grade, about child and PIN', (WidgetTester tester) async {
      ChildModel? saved;
      await openDialog(tester, onResult: (ChildModel? result) => saved = result);

      await tester.enterText(find.byType(TextFormField).at(0), 'Mia');
      await tester.enterText(find.byType(TextFormField).at(1), '7');
      await tester.enterText(find.byType(TextFormField).at(2), 'Loves drawing');
      await tester.enterText(find.byType(TextFormField).at(3), '1234');
      await tester.ensureVisible(find.text('Grade 2'));
      await tester.tap(find.text('Grade 2'));
      await tester.pump();
      await tester.ensureVisible(find.text('Add child'));
      await tester.tap(find.text('Add child'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!.name, 'Mia');
      expect(saved!.age, 7);
      expect(saved!.grade, 'Grade 2');
      expect(saved!.aboutChild, 'Loves drawing');
      expect(saved!.pin, '1234');
    });
  });
}
