import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';
import 'dart:io'; // ... Add this import ... //

import '../../../core/app_export.dart';
import '../../../services/openai_client.dart';
import '../../../services/supabase_service.dart';
import '../../../theme/app_theme.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final Function(String audioPath, String transcribedText) onRecordingComplete;

  const VoiceRecordingWidget({super.key, required this.onRecordingComplete});

  @override
  _VoiceRecordingWidgetState createState() => _VoiceRecordingWidgetState();
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
  bool _isTranscribing = false;

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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
    if (!_isRecording) return;

    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _recordingPath = path;
        });

        await _uploadAndTranscribe();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
    }
  }

  Future<void> _uploadAndTranscribe() async {
    if (_recordingPath == null) return;

    setState(() => _isTranscribing = true);

    try {
      final supabase = SupabaseService.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload to storage
      final fileName = 'dream_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = '${user.id}/$fileName';

      final file = File(_recordingPath!);
      final bytes = await file.readAsBytes();

      await supabase.storage
          .from('dream-recordings')
          .uploadBinary(filePath, bytes);

      // Call transcription Edge Function
      final response = await supabase.functions.invoke(
        'transcribe_audio',
        body: {
          'bucket': 'dream-recordings',
          'path': filePath,
          'language': 'en',
        },
      );

      if (response.status == 200 && response.data != null) {
        final transcribedText = response.data['text'] as String? ?? '';

        // Callback with both audio path and transcribed text
        widget.onRecordingComplete(filePath, transcribedText);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording transcribed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(
          'Transcription failed: ${response.data?['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during upload/transcription: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transcription failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isTranscribing = false);
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

    return Container(
      width: 40.w,
      height: 40.w,
      child: Column(
        children: [
          // ... keep existing recording UI ...
          if (_isTranscribing)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Transcribing audio...',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          // ... rest of existing code ...
        ],
      ),
    );
  }
}