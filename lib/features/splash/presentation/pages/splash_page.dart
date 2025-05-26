import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.black,
      onEnd: () {
        context.go('/home');
      },
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(seconds: 2),
      childWidget: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100),
            const SizedBox(height: 24),
            Text(
              'FTH Admin',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFFF6B00),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
