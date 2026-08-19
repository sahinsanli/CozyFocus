// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cozy Focus Room';

  @override
  String get settings => 'Settings';

  @override
  String get openProfile => 'Open profile';

  @override
  String get focus => 'Focus';

  @override
  String get room => 'Room';

  @override
  String get stats => 'Stats';

  @override
  String get sounds => 'Sounds';

  @override
  String get newBadge => 'NEW BADGE';

  @override
  String get lovely => 'Lovely!';

  @override
  String get splashTagline => 'Your peaceful space to grow.';

  @override
  String get tapToBegin => 'TAP TO BEGIN';

  @override
  String get onboardingFocusTitle => 'Find Your Focus';

  @override
  String get onboardingFocusBody =>
      'Create a dedicated space for deep work and mindfulness. Choose your time and let the world fade away.';

  @override
  String get onboardingProgressTitle => 'Watch Your Progress Grow';

  @override
  String get onboardingProgressBody =>
      'Every focused minute helps you unlock new decorations for your room. Build your perfect sanctuary as you reach your goals.';

  @override
  String get onboardingSanctuaryTitle => 'Your Personal Sanctuary';

  @override
  String get onboardingSanctuaryBody =>
      'Make it yours. Customize your room with plants, furniture, and calming sounds. Ready to start your journey?';

  @override
  String get onboardingRhythmTitle => 'Set Your Focus Rhythm';

  @override
  String get onboardingRhythmBody =>
      'Choose a pace that feels calm and realistic. You can change these anytime in Settings.';

  @override
  String get onboardingDailyGoalHint =>
      'How much focused time would feel meaningful each day?';

  @override
  String get onboardingFocusDurationHint =>
      'Choose the length of a typical focus session.';

  @override
  String get onboardingBreakDurationHint =>
      'Leave a little space to pause and recharge.';

  @override
  String chooseSetting(Object setting) {
    return 'Choose $setting';
  }

  @override
  String selectedSettingSemantics(Object duration, Object setting) {
    return '$setting: $duration. Tap to change.';
  }

  @override
  String get saveAndStart => 'Save & Start';

  @override
  String get onboardingSaveFailed =>
      'Your preferences could not be saved. Try again.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get name => 'Name';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get chooseProfilePicture => 'Choose your profile picture';

  @override
  String get chooseProfilePictureBody =>
      'Pick a cozy symbol for your sanctuary.';

  @override
  String get tapPictureToChange => 'Tap your picture to change it';

  @override
  String get zenMaster => '🌱  Zen Master';

  @override
  String get focusHours => 'Focus Hours';

  @override
  String get dayStreak => 'Day Streak';

  @override
  String get decorations => 'Decorations';

  @override
  String get earnedBadges => 'Earned Badges';

  @override
  String get yourJourney => 'Your Journey';

  @override
  String get journeySubtitle =>
      'Take a moment to reflect on your progress.\nEvery focused minute builds a calmer you.';

  @override
  String get focusSummary => 'Focus Summary';

  @override
  String get today => 'TODAY';

  @override
  String get weekly => 'WEEKLY';

  @override
  String get allTime => 'ALL TIME';

  @override
  String get dailyGoalComplete => 'Daily goal complete';

  @override
  String minutesToGoal(Object minutes) {
    return '$minutes min to your goal';
  }

  @override
  String get currentRhythm => 'Your current rhythm';

  @override
  String get journeyStartsHere => 'Your journey starts here';

  @override
  String get growingPractice => 'A growing focus practice';

  @override
  String get dailyStreak => 'Daily Streak';

  @override
  String get daysInARow => 'DAYS IN A ROW';

  @override
  String get weekRhythm => 'This Week’s Rhythm';

  @override
  String get milestones => 'Milestones';

  @override
  String get sanctuaryKeeper => 'Sanctuary Keeper';

  @override
  String get readyToClaim => 'Ready to claim';

  @override
  String get everyRewardUnlocked => 'Every room reward is unlocked.';

  @override
  String get claimFinishedItem =>
      'Claim the finished item to add it to your inventory.';

  @override
  String focusedMinutesToFinish(Object minutes) {
    return '$minutes focused minutes to finish';
  }

  @override
  String get upcomingUnlocks => 'UPCOMING UNLOCKS';

  @override
  String get allDecorationsUnlocked => 'All decorations unlocked';

  @override
  String focusedMinutesRequired(Object minutes) {
    return '$minutes focused minutes required';
  }

  @override
  String get roomDecoration => 'Room Decoration';

  @override
  String get buildSanctuary => 'Build your sanctuary, one focus at a time.';

  @override
  String get autoSaved => 'Auto-saved';

  @override
  String get inventory => 'Inventory';

  @override
  String availableCount(Object available, Object total) {
    return '$available/$total available';
  }

  @override
  String get inventoryHint =>
      'Tap an available item to place it in its designed home or store it.';

  @override
  String get gentleGoalCollection => 'Gentle Goal Collection';

  @override
  String get gentleGoalCollectionHint =>
      'Complete the daily goal to open a non-repeating decor box. Tap an owned piece to place or store it.';

  @override
  String get mystery => 'Mystery';

  @override
  String get inRoom => 'In room';

  @override
  String get stored => 'Stored';

  @override
  String needsItem(Object item) {
    return 'Needs $item';
  }

  @override
  String get crafting => 'Crafting';

  @override
  String get claim => 'Claim';

  @override
  String get ownedTapToPlace => 'Owned • tap to place';

  @override
  String get placedTapToStore => 'Placed • tap to store';

  @override
  String get waitingClaimQueue => 'Waiting in claim queue';

  @override
  String get inProgress => 'In progress';

  @override
  String switchDecoration(Object item, Object state) {
    return '$item, tap to switch $state';
  }

  @override
  String get on => 'on';

  @override
  String get off => 'off';

  @override
  String get testFocusComplete => 'Test focus complete!';

  @override
  String get beautifulWork => 'Beautiful work!';

  @override
  String get timeToBreathe => 'Time to breathe';

  @override
  String get readyToFocus => 'Ready to focus?';

  @override
  String get testProgressRules =>
      'Fast-forwarded time used the real progression rules.';

  @override
  String get sanctuaryGrew => 'Your sanctuary grew a little calmer.';

  @override
  String get focusSafe => 'Your focus is safe. Take a gentle pause.';

  @override
  String get settleIn => 'Settle in and give one thing your full attention.';

  @override
  String get completeFocusNow => 'Complete focus now';

  @override
  String get endBreak => 'End break';

  @override
  String get resetTimer => 'Reset timer';

  @override
  String takeBreak(Object minutes) {
    return 'Take a $minutes min break';
  }

  @override
  String get gentleReminder =>
      'A gentle reminder: one small focus session is enough to begin.';

  @override
  String get todaysGentleGoal => 'Today’s gentle goal';

  @override
  String durationOf(Object current, Object goal) {
    return '$current of $goal';
  }

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get startFocus => 'Start focus';

  @override
  String get keepProgressSafe => 'Keep your progress safe';

  @override
  String get guestProgressPrompt =>
      'Guest progress stays on this device. Sign in to keep your focus history, rewards, and room after a reinstall or device change.';

  @override
  String get protectMyProgress => 'Protect my progress';

  @override
  String get openAccountSettings => 'Open account settings';

  @override
  String get collectionComplete => 'Your sanctuary collection is complete';

  @override
  String craftingItem(Object item) {
    return 'Crafting $item';
  }

  @override
  String craftStage(Object current, Object required, Object stage) {
    return '$current / $required focused minutes • stage $stage/5';
  }

  @override
  String focusTimerSemantics(Object time) {
    return 'Focus timer $time';
  }

  @override
  String percentComplete(Object percent) {
    return '$percent percent complete';
  }

  @override
  String get testPreview => 'TEST PREVIEW';

  @override
  String get breakPaused => 'BREAK PAUSED';

  @override
  String get shortBreak => 'SHORT BREAK';

  @override
  String get focusing => 'FOCUSING';

  @override
  String get paused => 'PAUSED';

  @override
  String get focusSession => 'FOCUS SESSION';

  @override
  String get testMode => 'Test Mode';

  @override
  String minutesPreviewed(Object elapsed, Object total) {
    return '$elapsed of $total minutes previewed';
  }

  @override
  String get testModeBody =>
      'Fast-forward focus time while keeping the real production, claim, badge, and inventory rules.';

  @override
  String advanceMinutes(Object minutes) {
    return 'Advance $minutes min';
  }

  @override
  String get testSessionsSaved =>
      'Completed test sessions are saved exactly like normal focus sessions.';

  @override
  String get testSessionComplete => 'Test session complete';

  @override
  String get sessionComplete => 'Session complete';

  @override
  String focusMinutesReward(Object minutes) {
    return '+$minutes focus minutes';
  }

  @override
  String get minutesSaved =>
      'Your focus minutes were saved. Keep going to finish the current item.';

  @override
  String itemReadyToClaim(Object item) {
    return '$item is ready to claim.';
  }

  @override
  String itemFromGoal(Object item) {
    return '$item came from today’s gentle goal.';
  }

  @override
  String get claimAndPlace => 'Claim & Place';

  @override
  String get claimForLater => 'Claim for later';

  @override
  String moreRewardsWaiting(Object count) {
    return '$count more rewards waiting';
  }

  @override
  String get oneMoreRewardWaiting => '1 more reward waiting';

  @override
  String get continueBreak => 'Continue break';

  @override
  String get beginAnotherSession => 'Begin another session';

  @override
  String get ambientSounds => 'Ambient\nSounds';

  @override
  String get soundsSubtitle => 'Mix your perfect background noise.';

  @override
  String soundComingSoon(Object sound) {
    return '$sound is coming soon.';
  }

  @override
  String get chooseSounds => 'Choose sounds to create a mix.';

  @override
  String activeSounds(Object count) {
    return '$count sounds are in your active mix.';
  }

  @override
  String activeMix(Object count) {
    return 'Active Mix ($count)';
  }

  @override
  String get stopAll => 'Stop All';

  @override
  String get sleepTimer => 'Sleep Timer';

  @override
  String cancelTimer(Object time) {
    return 'Cancel timer • $time';
  }

  @override
  String get playBeforeTimer =>
      'Play at least one sound before starting the sleep timer.';

  @override
  String get startSleepTimer => 'Start sleep timer';

  @override
  String get sleepTimerComplete => 'Sleep timer complete — all sounds stopped.';

  @override
  String get soundsInfo =>
      'Rain, campfire, forest, and piano are ready to mix. More ambience loops are coming soon.';

  @override
  String playSound(Object sound) {
    return 'Play $sound';
  }

  @override
  String pauseSound(Object sound) {
    return 'Pause $sound';
  }

  @override
  String get comingSoon => 'COMING SOON';

  @override
  String percent(Object percent) {
    return '$percent percent';
  }

  @override
  String get settingsSubtitle => 'Customize your cozy experience.';

  @override
  String get appSettings => 'APP SETTINGS';

  @override
  String get focusReminders => 'Focus Reminders';

  @override
  String get focusRemindersBody => 'Show a gentle nudge on the Focus screen';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get dailyGoalBody => 'Set your focus target';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceBody => 'Light or Dark mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageBody => 'Choose the app language';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';

  @override
  String get focusOptions => 'FOCUS OPTIONS';

  @override
  String get defaultFocusDuration => 'Default Focus Duration';

  @override
  String get defaultFocusDurationBody => 'Used for new focus sessions';

  @override
  String get shortBreakDuration => 'Short Break Duration';

  @override
  String get shortBreakDurationBody => 'Time to gently recharge';

  @override
  String get autoStartBreaks => 'Auto-start Breaks';

  @override
  String autoStartBreaksBody(Object minutes) {
    return 'Start a $minutes min break after focus ends';
  }

  @override
  String get testModeSettingsBody => 'Preview timers, rewards, and unlocks';

  @override
  String get accountAndSync => 'ACCOUNT & SYNC';

  @override
  String get supportSection => 'SUPPORT';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get helpCenterBody =>
      'Cozy Focus works offline and securely syncs your progress when you connect a Google or email account.';

  @override
  String get aboutCozyFocus => 'About Cozy Focus';

  @override
  String get aboutBody =>
      'Cozy Focus • Version 1.0.0\nA calm, local-first productivity sanctuary.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get accountDeletionInfo => 'Account deletion information';

  @override
  String get support => 'Support';

  @override
  String get accountSyncTitle => 'Account & Sync';

  @override
  String get sanctuaryProtected => 'Your sanctuary is protected';

  @override
  String get accountKeepProgress => 'Keep your progress safe';

  @override
  String get syncProtectedBody =>
      'Your focus history, rewards, inventory, and room are synced with your account.';

  @override
  String get guestSyncBody =>
      'Guest progress stays on this device. Connect Google or create an email account so it survives a reinstall or device change.';

  @override
  String get storedOnDevice => 'Stored safely on this device';

  @override
  String get syncing => 'Syncing your sanctuary…';

  @override
  String get cloudSyncActive => 'Cloud sync is active';

  @override
  String syncedAt(Object time) {
    return 'Synced at $time';
  }

  @override
  String get offlineSyncLater => 'Offline — changes will sync later';

  @override
  String get guestAccount => 'Guest account';

  @override
  String get cozyAccount => 'Cozy account';

  @override
  String get syncNow => 'Sync now';

  @override
  String get accountUnavailable =>
      'Account services are temporarily unavailable. Your progress remains on this device.';

  @override
  String get googleLinked => 'Your progress is now linked to Google.';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get createEmailAccount => 'Create email account';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get signedOut => 'Signed out. A new guest space is ready.';

  @override
  String get logOut => 'Log out';

  @override
  String get deleteAccountData => 'Delete account and data';

  @override
  String get createAccount => 'Create account';

  @override
  String get emailSignIn => 'Email sign in';

  @override
  String get email => 'Email';

  @override
  String get invalidEmail => 'Enter a valid email.';

  @override
  String get password => 'Password';

  @override
  String get passwordSixChars => 'Use at least 6 characters.';

  @override
  String get resetEmailSent => 'Password reset email sent.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get create => 'Create';

  @override
  String get signIn => 'Sign in';

  @override
  String get accountCreated => 'Account created. Your progress is syncing.';

  @override
  String get welcomeBack => 'Welcome back. Your progress has been merged.';

  @override
  String get deleteAccountQuestion => 'Delete account?';

  @override
  String get deleteAccountWarning =>
      'This permanently deletes your cloud progress and account. This cannot be undone.';

  @override
  String get confirmPassword => 'Confirm your password';

  @override
  String get enterPassword => 'Enter your password.';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get accountDeleted => 'Your account and cloud data were deleted.';

  @override
  String get accountActionFailed => 'The account action failed.';

  @override
  String get authInvalidCredentials => 'The email or password is incorrect.';

  @override
  String get authEmailInUse => 'An account already uses this email address.';

  @override
  String get authWeakPassword =>
      'Choose a stronger password with at least 6 characters.';

  @override
  String get authTooManyRequests =>
      'Too many attempts. Please wait and try again.';

  @override
  String get authNetwork => 'Check your connection and try again.';

  @override
  String get audioPlaybackFailed => 'This sound could not be played.';

  @override
  String get audioVolumeFailed => 'The sound volume could not be changed.';

  @override
  String minutesShort(Object minutes) {
    return '$minutes min';
  }

  @override
  String hoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String hoursMinutes(Object hours, Object minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get weekdayInitials => 'M,T,W,T,F,S,S';

  @override
  String get itemDesk => 'Study Desk';

  @override
  String get itemChair => 'Study Chair';

  @override
  String get itemRug => 'Botanical Rug';

  @override
  String get itemBookshelf => 'Bookshelf';

  @override
  String get itemCandle => 'Moon Candle';

  @override
  String get itemWallArt => 'Botanical Print';

  @override
  String get itemHangingPlant => 'Hanging Plant';

  @override
  String get itemSleepingCat => 'Sleeping Cat';

  @override
  String get itemTeaCup => 'Moon Tea';

  @override
  String get itemNightFern => 'Night Fern';

  @override
  String get itemOwlFigure => 'Owl Figure';

  @override
  String get itemLeafLantern => 'Leaf Lantern';

  @override
  String get categoryFurniture => 'Furniture';

  @override
  String get categoryFloorDecor => 'Floor decor';

  @override
  String get categoryLighting => 'Lighting';

  @override
  String get categoryWallDecor => 'Wall decor';

  @override
  String get categoryCeilingDecor => 'Ceiling decor';

  @override
  String get categoryCompanion => 'Companion';

  @override
  String get categoryKeepsake => 'Keepsake';

  @override
  String get avatarMoonleaf => 'Moonleaf';

  @override
  String get avatarCat => 'Sleepy Cat';

  @override
  String get avatarMoon => 'Crescent Moon';

  @override
  String get avatarLamp => 'Cozy Lamp';

  @override
  String get avatarForest => 'Night Forest';

  @override
  String get avatarTea => 'Moon Tea';

  @override
  String get badgeFirstFocusName => 'First Bloom';

  @override
  String get badgeFirstFocusDescription => 'Complete your first focus session.';

  @override
  String get badgeFirstClaimName => 'Room Maker';

  @override
  String get badgeFirstClaimDescription =>
      'Claim your first crafted room item.';

  @override
  String get badgeFirstDailyGoalName => 'Gentle Keeper';

  @override
  String get badgeFirstDailyGoalDescription =>
      'Complete your first daily focus goal.';

  @override
  String get badgeSoundWeaverName => 'Sound Weaver';

  @override
  String get badgeSoundWeaverDescription => 'Play two ambient sounds together.';

  @override
  String get badgeNightOwlName => 'Night Owl';

  @override
  String get badgeNightOwlDescription => 'Reach 120 total focus minutes.';

  @override
  String get badgeDeepWoodsName => 'Deep Woods';

  @override
  String get badgeDeepWoodsDescription => 'Reach 300 total focus minutes.';

  @override
  String get badgeZenKeeperName => 'Zen Keeper';

  @override
  String get badgeZenKeeperDescription => 'Reach 600 total focus minutes.';

  @override
  String get focusRitual => 'Focus Ritual';

  @override
  String get manageRituals => 'Manage rituals';

  @override
  String get defaultFocus => 'Default Focus';

  @override
  String get defaultFocusDescription =>
      'Uses your Focus and Break settings with the current mixer.';

  @override
  String get ritualStudy => 'Study';

  @override
  String get ritualReading => 'Reading';

  @override
  String get ritualDeepFocus => 'Deep Focus';

  @override
  String ritualTimeSummary(Object breakDuration, Object focusDuration) {
    return '$focusDuration focus · $breakDuration break';
  }

  @override
  String get ritualLocked =>
      'Rituals can be changed when the focus timer is idle.';

  @override
  String get newRitual => 'New ritual';

  @override
  String get editRitual => 'Edit ritual';

  @override
  String get createRitual => 'Create ritual';

  @override
  String get deleteRitual => 'Delete ritual';

  @override
  String deleteRitualQuestion(Object name) {
    return 'Delete $name?';
  }

  @override
  String get deleteRitualBody =>
      'This ritual will be removed from your synced collection.';

  @override
  String get maxFiveRituals => 'You can keep up to five rituals.';

  @override
  String get ritualName => 'Ritual name';

  @override
  String get focusDuration => 'Focus duration';

  @override
  String get breakDuration => 'Break duration';

  @override
  String get ambienceMix => 'Ambience mix';

  @override
  String get chooseUpToTwoSounds =>
      'Choose up to two sounds. They begin only when focus starts.';

  @override
  String get silentRitual => 'Silent ritual';

  @override
  String get saveRitual => 'Save ritual';

  @override
  String get ritualNameRequired => 'Enter a ritual name.';

  @override
  String get ritualNameTooLong => 'Use 30 characters or fewer.';

  @override
  String get maxTwoSounds => 'A ritual can use up to two sounds.';

  @override
  String soundVolume(Object percent, Object sound) {
    return '$sound · $percent%';
  }

  @override
  String ritualAudioWarning(Object sounds) {
    return 'Focus started, but these sounds could not play: $sounds';
  }

  @override
  String get selected => 'Selected';
}
