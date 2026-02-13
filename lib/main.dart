import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'notification_controller.dart';
import 'router/app_router.dart';
import 'services/firebase_service.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services with error handling
  await LocalStorageService.initialize();

  try {
    await FirebaseService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue without Firebase for now
  }

  // Initialize notifications BEFORE runApp (CRITICAL)
  await NotificationController.initializeLocalNotifications();

  runApp(const ProviderScope(child: IgniSaveApp()));
}

class IgniSaveApp extends ConsumerStatefulWidget {
  const IgniSaveApp({super.key});

  @override
  ConsumerState<IgniSaveApp> createState() => _IgniSaveAppState();
}

class _IgniSaveAppState extends ConsumerState<IgniSaveApp> {
  @override
  void initState() {
    super.initState();
    // Start listening for notification events
    NotificationController.startListeningNotificationEvents();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'IgniSave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('id')],
      builder: (context, child) {
        return child!;
      },
    );
  }
}
