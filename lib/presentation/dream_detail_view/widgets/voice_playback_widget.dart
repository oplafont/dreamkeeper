import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoicePlaybackWidget extends StatefulWidget {
  final String? audioPath;

  const VoicePlaybackWidget({Key? key, this.audioPath}) : super(key: key);

  @override
  State<VoicePlaybackWidget> createState() => _VoicePlaybackWidgetState();
}

class _VoicePlaybackWidgetState extends State<VoicePlaybackWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    if (widget.audioPath == null || widget.audioPath!.isEmpty) return;

    try {
      await _audioPlayer.setFilePath(widget.audioPath!);

      _audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration ?? Duration.zero;
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      // Handle audio initialization error silently
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioPath == null || widget.audioPath!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'mic',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Voice Recording',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: _isPlaying ? 'pause' : 'play_arrow',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value:
                            _duration.inMilliseconds > 0
                                ? _position.inMilliseconds /
                                    _duration.inMilliseconds
                                : 0.0,
                        onChanged: (value) {
                          final position = Duration(
                            milliseconds:
                                (value * _duration.inMilliseconds).round(),
                          );
                          _audioPlayer.seek(position);
                        },
                        activeColor: AppTheme.lightTheme.colorScheme.primary,
                        inactiveColor: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Speed: ', style: AppTheme.lightTheme.textTheme.labelMedium),
              ...[0.5, 1.0, 1.25, 1.5, 2.0]
                  .map(
                    (speed) => GestureDetector(
                      onTap: () => _setPlaybackSpeed(speed),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        decoration: BoxDecoration(
                          color:
                              _playbackSpeed == speed
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${speed}x',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                                color:
                                    _playbackSpeed == speed
                                        ? Colors.white
                                        : AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      // Handle playback error silently
    }
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
      setState(() {
        _playbackSpeed = speed;
      });
    } catch (e) {
      // Handle speed change error silently
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
