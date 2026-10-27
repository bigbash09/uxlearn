import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/content.dart';
import 'screens/glossary.dart';
import 'screens/home.dart';
import 'screens/learn.dart';
import 'screens/progress_screen.dart';
import 'screens/resources.dart';
import 'state/progress.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Content.load();
  final progress = await Progress.load();
  runApp(UxTermsApp(progress: progress));
}

class UxTermsApp extends StatelessWidget {
  const UxTermsApp({super.key, required this.progress});
  final Progress progress;
  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      progress: progress,
      child: MaterialApp(
        title: 'UX Terms',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        // On tablets, keep the phone-first layout readable by centring it.
        builder: (context, child) => ColoredBox(
          color: context.c.bg,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: child,
            ),
          ),
        ),
        home: const Splash(),
      ),
    );
  }
}

/// Global navigation state shared by the tabs.
class Nav {
  static final tab = ValueNotifier<int>(0);
  static final resourceTopic = ValueNotifier<String>('all');
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _gone = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), _go);
  }

  void _go() {
    if (_gone || !mounted) return;
    _gone = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => const Shell(),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onTap: _go,
        child: Scaffold(
          backgroundColor: c.blue,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .18),
                        blurRadius: 40,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'U',
                          style: display(
                            46,
                            AppColors.light.blue,
                            weight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: 'X',
                          style: display(
                            46,
                            AppColors.light.peri,
                            weight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('UX Terms', style: display(30, Colors.white)),
                const SizedBox(height: 6),
                Text(
                  'Learn the language of design',
                  style: body(15, Colors.white.withValues(alpha: .85)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.menu_book_outlined, Icons.menu_book_rounded, 'Learn'),
    (Icons.sort_by_alpha_rounded, Icons.sort_by_alpha_rounded, 'Glossary'),
    (Icons.layers_outlined, Icons.layers_rounded, 'Resources'),
    (Icons.donut_large_rounded, Icons.donut_large_rounded, 'Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ValueListenableBuilder<int>(
      valueListenable: Nav.tab,
      builder: (context, tab, _) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: tab == 0
            ? SystemUiOverlayStyle.light
            : (Theme.of(context).brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark),
        child: Scaffold(
          body: IndexedStack(
            index: tab,
            children: const [
              HomeScreen(),
              LearnScreen(),
              GlossaryScreen(),
              ResourcesScreen(),
              ProgressScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(top: BorderSide(color: c.line)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: List.generate(_items.length, (i) {
                    final on = i == tab, it = _items[i];
                    return Expanded(
                      child: Semantics(
                        selected: on,
                        button: true,
                        label: it.$3,
                        child: InkResponse(
                          onTap: () => Nav.tab.value = i,
                          child: ExcludeSemantics(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  on ? it.$2 : it.$1,
                                  color: on ? c.blue : c.muted,
                                  size: 24,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  it.$3,
                                  style: body(
                                    11,
                                    on ? c.blue : c.muted,
                                    weight: FontWeight.w600,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: on ? c.blue : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
