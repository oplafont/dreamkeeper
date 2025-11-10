import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/sleep_correlation_widget.dart';
import './widgets/sleep_debt_calculator_widget.dart';
import './widgets/sleep_duration_picker_widget.dart';
import './widgets/sleep_environment_widget.dart';
import './widgets/sleep_interruptions_widget.dart';
import './widgets/sleep_quality_slider_widget.dart';
import './widgets/sleep_suggestions_widget.dart';
import './widgets/time_to_sleep_widget.dart';

class SleepQualityTracking extends StatefulWidget {
  const SleepQualityTracking({super.key});

  @override
  State<SleepQualityTracking> createState() => _SleepQualityTrackingState();
}

class _SleepQualityTrackingState extends State<SleepQualityTracking> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Sleep data variables
  DateTime? _bedtime;
  DateTime? _wakeTime;
  Duration? _sleepDuration;
  double _sleepQuality = 5.0;
  int _interruptions = 0;
  int _timeToFallAsleep = 15; // minutes

  // Environment factors
  String _roomTemperature = 'comfortable';
  String _noiseLevel = 'quiet';
  String _lightExposure = 'dark';

  // Auto-save functionality
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadPreviousData();
  }

  Future<void> _loadPreviousData() async {
    // Load any auto-saved data
    // Implementation for loading previous session data
  }

  void _onDataChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  void _calculateSleepDuration() {
    if (_bedtime != null && _wakeTime != null) {
      Duration duration = _wakeTime!.difference(_bedtime!);

      // Handle next day wake time
      if (duration.isNegative) {
        duration = duration + const Duration(days: 1);
      }

      setState(() {
        _sleepDuration = duration;
      });
      _onDataChanged();
    }
  }

  Future<void> _saveSleepData() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: CircularProgressIndicator(color: AppTheme.accentPurple),
            ),
      );

      // Save sleep data to Supabase
      final sleepData = {
        'bedtime': _bedtime?.toIso8601String(),
        'wake_time': _wakeTime?.toIso8601String(),
        'sleep_duration': _sleepDuration?.inMinutes,
        'sleep_quality': _sleepQuality,
        'interruptions': _interruptions,
        'time_to_fall_asleep': _timeToFallAsleep,
        'room_temperature': _roomTemperature,
        'noise_level': _noiseLevel,
        'light_exposure': _lightExposure,
        'recorded_at': DateTime.now().toIso8601String(),
      };

      // TODO: Implement Supabase save
      await Future.delayed(const Duration(seconds: 1)); // Placeholder

      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sleep data saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _hasUnsavedChanges = false;
      });

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving sleep data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.primaryDarkPurple,
            title: const Text(
              'Discard Changes?',
              style: TextStyle(color: AppTheme.textWhite),
            ),
            content: const Text(
              'You have unsaved changes. Are you sure you want to discard them?',
              style: TextStyle(color: AppTheme.textLightGray),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.accentPurple),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Discard',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDarkest,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryDarkPurple,
          title: Text(
            'Sleep Quality Tracking',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
            onPressed:
                () => _onWillPop().then((canPop) {
                  if (canPop) Navigator.of(context).pop();
                }),
          ),
          actions: [
            TextButton(
              onPressed: _hasUnsavedChanges ? _saveSleepData : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color:
                      _hasUnsavedChanges
                          ? AppTheme.accentPurple
                          : AppTheme.textMediumGray,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sleep Duration Section
                SleepDurationPickerWidget(
                  bedtime: _bedtime,
                  wakeTime: _wakeTime,
                  sleepDuration: _sleepDuration,
                  onBedtimeChanged: (time) {
                    setState(() {
                      _bedtime = time;
                    });
                    _calculateSleepDuration();
                  },
                  onWakeTimeChanged: (time) {
                    setState(() {
                      _wakeTime = time;
                    });
                    _calculateSleepDuration();
                  },
                ),

                SizedBox(height: 6.w),

                // Sleep Quality Section
                SleepQualitySliderWidget(
                  quality: _sleepQuality,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _sleepQuality = value;
                    });
                    _onDataChanged();
                  },
                ),

                SizedBox(height: 6.w),

                // Sleep Interruptions
                SleepInterruptionsWidget(
                  interruptions: _interruptions,
                  onChanged: (value) {
                    setState(() {
                      _interruptions = value;
                    });
                    _onDataChanged();
                  },
                ),

                SizedBox(height: 6.w),

                // Time to Fall Asleep
                TimeToSleepWidget(
                  minutes: _timeToFallAsleep,
                  onChanged: (value) {
                    setState(() {
                      _timeToFallAsleep = value;
                    });
                    _onDataChanged();
                  },
                ),

                SizedBox(height: 6.w),

                // Sleep Environment
                SleepEnvironmentWidget(
                  temperature: _roomTemperature,
                  noiseLevel: _noiseLevel,
                  lightExposure: _lightExposure,
                  onTemperatureChanged: (value) {
                    setState(() {
                      _roomTemperature = value;
                    });
                    _onDataChanged();
                  },
                  onNoiseLevelChanged: (value) {
                    setState(() {
                      _noiseLevel = value;
                    });
                    _onDataChanged();
                  },
                  onLightExposureChanged: (value) {
                    setState(() {
                      _lightExposure = value;
                    });
                    _onDataChanged();
                  },
                ),

                SizedBox(height: 6.w),

                // Smart Suggestions
                SleepSuggestionsWidget(
                  sleepDuration: _sleepDuration,
                  sleepQuality: _sleepQuality,
                  interruptions: _interruptions,
                ),

                SizedBox(height: 6.w),

                // Correlation Indicators
                SleepCorrelationWidget(
                  sleepQuality: _sleepQuality,
                  sleepDuration: _sleepDuration,
                ),

                SizedBox(height: 6.w),

                // Sleep Debt Calculator
                SleepDebtCalculatorWidget(currentSleepDuration: _sleepDuration),

                SizedBox(height: 10.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}