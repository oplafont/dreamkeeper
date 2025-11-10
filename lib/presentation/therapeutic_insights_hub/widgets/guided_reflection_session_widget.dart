import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class GuidedReflectionSessionWidget extends StatefulWidget {
  const GuidedReflectionSessionWidget({super.key});

  @override
  State<GuidedReflectionSessionWidget> createState() =>
      _GuidedReflectionSessionWidgetState();
}

class _GuidedReflectionSessionWidgetState
    extends State<GuidedReflectionSessionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _breathingAnimation;

  bool _isSessionActive = false;
  int _sessionDuration = 5; // minutes
  int _currentTime = 0;
  String _currentPhase = 'preparation';
  String _currentInstruction =
      'Prepare yourself for a guided reflection session';

  final List<Map<String, dynamic>> _sessionPhases = [
    {
      'name': 'preparation',
      'duration':
          60, // seconds 'instruction': 'Find a comfortable position and close your eyes. Take three deep breaths.',
      'color': Color(0xFF8B5CF6),
    },
    {
      'name': 'centering',
      'duration': 120,
      'instruction':
          'Focus on your breathing. Notice the rhythm of your breath.',
      'color': Color(0xFF10B981),
    },
    {
      'name': 'reflection',
      'duration': 180,
      'instruction': 'Reflect on your recent dreams. What emotions arise?',
      'color': Color(0xFF3B82F6),
    },
    {
      'name': 'integration',
      'duration': 120,
      'instruction': 'Consider how these insights apply to your waking life.',
      'color': Color(0xFFFBBF24),
    },
    {
      'name': 'completion',
      'duration': 60,
      'instruction':
          'Take a moment to appreciate this time of self-reflection.',
      'color': Color(0xFF8B5CF6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _currentTime = 0;
      _currentPhase = _sessionPhases.first['name'];
      _currentInstruction = _sessionPhases.first['instruction'];
    });

    _animationController.repeat(reverse: true);
    _runSession();
  }

  void _runSession() async {
    for (final phase in _sessionPhases) {
      if (!_isSessionActive) break;

      setState(() {
        _currentPhase = phase['name'];
        _currentInstruction = phase['instruction'];
      });

      final phaseDuration = phase['duration'] as int;

      for (int i = 0; i < phaseDuration; i++) {
        if (!_isSessionActive) break;

        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _currentTime++;
        });
      }
    }

    if (_isSessionActive) {
      _completeSession();
    }
  }

  void _completeSession() {
    setState(() {
      _isSessionActive = false;
      _currentTime = 0;
      _currentPhase = 'completed';
      _currentInstruction =
          'Session completed! Take a moment to journal your insights.';
    });

    _animationController.stop();
    _showCompletionDialog();
  }

  void _stopSession() {
    setState(() {
      _isSessionActive = false;
      _currentTime = 0;
      _currentPhase = 'preparation';
      _currentInstruction = 'Session paused. You can restart when ready.';
    });

    _animationController.stop();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.celebration,
              color: Color(0xFF10B981),
            ),
            SizedBox(width: 2.w),
            Text(
              'Session Complete!',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Great job completing your guided reflection session!',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Consider journaling about:',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            ...[
              'What emotions came up during reflection?',
              'What insights did you gain?',
              'How can you apply these insights?'
            ]
                .map((prompt) => Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Text(
                        '• $prompt',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSession();
            },
            child: Text(
              'Done',
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

  void _resetSession() {
    setState(() {
      _currentPhase = 'preparation';
      _currentInstruction = 'Prepare yourself for a guided reflection session';
      _currentTime = 0;
    });
  }

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
                    color: const Color(0xFF8B5CF6).withAlpha(26),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    color: Color(0xFF8B5CF6),
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guided Reflection Session',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Structured therapeutic exercise with timer',
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
            if (!_isSessionActive && _currentPhase != 'completed') ...[
              _buildSessionSetup(),
            ] else ...[
              _buildActiveSession(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Duration',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [5, 10, 15]
              .map((duration) => Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: ChoiceChip(
                      label: Text(
                        '$duration min',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: _sessionDuration == duration,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _sessionDuration = duration;
                          });
                        }
                      },
                      selectedColor: const Color(0xFF8B5CF6).withAlpha(51),
                      backgroundColor: const Color(0xFF333333),
                      labelStyle: GoogleFonts.inter(
                        color: _sessionDuration == duration
                            ? const Color(0xFF8B5CF6)
                            : Colors.white70,
                      ),
                      side: BorderSide(
                        color: _sessionDuration == duration
                            ? const Color(0xFF8B5CF6)
                            : Colors.transparent,
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: 3.h),
        Text(
          'Session Phases',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ..._sessionPhases
            .map((phase) => Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: phase['color'],
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: phase['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          '${phase['name'].toString().toUpperCase()} (${(phase['duration'] as int) ~/ 60}m)',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        SizedBox(height: 3.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: Text(
              'Start Guided Session',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSession() {
    final currentPhaseData = _sessionPhases.firstWhere(
      (phase) => phase['name'] == _currentPhase,
      orElse: () => _sessionPhases.first,
    );

    final totalDuration = _sessionPhases.fold<int>(
        0, (sum, phase) => sum + (phase['duration'] as int));

    final progress = _currentTime / totalDuration;

    return Column(
      children: [
        // Breathing animation circle
        Center(
          child: AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return Container(
                width: 120 * _breathingAnimation.value,
                height: 120 * _breathingAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      currentPhaseData['color'].withAlpha(77),
                      currentPhaseData['color'].withAlpha(26),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentPhaseData['color'].withAlpha(204),
                    ),
                    child: Icon(
                      Icons.self_improvement,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          _currentPhase.toUpperCase(),
          style: GoogleFonts.inter(
            color: currentPhaseData['color'],
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          _currentInstruction,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 3.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white10,
          valueColor: AlwaysStoppedAnimation<Color>(currentPhaseData['color']),
        ),
        SizedBox(height: 1.h),
        Text(
          '${_formatTime(_currentTime)} / ${_formatTime(totalDuration)}',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 3.h),
        ElevatedButton.icon(
          onPressed: _stopSession,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withAlpha(26),
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.stop, size: 18),
          label: Text(
            'End Session',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}