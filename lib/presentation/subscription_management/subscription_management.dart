import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/payment_service.dart';
import '../subscription_checkout/subscription_checkout.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  @override
  _SubscriptionManagementScreenState createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  UserSubscription? _activeSubscription;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final subscription =
          await PaymentService.instance.getActiveSubscription();

      setState(() {
        _activeSubscription = subscription;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load subscription data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Subscription',
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.purple),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    _buildErrorCard(),
                    SizedBox(height: 16),
                  ],
                  if (_activeSubscription != null) ...[
                    _buildActiveSubscriptionCard(),
                    SizedBox(height: 24),
                    _buildSubscriptionDetails(),
                    SizedBox(height: 24),
                    _buildManageSubscriptionActions(),
                  ] else ...[
                    _buildNoSubscriptionCard(),
                    SizedBox(height: 24),
                    _buildSubscribeToPro(),
                  ],
                  SizedBox(height: 24),
                  _buildFreeFeatures(),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[900]?.withAlpha(77),
        border: Border.all(color: Colors.red[700]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(color: Colors.red[300]),
            ),
          ),
          TextButton(
            onPressed: _loadSubscriptionData,
            child: Text(
              'Retry',
              style: GoogleFonts.inter(color: Colors.red[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[900]!, Colors.purple[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 24),
              SizedBox(width: 8),
              Text(
                'DreamKeeper Pro Active',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '\$${_activeSubscription!.plan.priceAmount.toStringAsFixed(2)}/${_activeSubscription!.plan.priceCurrency}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          if (_activeSubscription!.cancelAtPeriodEnd) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Cancels at period end',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Auto-renews monthly',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails() {
    if (_activeSubscription == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Details',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildDetailRow('Status', _activeSubscription!.status.toUpperCase()),
          if (_activeSubscription!.currentPeriodStart != null)
            _buildDetailRow(
              'Current Period',
              '${_formatDate(_activeSubscription!.currentPeriodStart!)} - ${_formatDate(_activeSubscription!.currentPeriodEnd!)}',
            ),
          if (_activeSubscription!.currentPeriodEnd != null)
            _buildDetailRow(
              'Next Billing Date',
              _formatDate(_activeSubscription!.currentPeriodEnd!),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageSubscriptionActions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Subscription',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          if (!_activeSubscription!.cancelAtPeriodEnd) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showCancelDialog,
                child: Text(
                  'Cancel Subscription',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[900]?.withAlpha(77),
                border: Border.all(color: Colors.orange[700]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Your subscription will be canceled at the end of the current billing period.',
                    style: GoogleFonts.inter(
                        color: Colors.orange[300], fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You will continue to have access until ${_formatDate(_activeSubscription!.currentPeriodEnd!)}',
                    style: GoogleFonts.inter(
                      color: Colors.orange[400],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to billing portal or contact support
                _showBillingPortalInfo();
              },
              child: Text(
                'Update Payment Method',
                style: GoogleFonts.inter(
                  color: Colors.purple,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.purple),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'Free Plan Active',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'You are currently using the free version of DreamKeeper.',
            style: GoogleFonts.inter(
              color: Colors.grey[300],
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Upgrade to Pro for unlimited access and advanced features.',
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeToPro() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[900]!, Colors.purple[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upgrade to DreamKeeper Pro',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '\$8.00/month',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Unlock premium features:',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          ..._buildProFeatures(),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubscriptionCheckoutScreen()),
                );
              },
              child: Text(
                'Subscribe Now',
                style: GoogleFonts.inter(
                  color: Colors.purple[900],
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeFeatures() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Included in Free Plan',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          ..._buildFreeFeatureList(),
        ],
      ),
    );
  }

  List<Widget> _buildProFeatures() {
    final features = [
      'Unlimited dream entries',
      'AI-powered analysis',
      'Advanced pattern recognition',
      'Export capabilities',
      'Therapeutic insights',
      'Premium support',
    ];

    return features
        .map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 16),
                  SizedBox(width: 8),
                  Text(
                    feature,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  List<Widget> _buildFreeFeatureList() {
    final features = [
      'Basic dream recording',
      'Limited entries (5 per month)',
      'Basic search functionality',
      'Simple mood tracking',
    ];

    return features
        .map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.grey[500], size: 16),
                  SizedBox(width: 8),
                  Text(
                    feature,
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Cancel Subscription',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to cancel your subscription? You will lose access to Pro features at the end of your current billing period.',
            style: GoogleFonts.inter(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Keep Subscription',
                style: GoogleFonts.inter(color: Colors.purple),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _cancelSubscription();
              },
              child: Text(
                'Cancel Subscription',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBillingPortalInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Update Payment Method',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          content: Text(
            'To update your payment method, please contact our support team at support@dreamkeeper.app or through the help section.',
            style: GoogleFonts.inter(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: GoogleFonts.inter(color: Colors.purple),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelSubscription() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final success = await PaymentService.instance.cancelSubscription();

      if (success) {
        await _loadSubscriptionData(); // Reload data to show updated status
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Subscription canceled. You will retain access until the end of your billing period.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
          ),
        );
      } else {
        throw Exception('Failed to cancel subscription');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to cancel subscription: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
