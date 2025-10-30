import 'package:expense_tracker_app/features/dashboard/dashboard_screen.dart';
import 'package:expense_tracker_app/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Simulate loading time before navigating
    Future.delayed(const Duration(seconds: 3
    ), () {
     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
       return HomeScreen();
     },));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      body: Stack(
        children: [
          // 🌈 Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 💰 Centered logo + text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated logo or icon
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: theme.colorScheme.primary,
                    size: 60,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(delay: 300.ms, duration: 700.ms),

                const SizedBox(height: 20),

                // App name
                Text(
                  "Expense Tracker",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.4, end: 0),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  "Track. Save. Grow.",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),

          // ⚙️ Subtle progress indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const CircularProgressIndicator(strokeWidth: 2),
                const SizedBox(height: 10),
                Text(
                  "Loading your budgets...",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1000.ms),
          ),
        ],
      ),
    );
  }
}
