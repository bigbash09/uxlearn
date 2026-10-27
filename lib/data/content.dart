import 'dart:convert';

import 'package:flutter/services.dart';

/// All course content, loaded once from assets/content.json.
class Content {
  Content._();
  static late final List<Track> tracks;
  static late final List<Lesson> lessons;
  static late final List<Resource> resources;
  static late final List<Term> terms;
  static late final Map<String, LessonExtra> extra;
  static late final Map<String, String> topics;
  static late final Map<String, String> types;
  static late final List<String> categories;
  static late final Map<String, List<String>> animCaptions;
  static late final List<List<String>> scamperWords;

  static Future<void> load() async {
    final j = jsonDecode(
      await rootBundle.loadString('assets/content.json'),
    ) as Map<String, dynamic>;
    tracks = (j['tracks'] as List).map((t) => Track.fromJson(t)).toList();
    lessons = [for (final t in tracks) ...t.lessons];
    resources = (j['resources'] as List)
        .map((r) => Resource.fromJson(r))
        .toList();
    terms = (j['terms'] as List).map((t) => Term.fromJson(t)).toList()
      ..sort((a, b) => a.t.toLowerCase().compareTo(b.t.toLowerCase()));
    extra = (j['extra'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, LessonExtra.fromJson(v)),
    );
    topics = Map<String, String>.from(j['topics']);
    types = Map<String, String>.from(j['types']);
    categories = List<String>.from(j['categories']);
    final caps = j['animCaptions'] as Map<String, dynamic>;
    scamperWords = (caps.remove('scamperWords') as List)
        .map((e) => List<String>.from(e))
        .toList();
    animCaptions = caps.map((k, v) => MapEntry(k, List<String>.from(v)));
  }

  static Track track(String id) => tracks.firstWhere((t) => t.id == id);
  static Lesson? lesson(String? id) =>
      id == null ? null : lessons.where((l) => l.id == id).firstOrNull;
  static Term? term(String id) => terms.where((t) => t.id == id).firstOrNull;
  static Resource? resource(String id) =>
      resources.where((r) => r.id == id).firstOrNull;
  static Lesson? after(Lesson l) {
    final i = lessons.indexOf(l);
    return i + 1 < lessons.length ? lessons[i + 1] : null;
  }
}

class Track {
  Track({
    required this.id,
    required this.title,
    required this.sub,
    required this.blurb,
    required this.lessons,
  });
  final String id, title, sub, blurb;
  final List<Lesson> lessons;
  int get minutes => lessons.fold(0, (a, l) => a + l.minutes);

  factory Track.fromJson(Map<String, dynamic> j) {
    final t = Track(
      id: j['id'],
      title: j['title'],
      sub: j['sub'],
      blurb: j['blurb'],
      lessons: [],
    );
    final ls = j['lessons'] as List;
    for (var i = 0; i < ls.length; i++) {
      t.lessons.add(Lesson.fromJson(ls[i], t, i));
    }
    return t;
  }
}

class Lesson {
  Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.baseMinutes,
    required this.concept,
    required this.example,
    required this.tryIt,
    required this.takeaway,
    required this.track,
    required this.index,
  });
  final String id, title, summary, concept, example, tryIt, takeaway;
  final int baseMinutes, index;
  final Track track;

  LessonExtra get extra => Content.extra[id] ?? LessonExtra.empty;
  int get minutes => baseMinutes + extra.deep.length * 2;

  factory Lesson.fromJson(Map<String, dynamic> j, Track t, int i) => Lesson(
    id: j['id'],
    title: j['t'],
    summary: j['s'],
    baseMinutes: j['m'],
    concept: j['c'],
    example: j['e'],
    tryIt: j['y'],
    takeaway: j['k'],
    track: t,
    index: i,
  );
}

/// A photo, a drawn diagram, or an animated explainer.
class Media {
  Media({this.img, this.alt, this.cap, this.anim, this.diagram});
  final String? img, alt, cap, anim, diagram;
  static Media? fromJson(dynamic j) {
    if (j == null) return null;
    return Media(
      img: j['img'],
      alt: j['alt'],
      cap: j['cap'],
      anim: j['anim'],
      diagram: j['svg'],
    );
  }
}

class DeepCard {
  DeepCard({
    required this.kicker,
    required this.heading,
    this.media,
    this.paras = const [],
    this.callout,
    this.paras2 = const [],
    this.steps = const [],
    this.defs = const [],
  });
  final String kicker, heading;
  final Media? media;
  final List<String> paras, paras2, steps;
  final String? callout;
  final List<List<String>> defs;

  factory DeepCard.fromJson(Map<String, dynamic> j) => DeepCard(
    kicker: j['k'],
    heading: j['h'],
    media: Media.fromJson(j['media']),
    paras: List<String>.from(j['p'] ?? const []),
    callout: j['callout'],
    paras2: List<String>.from(j['p2'] ?? const []),
    steps: List<String>.from(j['steps'] ?? const []),
    defs: ((j['defs'] ?? const []) as List)
        .map((d) => List<String>.from(d))
        .toList(),
  );
}

class LessonExtra {
  LessonExtra({
    this.hero,
    this.conceptMedia,
    this.exampleMedia,
    this.deep = const [],
    this.watch,
  });
  final Media? hero, conceptMedia, exampleMedia;
  final List<DeepCard> deep;
  final List<String>? watch; // [title, YouTube search query]
  static final empty = LessonExtra();

  factory LessonExtra.fromJson(Map<String, dynamic> j) => LessonExtra(
    hero: Media.fromJson(j['hero']),
    conceptMedia: Media.fromJson(j['cm']),
    exampleMedia: Media.fromJson(j['em']),
    deep: ((j['deep'] ?? const []) as List)
        .map((d) => DeepCard.fromJson(d))
        .toList(),
    watch: j['w'] == null ? null : List<String>.from(j['w']),
  );
}

class Resource {
  Resource({
    required this.id,
    required this.title,
    required this.source,
    required this.type,
    required this.topic,
    required this.meta,
    required this.url,
  });
  final String id, title, source, type, topic, meta, url;
  factory Resource.fromJson(Map<String, dynamic> j) => Resource(
    id: j['id'],
    title: j['t'],
    source: j['src'],
    type: j['type'],
    topic: j['topic'],
    meta: j['meta'],
    url: j['url'],
  );
}

class Term {
  Term({
    required this.id,
    required this.t,
    required this.cat,
    required this.def,
    required this.example,
    this.lessonId,
  });
  final String id, t, cat, def, example;
  final String? lessonId;
  factory Term.fromJson(Map<String, dynamic> j) => Term(
    id: j['id'],
    t: j['t'],
    cat: j['cat'],
    def: j['d'],
    example: j['ex'],
    lessonId: j['lesson'],
  );
}
