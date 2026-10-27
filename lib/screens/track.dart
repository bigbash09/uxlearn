import 'package:flutter/material.dart';

import '../data/content.dart';
import '../main.dart';
import '../state/progress.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'routes.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key, required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = ProgressScope.of(context);
    final d = p.trackDone(track), n = track.lessons.length;
    final res = Content.resources
        .where((r) => r.topic == track.id)
        .take(4)
        .toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.blue,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: kGutter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrackGlyph(track.id, size: 64, radius: 18),
                const SizedBox(height: 12),
                Text(track.title, style: display(26, c.ink)),
                const SizedBox(height: 6),
                Text(track.blurb, style: body(15, c.muted)),
                const SizedBox(height: 14),
                ProgressBar(d / n),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$d of $n lessons complete',
                        style: body(12, c.muted),
                      ),
                    ),
                    Text(
                      '${track.minutes} min total',
                      style: body(12, c.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const SectionHeader('Lessons'),
          const SizedBox(height: 10),
          Padding(
            padding: kGutter,
            child: Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final l in track.lessons) ...[
                    if (l.index > 0) Divider(height: 1, color: c.line),
                    LessonRow(lesson: l),
                  ],
                ],
              ),
            ),
          ),
          if (res.isNotEmpty) ...[
            const SizedBox(height: 26),
            SectionHeader(
              'Go deeper',
              action: 'All ${Content.topics[track.id]} resources',
              onAction: () {
                Nav.resourceTopic.value = track.id;
                Nav.tab.value = 3;
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
            const SizedBox(height: 10),
            for (final r in res)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ResourceCard(r),
              ),
          ],
        ],
      ),
    );
  }
}

class LessonRow extends StatelessWidget {
  const LessonRow({super.key, required this.lesson});
  final Lesson lesson;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final done = ProgressScope.of(context).isDone(lesson.id);
    return InkWell(
      onTap: () => openLesson(context, lesson),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? c.good : null,
                border: Border.all(color: done ? c.good : c.tint2, width: 1.5),
              ),
              alignment: Alignment.center,
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                      semanticLabel: 'Completed',
                    )
                  : Text(
                      '${lesson.index + 1}',
                      style: body(13, c.blue, weight: FontWeight.w700),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: body(15, c.ink, weight: FontWeight.w700),
                  ),
                  Text(lesson.summary, style: body(13, c.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${lesson.minutes} min', style: body(12, c.muted)),
          ],
        ),
      ),
    );
  }
}
