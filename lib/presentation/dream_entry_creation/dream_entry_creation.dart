import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_constants.dart';
import '../../providers/dream_provider.dart';
import '../../theme/app_theme.dart';

class DreamEntryCreation extends StatefulWidget {
  const DreamEntryCreation({Key? key}) : super(key: key);

  @override
  State<DreamEntryCreation> createState() => _DreamEntryCreationState();
}

class _DreamEntryCreationState extends State<DreamEntryCreation>
    with TickerProviderStateMixin {
  // Controllers
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Recording State
  bool _isRecording = false;
  bool _hasRecording = false;
  String _transcribedText = '';

  // Form State
  String? _selectedMood;
  int _wakeUpEnergy = 3;
  double _clarityScore = 7.0;
  String _sleepQuality = 'good';
  List<String> _selectedTags = [];
  bool _setBedrimeReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 22, minute: 0);

  // UI State
  bool _showAdvancedOptions = false;
  bool _isSaving = false;
  bool _isProcessingAI = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
        // Simulate recording completion
        _hasRecording = true;
        _transcribedText =
            "I was flying over a vast ocean, the water below shimmered with golden light. There was a sense of freedom and peace. I could see dolphins swimming below, and suddenly I realized I was dreaming...";
        _contentController.text = _transcribedText;
      }
    });
  }

  Future<void> _performAICleanup() async {
    if (_contentController.text.isEmpty) return;

    setState(() => _isProcessingAI = true);

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessingAI = false;
        // AI would clean up and enhance the text
        _contentController.text =
            "Flying over a vast, golden-shimmered ocean. The water glistened with ethereal light as dolphins swam gracefully below. A profound sense of freedom and peace washed over me. In that moment of clarity, I became aware—I was dreaming. A lucid experience.";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.auto_fix_high, color: AppTheme.textWhite, size: 20),
              SizedBox(width: 12),
              Text('AI enhanced your dream entry'),
            ],
          ),
          backgroundColor: AppTheme.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _saveDream() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add dream content'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dreamProvider = context.read<DreamProvider>();

      final dream = await dreamProvider.createDream(
        content: _contentController.text,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        mood: _selectedMood,
        tags: _selectedTags.isEmpty ? null : _selectedTags,
        sleepQuality: _sleepQuality,
        clarityScore: _clarityScore.round(),
        performAIAnalysis: true,
      );

      if (dream != null && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.textWhite),
                SizedBox(width: 12),
                Text('Dream saved and analyzed!'),
              ],
            ),
            backgroundColor: AppTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dreamProvider.error ?? 'Failed to save dream'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDarkest,
      body: Container(
        decoration: AppTheme.createGradientBackground(),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Voice Recording Section
                      _buildVoiceRecordingSection(),

                      const SizedBox(height: 24),

                      // Transcribed/Written Content
                      _buildContentSection(),

                      const SizedBox(height: 24),

                      // AI Cleanup Button
                      if (_contentController.text.isNotEmpty)
                        _buildAICleanupButton(),

                      const SizedBox(height: 24),

                      // Wake-up Mood & Energy
                      _buildMoodEnergySection(),

                      const SizedBox(height: 24),

                      // Advanced Options Toggle
                      _buildAdvancedOptionsToggle(),

                      // Advanced Options
                      if (_showAdvancedOptions) ...[
                        const SizedBox(height: 24),
                        _buildClaritySlider(),
                        const SizedBox(height: 24),
                        _buildSleepQualitySection(),
                        const SizedBox(height: 24),
                        _buildTagsSection(),
                        const SizedBox(height: 24),
                        _buildBedrimeReminderSection(),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Bottom Save Button
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppTheme.textSecondary),
          ),
          Text(
            'Capture Dream',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildVoiceRecordingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withOpacity(0.15),
            AppTheme.secondaryTeal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isRecording
              ? AppTheme.primaryPurple
              : AppTheme.primaryPurple.withOpacity(0.3),
          width: _isRecording ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Recording Button
          GestureDetector(
            onTap: _toggleRecording,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: _isRecording
                          ? const LinearGradient(
                              colors: [AppTheme.errorColor, AppTheme.tertiaryOrange],
                            )
                          : AppTheme.createAccentGradient(),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? AppTheme.errorColor
                                  : AppTheme.primaryPurple)
                              .withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: AppTheme.textWhite,
                      size: 44,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Status Text
          Text(
            _isRecording
                ? 'Recording... Tap to stop'
                : _hasRecording
                    ? 'Tap to record again'
                    : 'Tap to start recording',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _isRecording ? AppTheme.tertiaryOrange : AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          if (_isRecording) ...[
            const SizedBox(height: 12),
            // Recording indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '0:23', // Would be dynamic in real implementation
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit_note, color: AppTheme.textMuted, size: 20),
            const SizedBox(width: 8),
            Text(
              'Dream Content',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppTheme.createCardDecoration(),
          child: TextField(
            controller: _contentController,
            maxLines: 6,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: AppConstants.placeholderDreamContent,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSubtle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAICleanupButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryTeal.withOpacity(0.2),
            AppTheme.primaryPurple.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryTeal.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isProcessingAI ? null : _performAICleanup,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isProcessingAI)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.secondaryTeal,
                    ),
                  )
                else
                  const Icon(
                    Icons.auto_fix_high,
                    color: AppTheme.secondaryTeal,
                    size: 22,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isProcessingAI ? 'Processing...' : AppConstants.buttonAICleanup,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.secondaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodEnergySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How do you feel this morning?',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Mood Chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppConstants.moodOptions.map((mood) {
            final isSelected = _selectedMood == mood['value'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMood = isSelected ? null : mood['value'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryPurple.withOpacity(0.2)
                      : AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryPurple
                        : AppTheme.borderSubtle,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mood['emoji'] as String,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mood['label'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.primaryPurple
                            : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Wake-up Energy
        Row(
          children: [
            const Icon(Icons.bolt, color: AppTheme.tertiaryOrange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Wake-up Energy',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            final level = index + 1;
            final isSelected = _wakeUpEnergy >= level;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _wakeUpEnergy = level),
                child: Container(
                  margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.tertiaryOrange.withOpacity(0.2)
                        : AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.tertiaryOrange
                          : AppTheme.borderSubtle,
                    ),
                  ),
                  child: Icon(
                    Icons.bolt,
                    color: isSelected
                        ? AppTheme.tertiaryOrange
                        : AppTheme.textSubtle,
                    size: 20,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Very Low',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSubtle,
              ),
            ),
            Text(
              'Very High',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSubtle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedOptionsToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.createCardDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: AppTheme.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Advanced Options',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              _showAdvancedOptions ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaritySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.visibility, color: AppTheme.secondaryTeal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Dream Clarity',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryTeal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_clarityScore.round()}/10',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.secondaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.secondaryTeal,
            inactiveTrackColor: AppTheme.borderDefault,
            thumbColor: AppTheme.secondaryTeal,
            overlayColor: AppTheme.secondaryTeal.withOpacity(0.2),
          ),
          child: Slider(
            value: _clarityScore,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) => setState(() => _clarityScore = value),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fuzzy',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSubtle,
              ),
            ),
            Text(
              'Crystal Clear',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSubtle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleepQualitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bedtime, color: AppTheme.primaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sleep Quality',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppConstants.sleepQualityOptions.map((option) {
            final isSelected = _sleepQuality == option['value'];
            return GestureDetector(
              onTap: () {
                setState(() => _sleepQuality = option['value'] as String);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.getSleepQualityColor(option['value'] as String)
                          .withOpacity(0.2)
                      : AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.getSleepQualityColor(option['value'] as String)
                        : AppTheme.borderSubtle,
                  ),
                ),
                child: Text(
                  option['label'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.getSleepQualityColor(option['value'] as String)
                        : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    final predefinedTags = ['Lucid', 'Nightmare', 'Recurring', 'Flying', 'Falling', 'Chase', 'Water', 'Family'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tag, color: AppTheme.accentPink, size: 20),
            const SizedBox(width: 8),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: predefinedTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentPink.withOpacity(0.2)
                      : AppTheme.cardBackgroundElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentPink
                        : AppTheme.borderSubtle,
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? AppTheme.accentPink : AppTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBedrimeReminderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.createCardDecoration(
        hasAccent: _setBedrimeReminder,
        accentColor: AppTheme.primaryPurple,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.alarm, color: AppTheme.primaryPurple, size: 22),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bedtime Reminder',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Get reminded to prepare for sleep',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: _setBedrimeReminder,
                onChanged: (value) => setState(() => _setBedrimeReminder = value),
                activeColor: AppTheme.primaryPurple,
              ),
            ],
          ),
          if (_setBedrimeReminder) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (time != null) {
                  setState(() => _reminderTime = time);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, color: AppTheme.primaryPurple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _reminderTime.format(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          top: BorderSide(color: AppTheme.borderSubtle),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppTheme.createAccentGradient(),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveDream,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.textWhite,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, color: AppTheme.textWhite),
                      const SizedBox(width: 12),
                      Text(
                        'Save Dream',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
