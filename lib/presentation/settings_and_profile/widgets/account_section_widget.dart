import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountSectionWidget extends StatefulWidget {
  final Map<String, dynamic> accountInfo;
  final VoidCallback onDeleteAccount;

  const AccountSectionWidget({
    super.key,
    required this.accountInfo,
    required this.onDeleteAccount,
  });

  @override
  State<AccountSectionWidget> createState() => _AccountSectionWidgetState();
}

class _AccountSectionWidgetState extends State<AccountSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'account_circle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text('Account', style: AppTheme.lightTheme.textTheme.titleMedium),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSubscriptionStatus(),
          SizedBox(height: 2.h),
          _buildAccountActions(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatus() {
    final bool isPremium = widget.accountInfo['isPremium'] as bool;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color:
            isPremium
                ? AppTheme.lightTheme.colorScheme.tertiary.withValues(
                  alpha: 0.1,
                )
                : AppTheme.lightTheme.colorScheme.surface.withValues(
                  alpha: 0.5,
                ),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color:
              isPremium
                  ? AppTheme.lightTheme.colorScheme.tertiary.withValues(
                    alpha: 0.3,
                  )
                  : AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: isPremium ? 'star' : 'star_border',
                color:
                    isPremium
                        ? AppTheme.lightTheme.colorScheme.tertiary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? 'Premium Member' : 'Free Account',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isPremium
                                ? AppTheme.lightTheme.colorScheme.tertiary
                                : null,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      isPremium
                          ? 'Expires on ${widget.accountInfo['premiumExpiry']}'
                          : 'Upgrade for unlimited dreams and advanced insights',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              if (!isPremium)
                ElevatedButton(
                  onPressed: _showUpgradeDialog,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    minimumSize: Size(0, 0),
                  ),
                  child: Text(
                    'Upgrade',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if (isPremium) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: Column(
                children: [
                  Text(
                    'Premium Features Active',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: [
                      _buildFeatureChip('Unlimited Dreams'),
                      _buildFeatureChip('Advanced Analytics'),
                      _buildFeatureChip('Cloud Backup'),
                      _buildFeatureChip('Export Options'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Text(
        feature,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.tertiary,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Actions',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          _buildActionTile(
            'Change Password',
            'Update your account password',
            'lock',
            _changePassword,
          ),
          SizedBox(height: 1.h),
          _buildActionTile(
            'Export Account Data',
            'Download all your personal data',
            'download',
            _exportAccountData,
          ),
          SizedBox(height: 1.h),
          _buildActionTile(
            'Delete Account',
            'Permanently delete your account and all data',
            'delete_forever',
            _showDeleteConfirmation,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CustomIconWidget(
        iconName: iconName,
        color:
            isDestructive
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 5.w,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: isDestructive ? AppTheme.lightTheme.colorScheme.error : null,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 5.w,
      ),
      onTap: onTap,
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Upgrade to Premium'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unlock premium features:'),
                SizedBox(height: 2.h),
                _buildPremiumFeature('Unlimited dream entries'),
                _buildPremiumFeature('Advanced pattern analysis'),
                _buildPremiumFeature('Cloud backup & sync'),
                _buildPremiumFeature('Export in multiple formats'),
                _buildPremiumFeature('Priority customer support'),
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '\$9.99/month',
                        style: AppTheme.lightTheme.textTheme.titleLarge
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'or \$99.99/year (save 17%)',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Maybe Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Upgrade feature coming soon!')),
                  );
                },
                child: Text('Upgrade Now'),
              ),
            ],
          ),
    );
  }

  Widget _buildPremiumFeature(String feature) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: Colors.green,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              feature,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password change feature coming soon!')),
    );
  }

  void _exportAccountData() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Account data export initiated')));
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text('Delete Account'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This action cannot be undone. All your dreams, settings, and account data will be permanently deleted.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.error.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.error.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What will be deleted:',
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 1.h),
                      Text('• All dream entries and recordings'),
                      Text('• Personal settings and preferences'),
                      Text('• Account information and statistics'),
                      Text('• Cloud backups and synced data'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDeleteAccount();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                ),
                child: Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
