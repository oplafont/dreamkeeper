import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TherapeuticActionCardWidget extends StatefulWidget {
  final Map<String, dynamic> action;
  final Function(bool) onCompletedChanged;

  const TherapeuticActionCardWidget({
    super.key,
    required this.action,
    required this.onCompletedChanged,
  });

  @override
  State<TherapeuticActionCardWidget> createState() =>
      _TherapeuticActionCardWidgetState();
}

class _TherapeuticActionCardWidgetState
    extends State<TherapeuticActionCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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

  void _onTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _toggleCompleted() {
    final newCompletedState = !(widget.action['completed'] ?? false);
    widget.onCompletedChanged(newCompletedState);

    if (newCompletedState) {
      _showCompletionFeedback();
    }
  }

  void _showCompletionFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.white),
            SizedBox(width: 2.w),
            Text(
              'Great job! Action completed',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.action['completed'] ?? false;
    final actionType = widget.action['type'] ?? 'therapeutic';
    final title = widget.action['title'] ?? 'Therapeutic Action';
    final description = widget.action['description'] ?? '';
    final duration = widget.action['duration'] ?? '';

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            color: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : _getActionTypeColor(actionType),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: _onTap,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
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
                            color: isCompleted
                                ? const Color(0xFF10B981).withAlpha(26)
                                : _getActionTypeColor(actionType).withAlpha(26),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : _getActionTypeIcon(actionType),
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : _getActionTypeColor(actionType),
                            size: 24,
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
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getActionTypeColor(actionType)
                                          .withAlpha(26),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      actionType.toUpperCase(),
                                      style: GoogleFonts.inter(
                                        color: _getActionTypeColor(actionType),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (duration.isNotEmpty) ...[
                                    SizedBox(width: 2.w),
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      duration,
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleCompleted,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isCompleted
                                    ? const Color(0xFF10B981)
                                    : Colors.white38,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          height: 1.4,
                        ),
                      ),
                    ],
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isExpanded ? null : 0,
                      child: _isExpanded ? _buildExpandedContent() : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedContent() {
    final actionType = widget.action['type'] ?? 'therapeutic';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 2.h),
        const Divider(color: Color(0xFF333333)),
        SizedBox(height: 2.h),
        Text(
          'Guidance',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ..._getActionGuidance(actionType)
            .map((guidance) => Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: EdgeInsets.only(top: 0.8.h, right: 2.w),
                        decoration: BoxDecoration(
                          color: _getActionTypeColor(actionType),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          guidance,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _startAction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _getActionTypeColor(actionType).withAlpha(26),
                  foregroundColor: _getActionTypeColor(actionType),
                  side: BorderSide(color: _getActionTypeColor(actionType)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: Text(
                  'Start Session',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            IconButton(
              onPressed: () {
                _showActionDetails();
              },
              icon: Icon(
                Icons.info_outline,
                color: _getActionTypeColor(actionType),
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _startAction() {
    // Simulate starting the therapeutic action
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Session Started',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Your therapeutic session has begun. Take your time and focus on the present moment.',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue',
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

  void _showActionDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.action['title'],
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Benefits',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            ..._getActionBenefits(widget.action['type'])
                .map((benefit) => Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Text(
                        '• $benefit',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ))
                .toList(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Color _getActionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'mindfulness':
        return const Color(0xFF10B981);
      case 'behavioral':
        return const Color(0xFF3B82F6);
      case 'therapeutic':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getActionTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'mindfulness':
        return Icons.self_improvement;
      case 'behavioral':
        return Icons.psychology;
      case 'therapeutic':
        return Icons.healing;
      default:
        return Icons.lightbulb;
    }
  }

  List<String> _getActionGuidance(String type) {
    switch (type.toLowerCase()) {
      case 'mindfulness':
        return [
          'Find a quiet, comfortable space',
          'Focus on your breathing rhythm',
          'Observe thoughts without judgment',
          'Return attention to breath when distracted',
        ];
      case 'behavioral':
        return [
          'Set clear, achievable goals',
          'Track your progress consistently',
          'Practice in small, manageable steps',
          'Celebrate small victories',
        ];
      case 'therapeutic':
        return [
          'Allow yourself to feel emotions fully',
          'Write down your thoughts and feelings',
          'Practice self-compassion',
          'Seek support when needed',
        ];
      default:
        return [
          'Take your time with this practice',
          'Be patient with yourself',
          'Focus on the process, not perfection',
        ];
    }
  }

  List<String> _getActionBenefits(String type) {
    switch (type.toLowerCase()) {
      case 'mindfulness':
        return [
          'Reduces stress and anxiety',
          'Improves focus and concentration',
          'Enhances emotional regulation',
          'Promotes better sleep quality',
        ];
      case 'behavioral':
        return [
          'Builds positive habits',
          'Increases self-awareness',
          'Improves decision-making',
          'Enhances goal achievement',
        ];
      case 'therapeutic':
        return [
          'Processes difficult emotions',
          'Improves self-understanding',
          'Builds emotional resilience',
          'Supports mental health recovery',
        ];
      default:
        return [
          'Promotes overall well-being',
          'Enhances self-awareness',
          'Supports personal growth',
        ];
    }
  }
}
