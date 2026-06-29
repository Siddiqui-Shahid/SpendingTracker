import 'package:flutter/material.dart';
import '../presentation/widgets/widgets.dart';

const q1 =
    'Be vulnerable, be courageous, and find comfort in the uncomfortable.';
const q2 =
    'Prepare like you have never won and perform like you have never lost.';
const q3 = 'Trust the process.';
const q4 = 'A vision is a dream with a plan.';
const q5 = 'You only fail when you stop trying.';
const quotes = [q1, q2, q3, q4, q5];

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quote = quotes[DateTime.now().day % quotes.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivation'),
        centerTitle: true,
      ),
      body: StitchEmptyState(
        icon: Icons.format_quote_rounded,
        title: 'Daily Quote',
        message: quote,
      ),
    );
  }
}
