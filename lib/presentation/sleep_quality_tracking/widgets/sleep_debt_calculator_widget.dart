import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SleepDebtCalculatorWidget extends StatelessWidget {
  final Duration? currentSleepDuration;

  const SleepDebtCalculatorWidget({super.key, this.currentSleepDuration});

  @override
  Widget build(BuildContext context) {
    final sleepDebt = _calculateWeeklySleepDebt();
    final todayDebt = _calculateTodayDebt();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryDarkPurple,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.borderPurple.withAlpha(128),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hourglass_empty,
                color: AppTheme.accentPurple,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Sleep Debt Calculator',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.w),

          // Today's Sleep Debt
          _buildDebtCard(
            title: 'Today\'s Sleep Balance',
            debt: todayDebt,
            isToday: true,
          ),

          SizedBox(height: 3.w),

          // Weekly Sleep Debt
          _buildDebtCard(
            title: 'Weekly Sleep Debt',
            debt: sleepDebt,
            isToday: false,
          ),

          SizedBox(height: 4.w),

          // Recovery Recommendations
          _buildRecoveryRecommendations(sleepDebt, todayDebt),

          SizedBox(height: 4.w),

          // Sleep Debt Explanation
          _buildSleepDebtInfo(),
        ],
      ),
    );
  }

  Widget _buildDebtCard({
    required String title,
    required Duration debt,
    required bool isToday,
  }) {
    final isPositive = debt.inMinutes >= 0;
    final debtHours = debt.inHours.abs();
    final debtMinutes = debt.inMinutes.abs() % 60;

    Color debtColor;
    IconData debtIcon;
    String debtStatus;

    if (isPositive) {
      // Sleep surplus
      debtColor = Colors.green;
      debtIcon = Icons.trending_up;
      debtStatus = 'Surplus';
    } else {
      // Sleep deficit
      if (debt.inHours.abs() >= 2) {
        debtColor = Colors.red;
        debtIcon = Icons.warning;
        debtStatus = 'High Debt';
      } else if (debt.inHours.abs() >= 1) {
        debtColor = Colors.orange;
        debtIcon = Icons.trending_down;
        debtStatus = 'Moderate Debt';
      } else {
        debtColor = Colors.yellow;
        debtIcon = Icons.trending_down;
        debtStatus = 'Minor Debt';
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkPurple,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: debtColor.withAlpha(128), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: debtColor.withAlpha(51),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Icon(debtIcon, color: debtColor, size: 6.w),
          ),

          SizedBox(width: 3.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 1.w),

                Row(
                  children: [
                    Text(
                      '${isPositive ? '+' : '-'}${debtHours}h ${debtMinutes}m',
                      style: TextStyle(
                        color: debtColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.w,
                      ),
                      decoration: BoxDecoration(
                        color: debtColor.withAlpha(51),
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                      child: Text(
                        debtStatus,
                        style: TextStyle(
                          color: debtColor,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 1.w),

                Text(
                  _getDebtDescription(debt, isToday),
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryRecommendations(
    Duration weeklyDebt,
    Duration todayDebt,
  ) {
    final recommendations = _generateRecoveryPlan(weeklyDebt, todayDebt);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkPurple,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: Colors.blue.withAlpha(128), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.blue, size: 4.w),
              SizedBox(width: 2.w),
              Text(
                'Recovery Plan',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.w),

          ...recommendations.map(
            (rec) => Padding(
              padding: EdgeInsets.only(bottom: 1.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(rec.icon, color: rec.color, size: 3.w),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      rec.text,
                      style: TextStyle(
                        color: AppTheme.textLightGray,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepDebtInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkPurple,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.borderPurple.withAlpha(64),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accentPurple, size: 4.w),
              SizedBox(width: 2.w),
              Text(
                'About Sleep Debt',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.w),

          Text(
            'Sleep debt is the cumulative effect of not getting enough sleep. '
            'It\'s calculated based on the difference between your sleep need (8 hours) '
            'and actual sleep duration over time.',
            style: TextStyle(color: AppTheme.textMediumGray, fontSize: 9.sp),
          ),

          SizedBox(height: 2.w),

          Text(
            'Key Facts:',
            style: TextStyle(
              color: AppTheme.textLightGray,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.w),

          ..._getSleepDebtFacts().map(
            (fact) => Padding(
              padding: EdgeInsets.only(bottom: 0.5.w),
              child: Text(
                '• $fact',
                style: TextStyle(
                  color: AppTheme.textMediumGray,
                  fontSize: 9.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Duration _calculateTodayDebt() {
    if (currentSleepDuration == null) {
      return const Duration(); // No data available
    }

    const optimalSleep = Duration(hours: 8);
    return currentSleepDuration! - optimalSleep;
  }

  Duration _calculateWeeklySleepDebt() {
    // Simulated weekly data - in a real app, this would come from stored sleep records
    final weeklyActualSleep = [
      const Duration(hours: 6, minutes: 30), // Monday
      const Duration(hours: 7, minutes: 15), // Tuesday
      const Duration(hours: 5, minutes: 45), // Wednesday
      const Duration(hours: 8, minutes: 20), // Thursday
      const Duration(hours: 7, minutes: 0), // Friday
      const Duration(hours: 9, minutes: 15), // Saturday
      currentSleepDuration ?? const Duration(hours: 7), // Today
    ];

    const optimalWeeklySleep = Duration(hours: 56); // 8 hours × 7 days

    final totalActualSleep = weeklyActualSleep.fold<Duration>(
      const Duration(),
      (total, sleep) => total + sleep,
    );

    return totalActualSleep - optimalWeeklySleep;
  }

  String _getDebtDescription(Duration debt, bool isToday) {
    if (debt.inMinutes >= 0) {
      return isToday
          ? 'You got extra sleep today!'
          : 'You\'re ahead on sleep this week!';
    } else {
      final hours = debt.inHours.abs();
      if (isToday) {
        return hours >= 2
            ? 'Significant sleep shortage today'
            : 'Minor sleep deficit today';
      } else {
        return hours >= 4
            ? 'Substantial weekly sleep debt'
            : hours >= 2
            ? 'Moderate weekly sleep debt'
            : 'Small weekly sleep debt';
      }
    }
  }

  List<RecoveryRecommendation> _generateRecoveryPlan(
    Duration weeklyDebt,
    Duration todayDebt,
  ) {
    List<RecoveryRecommendation> recommendations = [];

    // High debt recommendations
    if (weeklyDebt.inHours.abs() >= 4) {
      recommendations.add(
        RecoveryRecommendation(
          icon: Icons.schedule,
          color: Colors.red,
          text:
              'Prioritize sleep: aim for 8.5-9 hours tonight to start recovery',
        ),
      );
      recommendations.add(
        RecoveryRecommendation(
          icon: Icons.weekend,
          color: Colors.orange,
          text:
              'Consider a weekend sleep-in to catch up (but limit to +2 hours)',
        ),
      );
    } else if (weeklyDebt.inHours.abs() >= 2) {
      recommendations.add(
        RecoveryRecommendation(
          icon: Icons.bedtime,
          color: Colors.orange,
          text: 'Go to bed 30 minutes earlier for the next few nights',
        ),
      );
    } else if (weeklyDebt.inMinutes >= 0) {
      recommendations.add(
        RecoveryRecommendation(
          icon: Icons.check_circle,
          color: Colors.green,
          text: 'Great job! Maintain your current sleep schedule',
        ),
      );
    }

    // General recommendations
    recommendations.add(
      RecoveryRecommendation(
        icon: Icons.help_outline,
        color: Colors.blue,
        text: 'Keep consistent sleep and wake times, even on weekends',
      ),
    );

    if (todayDebt.inHours.abs() >= 1) {
      recommendations.add(
        RecoveryRecommendation(
          icon: Icons.help_outline,
          color: Colors.purple,
          text: 'Consider a 20-minute power nap (before 3 PM) if feeling tired',
        ),
      );
    }

    return recommendations;
  }

  List<String> _getSleepDebtFacts() {
    return [
      'Sleep debt accumulates over days and weeks',
      'Even 1 hour less sleep per night adds up quickly',
      'It takes multiple good nights to fully recover from sleep debt',
      'Chronic sleep debt affects mood, memory, and immune function',
      'Weekend "catch-up" sleep helps but doesn\'t fully compensate',
      'Consistent sleep schedule prevents debt accumulation',
    ];
  }
}

class RecoveryRecommendation {
  final IconData icon;
  final Color color;
  final String text;

  const RecoveryRecommendation({
    required this.icon,
    required this.color,
    required this.text,
  });
}