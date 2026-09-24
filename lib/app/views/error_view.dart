import 'package:flutter/material.dart';

// Terminal error screen. Shown by the router for unknown routes and as a
// destination when a guard cannot resolve where the user should be.
class ErrorView extends StatelessWidget {
  final String code;
  final String message;

  const ErrorView({
    super.key,
    this.code = 'PAN-0001',
    this.message = 'It\'s not you, it\'s us. You will need to restart the app.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // **The body is inside a SafeArea.** A Scaffold does not inset its
      // body for the status bar or the home indicator unless an AppBar is
      // doing it, so without this the first line sits under the notch on
      // every phone that has one -- and at a large text size the scroll view
      // reaches the top edge on every phone.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //

              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.7),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Text(
                'Error code: $code',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
