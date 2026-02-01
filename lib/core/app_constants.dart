/// Lucidlog - AI Dream Journal
/// App constants and branding configuration

class AppConstants {
  AppConstants._();

  // ============================================================
  // BRANDING
  // ============================================================

  static const String appName = 'Lucidlog';
  static const String appSubtitle = 'AI Dream Journal';
  static const String appTagline = 'REMember your nights, decode your days.';
  static const String appDescription =
      'Your intelligent dream companion that helps you capture, understand, and explore your dreams.';

  // ============================================================
  // FEATURE LABELS
  // ============================================================

  static const String featureVoiceCapture = 'Voice Capture';
  static const String featureAIAnalysis = 'AI Analysis';
  static const String featureDreamTimeline = 'Dream Timeline';
  static const String featureInsights = 'Dream Insights';
  static const String featureSleepTracking = 'Sleep Tracking';
  static const String featureMoodTracking = 'Mood Tracking';

  // ============================================================
  // STATS LABELS
  // ============================================================

  static const String statRestedScore = 'Rested';
  static const String statRecallVividness = 'Recall Vividness';
  static const String statLoggingStreak = 'Logging Streak';
  static const String statWakeUpMood = 'Wake-up Mood';
  static const String statTotalDreams = 'Total Dreams';
  static const String statLucidDreams = 'Lucid Dreams';
  static const String statAverageClarity = 'Avg. Clarity';

  // ============================================================
  // SECTION TITLES
  // ============================================================

  static const String sectionRecentDreams = 'Recent Dreams';
  static const String sectionDreamTimeline = 'Dream Timeline';
  static const String sectionQuickCapture = 'Quick Capture';
  static const String sectionInsights = 'Insights';
  static const String sectionYourDreams = 'Your Dreams';
  static const String sectionToday = 'Today';
  static const String sectionThisWeek = 'This Week';
  static const String sectionThisMonth = 'This Month';

  // ============================================================
  // BUTTON LABELS
  // ============================================================

  static const String buttonRecordDream = 'Record Dream';
  static const String buttonWriteDream = 'Write Dream';
  static const String buttonStartRecording = 'Start Recording';
  static const String buttonStopRecording = 'Stop Recording';
  static const String buttonAICleanup = 'AI Cleanup';
  static const String buttonSave = 'Save';
  static const String buttonCancel = 'Cancel';
  static const String buttonDelete = 'Delete';
  static const String buttonEdit = 'Edit';
  static const String buttonShare = 'Share';
  static const String buttonExport = 'Export';
  static const String buttonViewAll = 'View All';
  static const String buttonSetReminder = 'Set Reminder';

  // ============================================================
  // PLACEHOLDER TEXT
  // ============================================================

  static const String placeholderDreamContent =
      'Describe your dream... What did you see, feel, or experience?';
  static const String placeholderDreamTitle = 'Give your dream a title';
  static const String placeholderSearch = 'Search dreams...';
  static const String placeholderVoicePrompt =
      'Tap to start recording your dream...';

  // ============================================================
  // EMPTY STATES
  // ============================================================

  static const String emptyDreamsTitle = 'No Dreams Yet';
  static const String emptyDreamsMessage =
      'Start your journey by recording your first dream. Tap the microphone to capture your dream using voice.';
  static const String emptySearchTitle = 'No Results';
  static const String emptySearchMessage =
      'Try adjusting your search or filters to find what you\'re looking for.';

  // ============================================================
  // GREETINGS
  // ============================================================

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  static String getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '☀️';
    } else if (hour < 17) {
      return '🌤️';
    } else if (hour < 21) {
      return '🌅';
    } else {
      return '🌙';
    }
  }

  // ============================================================
  // MOOD OPTIONS
  // ============================================================

  static const List<Map<String, dynamic>> moodOptions = [
    {'label': 'Energized', 'emoji': '⚡', 'value': 'energized'},
    {'label': 'Calm', 'emoji': '😌', 'value': 'calm'},
    {'label': 'Happy', 'emoji': '😊', 'value': 'happy'},
    {'label': 'Neutral', 'emoji': '😐', 'value': 'neutral'},
    {'label': 'Tired', 'emoji': '😴', 'value': 'tired'},
    {'label': 'Anxious', 'emoji': '😰', 'value': 'anxious'},
    {'label': 'Confused', 'emoji': '🤔', 'value': 'confused'},
    {'label': 'Inspired', 'emoji': '✨', 'value': 'inspired'},
  ];

  // ============================================================
  // ENERGY LEVELS
  // ============================================================

  static const List<Map<String, dynamic>> energyLevels = [
    {'label': 'Very Low', 'value': 1, 'icon': '🔋'},
    {'label': 'Low', 'value': 2, 'icon': '🔋'},
    {'label': 'Medium', 'value': 3, 'icon': '🔋'},
    {'label': 'High', 'value': 4, 'icon': '🔋'},
    {'label': 'Very High', 'value': 5, 'icon': '⚡'},
  ];

  // ============================================================
  // SLEEP QUALITY OPTIONS
  // ============================================================

  static const List<Map<String, dynamic>> sleepQualityOptions = [
    {'label': 'Terrible', 'value': 'terrible', 'score': 1},
    {'label': 'Poor', 'value': 'poor', 'score': 2},
    {'label': 'Fair', 'value': 'fair', 'score': 3},
    {'label': 'Good', 'value': 'good', 'score': 4},
    {'label': 'Excellent', 'value': 'excellent', 'score': 5},
  ];

  // ============================================================
  // DREAM CATEGORIES
  // ============================================================

  static const List<Map<String, dynamic>> dreamCategories = [
    {'label': 'Normal', 'value': 'normal', 'icon': '💭'},
    {'label': 'Lucid', 'value': 'lucid', 'icon': '✨'},
    {'label': 'Nightmare', 'value': 'nightmare', 'icon': '👻'},
    {'label': 'Recurring', 'value': 'recurring', 'icon': '🔄'},
    {'label': 'Prophetic', 'value': 'prophetic', 'icon': '🔮'},
  ];

  // ============================================================
  // TIME RANGES FOR INSIGHTS
  // ============================================================

  static const List<Map<String, dynamic>> timeRanges = [
    {'label': '7 Days', 'value': 7},
    {'label': '30 Days', 'value': 30},
    {'label': '90 Days', 'value': 90},
    {'label': 'All Time', 'value': 0},
  ];

  // ============================================================
  // API & LIMITS
  // ============================================================

  static const int maxDreamTitleLength = 100;
  static const int maxDreamContentLength = 10000;
  static const int maxTagsPerDream = 10;
  static const int maxRecordingDurationSeconds = 300; // 5 minutes
  static const int cacheExpirationMinutes = 15;
  static const int offlineCacheExpirationHours = 24;

  // ============================================================
  // ANIMATION DURATIONS
  // ============================================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}
