import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../services/openai_client.dart';
import '../../../services/openai_service.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final Function(String transcription) onRecordingComplete;

  const VoiceRecordingWidget({
    super.key,
    required this.onRecordingComplete,
  });

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  late final OpenAIClient _aiClient;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isRecording = false;
  bool _isProcessing = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _aiClient = OpenAIClient(OpenAIService().dio);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    try {
      // Request permission
      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) {
        _showError('Microphone permission is required to record dreams');
        return;
      }

      // Check if recorder is available
      if (await _audioRecorder.hasPermission()) {
        // Get temporary directory for recording
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _recordingPath = '${tempDir.path}/dream_recording_$timestamp.m4a';

        // Start recording
        await _audioRecorder.start(
          const RecordConfig(),
          path: _recordingPath!,
        );

        setState(() {
          _isRecording = true;
        });

        // Start pulsing animation
        _animationController.repeat(reverse: true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording your dream... Tap to stop'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _showError('Unable to access microphone');
      }
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      _animationController.stop();
      _animationController.reset();

      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      if (_recordingPath != null) {
        await _processRecording();
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
      _showError('Failed to stop recording: $e');
    }
  }

  Future<void> _processRecording() async {
    try {
      if (_recordingPath == null) return;

      final audioFile = File(_recordingPath!);
      if (!await audioFile.exists()) {
        throw Exception('Recording file not found');
      }

      // Transcribe the audio using OpenAI Whisper
      final transcription = await _aiClient.transcribeAudio(
        audioFile: audioFile,
        prompt:
            'This is a dream journal recording. Please transcribe the dream description accurately.',
      );

      // Clean up the temporary file
      try {
        await audioFile.delete();
      } catch (e) {
        print('Failed to delete temporary file: $e');
      }

      setState(() {
        _isProcessing = false;
      });

      // Call the completion callback
      widget.onRecordingComplete(transcription.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dream transcribed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Failed to transcribe recording: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade700,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withAlpha(77),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Recording Button
          GestureDetector(
            onTap: _isProcessing
                ? null
                : _isRecording
                    ? _stopRecording
                    : _startRecording,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _scaleAnimation.value : 1.0,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isProcessing
                          ? Colors.orange
                          : _isRecording
                              ? Colors.red
                              : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: (_isProcessing
                                  ? Colors.orange
                                  : _isRecording
                                      ? Colors.red
                                      : Colors.white)
                              .withAlpha(77),
                          spreadRadius: _isRecording ? 10 : 5,
                          blurRadius: _isRecording ? 20 : 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: _isProcessing
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            size: 8.w,
                            color: _isRecording ? Colors.white : Colors.purple,
                          ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 3.h),

          // Status Text
          Text(
            _isProcessing
                ? 'Processing your dream...'
                : _isRecording
                    ? 'Recording... Tap to stop'
                    : 'Tap and speak',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),

          SizedBox(height: 1.h),

          // Subtitle
          if (!_isRecording && !_isProcessing)
            Text(
              'Tell me about your dream',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(204),
                  ),
            ),

          // Recording indicator
          if (_isRecording) ...[
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 2.w,
                  height: 2.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'REC',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
