import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';


class PrivacyControlsWidget extends StatefulWidget {
  const PrivacyControlsWidget({super.key});

  @override
  State<PrivacyControlsWidget> createState() => _PrivacyControlsWidgetState();
}

class _PrivacyControlsWidgetState extends State<PrivacyControlsWidget> {
  bool _isDataEncrypted = true;
  bool _isCloudSyncEnabled = false;
  bool _isProfessionalSharingEnabled = false;
  bool _isAnonymousAnalyticsEnabled = true;
  String _dataRetentionPeriod = '1 year';
  String _professionalEmail = '';

  final List<String> _retentionOptions = [
    '6 months',
    '1 year',
    '2 years',
    'Indefinitely',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(26),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy & Security',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Control how your therapeutic content is stored and shared',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildPrivacySection(
              'Data Protection',
              [
                _buildSwitchTile(
                  'End-to-End Encryption',
                  'Your therapeutic content is encrypted on your device',
                  Icons.lock,
                  _isDataEncrypted,
                  const Color(0xFF10B981),
                  (value) => setState(() => _isDataEncrypted = value),
                  enabled: false, // Always enabled for security
                ),
                _buildSwitchTile(
                  'Cloud Sync',
                  'Sync encrypted data across your devices',
                  Icons.cloud_sync,
                  _isCloudSyncEnabled,
                  const Color(0xFF3B82F6),
                  (value) => setState(() => _isCloudSyncEnabled = value),
                ),
                _buildSwitchTile(
                  'Anonymous Analytics',
                  'Help improve the app with anonymous usage data',
                  Icons.analytics,
                  _isAnonymousAnalyticsEnabled,
                  const Color(0xFF8B5CF6),
                  (value) =>
                      setState(() => _isAnonymousAnalyticsEnabled = value),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildPrivacySection(
              'Professional Sharing',
              [
                _buildSwitchTile(
                  'Professional Consultation',
                  'Allow sharing insights with healthcare professionals',
                  Icons.medical_services,
                  _isProfessionalSharingEnabled,
                  const Color(0xFFFBBF24),
                  (value) =>
                      setState(() => _isProfessionalSharingEnabled = value),
                ),
                if (_isProfessionalSharingEnabled) ...[
                  SizedBox(height: 2.h),
                  _buildProfessionalEmailField(),
                  SizedBox(height: 2.h),
                  _buildSharingOptionsCard(),
                ],
              ],
            ),
            SizedBox(height: 3.h),
            _buildPrivacySection(
              'Data Management',
              [
                _buildDataRetentionCard(),
                SizedBox(height: 2.h),
                _buildDataActionButtons(),
              ],
            ),
            SizedBox(height: 3.h),
            _buildPrivacyInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Color color,
    Function(bool) onChanged, {
    bool enabled = true,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? color.withAlpha(77) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: enabled ? Colors.white : Colors.white60,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: enabled ? Colors.white70 : Colors.white38,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: color,
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalEmailField() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Email',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12.sp,
            ),
            decoration: InputDecoration(
              hintText: 'doctor@example.com',
              hintStyle: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 12.sp,
              ),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.5.h,
              ),
            ),
            onChanged: (value) => setState(() => _professionalEmail = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSharingOptionsCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFBBF24).withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.share,
                color: const Color(0xFFFBBF24),
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text(
                'Sharing Options',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...[
            'Weekly progress summaries',
            'Mood pattern analysis',
            'Therapeutic insights & recommendations',
            'Dream correlation data (anonymized)',
          ]
              .map((option) => Padding(
                    padding: EdgeInsets.only(bottom: 0.5.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: const Color(0xFF10B981),
                          size: 14,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            option,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDataRetentionCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Retention Period',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'How long should we keep your therapeutic data?',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 10.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _retentionOptions
                .map((option) => ChoiceChip(
                      label: Text(
                        option,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: _dataRetentionPeriod == option,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _dataRetentionPeriod = option);
                        }
                      },
                      selectedColor: const Color(0xFF8B5CF6).withAlpha(51),
                      backgroundColor: const Color(0xFF333333),
                      labelStyle: GoogleFonts.inter(
                        color: _dataRetentionPeriod == option
                            ? const Color(0xFF8B5CF6)
                            : Colors.white70,
                      ),
                      side: BorderSide(
                        color: _dataRetentionPeriod == option
                            ? const Color(0xFF8B5CF6)
                            : Colors.transparent,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _exportData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6).withAlpha(26),
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.download, size: 16),
            label: Text(
              'Export Data',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _deleteAllData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withAlpha(26),
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.delete_forever, size: 16),
            label: Text(
              'Delete All',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyInfoCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF10B981),
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text(
                'Privacy Commitment',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Your therapeutic content is private and secure. We never sell your data or use it for advertising. All data is encrypted and only you control who has access.',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 10.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              TextButton.icon(
                onPressed: _showPrivacyPolicy,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.policy, size: 14),
                label: Text(
                  'Privacy Policy',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              TextButton.icon(
                onPressed: _contactSupport,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.support_agent, size: 14),
                label: Text(
                  'Support',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Export Your Data',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will create an encrypted backup of all your therapeutic data. The export may take a few moments.',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate export process
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Data export started. You\'ll receive a notification when complete.',
                    style: GoogleFonts.inter(),
                  ),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: Text(
              'Export',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete All Data',
          style: GoogleFonts.inter(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will permanently delete all your therapeutic data, including insights, reflections, and progress. This action cannot be undone.',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Data deletion cancelled for demo purposes.',
                    style: GoogleFonts.inter(),
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete All',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'This is a comprehensive privacy policy that would detail how therapeutic data is collected, stored, processed, and protected. It would include information about encryption, data retention, user rights, and compliance with healthcare privacy regulations.',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Contact Support',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'For privacy and security questions, contact us at privacy@dreamdecoder.com',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: const Color(0xFF8B5CF6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
