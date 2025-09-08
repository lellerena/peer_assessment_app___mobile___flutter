import 'package:flutter/material.dart';

class ErrorContent extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const ErrorContent({
    super.key,
    required this.errorMessage,
    required this.onRetry,
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage ?? 'Unknown error occurred',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6A1B9A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
