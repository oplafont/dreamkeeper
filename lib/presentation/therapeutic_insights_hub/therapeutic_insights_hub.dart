import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/dream.dart';
import '../../services/dream_service.dart';
import '../../services/openai_service.dart';
import './widgets/guided_reflection_session_widget.dart';
import './widgets/mood_correlation_matrix_widget.dart';
import './widgets/privacy_controls_widget.dart';
import './widgets/progress_tracking_widget.dart';
import './widgets/reflection_question_card_widget.dart';
import './widgets/therapeutic_action_card_widget.dart';

class TherapeuticInsightsHub extends StatefulWidget {
  const TherapeuticInsightsHub({super.key});

  @override
  State<TherapeuticInsightsHub> createState() => _TherapeuticInsightsHubState();
}

class _TherapeuticInsightsHubState extends State<TherapeuticInsightsHub>
    with TickerProviderStateMixin {
  final OpenAIService _openAIService = OpenAIService();
  final DreamService _dreamService = DreamService();

  late TabController _tabController;
  bool _isLoading = false;
  String _error = '';

  List<Map<String, dynamic>> _reflectionQuestions = [];
  List<Dream> _recentDreams = [];
  Map<String, dynamic> _moodData = {};
  List<Map<String, dynamic>> _therapeuticActions = [];
  Map<String, dynamic> _progressData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTherapeuticData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTherapeuticData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Load recent dreams for analysis
      final dreamsData = await _dreamService.getUserDreams(limit: 10);
      _recentDreams = dreamsData.map((data) => Dream.fromJson(data)).toList();

      // Generate AI-powered reflection questions
      await _generateReflectionQuestions();

      // Load mood correlation data
      await _loadMoodCorrelationData();

      // Generate therapeutic action suggestions
      await _generateTherapeuticActions();

      // Load progress tracking data
      await _loadProgressData();
    } catch (e) {
      setState(() {
        _error = 'Failed to load therapeutic insights: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateReflectionQuestions() async {
    if (_recentDreams.isEmpty) {
      _reflectionQuestions = _getDefaultReflectionQuestions();
      return;
    }

    try {
      final dreamThemes = _recentDreams.map((dream) => dream.content).join(' ');

      final questions =
          await _openAIService.generateReflectionQuestions(dreamThemes);

      setState(() {
        _reflectionQuestions = questions
            .map((q) => {
                  'question': q,
                  'answered': false,
                  'answer': '',
                  'timestamp': null,
                })
            .toList();
      });
    } catch (e) {
      _reflectionQuestions = _getDefaultReflectionQuestions();
    }
  }

  List<Map<String, dynamic>> _getDefaultReflectionQuestions() {
    return [
      {
        'question': 'What emotions were most prominent in your recent dreams?',
        'answered': false,
        'answer': '',
        'timestamp': null,
      },
      {
        'question':
            'How do your dream themes relate to your current life challenges?',
        'answered': false,
        'answer': '',
        'timestamp': null,
      },
      {
        'question': 'What patterns do you notice in your dream symbols?',
        'answered': false,
        'answer': '',
        'timestamp': null,
      },
    ];
  }

  Future<void> _loadMoodCorrelationData() async {
    // Analyze mood patterns from dreams
    final moodCounts = <String, int>{};
    final emotionCorrelations = <String, List<String>>{};

    for (final dream in _recentDreams) {
      if (dream.mood?.isNotEmpty ?? false) {
        final mood = dream.mood!;
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;

        // Extract emotional themes from content
        final emotions = _extractEmotionalThemes(dream.content);
        emotionCorrelations[mood] = emotions;
      }
    }

    setState(() {
      _moodData = {
        'moodCounts': moodCounts,
        'emotionCorrelations': emotionCorrelations,
        'totalEntries': _recentDreams.length,
      };
    });
  }

  List<String> _extractEmotionalThemes(String content) {
    final emotionalKeywords = [
      'fear',
      'joy',
      'anxiety',
      'love',
      'anger',
      'peace',
      'excitement',
      'sadness'
    ];
    final themes = <String>[];

    for (final keyword in emotionalKeywords) {
      if (content.toLowerCase().contains(keyword)) {
        themes.add(keyword);
      }
    }

    return themes;
  }

  Future<void> _generateTherapeuticActions() async {
    if (_recentDreams.isEmpty) {
      _therapeuticActions = _getDefaultTherapeuticActions();
      return;
    }

    try {
      final dreamPatterns = _analyzeDreamPatterns();
      final actions =
          await _openAIService.generateTherapeuticActions(dreamPatterns);

      setState(() {
        _therapeuticActions = actions
            .map((action) => {
                  'title': action['title'],
                  'description': action['description'],
                  'type': action[
                      'type'], // 'mindfulness', 'behavioral', 'therapeutic'
                  'duration': action['duration'],
                  'completed': false,
                })
            .toList();
      });
    } catch (e) {
      _therapeuticActions = _getDefaultTherapeuticActions();
    }
  }

  Map<String, dynamic> _analyzeDreamPatterns() {
    final patterns = <String, dynamic>{};
    final themes = <String>[];
    final emotions = <String>[];

    for (final dream in _recentDreams) {
      themes.addAll(dream.tags);
      if (dream.mood != null) {
        emotions.add(dream.mood!);
      }
    }

    patterns['commonThemes'] = _getFrequencyMap(themes);
    patterns['emotionalPatterns'] = _getFrequencyMap(emotions);
    patterns['averageQuality'] =
        _recentDreams.map((d) => double.tryParse(d.sleepQuality ?? '0') ?? 0.0).reduce((a, b) => a + b) /
            _recentDreams.length;

    return patterns;
  }

  Map<String, int> _getFrequencyMap(List<String> items) {
    final frequency = <String, int>{};
    for (final item in items) {
      if (item.isNotEmpty) {
        frequency[item] = (frequency[item] ?? 0) + 1;
      }
    }
    return frequency;
  }

  List<Map<String, dynamic>> _getDefaultTherapeuticActions() {
    return [
      {
        'title': 'Morning Mindfulness',
        'description':
            'Start your day with 10 minutes of mindful breathing to center yourself.',
        'type': 'mindfulness',
        'duration': '10 minutes',
        'completed': false,
      },
      {
        'title': 'Dream Journaling',
        'description':
            'Write down your dreams immediately upon waking to improve recall.',
        'type': 'behavioral',
        'duration': '15 minutes',
        'completed': false,
      },
      {
        'title': 'Evening Reflection',
        'description':
            'Reflect on your day and set positive intentions before sleep.',
        'type': 'therapeutic',
        'duration': '20 minutes',
        'completed': false,
      },
    ];
  }

  Future<void> _loadProgressData() async {
    // Calculate wellness trends over time
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentDreams = _recentDreams
        .where((dream) => dream.createdAt.isAfter(thirtyDaysAgo))
        .toList();

    final weeklyProgress = <String, dynamic>{};
    final emotionalTrends = <String, List<double>>{};

    // Group dreams by week
    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: (i + 1) * 7));
      final weekEnd = now.subtract(Duration(days: i * 7));

      final weekDreams = recentDreams
          .where((dream) =>
              dream.createdAt.isAfter(weekStart) &&
              dream.createdAt.isBefore(weekEnd))
          .toList();

      if (weekDreams.isNotEmpty) {
        final avgQuality =
            weekDreams.map((d) => double.tryParse(d.sleepQuality ?? '0') ?? 0.0).reduce((a, b) => a + b) /
                weekDreams.length;

        weeklyProgress['week_${4 - i}'] = {
          'dreamCount': weekDreams.length,
          'avgQuality': avgQuality,
          'moodDistribution': _getMoodDistribution(weekDreams),
        };
      }
    }

    setState(() {
      _progressData = {
        'weeklyProgress': weeklyProgress,
        'improvementAreas': _identifyImprovementAreas(recentDreams),
        'overallTrend': _calculateOverallTrend(recentDreams),
      };
    });
  }

  Map<String, int> _getMoodDistribution(List<Dream> dreams) {
    final distribution = <String, int>{};
    for (final dream in dreams) {
      if (dream.mood?.isNotEmpty ?? false) {
        final mood = dream.mood!;
        distribution[mood] = (distribution[mood] ?? 0) + 1;
      }
    }
    return distribution;
  }

  List<String> _identifyImprovementAreas(List<Dream> dreams) {
    final areas = <String>[];

    if (dreams.isNotEmpty) {
      final avgQuality =
          dreams.map((d) => double.tryParse(d.sleepQuality ?? '0') ?? 0.0).reduce((a, b) => a + b) /
              dreams.length;

      if (avgQuality < 3.0) {
        areas.add('Sleep Quality');
      }

      final negativeEmotions = dreams
          .where((d) => ['anxious', 'fearful', 'sad', 'angry']
              .contains(d.mood?.toLowerCase()))
          .length;

      if (negativeEmotions > dreams.length * 0.6) {
        areas.add('Emotional Regulation');
      }

      final dreamFrequency = dreams.length / 30.0; // dreams per day
      if (dreamFrequency < 0.3) {
        areas.add('Dream Recall');
      }
    }

    return areas;
  }

  String _calculateOverallTrend(List<Dream> dreams) {
    if (dreams.length < 2) return 'stable';

    final firstHalf = dreams.take(dreams.length ~/ 2).toList();
    final secondHalf = dreams.skip(dreams.length ~/ 2).toList();

    final firstAvg = firstHalf.isNotEmpty
        ? firstHalf.map((d) => double.tryParse(d.sleepQuality ?? '0') ?? 0.0).reduce((a, b) => a + b) /
            firstHalf.length
        : 0.0;

    final secondAvg = secondHalf.isNotEmpty
        ? secondHalf.map((d) => double.tryParse(d.sleepQuality ?? '0') ?? 0.0).reduce((a, b) => a + b) /
            secondHalf.length
        : 0.0;

    final difference = secondAvg - firstAvg;

    if (difference > 0.5) return 'improving';
    if (difference < -0.5) return 'declining';
    return 'stable';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Therapeutic Insights',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTherapeuticData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8B5CF6),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Reflection'),
            Tab(text: 'Insights'),
            Tab(text: 'Actions'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B5CF6),
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48.sp,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _error,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: _loadTherapeuticData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReflectionTab(),
                    _buildInsightsTab(),
                    _buildActionsTab(),
                    _buildProgressTab(),
                  ],
                ),
    );
  }

  Widget _buildReflectionTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalized Reflection Questions',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'AI-generated questions based on your recent dream patterns',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 3.h),
          ..._reflectionQuestions
              .map((question) => Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: ReflectionQuestionCardWidget(
                      question: question,
                      onAnswerChanged: (answer) {
                        setState(() {
                          question['answer'] = answer;
                          question['answered'] = answer.isNotEmpty;
                          question['timestamp'] = DateTime.now();
                        });
                      },
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood & Emotion Analysis',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          MoodCorrelationMatrixWidget(
            moodData: _moodData,
          ),
          SizedBox(height: 3.h),
          PrivacyControlsWidget(),
        ],
      ),
    );
  }

  Widget _buildActionsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Therapeutic Actions',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Personalized recommendations based on your dream insights',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 3.h),
          ..._therapeuticActions
              .map((action) => Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: TherapeuticActionCardWidget(
                      action: action,
                      onCompletedChanged: (completed) {
                        setState(() {
                          action['completed'] = completed;
                        });
                      },
                    ),
                  ))
              .toList(),
          SizedBox(height: 3.h),
          GuidedReflectionSessionWidget(),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wellness Progress',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          ProgressTrackingWidget(
            progressData: _progressData,
          ),
        ],
      ),
    );
  }
}