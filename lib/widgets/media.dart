import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/content.dart';
import '../theme.dart';

/// Renders any lesson media: a photo, a static diagram, or an animated explainer.
class MediaView extends StatelessWidget {
  const MediaView(this.m, {super.key, this.active = false});
  final Media m;
  final bool active;
  @override
  Widget build(BuildContext context) {
    if (m.img != null) return PhotoFigure(m);
    if (m.diagram != null) return DiagramFigure(m.diagram!, m.cap ?? '');
    if (m.anim != null) return Explainer(m.anim!, active: active);
    return const SizedBox.shrink();
  }
}

class AiTag extends StatelessWidget {
  const AiTag({super.key, this.onPhoto = false});
  final bool onPhoto;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Text(
      'AI-GENERATED IMAGE',
      style: TextStyle(
        fontFamily: kBody,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: .5,
        color: onPhoto ? Colors.white : c.muted,
      ),
    );
    if (!onPhoto) return t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(99),
      ),
      child: t,
    );
  }
}

class PhotoFigure extends StatelessWidget {
  const PhotoFigure(this.m, {super.key});
  final Media m;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Image.asset(
              'assets/images/${m.img}.jpg',
              fit: BoxFit.cover,
              semanticLabel: m.alt,
              cacheWidth: 900,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(m.cap ?? '', style: body(13, c.muted, height: 1.4)),
        const SizedBox(height: 2),
        const AiTag(),
      ],
    );
  }
}

/// Fixed 320-wide drawing stage scaled to the available width.
class Stage extends StatelessWidget {
  const Stage({super.key, required this.children, this.h = 190});
  final List<Widget> children;
  final double h;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 320 / h,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 320,
          height: h,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(child: ColoredBox(color: context.c.tint)),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class DiagramFigure extends StatelessWidget {
  const DiagramFigure(this.id, this.cap, {super.key});
  final String id, cap;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stage(h: 200, children: diagram(id, c)),
        ),
        const SizedBox(height: 6),
        Text(cap, style: body(13, c.muted, height: 1.4)),
      ],
    );
  }
}

// ---------- stage helpers (coordinates match a 320 × 190 canvas) ----------
const _d = Duration(milliseconds: 750);
const _curve = Curves.easeOutCubic;

Widget box(
  double x,
  double y,
  double w,
  double h, {
  Color? color,
  double r = 0,
  Color? border,
  double bw = 1,
  Widget? child,
  double opacity = 1,
  Duration d = _d,
}) {
  return AnimatedPositioned(
    duration: d,
    curve: _curve,
    left: x,
    top: y,
    width: w,
    height: h,
    child: AnimatedOpacity(
      duration: d,
      opacity: opacity,
      child: AnimatedContainer(
        duration: d,
        curve: _curve,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(r),
          border: border == null ? null : Border.all(color: border, width: bw),
        ),
        child: child,
      ),
    ),
  );
}

Widget dot(
  double cx,
  double cy,
  double r,
  Color color, {
  double opacity = 1,
  Duration d = _d,
}) => box(
  cx - r,
  cy - r,
  r * 2,
  r * 2,
  color: color,
  r: r,
  opacity: opacity,
  d: d,
);

/// Text placed by baseline-ish y, like SVG text.
Widget label(
  double x,
  double y,
  String text,
  TextStyle style, {
  TextAlign align = TextAlign.center,
  double opacity = 1,
  double width = 220,
}) {
  final top = y - (style.fontSize ?? 12) * 1.0;
  final left = align == TextAlign.center
      ? x - width / 2
      : (align == TextAlign.right ? x - width : x);
  return Positioned(
    left: left,
    top: top,
    width: width,
    child: AnimatedOpacity(
      duration: _d,
      opacity: opacity,
      child: Text(
        text,
        textAlign: align,
        style: style.copyWith(height: 1.15),
        maxLines: 1,
        softWrap: false,
      ),
    ),
  );
}

Widget layer(double opacity, List<Widget> children) => Positioned.fill(
  child: AnimatedOpacity(
    duration: _d,
    opacity: opacity,
    child: Stack(children: children),
  ),
);

Widget paint(void Function(Canvas c) fn, {double opacity = 1}) =>
    Positioned.fill(
      child: AnimatedOpacity(
        duration: _d,
        opacity: opacity,
        child: CustomPaint(painter: _FnPainter(fn)),
      ),
    );

class _FnPainter extends CustomPainter {
  _FnPainter(this.fn);
  final void Function(Canvas) fn;
  @override
  void paint(Canvas canvas, Size size) => fn(canvas);
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Paint stroke(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;
Paint fill(Color c) => Paint()..color = c;

Path dashed(Path src, {double dash = 5, double gap = 5}) {
  final out = Path();
  for (final m in src.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      out.addPath(m.extractPath(d, math.min(d + dash, m.length)), Offset.zero);
      d += dash + gap;
    }
  }
  return out;
}

TextStyle _t(double s, Color c, [FontWeight w = FontWeight.w400]) =>
    body(s, c, weight: w);

// ---------- animated explainers ----------
const _frameMs = {
  'dtloop': 1500,
  'affinity': 1700,
  'crazy8': 800,
  'scamper': 2600,
  'fidelity': 1900,
  'users': 1300,
  'proximity': 2000,
  'similarity': 2000,
  'closure': 2000,
  'fitts': 1900,
  'hicks': 2100,
  'miller': 2300,
  'spectrum': 2300,
  'comfort': 2200,
  'prompt': 2000,
  'voice': 2300,
};

class Explainer extends StatefulWidget {
  const Explainer(this.id, {super.key, this.active = false});
  final String id;
  final bool active;
  @override
  State<Explainer> createState() => _ExplainerState();
}

class _ExplainerState extends State<Explainer> {
  int f = 0;
  Timer? _timer, _delay;
  bool played = false;
  List<String> get caps => Content.animCaptions[widget.id] ?? const [''];
  int get n => caps.length;
  bool get playing => _timer != null;

  @override
  void initState() {
    super.initState();
    if (widget.active) _autoplay();
  }

  @override
  void didUpdateWidget(Explainer old) {
    super.didUpdateWidget(old);
    if (widget.id != old.id) {
      // A different animation reused this state: start it from the first frame.
      _timer?.cancel();
      _timer = null;
      f = 0;
      played = false;
      if (widget.active) _autoplay();
      return;
    }
    if (widget.active && !old.active && !played) _autoplay();
    if (!widget.active && old.active) _stop();
  }

  void _autoplay() {
    _delay?.cancel();
    _delay = Timer(const Duration(milliseconds: 450), () {
      if (mounted && widget.active && !played) _play();
    });
  }

  void _play() {
    _timer?.cancel();
    played = true;
    setState(() {
      if (f >= n - 1) f = 0;
    });
    _timer = Timer.periodic(
      Duration(milliseconds: _frameMs[widget.id] ?? 1800),
      (_) {
        if (!mounted) return;
        if (f + 1 >= n) {
          _stop();
        } else {
          setState(() => f++);
        }
      },
    );
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _delay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final atEnd = f >= n - 1;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.line),
      ),
      child: Column(
        children: [
          Semantics(
            label: 'Animation: ${caps[f]}',
            child: ExcludeSemantics(
              child: Stage(
                key: ValueKey(widget.id),
                children: scene(widget.id, f, c),
              ),
            ),
          ),
          Container(
            color: c.surface,
            padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: IconButton.filled(
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: c.blue,
                      foregroundColor: c.onBlue,
                    ),
                    tooltip: playing
                        ? 'Pause animation'
                        : (atEnd && played
                              ? 'Replay animation'
                              : 'Play animation'),
                    onPressed: () => playing ? _stop() : _play(),
                    icon: Icon(
                      playing
                          ? Icons.pause_rounded
                          : (atEnd && played
                                ? Icons.replay_rounded
                                : Icons.play_arrow_rounded),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 38),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          caps[f],
                          key: ValueKey(f),
                          style: body(13.5, c.ink, height: 1.35),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(
                    n,
                    (i) => Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(left: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == f ? c.blue : c.tint2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> scene(String id, int f, AppColors c) {
  switch (id) {
    case 'dtloop':
      const names = ['Empathize', 'Define', 'Ideate', 'Prototype', 'Test'];
      return [
        paint((cv) {
          for (var i = 0; i < 4; i++) {
            cv.drawLine(
              Offset(62.0 + i * 60, 100),
              Offset(78.0 + i * 60, 100),
              stroke(c.line, 2),
            );
          }
        }),
        paint((cv) {
          final p = Path()
            ..moveTo(280, 74)
            ..cubicTo(272, 8, 48, 8, 40, 74);
          cv.drawPath(dashed(p), stroke(c.blue, 2.5));
          cv.drawPath(
            Path()
              ..moveTo(33, 64)
              ..lineTo(40, 77)
              ..lineTo(48, 65)
              ..close(),
            fill(c.blue),
          );
        }, opacity: f >= 5 ? 1 : 0),
        for (var i = 0; i < 5; i++) ...[
          box(
            18.0 + i * 60,
            78,
            44,
            44,
            color: i <= f ? c.blue : c.surface,
            r: 22,
            border: i <= f ? c.blue : c.tint2,
            bw: 2,
            child: Center(
              child: Text(
                names[i][0],
                style: _t(17, i <= f ? Colors.white : c.muted, FontWeight.w700),
              ),
            ),
          ),
          label(40.0 + i * 60, 146, names[i], _t(10.5, c.ink)),
        ],
      ];
    case 'affinity':
      const sc = [
        [60, 90],
        [-20, 40],
        [110, -10],
        [30, 70],
        [-60, 60],
        [40, -30],
        [-90, 20],
        [70, 50],
        [-120, -20],
        [-30, 80],
        [20, -25],
        [-150, 40],
      ];
      final cols = [c.blue, c.peri, c.amber];
      final out = <Widget>[];
      var k = 0;
      for (var j = 0; j < 4; j++) {
        for (var g = 0; g < 3; g++) {
          final x = 26.0 + g * 100 + (j % 2) * 38, y = 60.0 + (j ~/ 2) * 34;
          final o = sc[k++];
          final dx = f < 2 ? o[0] * .6 : 0.0, dy = f < 2 ? o[1] * .5 : 0.0;
          final lineC = (g == 0 && f >= 1)
              ? Colors.white
              : c.muted.withValues(alpha: .6);
          out.add(
            box(
              x + dx,
              y + dy,
              34,
              27,
              color: f >= 1 ? cols[g] : c.surface,
              r: 3,
              border: f >= 1 ? cols[g] : c.line,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 1.4, width: 20, color: lineC),
                    const SizedBox(height: 5.6),
                    Container(height: 1.4, width: 14, color: lineC),
                  ],
                ),
              ),
            ),
          );
        }
      }
      for (var g = 0; g < 3; g++) {
        out.add(
          label(
            62.0 + g * 100,
            44,
            const ['Time', 'Cost', 'Noise'][g],
            _t(13, c.ink, FontWeight.w700),
            opacity: f >= 3 ? 1 : 0,
          ),
        );
      }
      return out;
    case 'crazy8':
      return [
        box(24, 24, 208, 148, color: c.surface, r: 3, border: c.line, bw: 1.5),
        paint((cv) {
          final p = Path();
          for (final x in [76.0, 128.0, 180.0]) {
            p
              ..moveTo(x, 24)
              ..lineTo(x, 172);
          }
          p
            ..moveTo(24, 98)
            ..lineTo(232, 98);
          cv.drawPath(dashed(p, dash: 3, gap: 3), stroke(c.line, 1.2));
        }),
        for (var k = 0; k < 8; k++)
          Positioned(
            left: 24.0 + (k % 4) * 52 + 12,
            top: 24.0 + (k ~/ 4) * 74 + 10,
            width: 28,
            height: 54,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: k < f ? 1 : 0,
              child: _sketch(k % 4, c),
            ),
          ),
        Positioned(
          left: 244,
          top: 66,
          width: 64,
          height: 64,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: 1 - f / 8),
            duration: const Duration(milliseconds: 600),
            builder: (_, v, _) => CustomPaint(
              painter: _FnPainter((cv) {
                const r = Rect.fromLTWH(0, 0, 64, 64);
                cv.drawArc(
                  r.deflate(3.5),
                  0,
                  math.pi * 2,
                  false,
                  stroke(c.tint2, 7),
                );
                if (v > 0) {
                  cv.drawArc(
                    r.deflate(3.5),
                    -math.pi / 2,
                    math.pi * 2 * v,
                    false,
                    stroke(c.blue, 7),
                  );
                }
              }),
              child: Center(
                child: Text(
                  '${8 - f}:00',
                  style: _t(16, c.ink, FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        label(276, 150, 'minutes left', _t(10, c.muted)),
      ];
    case 'scamper':
      final w = Content.scamperWords[f.clamp(0, 6)];
      return [
        for (var i = 0; i < 7; i++)
          box(
            9.0 + i * 44,
            24,
            38,
            38,
            color: i == f ? c.blue : c.surface,
            r: 10,
            d: const Duration(milliseconds: 300),
            child: Center(
              child: Text(
                'SCAMPER'[i],
                style: _t(18, i == f ? Colors.white : c.blue, FontWeight.w800),
              ),
            ),
          ),
        Positioned(
          left: 0,
          width: 320,
          top: 84,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(f),
              children: [
                Text(w[0], style: display(23, c.blue)),
                const SizedBox(height: 8),
                Text(w[1], style: _t(13, c.muted)),
              ],
            ),
          ),
        ),
      ];
    case 'fidelity':
      const names = ['Sketch', 'Wireframe', 'High fidelity'];
      return [
        for (var i = 0; i < 3; i++) ...[
          dot(24, 66.0 + i * 30, 5, i == f ? c.blue : c.tint2),
          label(
            36,
            70.0 + i * 30,
            names[i],
            _t(12, i == f ? c.ink : c.muted, FontWeight.w600),
            align: TextAlign.left,
            width: 110,
          ),
        ],
        box(160, 10, 96, 172, color: c.surface, r: 16, border: c.line, bw: 2),
        paint((cv) {
          final s = stroke(c.muted, 1.6);
          cv.drawPath(
            Path()
              ..moveTo(172, 34)
              ..quadraticBezierTo(208, 30, 244, 33),
            s,
          );
          cv.drawPath(
            Path()
              ..moveTo(174, 54)
              ..quadraticBezierTo(182, 80, 204, 79)
              ..quadraticBezierTo(222, 78, 226, 55)
              ..quadraticBezierTo(200, 48, 174, 54),
            s,
          );
          cv.drawPath(
            Path()
              ..moveTo(172, 100)
              ..quadraticBezierTo(205, 103, 242, 101),
            s,
          );
          cv.drawPath(
            Path()
              ..moveTo(172, 112)
              ..quadraticBezierTo(198, 110, 222, 112),
            s,
          );
          cv.drawPath(
            Path()
              ..moveTo(180, 150)
              ..quadraticBezierTo(208, 147, 236, 149)
              ..lineTo(236, 167)
              ..quadraticBezierTo(208, 169, 180, 168)
              ..close(),
            s,
          );
        }, opacity: f == 0 ? 1 : 0),
        layer(f == 1 ? 1 : 0, [
          for (final r in const [
            [170, 26, 76, 12],
            [170, 46, 76, 44],
            [170, 98, 62, 7],
            [170, 111, 48, 7],
            [170, 150, 76, 18],
          ])
            box(
              r[0].toDouble(),
              r[1].toDouble(),
              r[2].toDouble(),
              r[3].toDouble(),
              color: c.tint2,
              r: 3,
            ),
        ]),
        layer(f == 2 ? 1 : 0, [
          box(162, 12, 92, 30, color: c.blue, r: 14),
          box(170, 48, 76, 44, color: c.peri, r: 8),
          dot(190, 66, 7, Colors.white),
          box(170, 98, 62, 7, color: c.ink, r: 3),
          box(170, 111, 48, 6, color: c.muted, r: 3),
          box(170, 150, 76, 20, color: c.blue, r: 8),
        ]),
      ];
    case 'users':
      const p = [31, 52, 67, 77, 85];
      return [
        paint(
          (cv) => cv.drawLine(
            const Offset(30, 160),
            const Offset(300, 160),
            stroke(c.line, 2),
          ),
        ),
        for (var i = 0; i < 5; i++) ...[
          box(
            50.0 + i * 52,
            i <= f ? 160 - p[i] * 1.3 : 160,
            32,
            i <= f ? p[i] * 1.3 : 0,
            color: c.blue,
            r: 5,
          ),
          label(
            66.0 + i * 52,
            152 - p[i] * 1.3,
            '${p[i]}%',
            _t(12, c.ink, FontWeight.w700),
            opacity: i <= f ? 1 : 0,
            width: 50,
          ),
          label(
            66.0 + i * 52,
            178,
            '${i + 1} user${i > 0 ? 's' : ''}',
            _t(10, c.muted),
            width: 50,
          ),
        ],
      ];
    case 'proximity':
      return [
        for (var k = 0; k < 16; k++)
          () {
            final i = k >> 2, j = k & 3;
            var x = 160 + (j - 1.5) * 30, y = 95 + (i - 1.5) * 30;
            if (f == 1) y = 95 + (i - 1.5) * 24 + (i < 2 ? -16 : 16);
            if (f == 2) x = 160 + (j - 1.5) * 24 + (j < 2 ? -22 : 22);
            return dot(x, y, 9, c.blue);
          }(),
      ];
    case 'similarity':
      return [
        for (var k = 0; k < 16; k++)
          () {
            final i = k >> 2, j = k & 3;
            final a = f == 1 ? j % 2 == 0 : (f == 2 ? i % 2 == 0 : false);
            return dot(115.0 + j * 30, 50.0 + i * 30, 10, a ? c.blue : c.peri);
          }(),
      ];
    case 'closure':
      final tri = Path()
        ..moveTo(160, 36)
        ..lineTo(96, 156)
        ..lineTo(224, 156)
        ..close();
      return [
        dot(160, 36, 24, c.blue),
        dot(96, 156, 24, c.blue),
        dot(224, 156, 24, c.blue),
        paint((cv) => cv.drawPath(tri, fill(c.tint)), opacity: f >= 1 ? 1 : 0),
        paint(
          (cv) =>
              cv.drawPath(dashed(tri, dash: 4, gap: 4), stroke(c.blue, 1.5)),
          opacity: f >= 2 ? 1 : 0,
        ),
      ];
    case 'fitts':
      const pos = [
        [30.0, 160.0],
        [122.0, 120.0],
        [30.0, 160.0],
        [290.0, 34.0],
      ];
      const dur = [300, 450, 350, 1500];
      return [
        box(80, 78, 84, 84, color: f == 1 ? c.good : c.tint2, r: 16),
        label(122, 178, 'Large & near', _t(10.5, c.muted)),
        dot(290, 34, 8, f == 3 ? c.good : c.tint2),
        label(290, 60, 'Small & far', _t(10.5, c.muted), width: 80),
        dot(30, 160, 4, c.muted),
        AnimatedPositioned(
          duration: Duration(milliseconds: dur[f]),
          curve: Curves.easeInOut,
          left: pos[f][0],
          top: pos[f][1],
          width: 16,
          height: 24,
          child: CustomPaint(
            painter: _FnPainter((cv) {
              final p = Path()
                ..moveTo(0, 0)
                ..lineTo(0, 18)
                ..lineTo(5, 13)
                ..lineTo(9, 22)
                ..lineTo(13, 20)
                ..lineTo(9, 12)
                ..lineTo(16, 12)
                ..close();
              cv.drawPath(p, fill(c.ink));
              cv.drawPath(p, stroke(c.surface, 1.2));
            }),
          ),
        ),
      ];
    case 'hicks':
      final n = const [2, 6, 12][f];
      final ratio = math.log(n + 1) / math.log(13);
      return [
        for (var i = 0; i < 12; i++)
          box(
            24,
            16 + i * 13.5,
            110,
            10,
            color: c.tint2,
            r: 4,
            opacity: i < n ? 1 : .12,
          ),
        label(
          164,
          66,
          'Time to decide',
          _t(12, c.muted),
          align: TextAlign.left,
          width: 140,
        ),
        box(164, 76, 130, 18, color: c.tint2, r: 9),
        box(164, 76, 130 * ratio, 18, color: c.blue, r: 9),
        Positioned(
          left: 164,
          top: 106,
          child: Text('$n options', style: _t(22, c.ink, FontWeight.w800)),
        ),
      ];
    case 'miller':
      double off(int i) => (i >= 3 ? 18.0 : 0) + (i >= 6 ? 18.0 : 0);
      const digits = '5550123456';
      return [
        for (final ch in const [
          [0, 2],
          [3, 5],
          [6, 9],
        ])
          box(
            52 + ch[0] * 22 + off(ch[0]) - 15,
            70,
            (ch[1] - ch[0]) * 22 + 30,
            46,
            color: c.surface,
            r: 10,
            opacity: f == 1 ? 1 : 0,
          ),
        for (var i = 0; i < 10; i++)
          AnimatedPositioned(
            duration: _d,
            curve: _curve,
            left: (f == 1 ? 52 + i * 22 + off(i) : 61.0 + i * 22) - 12,
            top: 76,
            width: 24,
            child: Text(
              digits[i],
              textAlign: TextAlign.center,
              style: _t(
                27,
                c.ink,
                FontWeight.w700,
              ).copyWith(fontFeatures: const [ui.FontFeature.tabularFigures()]),
            ),
          ),
      ];
    case 'spectrum':
      return [
        box(40, 20, 240, 4, color: c.tint2, r: 2),
        for (var i = 0; i < 4; i++) ...[
          dot(40.0 + i * 80, 22, 4, c.muted),
          label(
            40.0 + i * 80,
            44,
            const ['Real', 'AR', 'MR', 'VR'][i],
            _t(11, c.ink, FontWeight.w700),
            width: 60,
          ),
        ],
        dot(40.0 + f * 80, 22, 8, c.blue),
        paint((cv) {
          final s = stroke(c.ink, 2);
          cv.drawLine(const Offset(16, 172), const Offset(304, 172), s);
          cv.drawRRect(
            RRect.fromLTRBR(34, 66, 96, 120, const Radius.circular(3)),
            s,
          );
          cv.drawLine(
            const Offset(65, 66),
            const Offset(65, 120),
            stroke(c.ink, 1.5),
          );
          cv.drawRRect(
            RRect.fromLTRBR(170, 128, 274, 136, const Radius.circular(2)),
            fill(c.ink),
          );
          cv.drawLine(
            const Offset(180, 136),
            const Offset(180, 172),
            stroke(c.ink, 3),
          );
          cv.drawLine(
            const Offset(264, 136),
            const Offset(264, 172),
            stroke(c.ink, 3),
          );
          final m = stroke(c.muted, 2);
          cv.drawPath(
            Path()
              ..moveTo(118, 172)
              ..lineTo(118, 146)
              ..lineTo(134, 146)
              ..lineTo(134, 172)
              ..moveTo(112, 146)
              ..lineTo(140, 146),
            m,
          );
        }),
        layer(f == 1 ? 1 : 0, [
          box(
            182,
            70,
            82,
            26,
            color: c.blue,
            r: 13,
            child: Center(
              child: Text(
                'Desk · free',
                style: _t(11, Colors.white, FontWeight.w700),
              ),
            ),
          ),
          paint(
            (cv) => cv.drawPath(
              dashed(
                Path()
                  ..moveTo(223, 96)
                  ..lineTo(223, 126),
                dash: 3,
                gap: 3,
              ),
              stroke(c.blue, 1.5),
            ),
          ),
        ]),
        paint((cv) {
          cv.drawOval(
            Rect.fromCenter(
              center: const Offset(222, 128),
              width: 52,
              height: 8,
            ),
            fill(c.muted.withValues(alpha: .5)),
          );
          cv.drawPath(
            Path()
              ..moveTo(200, 92)
              ..lineTo(222, 81)
              ..lineTo(244, 92)
              ..lineTo(244, 116)
              ..lineTo(222, 127)
              ..lineTo(200, 116)
              ..close(),
            fill(c.peri),
          );
          cv.drawPath(
            Path()
              ..moveTo(200, 92)
              ..lineTo(222, 103)
              ..lineTo(244, 92)
              ..lineTo(222, 81)
              ..close(),
            fill(c.blue),
          );
          cv.drawPath(
            Path()
              ..moveTo(222, 103)
              ..lineTo(222, 127)
              ..lineTo(244, 116)
              ..lineTo(244, 92)
              ..close(),
            fill(c.blue.withValues(alpha: .7)),
          );
        }, opacity: f == 2 ? 1 : 0),
        paint((cv) {
          cv.drawRect(const Rect.fromLTWH(0, 54, 320, 136), fill(c.night));
          for (final s in const [
            [60.0, 80.0, 1.6],
            [120.0, 70.0, 1.2],
            [250.0, 76.0, 1.8],
            [190.0, 92.0, 1.2],
            [30.0, 100.0, 1.0],
            [160.0, 64.0, 1.4],
          ]) {
            cv.drawCircle(Offset(s[0], s[1]), s[2], fill(Colors.white));
          }
          cv.drawCircle(const Offset(270, 102), 14, fill(c.peri));
          cv.drawPath(
            Path()
              ..moveTo(0, 190)
              ..lineTo(70, 120)
              ..lineTo(120, 160)
              ..lineTo(180, 98)
              ..lineTo(250, 158)
              ..lineTo(320, 124)
              ..lineTo(320, 190)
              ..close(),
            fill(c.blue),
          );
        }, opacity: f == 3 ? 1 : 0),
      ];
    case 'comfort':
      const pos = [
        [160.0, 150.0],
        [290.0, 120.0],
        [160.0, 92.0],
      ];
      return [
        paint((cv) {
          final p = Path()
            ..moveTo(125.6, 125.9)
            ..lineTo(85.4, 68.5)
            ..arcToPoint(
              const Offset(234.6, 68.5),
              radius: const Radius.circular(130),
            )
            ..lineTo(194.4, 125.9)
            ..arcToPoint(
              const Offset(125.6, 125.9),
              radius: const Radius.circular(60),
              clockwise: false,
            )
            ..close();
          cv.drawPath(p, fill(c.good.withValues(alpha: .2)));
          cv.drawPath(
            Path()
              ..moveTo(154, 162)
              ..lineTo(160, 153)
              ..lineTo(166, 162)
              ..close(),
            fill(c.ink),
          );
        }),
        label(160, 58, 'comfort zone', _t(10.5, c.muted)),
        label(160, 16, 'Top-down view', _t(10, c.muted)),
        dot(160, 175, 14, c.ink),
        AnimatedPositioned(
          duration: _d,
          curve: _curve,
          left: pos[f][0] - 26,
          top: pos[f][1] - 7,
          width: 52,
          height: 14,
          child: AnimatedRotation(
            duration: _d,
            turns: f == 1 ? -55 / 360 : 0,
            child: AnimatedContainer(
              duration: _d,
              decoration: BoxDecoration(
                color: f == 2 ? c.good : c.bad,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ];
    case 'prompt':
      const chips = [
        ['Role', 'You are a UX researcher'],
        ['Context', '5 pain points from first-year students'],
        ['Task', 'Suggest "How might we" questions'],
        ['Limits', '10 questions, under 15 words each'],
        ['Format', 'Return a numbered list'],
      ];
      return [
        box(
          14,
          70,
          292,
          40,
          color: c.surface,
          r: 12,
          opacity: f == 0 ? 1 : 0,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('"Give me app ideas."', style: _t(14, c.muted)),
            ),
          ),
        ),
        for (var i = 0; i < 5; i++)
          box(
            14,
            12.0 + i * 34,
            292,
            28,
            color: c.surface,
            r: 9,
            opacity: i < f ? 1 : 0,
            child: Row(
              children: [
                Container(
                  width: 70,
                  decoration: BoxDecoration(
                    color: c.blue,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    chips[i][0],
                    style: _t(11, Colors.white, FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    chips[i][1],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(11, c.ink),
                  ),
                ),
              ],
            ),
          ),
      ];
    case 'voice':
      return [
        Positioned(
          left: 112,
          top: 20,
          width: 99,
          height: 26,
          child: _Wave(talking: f % 2 == 0, color: c.blue),
        ),
        box(
          120,
          70,
          186,
          34,
          color: c.blue,
          r: 17,
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                f < 2 ? '"Navigate home"' : '"Call Jo"',
                style: _t(13, Colors.white, FontWeight.w600),
              ),
            ),
          ),
        ),
        box(
          14,
          118,
          250,
          34,
          color: c.surface,
          r: 17,
          opacity: f % 2 == 1 ? 1 : 0,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                f < 2
                    ? 'Starting route home. 18 min.'
                    : 'Did you mean Jo Park or Joe Diaz?',
                style: _t(13, c.ink),
              ),
            ),
          ),
        ),
      ];
  }
  return const [];
}

Widget _sketch(int v, AppColors c) {
  Widget ln(double w, {Color? color, double h = 1.3}) =>
      Container(width: w, height: h, color: color ?? c.ink);
  final inner = switch (v) {
    0 => [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.ink, width: 1.3),
        ),
      ),
      const SizedBox(height: 10),
      ln(18),
      const SizedBox(height: 5),
      ln(12),
    ],
    1 => [
      for (var r = 0; r < 2; r++) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var q = 0; q < 2; q++)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  border: Border.all(color: c.ink, width: 1.1),
                ),
              ),
          ],
        ),
      ],
      const SizedBox(height: 10),
      ln(18, color: c.blue, h: 3),
    ],
    2 => [
      Container(width: 20, height: 15, color: c.peri),
      const SizedBox(height: 6),
      ln(18),
      const SizedBox(height: 4),
      ln(18),
      const SizedBox(height: 4),
      ln(10),
    ],
    _ => [
      for (var r = 0; r < 4; r++) ...[ln(18), const SizedBox(height: 6)],
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: c.blue, shape: BoxShape.circle),
      ),
    ],
  };
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: c.ink, width: 1.5),
    ),
    padding: const EdgeInsets.only(top: 5),
    child: Column(children: inner),
  );
}

class _Wave extends StatefulWidget {
  const _Wave({required this.talking, required this.color});
  final bool talking;
  final Color color;
  @override
  State<_Wave> createState() => _WaveState();
}

class _WaveState extends State<_Wave> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  @override
  void initState() {
    super.initState();
    if (widget.talking) _a.repeat();
  }

  @override
  void didUpdateWidget(_Wave old) {
    super.didUpdateWidget(old);
    if (widget.talking && !_a.isAnimating) _a.repeat();
    if (!widget.talking) {
      _a.animateTo(0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, _) => Row(
        children: List.generate(11, (i) {
          final s = widget.talking
              ? .3 +
                    .7 *
                        (0.5 +
                                0.5 *
                                    math.sin((_a.value * 2 * math.pi) + i * .7))
                            .abs()
              : .3;
          return Container(
            width: 5,
            height: 26 * s,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2.5),
            ),
          );
        }),
      ),
    );
  }
}

// ---------- static diagrams (320 × 200) ----------
List<Widget> diagram(String id, AppColors c) {
  switch (id) {
    case 'empathymap':
      return [
        paint((cv) {
          cv.drawLine(
            const Offset(160, 16),
            const Offset(160, 184),
            stroke(c.line, 2),
          );
          cv.drawLine(
            const Offset(16, 100),
            const Offset(304, 100),
            stroke(c.line, 2),
          );
        }),
        label(
          40,
          36,
          'Says',
          _t(14, c.ink, FontWeight.w700),
          align: TextAlign.left,
          width: 110,
        ),
        label(
          40,
          56,
          '"I just need somewhere quiet."',
          _t(9.5, c.muted),
          align: TextAlign.left,
          width: 118,
        ),
        label(
          200,
          36,
          'Thinks',
          _t(14, c.ink, FontWeight.w700),
          align: TextAlign.left,
          width: 110,
        ),
        label(
          200,
          56,
          '"Everyone else found a spot."',
          _t(9.5, c.muted),
          align: TextAlign.left,
          width: 118,
        ),
        label(
          40,
          150,
          'Circles the library twice',
          _t(9.5, c.muted),
          align: TextAlign.left,
          width: 118,
        ),
        label(
          40,
          170,
          'Does',
          _t(14, c.ink, FontWeight.w700),
          align: TextAlign.left,
          width: 110,
        ),
        label(
          200,
          150,
          'Stressed, rushed',
          _t(9.5, c.muted),
          align: TextAlign.left,
          width: 110,
        ),
        label(
          200,
          170,
          'Feels',
          _t(14, c.ink, FontWeight.w700),
          align: TextAlign.left,
          width: 110,
        ),
        dot(160, 100, 26, c.blue),
        paint((cv) {
          cv.drawCircle(const Offset(160, 93), 8, fill(Colors.white));
          cv.drawArc(
            Rect.fromCenter(
              center: const Offset(160, 116),
              width: 28,
              height: 24,
            ),
            math.pi,
            math.pi,
            true,
            fill(Colors.white),
          );
        }),
      ];
    case 'mindmap':
      const b = [
        ['Noise', 60.0, 40.0],
        ['Booking', 260.0, 40.0],
        ['Location', 40.0, 150.0],
        ['Hours', 280.0, 150.0],
        ['Outlets', 160.0, 182.0],
      ];
      return [
        paint((cv) {
          for (final n in b) {
            final x = n[1] as double, y = n[2] as double;
            cv.drawLine(
              const Offset(160, 100),
              Offset(x, y),
              stroke(c.blue, 2),
            );
            cv.drawCircle(
              Offset((x + 160) / 2 + (x < 160 ? -18 : 18), (y + 100) / 2 - 12),
              4,
              fill(c.peri),
            );
          }
        }),
        box(
          104,
          82,
          112,
          36,
          color: c.blue,
          r: 18,
          child: Center(
            child: Text(
              'Quiet study spots',
              style: _t(12, Colors.white, FontWeight.w700),
            ),
          ),
        ),
        for (final n in b)
          box(
            (n[1] as double) - 34,
            (n[2] as double) - 13,
            68,
            26,
            color: c.surface,
            r: 13,
            child: Center(
              child: Text(
                n[0] as String,
                style: _t(11, c.ink, FontWeight.w600),
              ),
            ),
          ),
      ];
    case 'matrix':
      return [
        box(40, 14, 130, 80, color: c.surface),
        box(172, 14, 130, 80, color: c.tint2),
        box(40, 96, 130, 80, color: c.tint2),
        box(172, 96, 130, 80, color: c.surface),
        label(
          105,
          34,
          'Quick wins',
          _t(12, c.blue, FontWeight.w700),
          width: 120,
        ),
        label(237, 34, 'Big bets', _t(12, c.ink, FontWeight.w700), width: 120),
        label(
          105,
          116,
          'Maybe later',
          _t(12, c.ink, FontWeight.w700),
          width: 120,
        ),
        label(237, 116, 'Skip', _t(12, c.muted, FontWeight.w700), width: 120),
        dot(80, 60, 7, c.blue),
        dot(120, 72, 7, c.blue),
        dot(230, 62, 7, c.peri),
        dot(90, 145, 7, c.peri),
        dot(250, 150, 7, c.muted),
        Positioned(
          left: 4,
          top: 60,
          width: 20,
          height: 70,
          child: RotatedBox(
            quarterTurns: 3,
            child: Center(child: Text('Impact →', style: _t(10, c.muted))),
          ),
        ),
        label(171, 194, 'Effort →', _t(10, c.muted)),
      ];
  }
  return const [];
}
