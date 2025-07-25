import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../authentification/login_page.dart';
import 'accueil_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;
  late Animation<Color?> _bgGradient;
  late Animation<double> _particleOpacity;
  late Animation<double> _textGlow;

  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeParticles();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Configuration des animations principales
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOutQuint),
    );

    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
    ]).animate(_mainController);

    _bgGradient = ColorTween(
      begin: const Color(0xFFFFD700),
      end: const Color(0xFFFFFFFF),
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCirc),
      ),
    );

    _particleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.5, 0.8)),
    );

    _textGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _mainController.forward();

    // Redirection après l'animation
    Timer(const Duration(milliseconds: 3500), _navigateWithPremiumTransition);
  }

  void _initializeParticles() {
    for (int i = 0; i < 25; i++) {
      _particles.add(
        Particle(
          x: _random.nextDouble() * 2 - 1,
          y: _random.nextDouble() * 2 - 1,
          size: _random.nextDouble() * 8 + 4,
          speed: _random.nextDouble() * 0.5 + 0.1,
          angle: _random.nextDouble() * pi * 2,
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        ),
      );
    }
  }

  Future<void> _navigateWithPremiumTransition() async {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    final nextPage = user != null ? const AccueilPage() : const LoginPage();

    // Préparation de la transition premium
    final overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final fakeLogo = Image.asset(
      'assets/images/snap_logo.png',
      width: 160,
      height: 160,
    );

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return _TransitionMasterpiece(
          startPosition: position,
          startSize: size,
          logo: fakeLogo,
          destinationPage: nextPage,
          onComplete:
              () => Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => nextPage,
                  transitionDuration: Duration.zero,
                ),
              ),
        );
      },
    );

    overlayState.insert(overlayEntry);
    await Future.delayed(const Duration(milliseconds: 50));

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextPage,
        transitionDuration: const Duration(milliseconds: 1200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _bgGradient.value,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Particules animées
              if (_particleOpacity.value > 0)
                Opacity(
                  opacity: _particleOpacity.value,
                  child: CustomPaint(
                    painter: ParticlePainter(
                      particles: _particles,
                      progress: _mainController.value,
                    ),
                  ),
                ),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: _logoRotation.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Image.asset(
                            'assets/images/snap_logo.png',
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _textGlow,
                      builder: (context, _) {
                        return Text(
                          'Bienvenue',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.8),
                            shadows: [
                              Shadow(
                                color: Colors.yellow.withOpacity(
                                  _textGlow.value * 0.8,
                                ),
                                blurRadius: 20 * _textGlow.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Particle {
  double x, y;
  double size;
  double speed;
  double angle;
  Color color;
  double baseSize;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.color,
  }) : baseSize = size;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxDistance = size.width / 2;

    for (final particle in particles) {
      final distance = progress * maxDistance * 0.8;
      final currentX = center.dx + particle.x * distance;
      final currentY = center.dy + particle.y * distance;
      final currentSize = particle.size * (1 - progress * 0.5);

      final paint =
          Paint()
            ..color = particle.color.withOpacity(1 - progress * 0.7)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(currentX, currentY), currentSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true;
  }
}

class _TransitionMasterpiece extends StatefulWidget {
  final Offset startPosition;
  final Size startSize;
  final Widget logo;
  final Widget destinationPage;
  final VoidCallback onComplete;

  const _TransitionMasterpiece({
    required this.startPosition,
    required this.startSize,
    required this.logo,
    required this.destinationPage,
    required this.onComplete,
  });

  @override
  _TransitionMasterpieceState createState() => _TransitionMasterpieceState();
}

class _TransitionMasterpieceState extends State<_TransitionMasterpiece>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<Offset> _position;
  late Animation<double> _rotation;
  late Animation<double> _waveEffect;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Configuration des animations de transition
    _scale = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOutBack),
      ),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _position = Tween<Offset>(
      begin: widget.startPosition,
      end: Offset(
        widget.startPosition.dx + widget.startSize.width / 2 - 80,
        widget.startPosition.dy + widget.startSize.height / 2 - 80,
      ),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _rotation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _waveEffect = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Page de destination en arrière-plan
        widget.destinationPage,

        // Animation du logo
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              left: _position.value.dx,
              top: _position.value.dy,
              child: Transform.scale(
                scale: _scale.value,
                child: Transform.rotate(
                  angle: _rotation.value,
                  child: Opacity(opacity: _opacity.value, child: widget.logo),
                ),
              ),
            );
          },
        ),

        // Effet de vagues concentriques
        if (_waveEffect.value > 0)
          CustomPaint(
            painter: _WaveEffectPainter(
              progress: _waveEffect.value,
              center: Offset(
                widget.startPosition.dx + widget.startSize.width / 2,
                widget.startPosition.dy + widget.startSize.height / 2,
              ),
            ),
          ),

        // Effet de particules radiales
        if (_controller.value < 0.8)
          CustomPaint(
            painter: _RadialParticlePainter(
              progress: _controller.value,
              center: Offset(
                widget.startPosition.dx + widget.startSize.width / 2,
                widget.startPosition.dy + widget.startSize.height / 2,
              ),
            ),
          ),
      ],
    );
  }
}

class _WaveEffectPainter extends CustomPainter {
  final double progress;
  final Offset center;

  _WaveEffectPainter({required this.progress, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    final waveCount = 3;
    final maxRadius = size.width * 0.8;

    for (int i = 0; i < waveCount; i++) {
      final radius = maxRadius * (progress + i * 0.2);
      final opacity = 0.6 * (1 - (progress + i * 0.2));

      if (opacity > 0) {
        final paint =
            Paint()
              ..color = Colors.white.withOpacity(opacity)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WaveEffectPainter oldDelegate) => true;
}

class _RadialParticlePainter extends CustomPainter {
  final double progress;
  final Offset center;

  _RadialParticlePainter({required this.progress, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    final particleCount = 15;
    final maxRadius = size.width * 0.7;
    final angleStep = 2 * pi / particleCount;

    for (int i = 0; i < particleCount; i++) {
      final angle = angleStep * i;
      final distance = maxRadius * progress;
      final x = center.dx + cos(angle) * distance;
      final y = center.dy + sin(angle) * distance;

      final paint =
          Paint()
            ..color = Colors.primaries[i % Colors.primaries.length].withOpacity(
              1 - progress,
            )
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

      canvas.drawCircle(Offset(x, y), 8 * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialParticlePainter oldDelegate) => true;
}
