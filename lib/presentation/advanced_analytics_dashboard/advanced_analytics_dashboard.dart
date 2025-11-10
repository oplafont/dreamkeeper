import 'package:flutter/material.dart';

import './widgets/advanced_filter_controls_widget.dart';
import './widgets/dream_frequency_trends_widget.dart';
import './widgets/emotional_pattern_tracking_widget.dart';
import './widgets/export_functionality_widget.dart';
import './widgets/interactive_drill_down_widget.dart';
import './widgets/machine_learning_insights_widget.dart';
import './widgets/personal_progress_tracking_widget.dart';
import './widgets/subconscious_theme_identification_widget.dart';

class AdvancedAnalyticsDashboard extends StatefulWidget {
  const AdvancedAnalyticsDashboard({super.key});

  @override
  State<AdvancedAnalyticsDashboard> createState() =>
      _AdvancedAnalyticsDashboardState();
}

class _AdvancedAnalyticsDashboardState extends State<AdvancedAnalyticsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFilterExpanded = false;
  String _selectedTimeRange = 'Last 30 Days';
  List<String> _selectedEmotions = [];
  String _selectedSleepQuality = 'All';
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Advanced Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.purple,
            ),
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.purple),
            onPressed: () => _showExportOptions(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          labelColor: Colors.purple,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Trends'),
            Tab(text: 'Patterns'),
            Tab(text: 'Themes'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Advanced Filter Controls
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isFilterExpanded ? 120 : 0,
            child: _isFilterExpanded
                ? AdvancedFilterControlsWidget(
                    selectedTimeRange: _selectedTimeRange,
                    selectedEmotions: _selectedEmotions,
                    selectedSleepQuality: _selectedSleepQuality,
                    selectedTags: _selectedTags,
                    onTimeRangeChanged: (value) {
                      setState(() {
                        _selectedTimeRange = value;
                      });
                    },
                    onEmotionsChanged: (emotions) {
                      setState(() {
                        _selectedEmotions = emotions;
                      });
                    },
                    onSleepQualityChanged: (quality) {
                      setState(() {
                        _selectedSleepQuality = quality;
                      });
                    },
                    onTagsChanged: (tags) {
                      setState(() {
                        _selectedTags = tags;
                      });
                    },
                  )
                : const SizedBox.shrink(),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Dream Frequency Trends Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DreamFrequencyTrendsWidget(
                        timeRange: _selectedTimeRange,
                        selectedTags: _selectedTags,
                      ),
                      const SizedBox(height: 20),
                      InteractiveDrillDownWidget(
                        data: _getDummyFrequencyData(),
                        title: 'Frequency Analysis',
                        onDataPointTap: (data) => _showDetailedBreakdown(data),
                      ),
                    ],
                  ),
                ),

                // Emotional Pattern Tracking Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      EmotionalPatternTrackingWidget(
                        selectedEmotions: _selectedEmotions,
                        timeRange: _selectedTimeRange,
                      ),
                      const SizedBox(height: 20),
                      InteractiveDrillDownWidget(
                        data: _getDummyEmotionalData(),
                        title: 'Emotional Correlations',
                        onDataPointTap: (data) => _showDetailedBreakdown(data),
                      ),
                    ],
                  ),
                ),

                // Subconscious Theme Identification Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SubconsciousThemeIdentificationWidget(
                        selectedTags: _selectedTags,
                        timeRange: _selectedTimeRange,
                      ),
                      const SizedBox(height: 20),
                      MachineLearningInsightsWidget(
                        analysisType: 'theme_identification',
                        filters: {
                          'timeRange': _selectedTimeRange,
                          'tags': _selectedTags,
                        },
                      ),
                    ],
                  ),
                ),

                // Personal Progress Tracking Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      PersonalProgressTrackingWidget(
                        timeRange: _selectedTimeRange,
                        sleepQuality: _selectedSleepQuality,
                      ),
                      const SizedBox(height: 20),
                      MachineLearningInsightsWidget(
                        analysisType: 'progress_tracking',
                        filters: {
                          'timeRange': _selectedTimeRange,
                          'sleepQuality': _selectedSleepQuality,
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ExportFunctionalityWidget(
        filters: {
          'timeRange': _selectedTimeRange,
          'emotions': _selectedEmotions,
          'sleepQuality': _selectedSleepQuality,
          'tags': _selectedTags,
        },
        onExport: (format) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exporting analytics report as $format...'),
              backgroundColor: Colors.purple,
            ),
          );
        },
      ),
    );
  }

  void _showDetailedBreakdown(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Detailed Analysis',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Data Point: ${data['label'] ?? 'Unknown'}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Value: ${data['value'] ?? 'N/A'}',
                style: const TextStyle(color: Colors.purple, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Confidence: ${data['confidence'] ?? 'N/A'}%',
                style: const TextStyle(color: Colors.green, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyFrequencyData() {
    return [
      {'label': 'Daily Dreams', 'value': 4.2, 'confidence': 92},
      {'label': 'Weekly Patterns', 'value': 28.5, 'confidence': 87},
      {'label': 'Monthly Trends', 'value': 124, 'confidence': 95},
    ];
  }

  List<Map<String, dynamic>> _getDummyEmotionalData() {
    return [
      {'label': 'Joy Correlation', 'value': 0.78, 'confidence': 89},
      {'label': 'Anxiety Patterns', 'value': 0.43, 'confidence': 76},
      {'label': 'Fear Indicators', 'value': 0.31, 'confidence': 82},
    ];
  }
}
