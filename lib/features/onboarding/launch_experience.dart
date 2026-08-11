import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/assets/atlas_sprite.dart';
import '../../home_shell.dart';
import '../../l10n/localization_extensions.dart';

class LaunchExperience extends StatefulWidget {
  const LaunchExperience({
    required this.onboardingCompleted,
    required this.onOnboardingComplete,
    super.key,
  });

  final bool onboardingCompleted;
  final Future<void> Function() onOnboardingComplete;

  @override
  State<LaunchExperience> createState() => _LaunchExperienceState();
}

enum _LaunchStage { splash, onboarding, home }

class _LaunchExperienceState extends State<LaunchExperience> {
  _LaunchStage _stage = _LaunchStage.splash;

  void _begin() {
    setState(() {
      _stage = widget.onboardingCompleted
          ? _LaunchStage.home
          : _LaunchStage.onboarding;
    });
  }

  Future<void> _completeOnboarding() async {
    await widget.onOnboardingComplete();
    if (!mounted) return;
    setState(() => _stage = _LaunchStage.home);
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 560),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    child: switch (_stage) {
      _LaunchStage.splash => _CozySplashScreen(
        key: const ValueKey('splash'),
        onBegin: _begin,
      ),
      _LaunchStage.onboarding => _OnboardingScreen(
        key: const ValueKey('onboarding'),
        onComplete: _completeOnboarding,
      ),
      _LaunchStage.home => const HomeShell(key: ValueKey('home')),
    },
  );
}

class _CozySplashScreen extends StatefulWidget {
  const _CozySplashScreen({required this.onBegin, super.key});

  final VoidCallback onBegin;

  @override
  State<_CozySplashScreen> createState() => _CozySplashScreenState();
}

class _CozySplashScreenState extends State<_CozySplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: InkWell(
            key: const Key('splash-begin'),
            onTap: widget.onBegin,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const illustrationAspectRatio = 900 / 1748;
                final widthBasedSize = constraints.maxWidth * .56;
                final heightBasedSize = constraints.maxHeight * .26;
                final illustrationWidth =
                    (widthBasedSize < heightBasedSize
                            ? widthBasedSize
                            : heightBasedSize)
                        .clamp(156.0, 220.0);
                final compact = constraints.maxHeight < 700;
                final titleSize = (constraints.maxWidth * .117).clamp(
                  36.0,
                  46.0,
                );
                return SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),
                          SizedBox(
                            key: const Key('splash-illustration'),
                            width: illustrationWidth,
                            child: AspectRatio(
                              aspectRatio: illustrationAspectRatio,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: colors.outlineVariant.withValues(
                                      alpha: .22,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.primary.withValues(
                                        alpha: .16,
                                      ),
                                      blurRadius: 36,
                                      offset: const Offset(0, 16),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  AppAssets.focusRoomHero,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 24 : 42),
                          Text(
                            context.l10n.appTitle.replaceFirst(
                              ' Room',
                              '\nRoom',
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontSize: titleSize, height: 1.12),
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          Text(
                            context.l10n.splashTagline,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 18,
                                ),
                          ),
                          const Spacer(flex: 3),
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) => Opacity(
                              opacity: .62 + _pulseController.value * .38,
                              child: Transform.scale(
                                scale: 1 + _pulseController.value * .035,
                                child: child,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  context.l10n.tapToBegin,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: colors.primary,
                                        letterSpacing: 2.1,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: colors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingScreen extends StatefulWidget {
  const _OnboardingScreen({required this.onComplete, super.key});

  final Future<void> Function() onComplete;

  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _completing = false;

  List<_OnboardingPageData> _pages(BuildContext context) => [
    _OnboardingPageData(
      title: context.l10n.onboardingFocusTitle,
      description: context.l10n.onboardingFocusBody,
      visual: _OnboardingVisual.focus,
    ),
    _OnboardingPageData(
      title: context.l10n.onboardingProgressTitle,
      description: context.l10n.onboardingProgressBody,
      visual: _OnboardingVisual.growth,
    ),
    _OnboardingPageData(
      title: context.l10n.onboardingSanctuaryTitle,
      description: context.l10n.onboardingSanctuaryBody,
      visual: _OnboardingVisual.sanctuary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    if (_completing) return;
    setState(() => _completing = true);
    await widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pages = _pages(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: _page < pages.length - 1
                    ? TextButton(
                        key: const Key('onboarding-skip'),
                        onPressed: _completing ? null : _finish,
                        child: Text(context.l10n.skip),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        width: index == _page ? 32 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: index == _page
                              ? colors.primary
                              : colors.outlineVariant.withValues(alpha: .42),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton.icon(
                      key: const Key('onboarding-next'),
                      onPressed: _completing ? null : _next,
                      iconAlignment: IconAlignment.end,
                      icon: _completing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        _page == pages.length - 1
                            ? context.l10n.getStarted
                            : context.l10n.next,
                      ),
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthBasedSize = constraints.maxWidth * .76;
        final heightBasedSize = constraints.maxHeight * .42;
        final visualSize =
            (widthBasedSize < heightBasedSize
                    ? widthBasedSize
                    : heightBasedSize)
                .clamp(120.0, 340.0);
        final compact = constraints.maxHeight < 600;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: visualSize,
                height: visualSize,
                decoration: BoxDecoration(
                  shape: data.visual == _OnboardingVisual.growth
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: data.visual == _OnboardingVisual.growth
                      ? null
                      : BorderRadius.circular(48),
                  color: dark
                      ? colors.surfaceContainerHigh.withValues(alpha: .72)
                      : Colors.white.withValues(alpha: .72),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: .2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: dark ? .13 : .08),
                      blurRadius: 34,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _OnboardingVisualWidget(visual: data.visual),
              ),
              SizedBox(height: compact ? 16 : 34),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                  fontSize: compact ? 25 : 30,
                ),
              ),
              SizedBox(height: compact ? 8 : 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style:
                      (compact
                              ? Theme.of(context).textTheme.bodyMedium
                              : Theme.of(context).textTheme.bodyLarge)
                          ?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: compact ? 1.35 : 1.55,
                          ),
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingVisualWidget extends StatelessWidget {
  const _OnboardingVisualWidget({required this.visual});

  final _OnboardingVisual visual;

  @override
  Widget build(BuildContext context) => switch (visual) {
    _OnboardingVisual.focus => Padding(
      padding: const EdgeInsets.all(22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          AppAssets.focusRoomHero,
          fit: BoxFit.cover,
          alignment: const Alignment(0, .12),
        ),
      ),
    ),
    _OnboardingVisual.growth => Padding(
      padding: const EdgeInsets.all(48),
      child: AtlasSprite(
        assetPath: AppAssets.plantGrowthAtlas,
        columns: 3,
        rows: 3,
        column: 2,
        row: 0,
        fit: BoxFit.contain,
      ),
    ),
    _OnboardingVisual.sanctuary => Image.asset(
      AppAssets.sanctuaryRoom,
      fit: BoxFit.cover,
      alignment: const Alignment(0, -.1),
    ),
  };
}

enum _OnboardingVisual { focus, growth, sanctuary }

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.visual,
  });

  final String title;
  final String description;
  final _OnboardingVisual visual;
}
