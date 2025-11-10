import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileSectionWidget extends StatelessWidget {
  final Map<String, dynamic> userProfile;
  final VoidCallback onEditProfile;

  const ProfileSectionWidget({
    super.key,
    required this.userProfile,
    required this.onEditProfile,
  });

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
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: userProfile['avatar'] as String,
                        width: 20.w,
                        height: 20.w,
                        fit: BoxFit.cover,
                        semanticLabel:
                            userProfile['avatarSemanticLabel'] as String,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onEditProfile,
                      child: Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: CustomIconWidget(
                          iconName: 'edit',
                          color: Colors.white,
                          size: 3.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile['name'] as String,
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Member since ${userProfile['memberSince']}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Dreams',
                  userProfile['totalDreams'].toString(),
                  CustomIconWidget(
                    iconName: 'nights_stay',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Current Streak',
                  '${userProfile['currentStreak']} days',
                  CustomIconWidget(
                    iconName: 'local_fire_department',
                    color: Colors.orange,
                    size: 5.w,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Widget icon) {
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
        children: [
          icon,
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
