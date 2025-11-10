import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatefulWidget {
  final VoidCallback onGetStarted;

  const EmptyStateWidget({Key? key, required this.onGetStarted})
    : super(key: key);

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _floatController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Container(
                        width: 60.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.getAccentPurple()
                                  .withValues(alpha: 0.1),
                              AppTheme.lightTheme.colorScheme.secondary
                                  .withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background stars
                            Positioned(
                              top: 3.h,
                              left: 8.w,
                              child: _buildStar(12),
                            ),
                            Positioned(
                              top: 8.h,
                              right: 6.w,
                              child: _buildStar(8),
                            ),
                            Positioned(
                              bottom: 6.h,
                              left: 12.w,
                              child: _buildStar(10),
                            ),
                            Positioned(
                              bottom: 10.h,
                              right: 10.w,
                              child: _buildStar(6),
                            ),

                            // Main illustration
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 25.w,
                                  height: 25.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .secondary,
                                        AppTheme.getAccentPurple(),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .secondary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'bedtime',
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'auto_stories',
                                        color: AppTheme.getAccentPurple(),
                                        size: 16,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'Dream Journal',
                                        style: AppTheme
                                            .lightTheme
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.getAccentPurple(),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 4.h),
                Text(
                  'Welcome to DreamKeeper',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Start capturing your dreams and unlock the mysteries of your subconscious mind',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'tips_and_updates',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Pro Tips for Better Dream Recall',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.5.h),
                      _buildTip(
                        'Keep your phone nearby for immediate recording',
                      ),
                      _buildTip('Record dreams as soon as you wake up'),
                      _buildTip('Include emotions and vivid details'),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                ElevatedButton(
                  onPressed: widget.onGetStarted,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'mic',
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Record Your First Dream',
                        style: AppTheme.lightTheme.textTheme.titleSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStar(double size) {
    return Container(
      width: size,
      height: size,
      child: CustomIconWidget(
        iconName: 'star',
        color: AppTheme.getAccentPurple().withValues(alpha: 0.3),
        size: size,
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.secondary,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}