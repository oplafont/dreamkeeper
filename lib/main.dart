import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import './services/payment_service.dart';
import './services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await SupabaseService.initialize();

    // Initialize Stripe (only if keys are available)
    try {
      await PaymentService.initialize();
    } catch (e) {
      if (kDebugMode) {
        print('Stripe initialization failed: $e');
      }
      // Continue app launch even if Stripe fails to initialize
      // This allows the app to work without payment functionality
    }

    bool _hasShownError = false;

    // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (!_hasShownError) {
        _hasShownError = true;

        // Reset flag after 3 seconds to allow error widget on new screens
        Future.delayed(Duration(seconds: 5), () {
          _hasShownError = false;
        });

        return CustomErrorWidget(errorDetails: details);
      }
      return SizedBox.shrink();
    };

    // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
    Future.wait([
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    ]).then((value) {
      runApp(MyApp());
    });
  } catch (e) {
    if (kDebugMode) {
      print('App initialization failed: $e');
    }
    // Handle initialization failure
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization failed: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'dreamdecoder',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          // 🚨 END CRITICAL SECTION
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,
          home: const AuthWrapper(),
        );
      },
    );
  }
}
