import 'package:flutter/material.dart';

class PrivacySettingsWidget extends StatefulWidget {
  final Map<String, bool> currentSettings;
  final ScrollController scrollController;
  final Function(Map<String, bool>) onSettingsChanged;

  const PrivacySettingsWidget({
    super.key,
    required this.currentSettings,
    required this.scrollController,
    required this.onSettingsChanged,
  });

  @override
  State<PrivacySettingsWidget> createState() => _PrivacySettingsWidgetState();
}

class _PrivacySettingsWidgetState extends State<PrivacySettingsWidget> {
  late Map<String, bool> _settings;

  final Map<String, Map<String, String>> _settingsInfo = {
    'anonymize_personal_data': {
      'title': 'Anonymize Personal Data',
      'description':
          'Remove all personal identifiers including names, locations, and specific dates',
      'category': 'Data Protection',
      'icon': 'person_off',
    },
    'include_metadata': {
      'title': 'Include Metadata',
      'description':
          'Export technical data like entry timestamps and device information',
      'category': 'Technical Data',
      'icon': 'info',
    },
    'hipaa_compliant': {
      'title': 'HIPAA Compliance Mode',
      'description':
          'Ensure all exports meet healthcare privacy regulations and standards',
      'category': 'Healthcare Compliance',
      'icon': 'medical_services',
    },
    'filter_sensitive_content': {
      'title': 'Filter Sensitive Content',
      'description':
          'Automatically detect and exclude potentially sensitive personal information',
      'category': 'Content Filtering',
      'icon': 'filter_alt',
    },
    'encrypt_exports': {
      'title': 'Encrypt All Exports',
      'description':
          'Apply end-to-end encryption to all exported files and shared links',
      'category': 'Security',
      'icon': 'lock',
    },
    'audit_trail': {
      'title': 'Maintain Audit Trail',
      'description':
          'Keep a record of all export and sharing activities for security purposes',
      'category': 'Auditing',
      'icon': 'history',
    },
    'consent_verification': {
      'title': 'Verify Consent',
      'description':
          'Require explicit consent confirmation before each export operation',
      'category': 'Consent Management',
      'icon': 'verified_user',
    },
    'data_minimization': {
      'title': 'Data Minimization',
      'description':
          'Only export essential data fields to reduce privacy risk exposure',
      'category': 'Privacy by Design',
      'icon': 'minimize',
    },
  };

  @override
  void initState() {
    super.initState();
    _settings = Map<String, bool>.from(widget.currentSettings);

    // Add missing settings with default values
    for (String key in _settingsInfo.keys) {
      _settings[key] ??= _getDefaultValue(key);
    }
  }

  bool _getDefaultValue(String key) {
    switch (key) {
      case 'anonymize_personal_data':
      case 'hipaa_compliant':
      case 'filter_sensitive_content':
      case 'encrypt_exports':
      case 'consent_verification':
      case 'data_minimization':
        return true;
      case 'include_metadata':
      case 'audit_trail':
        return false;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsByCategory = _groupSettingsByCategory();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.privacy_tip, color: Color(0xFF8B5CF6), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Privacy & Security Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),
        ),

        // Settings Content
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // Compliance Status
              _buildComplianceStatus(),
              const SizedBox(height: 24),

              // Settings by Category
              ...settingsByCategory.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryHeader(entry.key),
                    const SizedBox(height: 12),
                    ...entry.value.map((setting) => _buildSettingCard(setting)),
                    const SizedBox(height: 24),
                  ],
                );
              }).toList(),

              // Privacy Impact Assessment
              _buildPrivacyImpactAssessment(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, List<String>> _groupSettingsByCategory() {
    Map<String, List<String>> grouped = {};

    for (String key in _settingsInfo.keys) {
      String category = _settingsInfo[key]!['category']!;
      grouped[category] ??= [];
      grouped[category]!.add(key);
    }

    return grouped;
  }

  Widget _buildComplianceStatus() {
    bool isFullyCompliant =
        _settings['anonymize_personal_data'] == true &&
        _settings['hipaa_compliant'] == true &&
        _settings['filter_sensitive_content'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isFullyCompliant
                ? const Color(0xFF10B981).withAlpha(26)
                : const Color(0xFFF59E0B).withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isFullyCompliant
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFullyCompliant ? Icons.verified : Icons.warning,
            color:
                isFullyCompliant
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
                  isFullyCompliant ? 'Fully Compliant' : 'Compliance Warning',
                  style: TextStyle(
                    color:
                        isFullyCompliant
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isFullyCompliant
                      ? 'All privacy and security requirements are met'
                      : 'Some recommended privacy settings are disabled',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String category) {
    return Text(
      category,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSettingCard(String settingKey) {
    final info = _settingsInfo[settingKey]!;
    final isEnabled = _settings[settingKey] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF312E81),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? const Color(0xFF8B5CF6) : const Color(0xFF4C1D95),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isEnabled ? const Color(0xFF8B5CF6) : Colors.white70)
                  .withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconData(info['icon']!),
              color: isEnabled ? const Color(0xFF8B5CF6) : Colors.white70,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info['title']!,
                  style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info['description']!,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              setState(() {
                _settings[settingKey] = value;
              });
              widget.onSettingsChanged(_settings);
            },
            activeThumbColor: const Color(0xFF8B5CF6),
            inactiveThumbColor: Colors.white60,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyImpactAssessment() {
    int enabledCount = _settings.values.where((v) => v).length;
    int totalCount = _settings.length;
    double privacyScore = (enabledCount / totalCount) * 100;

    Color scoreColor =
        privacyScore >= 80
            ? const Color(0xFF10B981)
            : privacyScore >= 60
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Container(
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
              Icon(Icons.assessment, color: Color(0xFF8B5CF6), size: 20),
              SizedBox(width: 8),
              Text(
                'Privacy Impact Assessment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy Score',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${privacyScore.round()}%',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Enabled Settings',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          '$enabledCount / $totalCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: privacyScore / 100,
                      backgroundColor: const Color(0xFF4C1D95),
                      valueColor: AlwaysStoppedAnimation(scoreColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getPrivacyRecommendation(privacyScore),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                for (String key in _settingsInfo.keys) {
                  _settings[key] = _getDefaultValue(key);
                }
              });
              widget.onSettingsChanged(_settings);
            },
            icon: const Icon(Icons.security, size: 18),
            label: const Text('Apply Recommended Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    for (String key in _settings.keys) {
                      _settings[key] = false;
                    }
                  });
                  widget.onSettingsChanged(_settings);
                },
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Disable All'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    for (String key in _settings.keys) {
                      _settings[key] = true;
                    }
                  });
                  widget.onSettingsChanged(_settings);
                },
                icon: const Icon(Icons.select_all, size: 16),
                label: const Text('Enable All'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: const BorderSide(color: Color(0xFF10B981)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person_off':
        return Icons.person_off;
      case 'info':
        return Icons.info;
      case 'medical_services':
        return Icons.medical_services;
      case 'filter_alt':
        return Icons.filter_alt;
      case 'lock':
        return Icons.lock;
      case 'history':
        return Icons.history;
      case 'verified_user':
        return Icons.verified_user;
      case 'minimize':
        return Icons.minimize;
      default:
        return Icons.settings;
    }
  }

  String _getPrivacyRecommendation(double score) {
    if (score >= 80) {
      return 'Excellent privacy protection. Your data exports will be highly secure.';
    } else if (score >= 60) {
      return 'Good privacy protection. Consider enabling additional security features.';
    } else if (score >= 40) {
      return 'Basic privacy protection. We recommend enabling more security settings.';
    } else {
      return 'Limited privacy protection. Please review and enable essential security features.';
    }
  }
}
