import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

class ReflectionQuestionCardWidget extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(String) onAnswerChanged;

  const ReflectionQuestionCardWidget({
    super.key,
    required this.question,
    required this.onAnswerChanged,
  });

  @override
  State<ReflectionQuestionCardWidget> createState() =>
      _ReflectionQuestionCardWidgetState();
}

class _ReflectionQuestionCardWidgetState
    extends State<ReflectionQuestionCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final TextEditingController _answerController = TextEditingController();
  bool _isExpanded = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _answerController.text = widget.question['answer'] ?? '';
    _isExpanded = widget.question['answered'] ?? false;

    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _startVoiceRecording() async {
    setState(() {
      _isRecording = true;
    });

    // Simulate voice recording
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isRecording = false;
    });

    // Add transcribed text to answer
    final transcribedText =
        "Voice input: This is a sample transcription of the user's voice response.";
    _answerController.text +=
        (_answerController.text.isEmpty ? '' : '\n\n') + transcribedText;
    widget.onAnswerChanged(_answerController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isAnswered = widget.question['answered'] ?? false;

    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isAnswered ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: _toggleExpanded,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isAnswered
                    ? const Color(0xFF10B981).withAlpha(26)
                    : const Color(0xFF8B5CF6).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isAnswered ? Icons.check_circle : Icons.psychology,
                color: isAnswered
                    ? const Color(0xFF10B981)
                    : const Color(0xFF8B5CF6),
                size: 20,
              ),
            ),
            title: Text(
              widget.question['question'],
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: isAnswered
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Answered ${_formatTimestamp(widget.question['timestamp'])}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF10B981),
                        fontSize: 12.sp,
                      ),
                    ),
                  )
                : null,
            trailing: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white70,
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFF333333)),
                  SizedBox(height: 2.h),
                  Text(
                    'Your Reflection',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _answerController,
                    maxLines: 4,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts and reflections...',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 13.sp,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F0F0F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(3.w),
                    ),
                    onChanged: widget.onAnswerChanged,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isRecording ? null : _startVoiceRecording,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRecording
                                ? Colors.red.withAlpha(51)
                                : const Color(0xFF8B5CF6).withAlpha(26),
                            foregroundColor: _isRecording
                                ? Colors.red
                                : const Color(0xFF8B5CF6),
                            side: BorderSide(
                              color: _isRecording
                                  ? Colors.red
                                  : const Color(0xFF8B5CF6),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: _isRecording
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.red),
                                  ),
                                )
                              : const Icon(Icons.mic, size: 18),
                          label: Text(
                            _isRecording ? 'Recording...' : 'Voice Input',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      IconButton(
                        onPressed: () {
                          if (_answerController.text.isNotEmpty) {
                            Clipboard.setData(
                                ClipboardData(text: _answerController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Reflection copied to clipboard',
                                  style: GoogleFonts.inter(),
                                ),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _answerController.clear();
                          widget.onAnswerChanged('');
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
