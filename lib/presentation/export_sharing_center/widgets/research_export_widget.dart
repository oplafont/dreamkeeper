import 'package:flutter/material.dart';


class ResearchExportWidget extends StatefulWidget {
  final Map<String, bool> privacySettings;
  final Function(String) onExportTap;
  final VoidCallback onConsentTap;

  const ResearchExportWidget({
    super.key,
    required this.privacySettings,
    required this.onExportTap,
    required this.onConsentTap,
  });

  @override
  State<ResearchExportWidget> createState() => _ResearchExportWidgetState();
}

class _ResearchExportWidgetState extends State<ResearchExportWidget> {
  bool _hasConsented = false;
  String _selectedStudy = 'Global Dream Patterns Research';
  Map<String, bool> _dataCategories = {
    'dream_content': true,
    'emotional_patterns': true,
    'sleep_quality': false,
    'demographic_data': false,
    'timestamps': true,
    'lucidity_indicators': true,
  };

  final List<Map<String, dynamic>> _availableStudies = [
{ 'title': 'Global Dream Patterns Research',
'institution': 'International Sleep Research Foundation',
'description': 'Large-scale study on cross-cultural dream patterns and symbolism',
'participants': '50,000+',
'status': 'Active',
'irb_approved': true,
},
{ 'title': 'Lucid Dreaming Mechanisms',
'institution': 'Stanford Sleep Sciences Institute',
'description': 'Research on neural mechanisms underlying lucid dream experiences',
'participants': '12,000+',
'status': 'Recruiting',
'irb_approved': true,
},
{ 'title': 'Emotional Processing in Dreams',
'institution': 'Harvard Dream Laboratory',
'description': 'How emotional content in dreams relates to waking life processing',
'participants': '8,500+',
'status': 'Active',
'irb_approved': true,
},
];

  final Map<String, String> _dataCategoryDescriptions = {
    'dream_content': 'Anonymized dream narratives and themes',
    'emotional_patterns': 'Emotional tags and intensity ratings',
    'sleep_quality': 'Sleep duration and quality ratings',
    'demographic_data': 'Age range and geographic region (anonymized)',
    'timestamps': 'Date/time patterns (dates randomized)',
    'lucidity_indicators': 'Lucid dreaming frequency and triggers',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Consent Status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hasConsented 
              ? const Color(0xFF10B981).withAlpha(26)
              : const Color(0xFFF59E0B).withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasConsented 
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _hasConsented ? Icons.verified_user : Icons.info,
                color: _hasConsented 
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasConsented ? 'Research Consent Active' : 'Consent Required',
                      style: TextStyle(
                        color: _hasConsented 
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _hasConsented 
                        ? 'You can contribute to research studies with full privacy protection'
                        : 'Please review and consent to research participation terms',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_hasConsented)
                TextButton(
                  onPressed: () {
                    widget.onConsentTap();
                    setState(() {
                      _hasConsented = true;
                    });
                  },
                  child: const Text(
                    'Review',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Research Study Selection
        _buildSectionTitle('Available Research Studies'),
        const SizedBox(height: 12),
        ..._availableStudies.map((study) => _buildStudyCard(study)),

        const SizedBox(height: 24),

        // Data Category Selection
        _buildSectionTitle('Data Categories to Include'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF312E81),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4C1D95)),
          ),
          child: Column(
            children: _dataCategories.keys.map((category) {
              return CheckboxListTile(
                value: _dataCategories[category],
                onChanged: _hasConsented ? (value) {
                  setState(() {
                    _dataCategories[category] = value ?? false;
                  });
                } : null,
                title: Text(
                  _getCategoryDisplayName(category),
                  style: TextStyle(
                    color: _hasConsented ? Colors.white : Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  _dataCategoryDescriptions[category] ?? '',
                  style: TextStyle(
                    color: _hasConsented ? Colors.white70 : Colors.white24,
                    fontSize: 12,
                  ),
                ),
                activeColor: const Color(0xFF8B5CF6),
                checkColor: Colors.white,
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Privacy Guarantees
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4C1D95)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.shield,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Privacy Guarantees',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._buildPrivacyGuarantees(),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Export Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _hasConsented && _dataCategories.values.any((v) => v)
                ? () => widget.onExportTap(_selectedStudy)
                : null,
            icon: const Icon(Icons.science, size: 18),
            label: const Text('Contribute to Research'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStudyCard(Map<String, dynamic> study) {
    final isSelected = _selectedStudy == study['title'];
    
    return GestureDetector(
      onTap: _hasConsented ? () {
        setState(() {
          _selectedStudy = study['title'];
        });
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withAlpha(26) : const Color(0xFF312E81),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF4C1D95),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    study['title'],
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF10B981) : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (study['irb_approved'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'IRB Approved',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              study['institution'],
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              study['description'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStudyBadge('${study['participants']} participants', Icons.people),
                const SizedBox(width: 12),
                _buildStudyBadge(study['status'], Icons.circle, 
                  color: study['status'] == 'Active' 
                    ? const Color(0xFF10B981) 
                    : const Color(0xFF8B5CF6)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyBadge(String text, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.white70).withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color ?? Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color ?? Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPrivacyGuarantees() {
    final guarantees = [
      'All personal identifiers automatically removed',
      'Data encrypted during transmission and storage',
      'Research use only - no commercial applications',
      'You can withdraw participation at any time',
      'IRB oversight ensures ethical research practices',
    ];

    return guarantees.map((guarantee) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF10B981),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              guarantee,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'dream_content': return 'Dream Content';
      case 'emotional_patterns': return 'Emotional Patterns';
      case 'sleep_quality': return 'Sleep Quality';
      case 'demographic_data': return 'Demographic Data';
      case 'timestamps': return 'Timestamps';
      case 'lucidity_indicators': return 'Lucidity Indicators';
      default: return category;
    }
  }
}