import 'package:flutter/material.dart';
import '../game/utils/constants.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.bgDeepPurple,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'BRICK MANIA',
                style: GameConstants.neonTextFont.copyWith(
                  fontSize: 48,
                  color: GameConstants.neonCyan,
                  shadows: [
                    Shadow(color: GameConstants.neonCyan, blurRadius: 20),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'ANTI-GRAVITY',
                style: GameConstants.neonTextFont.copyWith(
                  fontSize: 24,
                  color: GameConstants.neonMagenta,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(color: GameConstants.neonMagenta, blurRadius: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
