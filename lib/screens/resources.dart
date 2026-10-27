import 'package:flutter/material.dart';

import '../data/content.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'glossary.dart';
import 'learn.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});
  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String q = '', type = 'all';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ValueListenableBuilder<String>(
      valueListenable: Nav.resourceTopic,
      builder: (context, topic, _) {
        final ql = q.trim().toLowerCase();
        final items = Content.resources
            .where(
              (r) =>
                  (type == 'all' || r.type == type) &&
                  (topic == 'all' || r.topic == topic) &&
                  (ql.isEmpty ||
                      '${r.title} ${r.source} ${r.meta}'.toLowerCase().contains(
                        ql,
                      )),
            )
            .toList();
        return SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: PageTitle(
                  'Resources',
                  'Videos, reading, courses and tools we trust',
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: PinnedFilters(
                  height: 164,
                  color: c.bg,
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      SearchField(
                        hint: 'Search resources',
                        onChanged: (v) => setState(() => q = v),
                      ),
                      const SizedBox(height: 12),
                      FilterChips(
                        options: [
                          const MapEntry('all', 'All formats'),
                          ...Content.types.entries,
                        ],
                        selected: type,
                        onSelect: (v) => setState(() => type = v),
                      ),
                      const SizedBox(height: 10),
                      FilterChips(
                        options: [
                          const MapEntry('all', 'All topics'),
                          ...Content.topics.entries,
                        ],
                        selected: topic,
                        onSelect: (v) => Nav.resourceTopic.value = v,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                  child: Text(
                    '${items.length} resource${items.length == 1 ? '' : 's'}',
                    style: body(13, c.muted),
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
                          'Nothing here yet',
                          style: body(16, c.ink, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Clear a filter to see more resources.',
                          style: body(14, c.muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: ResourceCard(items[i]),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}
