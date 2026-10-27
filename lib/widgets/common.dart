import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/content.dart';
import '../state/progress.dart';
import '../theme.dart';

/// Side padding used by every screen.
const kGutter = EdgeInsets.symmetric(horizontal: 20);

Future<void> openLink(BuildContext context, String url) async {
  final ok = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!ok && context.mounted) {
    toast(context, 'Could not open the link. Check your connection.');
  }
}

void toast(
  BuildContext context,
  String msg, {
  IconData icon = Icons.check_rounded,
}) {
  final c = context.c;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2200),
        content: Row(
          children: [
            Icon(icon, size: 18, color: c.bg),
            const SizedBox(width: 8),
            Flexible(child: Text(msg)),
          ],
        ),
      ),
    );
}

String pad2(int n) => n.toString().padLeft(2, '0');

IconData typeIcon(String type) => switch (type) {
  'video' => Icons.play_circle_outline_rounded,
  'article' => Icons.article_outlined,
  'course' => Icons.school_outlined,
  'guide' => Icons.explore_outlined,
  'tool' => Icons.build_outlined,
  'book' => Icons.menu_book_outlined,
  _ => Icons.link_rounded,
};

/// Simple drawn glyph for each track.
class TrackGlyph extends StatelessWidget {
  const TrackGlyph(
    this.trackId, {
    super.key,
    this.size = 56,
    this.radius = 16,
    this.color,
    this.bg,
  });
  final String trackId;
  final double size, radius;
  final Color? color, bg;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg ?? c.tint,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: EdgeInsets.all(size * .2),
      child: CustomPaint(painter: GlyphPainter(trackId, color ?? c.blue)),
    );
  }
}

class GlyphPainter extends CustomPainter {
  GlyphPainter(this.id, this.color);
  final String id;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48;
    canvas.scale(s);
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (id) {
      case 'dt':
        final path = Path()
          ..moveTo(7, 30)
          ..cubicTo(11, 20, 16, 20, 20, 26)
          ..cubicTo(24, 32, 29, 32, 33, 22)
          ..cubicTo(37, 12, 41, 16, 41, 22);
        canvas.drawPath(path, stroke..color = color.withValues(alpha: .5));
        for (final p in const [
          Offset(7, 30),
          Offset(16, 23),
          Offset(24, 29),
          Offset(32, 22),
          Offset(41, 22),
        ]) {
          canvas.drawCircle(p, 3.6, fill);
        }
      case 'gestalt':
        for (final y in const [10.0, 22.0, 39.0]) {
          for (final x in const [12.0, 24.0, 36.0]) {
            canvas.drawCircle(Offset(x, y), 4.6, fill);
          }
        }
      case 'laws':
        canvas.drawCircle(
          const Offset(22, 22),
          16,
          stroke..color = color.withValues(alpha: .45),
        );
        canvas.drawCircle(const Offset(22, 22), 9, stroke..color = color);
        canvas.drawCircle(const Offset(22, 22), 2.6, fill);
        canvas.drawPath(
          Path()
            ..moveTo(29, 29)
            ..lineTo(41, 33)
            ..lineTo(36, 35)
            ..lineTo(34, 40)
            ..close(),
          fill,
        );
      case 'ai':
        Path star(double cx, double cy, double r) => Path()
          ..moveTo(cx, cy - r)
          ..quadraticBezierTo(cx + r * .15, cy - r * .15, cx + r, cy)
          ..quadraticBezierTo(cx + r * .15, cy + r * .15, cx, cy + r)
          ..quadraticBezierTo(cx - r * .15, cy + r * .15, cx - r, cy)
          ..quadraticBezierTo(cx - r * .15, cy - r * .15, cx, cy - r);
        canvas.drawPath(star(20, 19, 13), fill);
        canvas.drawPath(
          star(36, 35, 7),
          Paint()..color = color.withValues(alpha: .55),
        );
      case 'xr':
        final r = RRect.fromLTRBR(6, 13, 42, 33, const Radius.circular(4));
        canvas.drawRRect(r, stroke);
        canvas.drawCircle(const Offset(16, 23), 3.6, fill);
        canvas.drawCircle(const Offset(32, 23), 3.6, fill);
    }
  }

  @override
  bool shouldRepaint(GlyphPainter old) => old.id != id || old.color != color;
}

class ProgressBar extends StatelessWidget {
  const ProgressBar(this.value, {super.key, this.height = 6});
  final double value, height;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: c.tint2,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                color: c.blue,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A bordered surface, the app's standard card.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.color,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: color ?? c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: c.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: kGutter,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: body(18, c.ink, weight: FontWeight.w700, height: 1.2),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: c.blue,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(44, 36),
              ),
              child: Text(
                action!,
                style: body(14, c.blue, weight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.tint,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: body(11, c.blue, weight: FontWeight.w700, height: 1.2),
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });
  final List<MapEntry<String, String>> options; // key -> label
  final String selected;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: kGutter,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final o = options[i], on = o.key == selected;
          return Semantics(
            selected: on,
            button: true,
            child: Material(
              color: on ? c.blue : c.surface,
              shape: StadiumBorder(
                side: BorderSide(color: on ? c.blue : c.line),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onSelect(o.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    child: Text(
                      o.value,
                      style: body(
                        13,
                        on ? c.onBlue : c.muted,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: kGutter,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: body(15, c.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: body(15, c.muted),
          prefixIcon: Icon(Icons.search_rounded, color: c.muted),
          filled: true,
          fillColor: c.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: c.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: c.blue, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class ResourceCard extends StatelessWidget {
  const ResourceCard(
    this.r, {
    super.key,
    this.titleOverride,
    this.metaOverride,
    this.showSave = true,
  });
  final Resource r;
  final String? titleOverride, metaOverride;
  final bool showSave;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = ProgressScope.of(context);
    final saved = p.resources.contains(r.id);
    return Panel(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      onTap: () => openLink(context, r.url),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon(r.type), color: c.blue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: titleOverride ?? r.title),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.north_east_rounded,
                            size: 13,
                            color: c.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  style: body(15, c.ink, weight: FontWeight.w700, height: 1.3),
                ),
                const SizedBox(height: 3),
                Text(
                  metaOverride ?? '${r.source} · ${r.meta}',
                  style: body(12.5, c.muted, height: 1.3),
                ),
                if (showSave) ...[
                  const SizedBox(height: 6),
                  Pill(Content.topics[r.topic] ?? ''),
                ],
              ],
            ),
          ),
          if (showSave)
            IconButton(
              tooltip: saved ? 'Remove from saved' : 'Save',
              onPressed: () {
                final on = ProgressScope.read(context).toggleResource(r.id);
                toast(context, on ? 'Resource saved' : 'Removed from saved');
              },
              icon: Icon(
                saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: saved ? c.blue : c.muted,
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom sheet with a glossary term.
Future<void> showTerm(
  BuildContext context,
  Term t, {
  required void Function(Lesson) openLesson,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (ctx) {
      final c = ctx.c;
      final p = ProgressScope.of(ctx);
      final saved = p.terms.contains(t.id);
      final l = Content.lesson(t.lessonId);
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          22,
          0,
          22,
          22 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Pill(t.cat),
            const SizedBox(height: 10),
            Text(t.t, style: display(26, c.ink)),
            const SizedBox(height: 10),
            Text(t.def, style: body(16, c.ink, height: 1.55)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.tint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXAMPLE', style: eyebrow(c.muted)),
                  const SizedBox(height: 4),
                  Text(t.example, style: body(14, c.ink)),
                ],
              ),
            ),
            if (l != null) ...[
              const SizedBox(height: 12),
              Panel(
                radius: 16,
                padding: const EdgeInsets.all(12),
                onTap: () {
                  Navigator.pop(ctx);
                  openLesson(l);
                },
                child: Row(
                  children: [
                    TrackGlyph(l.track.id, size: 40, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Related lesson',
                            style: body(15, c.ink, weight: FontWeight.w700),
                          ),
                          Text(
                            '${l.title} · ${l.minutes} min',
                            style: body(13, c.muted),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: c.muted),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SoftButton(
                    label: saved ? 'Saved' : 'Save term',
                    icon: saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    onTap: () => ProgressScope.read(ctx).toggleTerm(t.id),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: 'Got it',
                    onTap: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.trailing,
    this.color,
  });
  final String label;
  final VoidCallback? onTap;
  final IconData? icon, trailing;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color ?? c.blue,
          foregroundColor: c.onBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: body(16, c.onBlue, weight: FontWeight.w700),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Icon(trailing, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class SoftButton extends StatelessWidget {
  const SoftButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 52,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: c.bg,
          foregroundColor: c.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: body(16, c.ink, weight: FontWeight.w700),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

/// Big outlined number used on the Design Thinking cards.
class OutlineNumber extends StatelessWidget {
  const OutlineNumber(this.text, {super.key, this.size = 64, this.color});
  final String text;
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          display(
            size,
            Colors.transparent,
            weight: FontWeight.w800,
            height: .95,
          ).copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.3
              ..color = color ?? context.c.tint2,
          ),
    );
  }
}

/// Circular progress ring for the Progress screen.
class Ring extends StatelessWidget {
  const Ring(this.value, {super.key, this.size = 108});
  final double value, size;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v, c.tint2, c.blue),
          child: Center(
            child: Text('${(value * 100).round()}%', style: display(24, c.ink)),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.track, this.color);
  final double v;
  final Color track, color;
  @override
  void paint(Canvas canvas, Size s) {
    final r = Rect.fromLTWH(6, 6, s.width - 12, s.height - 12);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, p..color = track);
    if (v > 0) {
      canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, p..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.v != v || o.color != color;
}
