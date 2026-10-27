import 'package:flutter/material.dart';

import '../data/content.dart';
import '../widgets/common.dart';
import 'credits.dart';
import 'lesson.dart';
import 'track.dart';

void openLesson(BuildContext context, Lesson l) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => LessonScreen(lesson: l),
    fullscreenDialog: true,
  ),
);

void openTrack(BuildContext context, Track t) =>
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => TrackScreen(track: t)));

void openCredits(BuildContext context) =>
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CreditsScreen()));

void openTermSheet(BuildContext context, Term t) =>
    showTerm(context, t, openLesson: (l) => openLesson(context, l));
