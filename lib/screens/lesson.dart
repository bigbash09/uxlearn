import 'package:flutter/material.dart';

import '../data/content.dart';
import '../state/progress.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/media.dart';

/// Swipeable lesson: intro, idea, deep-dive cards, example, exercise, takeaway.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson});
  final Lesson lesson;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late Lesson lesson = widget.lesson;
  final _pc = PageController();
  int idx = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _go(int i, int n) {
    final t = i.clamp(0, n - 1);
    final reduce = MediaQuery.of(context).disableAnimations;
    reduce
        ? _pc.jumpToPage(t)
        : _pc.animateToPage(
            t,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          );
  }

  void _switchTo(Lesson next) {
    setState(() {
      lesson = next;
      idx = 0;
    });
    _pc.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = ProgressScope.of(context);
    final cards = _cards(context);
    final n = cards.length;
    final last = idx == n - 1;
    final next = Content.after(lesson);

    Widget mainButton;
    if (!last) {
      mainButton = PrimaryButton(
        label: 'Next',
        trailing: Icons.arrow_forward_rounded,
        onTap: () => _go(idx + 1, n),
      );
    } else if (!p.isDone(lesson.id)) {
      mainButton = PrimaryButton(
        label: 'Mark as complete',
        icon: Icons.check_rounded,
        color: c.good,
        onTap: () {
          final grew = ProgressScope.read(context).complete(lesson.id);
          final s = ProgressScope.read(context).streak;
          toast(
            context,
            grew ? 'Lesson complete · $s-day streak' : 'Lesson complete',
          );
        },
      );
    } else if (next != null) {
      mainButton = PrimaryButton(
        label: 'Next: ${next.title}',
        trailing: Icons.arrow_forward_rounded,
        onTap: () => _switchTo(next),
      );
    } else {
      mainButton = PrimaryButton(
        label: 'Done',
        icon: Icons.check_rounded,
        onTap: () => Navigator.pop(context),
      );
    }

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 6),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close lesson',
                    style: IconButton.styleFrom(backgroundColor: c.bg),
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: c.ink, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      label: 'Card ${idx + 1} of $n',
                      child: Row(
                        children: List.generate(
                          n,
                          (i) => Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: i <= idx ? c.blue : c.tint2,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                key: ValueKey(lesson.id),
                controller: _pc,
                itemCount: n,
                onPageChanged: (i) => setState(() => idx = i),
                itemBuilder: (_, i) => _CardScroll(child: cards[i](i == idx)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: IconButton(
                      tooltip: 'Previous card',
                      style: IconButton.styleFrom(
                        backgroundColor: c.bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: idx == 0 ? null : () => _go(idx - 1, n),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: idx == 0 ? c.line : c.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: mainButton),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Each card is built with an `active` flag so animations start when it is on screen.
  List<Widget Function(bool active)> _cards(BuildContext context) {
    final c = context.c;
    final l = lesson, x = l.extra, tr = l.track;
    final res = Content.resources
        .where((r) => r.topic == tr.id)
        .take(3)
        .toList();

    Widget kicker(String s) => Text(s.toUpperCase(), style: eyebrow(c.blue));
    Widget h3(String s) =>
        Text(s, style: body(22, c.ink, weight: FontWeight.w700, height: 1.2));
    Widget para(String s) => Text(s, style: body(17, c.ink, height: 1.55));
    Widget lead(String s, [double size = 16]) =>
        Text(s, style: body(size, c.muted, height: 1.5));
    Widget callout(String s, {bool dashed = false, bool formula = false}) =>
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: dashed ? c.bg : c.tint,
            borderRadius: BorderRadius.circular(16),
            border: dashed ? Border.all(color: c.peri, width: 1.5) : null,
          ),
          child: Text(
            s,
            style: formula
                ? display(17, c.blue, weight: FontWeight.w700, height: 1.35)
                : body(17, c.ink, height: 1.55),
          ),
        );

    final list = <Widget Function(bool)>[];

    // Intro
    list.add(
      (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (x.hero != null)
                    Image.asset(
                      'assets/images/${x.hero!.img}.jpg',
                      fit: BoxFit.cover,
                      semanticLabel: x.hero!.alt,
                      cacheWidth: 900,
                    )
                  else
                    Container(
                      color: c.blue,
                      padding: const EdgeInsets.all(70),
                      child: CustomPaint(
                        painter: GlyphPainter(tr.id, Colors.white),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    bottom: 2,
                    child: ExcludeSemantics(
                      child: Text(
                        pad2(l.index + 1),
                        style:
                            display(
                              64,
                              Colors.white.withValues(
                                alpha: x.hero != null ? .9 : .16,
                              ),
                              weight: FontWeight.w900,
                              height: 1,
                            ).copyWith(
                              shadows: x.hero != null
                                  ? [
                                      const Shadow(
                                        blurRadius: 16,
                                        color: Colors.black45,
                                      ),
                                    ]
                                  : null,
                            ),
                      ),
                    ),
                  ),
                  if (x.hero != null)
                    const Positioned(
                      right: 10,
                      top: 10,
                      child: AiTag(onPhoto: true),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          kicker('${tr.title} · Lesson ${l.index + 1} of ${tr.lessons.length}'),
          const SizedBox(height: 8),
          Text(l.title, style: display(30, c.ink, height: 1.05)),
          const SizedBox(height: 10),
          lead('${l.summary} About ${l.minutes} minutes.'),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.swipe_left_rounded, size: 18, color: c.muted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Swipe or tap Next to continue',
                  style: body(12.5, c.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // What it means
    list.add(
      (active) => _col([
        kicker('The idea'),
        h3('What it means'),
        para(l.concept),
        if (x.conceptMedia != null) MediaView(x.conceptMedia!, active: active),
      ]),
    );

    // Deep-dive cards
    for (final d in x.deep) {
      list.add(
        (active) => _col([
          kicker(d.kicker),
          h3(d.heading),
          if (d.media != null) MediaView(d.media!, active: active),
          for (final s in d.paras) para(s),
          if (d.callout != null) callout(d.callout!, formula: true),
          for (final s in d.paras2) lead(s),
          if (d.steps.isNotEmpty) _Steps(d.steps),
          if (d.defs.isNotEmpty) _Defs(d.defs),
        ]),
      );
    }

    // In practice
    list.add(
      (active) => _col([
        kicker('In practice'),
        h3('See it in action'),
        callout(l.example),
        if (x.exampleMedia != null) MediaView(x.exampleMedia!, active: active),
      ]),
    );

    // Try it
    list.add(
      (_) => _col([
        kicker('Try it'),
        h3('Your turn'),
        callout(l.tryIt, dashed: true),
        lead(
          'No need to finish now. Come back to it in your next studio session.',
          14,
        ),
      ]),
    );

    // Takeaway
    list.add(
      (_) => _col([
        kicker('Key takeaway'),
        Container(
          padding: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: c.blue, width: 3)),
          ),
          child: Text(
            l.takeaway,
            style: display(20, c.blue, weight: FontWeight.w700, height: 1.3),
          ),
        ),
        if (x.watch != null || res.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Go deeper', style: body(17, c.ink, weight: FontWeight.w700)),
          if (x.watch != null)
            ResourceCard(
              Resource(
                id: 'watch-${l.id}',
                title: 'Watch: ${x.watch![0]}',
                source: 'YouTube',
                type: 'video',
                topic: tr.id,
                meta: '',
                url:
                    'https://www.youtube.com/results?search_query=${Uri.encodeQueryComponent(x.watch![1])}',
              ),
              metaOverride: 'Video picks on YouTube',
              showSave: false,
            ),
          for (final r in res) ResourceCard(r),
        ],
      ]),
    );

    return list;
  }

  Widget _col(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) SizedBox(height: i == 1 ? 6 : 14),
        children[i],
      ],
    ],
  );
}

class _CardScroll extends StatelessWidget {
  const _CardScroll({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
    child: child,
  );
}

class _Steps extends StatelessWidget {
  const _Steps(this.steps);
  final List<String> steps;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.tint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: body(13, c.blue, weight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(steps[i], style: body(16, c.ink)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Defs extends StatelessWidget {
  const _Defs(this.defs);
  final List<List<String>> defs;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < defs.length; i++) ...[
            if (i > 0) Divider(height: 1, color: c.line),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(defs[i][0], style: display(15, Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          defs[i][1],
                          style: body(15, c.ink, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(defs[i][2], style: body(14, c.muted, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
