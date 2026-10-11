import 'package:flutter/material.dart';

import 'screens/role_selection_screen.dart';

void main() {
  runApp(const FoodLinkApp());
}

class FoodLinkApp extends StatelessWidget {
  const FoodLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAF7),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF248653)),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color green = Color(0xFF248653);
  static const Color darkGreen = Color(0xFF174D34);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 750;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: isWide
                      ? Row(
                          children: [
                            const Expanded(child: WelcomeIllustration()),
                            const SizedBox(width: 55),
                            Expanded(
                              child: WelcomeContent(
                                onGetStarted: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RoleSelectionScreen(),
                                    ),
                                  );
                                },
                                onLogin: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NextScreen(title: 'Login'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const WelcomeIllustration(),
                            const SizedBox(height: 30),
                            WelcomeContent(
                              onGetStarted: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RoleSelectionScreen(),
                                  ),
                                );
                              },
                              onLogin: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const NextScreen(title: 'Login'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: const Color(0xFFE2F3E5),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.volunteer_activism_rounded,
            size: 52,
            color: WelcomeScreen.green,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'FoodLink',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: WelcomeScreen.darkGreen,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Rescue Food. Share Hope.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: WelcomeScreen.green,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE4F4E7), Color(0xFFF0F7E9)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Column(
            children: [
              Icon(Icons.eco_rounded, size: 100, color: WelcomeScreen.green),
              SizedBox(height: 14),
              Text(
                'Good Food Deserves\nAnother Chance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  height: 1.3,
                  fontWeight: FontWeight.bold,
                  color: WelcomeScreen.darkGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Make a difference,\none donation at a time.',
          style: TextStyle(
            fontSize: 29,
            height: 1.25,
            fontWeight: FontWeight.bold,
            color: WelcomeScreen.darkGreen,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'FoodLink connects food donors with NGOs and '
          'charitable organizations to help surplus edible '
          'food reach people in need.',
          style: TextStyle(fontSize: 16, height: 1.7, color: Color(0xFF59665D)),
        ),
        const SizedBox(height: 28),

        // Primary action
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: onGetStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: WelcomeScreen.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary action
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: onLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: WelcomeScreen.green,
              side: const BorderSide(color: WelcomeScreen.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline_rounded,
              size: 17,
              color: WelcomeScreen.green,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Together, we can reduce food waste.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF68746B)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Temporary destination until we build the real screens.
class NextScreen extends StatelessWidget {
  const NextScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FoodLink')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.construction_rounded,
                size: 65,
                color: WelcomeScreen.green,
              ),
              const SizedBox(height: 18),
              Text(
                '$title Screen',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: WelcomeScreen.darkGreen,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We will build this screen in the next step.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
