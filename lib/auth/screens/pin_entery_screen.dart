// lib/auth/screens/pin_entry_screen.dart
import 'package:animal_kart_demo2/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:animal_kart_demo2/services/pin_auth_services.dart';

class PinEntryScreen extends StatefulWidget {
  final bool isSetup;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const PinEntryScreen({
    Key? key,
    this.isSetup = false,
    this.onSuccess,
    this.onCancel,
  }) : super(key: key);

  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String _enteredPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _showError = false;

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _showError = false;
      });

      if (_enteredPin.length == 4) {
        if (!widget.isSetup || _isConfirming) {
          _validatePin();
        } else {
          _confirmPin = _enteredPin;
          _enteredPin = '';
          setState(() => _isConfirming = true);
        }
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _showError = false;
      });
    }
  }

  Future<void> _validatePin() async {
    if (widget.isSetup) {
      if (_enteredPin == _confirmPin) {
        await PinAuthService.setPin(_enteredPin);
        if (widget.onSuccess != null) widget.onSuccess!();
      } else {
        setState(() {
          _showError = true;
          _enteredPin = '';
          _isConfirming = false;
          _confirmPin = '';
        });
      }
    } else {
      final isValid = await PinAuthService.validatePin(_enteredPin);
      if (isValid) {
        BiometricService.unlock();
        if (widget.onSuccess != null) widget.onSuccess!();
      } else {
        setState(() {
          _showError = true;
          _enteredPin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSetup ? 'Setup PIN' : 'Enter PIN'),
        leading: widget.onCancel != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onCancel,
              )
            : null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isConfirming
                  ? 'Confirm your PIN'
                  : widget.isSetup
                  ? 'Create a 4-digit PIN'
                  : 'Enter your PIN',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
                );
              }),
            ),
            if (_showError)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  widget.isSetup
                      ? 'PINs do not match. Try again.'
                      : 'Incorrect PIN. Try again.',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 30),
            _buildNumpad(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          for (int i = 0; i < 3; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (j) => _buildNumberButton('${i * 3 + j + 1}'),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 60, height: 60), // Empty space
              _buildNumberButton('0'),
              _buildDeleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNumberPressed(number),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: const Icon(Icons.backspace, size: 28),
      onPressed: _onDeletePressed,
    );
  }
}
