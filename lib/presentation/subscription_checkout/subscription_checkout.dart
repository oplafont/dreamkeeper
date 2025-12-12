import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/payment_service.dart';
import '../../services/supabase_service.dart';

class SubscriptionCheckoutScreen extends StatefulWidget {
  @override
  _SubscriptionCheckoutScreenState createState() =>
      _SubscriptionCheckoutScreenState();
}

class _SubscriptionCheckoutScreenState
    extends State<SubscriptionCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessingPayment = false;
  bool _agreedToTerms = false;
  String? _message;
  String? _errorMessage;

  // Controllers for billing form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    try {
      await PaymentService.initialize();
      _prefillUserData();
      setState(() {
        _message = 'Ready to subscribe to DreamDecoder Pro!';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize payment service: $e';
      });
    }
  }

  void _prefillUserData() {
    final user = SupabaseService.instance.client.auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _nameController.text = user.userMetadata?['full_name'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Subscribe to DreamDecoder Pro',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subscription Plan Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DreamDecoder Pro',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$8.00/month',
                      style: GoogleFonts.inter(
                        color: Colors.purple,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Full access to all features:',
                      style: GoogleFonts.inter(
                        color: Colors.grey[300],
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    ..._buildFeatureList(),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Billing Information
              Text(
                'Billing Information',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),

              _buildTextField(_nameController, 'Full Name', true),
              _buildTextField(_emailController, 'Email', true),
              _buildTextField(_phoneController, 'Phone', true),
              _buildTextField(_addressLine1Controller, 'Address Line 1', true),
              _buildTextField(_cityController, 'City', true),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_stateController, 'State', true),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child:
                        _buildTextField(_zipCodeController, 'Zip Code', true),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Payment Information
              Text(
                'Payment Information',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),

              // CardField
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                padding: EdgeInsets.all(16),
                child: stripe.CardField(
                  onCardChanged: (card) {
                    setState(() {
                      if (_errorMessage != null &&
                          _errorMessage!.contains('card')) {
                        _errorMessage = null;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Card Information',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    helperText: 'Enter your card details',
                    helperStyle:
                        TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Test card information (only in debug mode)
              if (kDebugMode)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[900]?.withAlpha(77),
                    border: Border.all(color: Colors.orange[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Cards (Development Mode):',
                        style: GoogleFonts.inter(
                          color: Colors.orange[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Success: 4242 4242 4242 4242',
                          style: TextStyle(
                              color: Colors.orange[300], fontSize: 11.sp)),
                      Text('Declined: 4000 0000 0000 9995',
                          style: TextStyle(
                              color: Colors.orange[300], fontSize: 11.sp)),
                    ],
                  ),
                ),

              SizedBox(height: 20),

              // Terms and conditions checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                    activeColor: Colors.purple,
                    checkColor: Colors.white,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreedToTerms = !_agreedToTerms;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              color: Colors.grey[300],
                              fontSize: 14.sp,
                            ),
                            children: [
                              TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: Colors.purple,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ', '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.purple,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ', and '),
                              TextSpan(
                                text: 'Medical Disclaimer',
                                style: TextStyle(
                                  color: Colors.purple,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Messages
              if (_message != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green[900]?.withAlpha(77),
                    border: Border.all(color: Colors.green[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _message!,
                          style: GoogleFonts.inter(color: Colors.green[300]),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[900]?.withAlpha(77),
                    border: Border.all(color: Colors.red[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(color: Colors.red[300]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Subscribe Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isProcessingPayment || !_agreedToTerms)
                      ? null
                      : _handleSubscription,
                  child: _isProcessingPayment
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Processing...',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ],
                        )
                      : Text(
                          'Subscribe to DreamDecoder Pro - \$8.00/month',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    disabledBackgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Legal disclaimers
              _buildLegalDisclaimers(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList() {
    final features = [
      'Unlimited dream entries',
      'AI-powered dream analysis',
      'Advanced pattern recognition',
      'Export capabilities',
      'Therapeutic insights',
      'Premium support'
    ];

    return features
        .map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.purple, size: 16),
                  SizedBox(width: 8),
                  Text(
                    feature,
                    style: GoogleFonts.inter(
                      color: Colors.grey[300],
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool required) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.grey[400]),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.purple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[900],
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildLegalDisclaimers() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withAlpha(128),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legal Disclaimers',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          _buildDisclaimerItem(
            'Medical Disclaimer:',
            'DreamDecoder is not a medical device. AI insights are for entertainment and self-reflection only. Always consult healthcare professionals for medical concerns.',
          ),
          _buildDisclaimerItem(
            'Liability Waiver:',
            'Dream analysis carries risks of misinterpretation. You use this service at your own risk. We are not liable for decisions based on app-generated insights.',
          ),
          _buildDisclaimerItem(
            'Data Usage:',
            'Your dream entries and usage data are encrypted and stored securely. We never share personal data with third parties without consent.',
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerItem(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.orange[300],
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 12.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscription() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      setState(() {
        _errorMessage = 'Please agree to the terms and conditions to continue.';
      });
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _message = 'Creating your subscription...';
      _errorMessage = null;
    });

    try {
      // Create billing details
      final billingDetails = stripe.BillingDetails(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: stripe.Address(
          line1: _addressLine1Controller.text,
          line2: '',
          city: _cityController.text,
          state: _stateController.text,
          postalCode: _zipCodeController.text,
          country: 'US',
        ),
      );

      // Step 1: Create subscription
      setState(() {
        _message = 'Setting up your subscription...';
      });

      final subscriptionResponse =
          await PaymentService.instance.createSubscription(
        planId: 'dreamdecoder_pro', // This would be retrieved from the database
        billingDetails: billingDetails,
      );

      setState(() {
        _message = 'Processing payment...';
      });

      // Step 2: Process payment
      final result = await PaymentService.instance.processPayment(
        clientSecret: subscriptionResponse.clientSecret,
        billingDetails: billingDetails,
      );

      // Step 3: Handle result
      if (result.success) {
        _showSuccessDialog(subscriptionResponse.subscriptionId);
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      setState(() {
        _message = null;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _showSuccessDialog(String subscriptionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                'Welcome to DreamDecoder Pro!',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your subscription has been activated successfully!',
                style: GoogleFonts.inter(color: Colors.grey[300]),
              ),
              SizedBox(height: 16),
              Text(
                'You now have access to:',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              ...[
                'Unlimited dream entries',
                'AI-powered analysis',
                'Advanced insights',
                'Export capabilities'
              ]
                  .map((feature) => Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check, color: Colors.purple, size: 16),
                            SizedBox(width: 8),
                            Text(
                              feature,
                              style: GoogleFonts.inter(
                                  color: Colors.grey[300], fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.mainNavigation);
              },
              child: Text(
                'Start Exploring',
                style: GoogleFonts.inter(color: Colors.purple),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }
}
