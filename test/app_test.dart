import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ux_terms/data/content.dart';
import 'package:ux_terms/main.dart';
import 'package:ux_terms/screens/lesson.dart';
import 'package:ux_terms/state/progress.dart';
import 'package:ux_terms/theme.dart';
import 'package:ux_terms/widgets/media.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Content.load();
  });

  group('content', () {
    test('loads every track, lesson, term and resource', () {
      expect(Content.tracks.length, 5);
      expect(Content.lessons.length, 28);
      expect(Content.terms.length, 44);
      expect(Content.resources.length, 32);
    });

    test('every referenced photo exists and every animation has captions and a scene', () {
      final media = <Media>[];
      for (final x in Content.extra.values) {
        media.addAll(
          [
            x.hero,
            x.conceptMedia,
            x.exampleMedia,
            for (final d in x.deep) d.media,
          ].whereType<Media>(),
        );
      }
      for (final m in media) {
        if (m.img != null) {
          expect(
            File('assets/images/${m.img}.jpg').existsSync(),
            isTrue,
            reason: m.img,
          );
        }
        if (m.anim != null) {
          expect(Content.animCaptions[m.anim], isNotEmpty, reason: m.anim);
          for (var f = 0; f < Content.animCaptions[m.anim]!.length; f++) {
            expect(
              scene(m.anim!, f, AppColors.light),
              isNotEmpty,
              reason: '${m.anim} frame $f',
            );
          }
        }
        if (m.diagram != null) {
          expect(
            diagram(m.diagram!, AppColors.light),
            isNotEmpty,
            reason: m.diagram,
          );
        }
      }
    });

    test('glossary links point at real lessons', () {
      for (final t in Content.terms.where((t) => t.lessonId != null)) {
        expect(Content.lesson(t.lessonId), isNotNull, reason: t.id);
      }
    });
  });

  group('progress', () {
    test('first launch shows sample progress with a 3-day streak', () async {
      SharedPreferences.setMockInitialValues({});
      final p = await Progress.load();
      expect(p.demo, isTrue);
      expect(p.lessonsDone, 3);
      expect(p.streak, 3);
      expect(p.next!.id, 'ideate');
    });

    test('completing, saving and resetting persist', () async {
      SharedPreferences.setMockInitialValues({});
      final p = await Progress.load();
      p.reset();
      expect(p.lessonsDone, 0);
      expect(p.streak, 0);
      expect(p.complete('empathize'), isTrue);
      expect(p.streak, 1);
      expect(p.toggleTerm('persona'), isTrue);
      expect(p.toggleResource('r-pair'), isTrue);
      final again = await Progress.load();
      expect(again.isDone('empathize'), isTrue);
      expect(again.terms, contains('persona'));
      expect(again.resources, contains('r-pair'));
      expect(again.demo, isFalse);
    });
  });

  group('screens', () {
    Future<Progress> pumpApp(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final p = await Progress.load();
      await tester.pumpWidget(UxTermsApp(progress: p));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      return p;
    }

    testWidgets('home opens after the splash and shows the next lesson', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.text('Howdy!'), findsOneWidget);
      expect(find.text('Ideate'), findsWidgets);
      expect(find.text('Design Thinking Process'), findsOneWidget);
    });

    testWidgets('a lesson can be read to the end and marked complete', (
      tester,
    ) async {
      final p = await pumpApp(tester);
      await tester.tap(find.text('CONTINUE · DESIGN THINKING'));
      await tester.pumpAndSettle();
      expect(find.byType(LessonScreen), findsOneWidget);
      // Swipe through every card with the Next button.
      for (
        var i = 0;
        i < 20 && find.text('Mark as complete').evaluate().isEmpty;
        i++
      ) {
        await tester.tap(find.text('Next'));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(seconds: 3));
      }
      await tester.tap(find.text('Mark as complete'));
      await tester.pump();
      expect(p.isDone('ideate'), isTrue);
      expect(find.textContaining('Next: Prototype'), findsOneWidget);
      await tester.tap(find.byTooltip('Close lesson'));
      await tester.pumpAndSettle();
    });

    testWidgets('glossary search and term sheet', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Glossary'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'hallucin');
      await tester.pumpAndSettle();
      expect(find.text('Hallucination'), findsOneWidget);
      await tester.tap(find.text('Hallucination'));
      await tester.pumpAndSettle();
      expect(find.text('Related lesson'), findsOneWidget);
      await tester.tap(find.text('Save term'));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('resources filter by format', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Resources').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Videos'));
      await tester.pumpAndSettle();
      expect(find.text('4 resources'), findsOneWidget);
    });

    testWidgets('progress shows badges and resets after confirmation', (
      tester,
    ) async {
      final p = await pumpApp(tester);
      await tester.tap(find.text('Progress').last);
      await tester.pumpAndSettle();
      expect(find.text('3 of 28 lessons'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Reset progress'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Reset progress'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(p.lessonsDone, 0);
    });

    testWidgets('every animation plays through without layout errors', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(340 * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      for (final id in Content.animCaptions.keys) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildTheme(Brightness.light),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: Explainer(id, active: true),
              ),
            ),
          ),
        );
        for (var f = 0; f < Content.animCaptions[id]!.length + 1; f++) {
          await tester.pump(const Duration(milliseconds: 2700));
        }
        expect(tester.takeException(), isNull, reason: id);
      }
      await tester.pumpWidget(const SizedBox());
    });
  });
}
