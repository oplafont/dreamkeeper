import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final Function(String) onTranscriptionComplete;

  const VoiceRecordingWidget({Key? key, required this.onTranscriptionComplete})
      : super(key: key);

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  RecorderController? _recorderController;
  bool _isRecording = false;
  bool _isInitialized = false;
  String? _recordingPath;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeRecorder() async {
    try {
      if (!kIsWeb) {
        _recorderController = RecorderController();
      }
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    if (kIsWeb) return true;

    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    try {
      if (!await _requestMicrophonePermission()) {
        _showPermissionDialog();
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: 'recording.wav',
          );
        } else {
          final dir = await getTemporaryDirectory();
          _recordingPath =
              '${dir.path}/dream_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: _recordingPath!,
          );

          if (_recorderController != null) {
            await _recorderController!.record();
          }
        }

        setState(() {
          _isRecording = true;
        });

        // Start pulsing animation
        _pulseController.repeat(reverse: true);
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _showErrorMessage('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      if (!kIsWeb && _recorderController != null) {
        await _recorderController!.stop();
      }

      setState(() {
        _isRecording = false;
      });

      // Stop pulsing animation
      _pulseController.stop();
      _pulseController.reset();

      if (path != null) {
        // Simulate transcription for demo purposes
        // In a real app, you would use a speech-to-text service
        await Future.delayed(const Duration(seconds: 1));
        widget.onTranscriptionComplete(
          "I had a vivid dream about flying over a beautiful landscape with mountains and rivers below. The feeling was incredibly peaceful and liberating.",
        );
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
      });
      _showErrorMessage('Failed to stop recording');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Microphone Permission Required',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Please grant microphone permission to record voice notes for your dreams.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _recorderController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRecording ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _isRecording
                    ? Colors.red.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  if (_isRecording) ...[
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ],
                border: Border.all(
                  color: _isRecording
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.secondary,
                  width: 4,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _isRecording ? 'stop' : 'mic',
                  color: _isRecording
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.secondary,
                  size: 12.w,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
