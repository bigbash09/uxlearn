import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static const _sources = [
    [
      'Medium',
      'Articles from UX Collective and design writers',
      'https://medium.com',
    ],
    [
      'YouTube',
      'Free video lessons from NN/g, Figma and AJ&Smart',
      'https://www.youtube.com',
    ],
    [
      'Tutors.com',
      'Teaching approaches and learning resources',
      'https://www.tutors.com',
    ],
    [
      'Interaction Design Foundation',
      'UX literature and courses',
      'https://www.interaction-design.org',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Text('Credits', style: display(26, c.ink)),
          const SizedBox(height: 8),
          Text(
            'UX Terms was designed by an MFA candidate and prospective teaching assistant for college freshmen new to UI/UX and design thinking. It bridges academic learning and practical application.',
            style: body(15, c.muted),
          ),
          const SizedBox(height: 8),
          Text(
            'Lesson photos are AI-generated illustrations made with Figma AI. Diagrams and animations were drawn for this app.',
            style: body(13, c.muted),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.blue,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'APPRECIATION',
                  style: eyebrow(Colors.white.withValues(alpha: .75)),
                ),
                const SizedBox(height: 6),
                Text(
                  'UX Toast App',
                  style: body(22, Colors.white, weight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Inspiration for the bite-sized learning format.',
                  style: body(14, Colors.white.withValues(alpha: .92)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text('Resources', style: body(18, c.ink, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          Panel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _sources.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: c.line),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      _sources[i][0],
                      style: display(16, c.ink, weight: FontWeight.w700),
                    ),
                    subtitle: Text(_sources[i][1], style: body(13, c.muted)),
                    trailing: Icon(
                      Icons.north_east_rounded,
                      size: 18,
                      color: c.muted,
                    ),
                    onTap: () => openLink(context, _sources[i][2]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
