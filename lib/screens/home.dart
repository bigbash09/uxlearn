import 'package:flutter/material.dart';

import '../data/content.dart';
import '../main.dart';
import '../state/progress.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = ProgressScope.of(context);
    final next = p.next;
    final dt = Content.track('dt');
    final tod =
        Content.terms[DateTime.now().difference(DateTime(2024)).inDays %
            Content.terms.length];
    final top = MediaQuery.of(context).padding.top;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header band with the Continue card overlapping its bottom edge.
        // The card sits in normal layout (not a transform) so the whole card is tappable.
        Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 72,
              child: ColoredBox(
                color: c.blue,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      right: -14,
                      bottom: -30,
                      child: ExcludeSemantics(
                        child: Text(
                          'UX',
                          style: display(
                            120,
                            Colors.white.withValues(alpha: .08),
                            weight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, top + 18, 20, 22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Howdy!', style: display(28, Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              'UI UX Terminologies',
                              style: body(
                                15,
                                Colors.white.withValues(alpha: .9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(9, 6, 12, 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${p.streak} day${p.streak == 1 ? '' : 's'}',
                              style: body(
                                13,
                                Colors.white,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: kGutter,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF14285A).withValues(alpha: .08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Panel(
                      onTap: next == null
                          ? null
                          : () => openLesson(context, next),
                      padding: const EdgeInsets.all(18),
                      child: next == null
                          ? Row(
                              children: [
                                TrackGlyph('ai', size: 56),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'You finished every lesson. Keep exploring Resources.',
                                    style: body(
                                      16,
                                      c.ink,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                TrackGlyph(next.track.id),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CONTINUE · ${next.track.title.toUpperCase()}',
                                        style: eyebrow(c.muted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        next.title,
                                        style: body(
                                          17,
                                          c.ink,
                                          weight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ProgressBar(
                                        p.trackDone(next.track) /
                                            next.track.lessons.length,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Lesson ${next.index + 1} of ${next.track.lessons.length}',
                                              style: body(12, c.muted),
                                            ),
                                          ),
                                          Text(
                                            '${next.minutes} min',
                                            style: body(12, c.muted),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 26),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              'Design Thinking Process',
              action: 'See all',
              onAction: () => openTrack(context, dt),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 184,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: kGutter,
                itemCount: dt.lessons.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final l = dt.lessons[i];
                  final done = p.isDone(l.id);
                  return SizedBox(
                    width: 240,
                    child: Panel(
                      onTap: () => openLesson(context, l),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OutlineNumber(pad2(i + 1)),
                              const Spacer(),
                              Text(
                                l.title,
                                style: body(
                                  20,
                                  c.blue,
                                  weight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.summary,
                                style: body(13, c.muted, height: 1.35),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          if (done)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Semantics(
                                label: 'Completed',
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: c.good,
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: kGutter,
              child: Material(
                color: c.blue,
                borderRadius: BorderRadius.circular(22),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => openTermSheet(context, tod),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TERM OF THE DAY',
                          style: eyebrow(Colors.white.withValues(alpha: .75)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tod.t,
                          style: body(
                            22,
                            Colors.white,
                            weight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tod.def,
                          style: body(14, Colors.white.withValues(alpha: .92)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Read more →',
                          style: body(
                            13,
                            Colors.white,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            SectionHeader(
              'Keep exploring',
              action: 'All tracks',
              onAction: () => Nav.tab.value = 1,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: kGutter,
              child: Panel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final t in Content.tracks.skip(1)) ...[
                      if (t != Content.tracks[1])
                        Divider(height: 1, color: c.line),
                      TrackRow(track: t),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }
}

class TrackRow extends StatelessWidget {
  const TrackRow({super.key, required this.track, this.showSub = true});
  final Track track;
  final bool showSub;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = ProgressScope.of(context);
    final d = p.trackDone(track), n = track.lessons.length;
    return InkWell(
      onTap: () => openTrack(context, track),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            TrackGlyph(track.id, size: 46, radius: 13),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: body(15, c.ink, weight: FontWeight.w700),
                  ),
                  if (showSub) Text(track.sub, style: body(13, c.muted)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: ProgressBar(d / n, height: 5)),
                      const SizedBox(width: 8),
                      Text('$d/$n', style: body(12, c.muted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: c.muted),
          ],
        ),
      ),
    );
  }
}
