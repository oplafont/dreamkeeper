import 'package:flutter/material.dart';


class ExportPreviewWidget extends StatefulWidget {
  final String reportType;
  final Map<String, bool> privacySettings;
  final VoidCallback onEditTap;
  final VoidCallback onExportTap;

  const ExportPreviewWidget({
    super.key,
    required this.reportType,
    required this.privacySettings,
    required this.onEditTap,
    required this.onExportTap,
  });

  @override
  State<ExportPreviewWidget> createState() => _ExportPreviewWidgetState();
}

class _ExportPreviewWidgetState extends State<ExportPreviewWidget> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewPages = _generatePreviewPages();

    return Column(
      children: [
        // Preview Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1B4B),
            border: Border(bottom: BorderSide(color: Color(0xFF4C1D95))),
          ),
          child: Row(
            children: [
              const Icon(Icons.preview, color: Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Preview: ${widget.reportType}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Page ${_currentPage + 1} of ${previewPages.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),

        // Preview Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: previewPages.length,
                itemBuilder: (context, index) {
                  return previewPages[index];
                },
              ),
            ),
          ),
        ),

        // Navigation Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1B4B),
            border: Border(top: BorderSide(color: Color(0xFF4C1D95))),
          ),
          child: Column(
            children: [
              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(previewPages.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          index == _currentPage
                              ? const Color(0xFF8B5CF6)
                              : Colors.white38,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Navigation Buttons
              Row(
                children: [
                  IconButton(
                    onPressed:
                        _currentPage > 0
                            ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                            : null,
                    icon: const Icon(Icons.chevron_left),
                    color: _currentPage > 0 ? Colors.white : Colors.white38,
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: widget.onEditTap,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: widget.onExportTap,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed:
                        _currentPage < previewPages.length - 1
                            ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                            : null,
                    icon: const Icon(Icons.chevron_right),
                    color:
                        _currentPage < previewPages.length - 1
                            ? Colors.white
                            : Colors.white38,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _generatePreviewPages() {
    switch (widget.reportType) {
      case 'Comprehensive Report':
        return [
          _buildCoverPage(),
          _buildSummaryPage(),
          _buildDreamPatternsPage(),
          _buildEmotionalAnalysisPage(),
          _buildRecommendationsPage(),
        ];
      case 'Summary Report':
        return [
          _buildCoverPage(),
          _buildSummaryPage(),
          _buildRecommendationsPage(),
        ];
      case 'Progress Report':
        return [
          _buildCoverPage(),
          _buildProgressOverviewPage(),
          _buildGoalsAchievementPage(),
        ];
      case 'Crisis Assessment':
        return [
          _buildCoverPage(),
          _buildCrisisIndicatorsPage(),
          _buildImmediateRecommendationsPage(),
        ];
      default:
        return [_buildCoverPage()];
    }
  }

  Widget _buildCoverPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reportType,
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dream Analysis Report',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Patient Information (Anonymized)
          _buildInfoSection('Patient Information', [
            _buildInfoRow(
              'Patient ID',
              widget.privacySettings['anonymize_personal_data'] == true
                  ? 'PT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
                  : 'John D.',
            ),
            _buildInfoRow(
              'Report Period',
              '${_formatDate(DateTime.now().subtract(const Duration(days: 90)))} - ${_formatDate(DateTime.now())}',
            ),
            _buildInfoRow('Generated On', _formatDate(DateTime.now())),
            _buildInfoRow('Report Type', widget.reportType),
          ]),

          const SizedBox(height: 24),

          // Compliance Information
          if (widget.privacySettings['hipaa_compliant'] == true)
            _buildComplianceNotice(),

          const Spacer(),

          // Footer
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Generated by DreamKeeper Analytics',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const Spacer(),
              Text(
                'Page 1',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Executive Summary'),

          const SizedBox(height: 20),

          // Key Metrics
          _buildInfoSection('Key Metrics', [
            _buildInfoRow('Total Dreams Recorded', '47'),
            _buildInfoRow('Average Dreams per Week', '3.9'),
            _buildInfoRow('Most Common Emotion', 'Neutral (32%)'),
            _buildInfoRow('Lucid Dream Frequency', '12.8%'),
          ]),

          const SizedBox(height: 20),

          // Sleep Quality Overview
          _buildInfoSection('Sleep Quality Overview', [
            _buildInfoRow('Average Sleep Quality', '7.2/10'),
            _buildInfoRow('Sleep Duration Avg', '7h 23m'),
            _buildInfoRow('Sleep Consistency Score', '8.1/10'),
          ]),

          const SizedBox(height: 20),

          // Key Findings
          _buildTextSection('Key Findings', [
            '• Dream recall has improved by 23% over the reporting period',
            '• Strong correlation between sleep quality and dream vividness',
            '• Increased frequency of positive emotional content in recent weeks',
            '• Notable pattern: work-related themes appear primarily on Sunday nights',
          ]),

          const Spacer(),
          _buildPageFooter('2'),
        ],
      ),
    );
  }

  Widget _buildDreamPatternsPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Dream Pattern Analysis'),

          const SizedBox(height: 20),

          // Common Themes
          _buildInfoSection('Most Frequent Themes', [
            _buildInfoRow('Flying/Floating', '19 occurrences (40%)'),
            _buildInfoRow('Social Interactions', '15 occurrences (32%)'),
            _buildInfoRow('Work/School Settings', '12 occurrences (26%)'),
            _buildInfoRow('Past Memories', '9 occurrences (19%)'),
          ]),

          const SizedBox(height: 20),

          // Emotional Patterns
          _buildInfoSection('Emotional Distribution', [
            _buildInfoRow('Positive Emotions', '52%'),
            _buildInfoRow('Neutral Emotions', '32%'),
            _buildInfoRow('Negative Emotions', '16%'),
          ]),

          const SizedBox(height: 20),

          // Weekly Patterns
          _buildTextSection('Weekly Patterns', [
            '• Monday: Higher anxiety-related content',
            '• Wednesday-Thursday: Peak creativity and flying dreams',
            '• Friday-Saturday: More social and recreational themes',
            '• Sunday: Work preparation and planning themes',
          ]),

          const Spacer(),
          _buildPageFooter('3'),
        ],
      ),
    );
  }

  Widget _buildEmotionalAnalysisPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Emotional Analysis'),

          const SizedBox(height: 20),

          // Mood Correlations
          _buildInfoSection('Sleep-Dream Correlations', [
            _buildInfoRow('Quality Sleep → Positive Dreams', '78% correlation'),
            _buildInfoRow('Poor Sleep → Fragmented Dreams', '65% correlation'),
            _buildInfoRow('Late Bedtime → Anxiety Content', '43% correlation'),
          ]),

          const SizedBox(height: 20),

          // Therapeutic Insights
          _buildTextSection('Therapeutic Insights', [
            '• Processing of daily stress occurs primarily in REM sleep',
            '• Creative problem-solving themes increased after meditation practice',
            '• Social dreams may indicate desire for deeper connections',
            '• Recurring flight dreams suggest need for freedom/escape',
          ]),

          const SizedBox(height: 20),

          // Progress Indicators
          _buildInfoSection('Emotional Health Indicators', [
            _buildInfoRow('Overall Emotional Tone', 'Improving'),
            _buildInfoRow('Anxiety Content Trend', '↓ Decreasing'),
            _buildInfoRow('Positive Content Trend', '↑ Increasing'),
            _buildInfoRow('Dream Recall Quality', '↑ Improving'),
          ]),

          const Spacer(),
          _buildPageFooter('4'),
        ],
      ),
    );
  }

  Widget _buildRecommendationsPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Clinical Recommendations'),

          const SizedBox(height: 20),

          _buildTextSection('Therapeutic Interventions', [
            '1. Continue dream journaling practice - showing positive results',
            '2. Explore flight dream symbolism in therapy sessions',
            '3. Address Sunday evening work anxiety through relaxation techniques',
            '4. Consider lucid dreaming techniques to process recurring themes',
          ]),

          const SizedBox(height: 20),

          _buildTextSection('Sleep Hygiene Recommendations', [
            '• Maintain consistent bedtime routine (current pattern is effective)',
            '• Consider meditation before bed on Sunday evenings',
            '• Monitor caffeine intake correlation with dream anxiety',
          ]),

          const SizedBox(height: 20),

          _buildTextSection('Follow-up Suggestions', [
            '• Schedule follow-up assessment in 6 weeks',
            '• Track correlation between therapy sessions and dream content',
            '• Monitor for seasonal changes in dream patterns',
          ]),

          const Spacer(),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'This report is generated for therapeutic consultation purposes. All recommendations should be considered within the context of comprehensive clinical assessment.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 12),
          _buildPageFooter('5'),
        ],
      ),
    );
  }

  Widget _buildProgressOverviewPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Progress Overview'),

          const SizedBox(height: 20),

          _buildInfoSection('Progress Metrics', [
            _buildInfoRow('Dream Recall Improvement', '+23%'),
            _buildInfoRow('Sleep Quality Score', '+1.2 points'),
            _buildInfoRow('Positive Dream Content', '+15%'),
            _buildInfoRow('Lucid Dreaming Success', '+8%'),
          ]),

          const Spacer(),
          _buildPageFooter('2'),
        ],
      ),
    );
  }

  Widget _buildGoalsAchievementPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Goals Achievement'),

          const SizedBox(height: 20),

          _buildTextSection('Achieved Goals', [
            '✓ Improve dream recall consistency',
            '✓ Reduce nightmare frequency',
            '✓ Establish regular sleep schedule',
          ]),

          const SizedBox(height: 20),

          _buildTextSection('Goals in Progress', [
            '◐ Increase lucid dreaming frequency',
            '◐ Process work-related stress through dreams',
          ]),

          const Spacer(),
          _buildPageFooter('3'),
        ],
      ),
    );
  }

  Widget _buildCrisisIndicatorsPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Crisis Assessment'),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Text(
              'URGENT: This assessment indicates patterns requiring immediate clinical attention.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          _buildTextSection('Risk Indicators', [
            '⚠ Increased nightmare frequency (5x baseline)',
            '⚠ Sleep fragmentation patterns',
            '⚠ Recurring trauma-related content',
          ]),

          const Spacer(),
          _buildPageFooter('2'),
        ],
      ),
    );
  }

  Widget _buildImmediateRecommendationsPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Immediate Recommendations'),

          const SizedBox(height: 20),

          _buildTextSection('Immediate Actions Required', [
            '1. Schedule emergency therapy session within 48 hours',
            '2. Implement crisis support protocols',
            '3. Monitor sleep patterns closely',
            '4. Consider temporary sleep medication consultation',
          ]),

          const Spacer(),
          _buildPageFooter('3'),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 2, width: 60, color: const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'HIPAA Compliant - All personal identifiers have been anonymized in accordance with healthcare privacy regulations.',
              style: TextStyle(color: Colors.black87, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageFooter(String pageNumber) {
    return Row(
      children: [
        const Text(
          'DreamKeeper Analytics Report',
          style: TextStyle(color: Colors.black54, fontSize: 11),
        ),
        const Spacer(),
        Text(
          'Page $pageNumber',
          style: const TextStyle(color: Colors.black54, fontSize: 11),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
