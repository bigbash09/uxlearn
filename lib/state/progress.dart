import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/content.dart';

/// Learner progress: completed lessons, saved terms and resources. Stored on the device.
class Progress extends ChangeNotifier {
  Progress._(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'uxterms.progress.v1';

  Map<String, String> done = {}; // lessonId -> yyyy-mm-dd
  List<String> terms = [];
  List<String> resources = [];
  bool demo = false;

  static Future<Progress> load() async {
    final p = Progress._(await SharedPreferences.getInstance());
    final raw = p._prefs.getString(_key);
    if (raw == null) {
      p._seed();
    } else {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        p.done = Map<String, String>.from(j['done'] ?? {});
        p.terms = List<String>.from(j['terms'] ?? []);
        p.resources = List<String>.from(j['res'] ?? []);
        p.demo = j['demo'] == true;
      } catch (_) {
        p._seed();
      }
    }
    return p;
  }

  static String day(int daysAgo) {
    final d = DateTime.now().subtract(Duration(days: daysAgo));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Sample progress so a first launch shows what a mid-course learner sees.
  void _seed() {
    done = {'empathize': day(2), 'define': day(1), 'proximity': day(0)};
    terms = ['affordance', 'cognitive-load'];
    resources = ['r-lawsofux'];
    demo = true;
  }

  void _save() {
    _prefs.setString(
      _key,
      jsonEncode({
        'done': done,
        'terms': terms,
        'res': resources,
        'demo': demo,
      }),
    );
    notifyListeners();
  }

  bool isDone(String lessonId) => done.containsKey(lessonId);
  int trackDone(Track t) => t.lessons.where((l) => isDone(l.id)).length;
  int get lessonsDone => Content.lessons.where((l) => isDone(l.id)).length;
  int get minutesDone => Content.lessons
      .where((l) => isDone(l.id))
      .fold(0, (a, l) => a + l.minutes);
  Lesson? get next => Content.lessons.where((l) => !isDone(l.id)).firstOrNull;

  int get streak {
    final days = done.values.toSet();
    var k = days.contains(day(0)) ? 0 : 1;
    var n = 0;
    while (days.contains(day(k))) {
      n++;
      k++;
    }
    return n;
  }

  /// Marks a lesson complete and returns true if the streak grew.
  bool complete(String lessonId) {
    final before = streak;
    done[lessonId] = day(0);
    _save();
    return streak > before;
  }

  bool toggleTerm(String id) {
    terms.contains(id) ? terms.remove(id) : terms.add(id);
    _save();
    return terms.contains(id);
  }

  bool toggleResource(String id) {
    resources.contains(id) ? resources.remove(id) : resources.add(id);
    _save();
    return resources.contains(id);
  }

  void reset() {
    done = {};
    terms = [];
    resources = [];
    demo = false;
    _save();
  }
}

class ProgressScope extends InheritedNotifier<Progress> {
  const ProgressScope({
    super.key,
    required Progress progress,
    required super.child,
  }) : super(notifier: progress);
  static Progress of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProgressScope>()!.notifier!;
  static Progress read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ProgressScope>()!.notifier!;
}
