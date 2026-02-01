import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import './core/app_export.dart';
import './providers/auth_provider.dart';
import './providers/dream_provider.dart';
import './providers/settings_provider.dart';
import './providers/sleep_provider.dart';
import './services/logger_service.dart';
import './services/payment_service.dart';
import './services/supabase_service.dart';
import './widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await SupabaseService.initialize();
    log.info('Supabase initialized');

    // Initialize Stripe (only if keys are available)
    try {
      await PaymentService.initialize();
      log.info('Stripe initialized');
    } catch (e) {
      log.warning('Stripe initialization failed', e);
      // Continue app launch even if Stripe fails to initialize
    }

    bool hasShownError = false;

    // Custom error handling
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (!hasShownError) {
        hasShownError = true;
        Future.delayed(const Duration(seconds: 5), () {
          hasShownError = false;
        });
        return CustomErrorWidget(errorDetails: details);
      }
      return const SizedBox.shrink();
    };

    // Device orientation lock
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    runApp(const DreamKeeperApp());
  } catch (e, stack) {
    log.fatal('App initialization failed', e, stack);
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
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

class DreamKeeperApp extends StatelessWidget {
  const DreamKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
        ChangeNotifierProxyProvider<AuthProvider, DreamProvider>(
          create: (_) => DreamProvider(),
          update: (_, auth, dream) {
            if (auth.isAuthenticated && dream != null && !dream.hasDreams) {
              dream.initialize();
            }
            return dream ?? DreamProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SleepProvider>(
          create: (_) => SleepProvider(),
          update: (_, auth, sleep) {
            if (auth.isAuthenticated && sleep != null) {
              sleep.initialize();
            }
            return sleep ?? SleepProvider();
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return Sizer(
            builder: (context, orientation, screenType) {
              return MaterialApp(
                title: 'DreamKeeper',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: _getThemeMode(settings.themeMode),
                builder: (context, child) {
                  // Allow text scaling for accessibility
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(
                        MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
                      ),
                    ),
                    child: child!,
                  );
                },
                debugShowCheckedModeBanner: false,
                routes: AppRoutes.routes,
                initialRoute: AppRoutes.initial,
              );
            },
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }
}
