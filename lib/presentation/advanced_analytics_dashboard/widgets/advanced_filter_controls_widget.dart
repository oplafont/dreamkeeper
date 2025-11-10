import 'package:flutter/material.dart';

class AdvancedFilterControlsWidget extends StatefulWidget {
  final String selectedTimeRange;
  final List<String> selectedEmotions;
  final String selectedSleepQuality;
  final List<String> selectedTags;
  final Function(String) onTimeRangeChanged;
  final Function(List<String>) onEmotionsChanged;
  final Function(String) onSleepQualityChanged;
  final Function(List<String>) onTagsChanged;

  const AdvancedFilterControlsWidget({
    super.key,
    required this.selectedTimeRange,
    required this.selectedEmotions,
    required this.selectedSleepQuality,
    required this.selectedTags,
    required this.onTimeRangeChanged,
    required this.onEmotionsChanged,
    required this.onSleepQualityChanged,
    required this.onTagsChanged,
  });

  @override
  State<AdvancedFilterControlsWidget> createState() =>
      _AdvancedFilterControlsWidgetState();
}

class _AdvancedFilterControlsWidgetState
    extends State<AdvancedFilterControlsWidget> {
  final List<String> _timeRanges = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
    'All Time',
  ];

  final List<String> _emotions = [
    'Joy',
    'Sadness',
    'Anger',
    'Fear',
    'Surprise',
    'Disgust',
    'Love',
    'Excitement',
    'Anxiety',
    'Peace',
  ];

  final List<String> _sleepQualities = [
    'All',
    'Excellent',
    'Good',
    'Fair',
    'Poor',
  ];

  final List<String> _availableTags = [
    'Lucid',
    'Nightmare',
    'Flying',
    'Water',
    'Animals',
    'People',
    'Adventure',
    'Romance',
    'Work',
    'Family',
    'Travel',
    'Fantasy',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Advanced Filters',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Time Range Filter
                _buildFilterSection(
                  'Time Range',
                  _buildTimeRangeChip(),
                ),
                const SizedBox(width: 16),

                // Emotions Filter
                _buildFilterSection(
                  'Emotions',
                  _buildEmotionsChips(),
                ),
                const SizedBox(width: 16),

                // Sleep Quality Filter
                _buildFilterSection(
                  'Sleep Quality',
                  _buildSleepQualityChip(),
                ),
                const SizedBox(width: 16),

                // Tags Filter
                _buildFilterSection(
                  'Tags',
                  _buildTagsChips(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        content,
      ],
    );
  }

  Widget _buildTimeRangeChip() {
    return PopupMenuButton<String>(
      onSelected: widget.onTimeRangeChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.purple.withAlpha(51),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.withAlpha(128)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.selectedTimeRange,
              style: const TextStyle(color: Colors.purple, fontSize: 12),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.purple, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => _timeRanges.map((range) {
        return PopupMenuItem<String>(
          value: range,
          child: Text(range),
        );
      }).toList(),
    );
  }

  Widget _buildEmotionsChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _emotions.take(4).map((emotion) {
        final isSelected = widget.selectedEmotions.contains(emotion);
        return GestureDetector(
          onTap: () => _toggleEmotion(emotion),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withAlpha(77)
                  : Colors.grey.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.withAlpha(77),
              ),
            ),
            child: Text(
              emotion,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white70,
                fontSize: 10,
              ),
            ),
          ),
        );
      }).toList()
        ..add(
          GestureDetector(
            onTap: _showAllEmotionsDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withAlpha(77)),
              ),
              child: const Text(
                '+More',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildSleepQualityChip() {
    return PopupMenuButton<String>(
      onSelected: widget.onSleepQualityChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(51),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withAlpha(128)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.selectedSleepQuality,
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.green, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => _sleepQualities.map((quality) {
        return PopupMenuItem<String>(
          value: quality,
          child: Text(quality),
        );
      }).toList(),
    );
  }

  Widget _buildTagsChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _availableTags.take(3).map((tag) {
        final isSelected = widget.selectedTags.contains(tag);
        return GestureDetector(
          onTap: () => _toggleTag(tag),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.orange.withAlpha(77)
                  : Colors.grey.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.grey.withAlpha(77),
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: isSelected ? Colors.orange : Colors.white70,
                fontSize: 10,
              ),
            ),
          ),
        );
      }).toList()
        ..add(
          GestureDetector(
            onTap: _showAllTagsDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withAlpha(77)),
              ),
              child: const Text(
                '+More',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
        ),
    );
  }

  void _toggleEmotion(String emotion) {
    final newEmotions = List<String>.from(widget.selectedEmotions);
    if (newEmotions.contains(emotion)) {
      newEmotions.remove(emotion);
    } else {
      newEmotions.add(emotion);
    }
    widget.onEmotionsChanged(newEmotions);
  }

  void _toggleTag(String tag) {
    final newTags = List<String>.from(widget.selectedTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    widget.onTagsChanged(newTags);
  }

  void _clearAllFilters() {
    widget.onTimeRangeChanged('Last 30 Days');
    widget.onEmotionsChanged([]);
    widget.onSleepQualityChanged('All');
    widget.onTagsChanged([]);
  }

  void _showAllEmotionsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Emotions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emotions.map((emotion) {
                  final isSelected = widget.selectedEmotions.contains(emotion);
                  return GestureDetector(
                    onTap: () => _toggleEmotion(emotion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withAlpha(77)
                            : Colors.grey.withAlpha(51),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.withAlpha(77),
                        ),
                      ),
                      child: Text(
                        emotion,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllTagsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Tags',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = widget.selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => _toggleTag(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orange.withAlpha(77)
                            : Colors.grey.withAlpha(51),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.orange
                              : Colors.grey.withAlpha(77),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Colors.orange : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
