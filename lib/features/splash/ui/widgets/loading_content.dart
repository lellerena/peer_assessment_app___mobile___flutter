import 'package:flutter/material.dart';

class LoadingContent extends StatelessWidget {
  final bool isLoading;
  final double progress;

  const LoadingContent({
    super.key,
    required this.isLoading,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0), Color(0xFFE91E63)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.assessment,
                size: 80,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 40),

            // App Title
            const Text(
              'Peer Assessment App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Subtitle
            const Text(
              'Evaluate • Learn • Grow',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            // Loading indicator
            if (isLoading) ...[
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
