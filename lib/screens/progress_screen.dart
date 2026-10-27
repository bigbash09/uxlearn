import 'package:flutter/material.dart';

import '../data/content.dart';
import '../state/progress.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'home.dart';
import 'learn.dart';
import 'routes.dart';

class _Badge {
  const _Badge(this.name, this.icon, this.track, this.test);
  final String name;
  final IconData? icon;
  final String? track;
  final bool Function(Progress p) test;
}

bool _trackComplete(Progress p, String id) {
  final t = Content.track(id);
  return p.trackDone(t) == t.lessons.length;
}

final _badges = <_Badge>[
  _Badge('First step', null, 'dt', (p) => p.lessonsDone > 0),
  _Badge('Empathy engine', null, 'dt', (p) => _trackComplete(p, 'dt')),
  _Badge('Gestalt eye', null, 'gestalt', (p) => _trackComplete(p, 'gestalt')),
  _Badge('Law abider', null, 'laws', (p) => _trackComplete(p, 'laws')),
  _Badge('AI co-pilot', null, 'ai', (p) => _trackComplete(p, 'ai')),
  _Badge('Spatial thinker', null, 'xr', (p) => _trackComplete(p, 'xr')),
  _Badge(
    'On a roll',
    Icons.local_fire_department_rounded,
    null,
    (p) => p.streak >= 3,
  ),
  _Badge(
    'Word collector',
    Icons.bookmark_rounded,
    null,
    (p) => p.terms.length >= 5,
  ),
];

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final c = context.c;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Reset progress?',
          style: body(20, c.ink, weight: FontWeight.w700),
        ),
        content: Text(
          'Completed lessons, saved terms and saved resources will be cleared. This cannot be undone.',
          style: body(15, c.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: c.bad),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ProgressScope.read(context).reset();
      toast(context, 'Progress cleared');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = ProgressScope.of(context);
    final total = Content.lessons.length, done = p.lessonsDone, next = p.next;
    final earned = _badges.where((b) => b.test(p)).length;

    Widget stat(int v, String l) => Expanded(
      child: Panel(
        radius: 16,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$v', style: display(24, c.blue)),
            const SizedBox(height: 2),
            Text(l, style: body(12, c.muted, height: 1.2)),
          ],
        ),
      ),
    );

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          const PageTitle('Progress', 'Your learning at a glance'),
          Padding(
            padding: kGutter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (p.demo) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.tint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Showing sample progress so you can see how tracking works. Reset it at the bottom of this screen.',
                      style: body(12.5, c.muted),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Panel(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Ring(total == 0 ? 0 : done / total),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$done of $total lessons',
                              style: body(17, c.ink, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${p.minutesDone} minutes of learning so far. ${next != null ? 'Next up: ${next.title}.' : 'Every lesson complete.'}',
                              style: body(13, c.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    stat(p.streak, 'Day streak'),
                    const SizedBox(width: 10),
                    stat(p.terms.length, 'Terms saved'),
                    const SizedBox(width: 10),
                    stat(p.resources.length, 'Resources saved'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const SectionHeader('Tracks'),
          const SizedBox(height: 10),
          Padding(
            padding: kGutter,
            child: Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final t in Content.tracks) ...[
                    if (t != Content.tracks.first)
                      Divider(height: 1, color: c.line),
                    TrackRow(track: t, showSub: false),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          Padding(
            padding: kGutter,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Badges',
                    style: body(18, c.ink, weight: FontWeight.w700),
                  ),
                ),
                Text('$earned of ${_badges.length}', style: body(13, c.muted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: kGutter,
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              childAspectRatio: .78,
              children: [
                for (final b in _badges)
                  () {
                    final on = b.test(p);
                    return Semantics(
                      label: '${b.name}, ${on ? 'earned' : 'locked'}',
                      child: ExcludeSemantics(
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: on ? c.blue : c.surface,
                                border: on
                                    ? null
                                    : Border.all(color: c.line, width: 1.5),
                              ),
                              padding: const EdgeInsets.all(14),
                              child: b.icon != null
                                  ? Icon(
                                      b.icon,
                                      color: on ? Colors.white : c.line,
                                      size: 26,
                                    )
                                  : CustomPaint(
                                      painter: GlyphPainter(
                                        b.track!,
                                        on ? Colors.white : c.line,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              b.name,
                              textAlign: TextAlign.center,
                              style: body(
                                11,
                                on ? c.ink : c.muted,
                                weight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }(),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const SectionHeader('Saved terms'),
          const SizedBox(height: 10),
          Padding(
            padding: kGutter,
            child: p.terms.isEmpty
                ? Text(
                    'Tap Save on any glossary term to keep it here.',
                    style: body(13, c.muted),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t
                          in p.terms.map(Content.term).whereType<Term>())
                        ActionChip(
                          label: Text(
                            t.t,
                            style: body(13, c.muted, weight: FontWeight.w600),
                          ),
                          backgroundColor: c.surface,
                          side: BorderSide(color: c.line),
                          shape: const StadiumBorder(),
                          onPressed: () => openTermSheet(context, t),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 26),
          const SectionHeader('Saved resources'),
          const SizedBox(height: 10),
          if (p.resources.isEmpty)
            Padding(
              padding: kGutter,
              child: Text(
                'Save videos, articles and tools from the Resources tab.',
                style: body(13, c.muted),
              ),
            )
          else
            for (final r
                in p.resources.map(Content.resource).whereType<Resource>())
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ResourceCard(r),
              ),
          const SizedBox(height: 18),
          Padding(
            padding: kGutter,
            child: Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.tint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.favorite_border_rounded, color: c.blue),
                    ),
                    title: Text(
                      'Credits & appreciation',
                      style: body(15, c.ink, weight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'The sources that made this app possible',
                      style: body(13, c.muted),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: c.muted),
                    onTap: () => openCredits(context),
                  ),
                  Divider(height: 1, color: c.line),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.tint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.restart_alt_rounded, color: c.blue),
                    ),
                    title: Text(
                      'Reset progress',
                      style: body(15, c.ink, weight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Start the course from scratch',
                      style: body(13, c.muted),
                    ),
                    onTap: () => _confirmReset(context),
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
