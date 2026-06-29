import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../presentation/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.comingSoon),
        centerTitle: true,
      ),
      body: StitchEmptyState(
        icon: Icons.lock_clock_rounded,
        title: AppStrings.comingSoon,
        message:
            'Account sign-in is on the roadmap. For now, manage your spending locally with ${AppStrings.appName}.',
      ),
    );
  }
}
