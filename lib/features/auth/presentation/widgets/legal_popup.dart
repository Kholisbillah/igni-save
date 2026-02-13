import 'dart:ui';

import 'package:flutter/material.dart';

class LegalPopup extends StatelessWidget {
  final String title;
  final String content;

  const LegalPopup({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    // Design reference size (similar scaling logic as AuthScreen for consistency)
    const designWidth = 402.0;
    double scaleW(double value) =>
        value * (MediaQuery.of(context).size.width / designWidth);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: scaleW(20),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF111827)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: scaleW(14),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Close Button (Bottom)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF4080F5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: scaleW(14),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF6F1F1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showLegalPopup(BuildContext context, String title) {
  String content = '';
  if (title == 'Terms') {
    content =
        '''Welcome to IgniSave! By using our app, you agree to these Terms of Service.

1. Account Security
You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.

2. User Conduct
You agree to use IgniSave only for lawful purposes and in a way that does not infringe the rights of, restrict or inhibit anyone else's use and enjoyment of the app.

3. Gamification Features
Our gamified saving features are designed for motivation. We do not guarantee specific financial results. Your savings are your responsibility.

4. Updates to Terms
We may update these terms from time to time. Continued use of the app implies acceptance of any changes.

5. Contact Us
If you have any questions about these Terms, please contact our support team.''';
  } else {
    content =
        '''Your privacy is important to us at IgniSave. This Privacy Policy explains how we collect, use, and protect your information.

1. Information We Collect
We collect information you provide directly, such as your name, email address, and financial goals when you create an account.

2. How We Use Your Information
We use your information to provide, maintain, and improve our services, including personalizing your gamified experience and tracking your savings progress.

3. Data Security
We implement security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.

4. Third-Party Services
We may use third-party services for authentication (like Google Sign-In) which have their own privacy policies.

5. Your Rights
You have the right to access, correct, or delete your personal information at any time through the app settings.''';
  }

  showDialog(
    context: context,
    builder: (context) => LegalPopup(title: title, content: content),
  );
}
