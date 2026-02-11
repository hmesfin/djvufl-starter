import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/auth_models.dart';
import '../providers/auth_provider.dart';

/// OTP Verification Screen
///
/// Allows users to verify their email with a 6-digit OTP code.
/// Provides resend functionality with countdown timer.
class OTPVerificationScreen extends ConsumerStatefulWidget {
  const OTPVerificationScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _errorMessage;
  String? _successMessage;
  bool _resendDisabled = false;
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _otpController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _resendDisabled = true;
      _countdown = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _resendDisabled = false;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final request = OtpVerificationRequest(
      email: widget.email,
      otpCode: _otpController.text.trim(),
    );

    try {
      await ref.read(authStateProvider.notifier).verifyOTP(request);
      if (mounted) {
        setState(() {
          _successMessage = 'Email verified successfully!';
        });
        // Navigate to login screen after verification
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // TODO: Navigate to login screen
          }
        });
      }
    } on AppException catch (e) {
      setState(() {
        _errorMessage = e.failure.when(
          network: (message, _) => message,
          auth: (message) => message,
          validation: (message, _) => message,
          notFound: (message) => message,
          server: (message, _) => message,
          unknown: (message, _) => message,
        );
      });
    }
  }

  Future<void> _handleResend() async {
    if (_resendDisabled) return;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).resendOTP(widget.email);
      if (mounted) {
        setState(() {
          _successMessage = 'New code sent to your email!';
        });
        _startCountdown();
      }
    } on AppException catch (e) {
      setState(() {
        _errorMessage = e.failure.when(
          network: (message, _) => message,
          auth: (message) => message,
          validation: (message, _) => message,
          notFound: (message) => message,
          server: (message, _) => message,
          unknown: (message, _) => message,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Verify Your Email',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // OTP Input
                  TextFormField(
                    controller: _otpController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSubmit(),
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'OTP Code',
                      hintText: '123456',
                      prefixIcon: Icon(Icons.sms_outlined),
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'OTP code is required';
                      }
                      if (value.length != 6) {
                        return 'OTP code must be 6 digits';
                      }
                      if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'OTP code must contain only digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Success Message
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _successMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Verify Button
                  FilledButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify Code'),
                  ),
                  const SizedBox(height: 8),

                  // Resend Button
                  TextButton(
                    onPressed: (_resendDisabled || isLoading)
                        ? null
                        : _handleResend,
                    child: Text(
                      _resendDisabled
                          ? 'Resend code in ${_countdown}s'
                          : 'Resend Code',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
