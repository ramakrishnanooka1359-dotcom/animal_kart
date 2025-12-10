import 'package:flutter/material.dart';
import 'package:animal_kart_demo2/services/biometric_service.dart';

class FingerprintDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;

  const FingerprintDialog({super.key, required this.onSuccess, this.onCancel});

  @override
  State<FingerprintDialog> createState() => _FingerprintDialogState();
}

class _FingerprintDialogState extends State<FingerprintDialog> {
  bool _isAuthenticating = false;
  String _statusMessage = 'Waiting for fingerprint...';
  bool _hasError = false;
  bool _isMounted = false;
  bool _authCompleted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    // Delay authentication slightly to ensure dialog is fully shown
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isMounted && !_authCompleted) {
        _startAuthentication();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _startAuthentication() async {
    if (_isAuthenticating || _authCompleted) return;

    if (_isMounted) {
      setState(() {
        _isAuthenticating = true;
        _statusMessage = 'Waiting for fingerprint...';
        _hasError = false;
      });
    }

    try {
      final hasBiometrics = await BiometricService.authenticate();

      if (!hasBiometrics) {
        if (_isMounted) {
          setState(() {
            _statusMessage = 'Biometric not available';
            _hasError = true;
          });
        }
        return;
      }

      final success = await BiometricService.authenticate();

      if (success && _isMounted) {
        _authCompleted = true;
        widget.onSuccess();
      } else if (_isMounted) {
        setState(() {
          _statusMessage = 'Authentication failed. Try again.';
          _hasError = true;
        });
      }
    } catch (e) {
      if (_isMounted) {
        setState(() {
          _statusMessage = 'Error: $e';
          _hasError = true;
        });
      }
    } finally {
      if (_isMounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  void _handleCancel() {
    if (_isMounted) {
      Navigator.of(context).pop();
      widget.onCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button from closing dialog
        return false;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fingerprint,
                size: 64,
                color: _hasError ? Colors.red : Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                'App Lock',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _hasError ? Colors.red : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _hasError ? Colors.red : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              if (!_isAuthenticating && _hasError)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _handleCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _startAuthentication,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              if (_isAuthenticating && !_hasError)
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
