import 'package:flutter/material.dart';

import '../data/content.dart';
import '../state/progress.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'routes.dart';

/// Large page title used by the tab screens.
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, this.sub, {super.key});
  final String title, sub;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: display(28, c.ink)),
          const SizedBox(height: 4),
          Text(sub, style: body(15, c.muted)),
        ],
      ),
    );
  }
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = ProgressScope.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          PageTitle(
            'Learn',
            '${Content.tracks.length} tracks · ${Content.lessons.length} short lessons · ${p.lessonsDone} done',
          ),
          const SizedBox(height: 10),
          for (final t in Content.tracks)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Panel(
                padding: const EdgeInsets.all(18),
                onTap: () => openTrack(context, t),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TrackGlyph(t.id),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: body(
                                  18,
                                  c.ink,
                                  weight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              Text(t.sub, style: body(14, c.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(t.blurb, style: body(14, c.muted)),
                    const SizedBox(height: 12),
                    ProgressBar(p.trackDone(t) / t.lessons.length),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${t.lessons.length} lessons · ${t.minutes} min',
                            style: body(12, c.muted),
                          ),
                        ),
                        p.trackDone(t) == t.lessons.length
                            ? Text(
                                'Completed',
                                style: body(
                                  12,
                                  c.good,
                                  weight: FontWeight.w700,
                                ),
                              )
                            : Text(
                                '${p.trackDone(t)} of ${t.lessons.length} done',
                                style: body(12, c.muted),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
