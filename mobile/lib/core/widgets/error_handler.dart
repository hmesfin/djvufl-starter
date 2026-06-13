import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/failures.dart';
import '../errors/exceptions.dart';

/// Error widget for displaying unhandled errors
class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const ErrorScreen({super.key, required this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Global error handler that wraps the app with error handling
class GlobalErrorHandler extends StatelessWidget {
  final Widget child;
  final String? appTitle;

  const GlobalErrorHandler({super.key, required this.child, this.appTitle});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle ?? 'DjVuFL Mobile',
      debugShowCheckedModeBanner: false,
      home: _ErrorHandler(child: child),
    );
  }
}

class _ErrorHandler extends StatelessWidget {
  final Widget child;

  const _ErrorHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // For now, just return the child
    // In a production app, you'd want to implement proper error boundary functionality
    return child;
  }
}
