import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import './supabase_service.dart';

class PaymentService {
  static PaymentService? _instance;
  static PaymentService get instance => _instance ??= PaymentService._();
  PaymentService._();

  final Dio _dio = Dio();
  String get _baseUrl => '${SupabaseService.supabaseUrl}/functions/v1';

  /// Initialize Stripe with publishable key
  static Future<void> initialize() async {
    try {
      const String publishableKey = String.fromEnvironment(
        'STRIPE_PUBLISHABLE_KEY',
        defaultValue: '',
      );

      if (publishableKey.isEmpty) {
        if (kDebugMode) {
          print(
              'STRIPE_PUBLISHABLE_KEY not configured. Payment features disabled.');
        }
        return;
      }

      // Initialize Stripe for both platforms
      Stripe.publishableKey = publishableKey;

      // Initialize web-specific settings if on web
      if (kIsWeb) {
        await Stripe.instance.applySettings();
      }

      if (kDebugMode) {
        print(
            'Stripe initialized successfully for ${kIsWeb ? 'web' : 'mobile'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Stripe initialization error: $e');
      }
      // Don't rethrow - allow app to continue without payment functionality
    }
  }

  /// Create subscription for DreamKeeper Pro
  Future<PaymentIntentResponse> createSubscription({
    required String planId,
    required BillingDetails billingDetails,
  }) async {
    try {
      // Check authentication
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please login and try again.');
      }

      // Get the current session for access token
      final session = SupabaseService.instance.client.auth.currentSession;
      if (session == null) {
        throw Exception('No active session found. Please login again.');
      }

      final response = await _dio.post(
        '$_baseUrl/create-subscription',
        data: {
          'plan_id': planId,
          'customer_details': {
            'name': billingDetails.name,
            'email': billingDetails.email,
            'phone': billingDetails.phone,
            'address': {
              'line1': billingDetails.address?.line1,
              'line2': billingDetails.address?.line2,
              'city': billingDetails.address?.city,
              'state': billingDetails.address?.state,
              'postal_code': billingDetails.address?.postalCode,
              'country': billingDetails.address?.country,
            }
          }
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PaymentIntentResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create subscription: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.response?.data != null) {
        if (e.response?.data['error'] != null) {
          errorMessage = 'Payment error: ${e.response?.data['error']}';
        } else {
          errorMessage =
              'Server error: ${e.response?.statusMessage ?? 'Unknown error'}';
        }
      } else if (e.message?.contains('SocketException') == true) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Unexpected error: $e');
    }
  }

  /// Process payment using unified approach for both mobile and web
  Future<PaymentResult> processPayment({
    required String clientSecret,
    required BillingDetails billingDetails,
  }) async {
    try {
      // Validate client secret
      if (clientSecret.isEmpty) {
        throw Exception('Invalid payment configuration');
      }

      // Check if Stripe is properly initialized
      if (Stripe.publishableKey.isEmpty) {
        throw Exception('Payment service not properly initialized');
      }

      // Confirm payment directly with CardField data
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );

      // Check payment status
      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        return PaymentResult(
          success: true,
          message:
              'Payment completed successfully! Your DreamKeeper Pro subscription is now active.',
          paymentIntentId: paymentIntent.id,
        );
      } else {
        return PaymentResult(
          success: false,
          message: 'Payment was not completed. Status: ${paymentIntent.status}',
        );
      }
    } on StripeException catch (e) {
      return PaymentResult(
        success: false,
        message: _getStripeErrorMessage(e),
        errorCode: e.error.code.name,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  /// Get user's active subscription
  Future<UserSubscription?> getActiveSubscription() async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) return null;

      final response = await SupabaseService.instance.client
          .from('user_subscriptions')
          .select('''
            id,
            status,
            current_period_start,
            current_period_end,
            cancel_at_period_end,
            subscription_plans!inner(
              id,
              name,
              description,
              price_amount,
              price_currency,
              features
            )
          ''')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) return null;

      return UserSubscription.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching active subscription: $e');
      }
      return null;
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    final subscription = await getActiveSubscription();
    return subscription != null;
  }

  /// Cancel subscription at period end
  Future<bool> cancelSubscription() async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) return false;

      final session = SupabaseService.instance.client.auth.currentSession;
      if (session == null) return false;

      final response = await _dio.post(
        '$_baseUrl/cancel-subscription',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling subscription: $e');
      }
      return false;
    }
  }

  /// Get user-friendly error message from Stripe error
  String _getStripeErrorMessage(StripeException e) {
    switch (e.error.code) {
      case FailureCode.Canceled:
        return 'Payment was cancelled';
      case FailureCode.Failed:
        return 'Payment failed. Please try again.';
      case FailureCode.Timeout:
        return 'Payment timed out. Please try again.';
      default:
        return e.error.localizedMessage ?? 'Payment failed. Please try again.';
    }
  }
}

/// Payment Intent Response model
class PaymentIntentResponse {
  final String clientSecret;
  final String paymentIntentId;
  final String subscriptionId;

  PaymentIntentResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.subscriptionId,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      clientSecret: json['client_secret'],
      paymentIntentId: json['payment_intent_id'],
      subscriptionId: json['subscription_id'],
    );
  }
}

/// Payment Result model
class PaymentResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? paymentIntentId;

  PaymentResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.paymentIntentId,
  });
}

/// User Subscription model
class UserSubscription {
  final String id;
  final String status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final SubscriptionPlan plan;

  UserSubscription({
    required this.id,
    required this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    required this.plan,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      status: json['status'],
      currentPeriodStart: json['current_period_start'] != null
          ? DateTime.parse(json['current_period_start'])
          : null,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'])
          : null,
      cancelAtPeriodEnd: json['cancel_at_period_end'] ?? false,
      plan: SubscriptionPlan.fromJson(json['subscription_plans']),
    );
  }
}

/// Subscription Plan model
class SubscriptionPlan {
  final String id;
  final String name;
  final String? description;
  final double priceAmount;
  final String priceCurrency;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    required this.priceAmount,
    required this.priceCurrency,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      priceAmount: (json['price_amount'] as num).toDouble(),
      priceCurrency: json['price_currency'] ?? 'usd',
      features: List<String>.from(json['features'] ?? []),
    );
  }
}
