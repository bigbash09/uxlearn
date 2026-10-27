import 'package:flutter/material.dart';

import '../data/content.dart';
import '../state/progress.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'learn.dart';
import 'routes.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});
  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String q = '', cat = 'All';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = ProgressScope.of(context);
    final ql = q.trim().toLowerCase();
    final items = Content.terms
        .where(
          (t) =>
              (cat == 'All' || t.cat == cat) &&
              (ql.isEmpty ||
                  t.t.toLowerCase().contains(ql) ||
                  t.def.toLowerCase().contains(ql)),
        )
        .toList();

    final rows = <Widget>[];
    String last = '';
    for (final t in items) {
      var letter = t.t[0].toUpperCase();
      if (RegExp(r'[0-9]').hasMatch(letter)) letter = '#';
      if (letter != last) {
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(letter, style: display(15, c.blue)),
          ),
        );
        last = letter;
      }
      rows.add(
        InkWell(
          onTap: () => openTermSheet(context, t),
          child: Container(
            margin: kGutter,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.t,
                        style: body(15, c.ink, weight: FontWeight.w700),
                      ),
                      Text(
                        t.def,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: body(13, c.muted),
                      ),
                    ],
                  ),
                ),
                if (p.terms.contains(t.id))
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.bookmark_rounded,
                      size: 16,
                      color: c.blue,
                      semanticLabel: 'Saved',
                    ),
                  ),
                const SizedBox(width: 8),
                Pill(t.cat),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PageTitle(
              'Glossary',
              '${Content.terms.length} terms in plain language',
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedFilters(
              height: 116,
              color: c.bg,
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  SearchField(
                    hint: 'Search terms',
                    onChanged: (v) => setState(() => q = v),
                  ),
                  const SizedBox(height: 12),
                  FilterChips(
                    options: [
                      for (final x in ['All', ...Content.categories])
                        MapEntry(x, x),
                    ],
                    selected: cat,
                    onSelect: (v) => setState(() => cat = v),
                  ),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Text(
                      'No terms match "$q"',
                      style: body(16, c.ink, weight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try a shorter word or pick another category.',
                      style: body(14, c.muted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList.list(children: rows),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class PinnedFilters extends SliverPersistentHeaderDelegate {
  PinnedFilters({
    required this.child,
    required this.height,
    required this.color,
  });
  final Widget child;
  final double height;
  final Color color;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(color: color, child: child);
  @override
  bool shouldRebuild(PinnedFilters old) => true;
}
