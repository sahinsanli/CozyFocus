import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cozy Focus Room'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @openProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfile;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @sounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get sounds;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW BADGE'**
  String get newBadge;

  /// No description provided for @lovely.
  ///
  /// In en, this message translates to:
  /// **'Lovely!'**
  String get lovely;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your peaceful space to grow.'**
  String get splashTagline;

  /// No description provided for @tapToBegin.
  ///
  /// In en, this message translates to:
  /// **'TAP TO BEGIN'**
  String get tapToBegin;

  /// No description provided for @onboardingFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Your Focus'**
  String get onboardingFocusTitle;

  /// No description provided for @onboardingFocusBody.
  ///
  /// In en, this message translates to:
  /// **'Create a dedicated space for deep work and mindfulness. Choose your time and let the world fade away.'**
  String get onboardingFocusBody;

  /// No description provided for @onboardingProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch Your Progress Grow'**
  String get onboardingProgressTitle;

  /// No description provided for @onboardingProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Every focused minute helps you unlock new decorations for your room. Build your perfect sanctuary as you reach your goals.'**
  String get onboardingProgressBody;

  /// No description provided for @onboardingSanctuaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Sanctuary'**
  String get onboardingSanctuaryTitle;

  /// No description provided for @onboardingSanctuaryBody.
  ///
  /// In en, this message translates to:
  /// **'Make it yours. Customize your room with plants, furniture, and calming sounds. Ready to start your journey?'**
  String get onboardingSanctuaryBody;

  /// No description provided for @onboardingRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Focus Rhythm'**
  String get onboardingRhythmTitle;

  /// No description provided for @onboardingRhythmBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a pace that feels calm and realistic. You can change these anytime in Settings.'**
  String get onboardingRhythmBody;

  /// No description provided for @onboardingDailyGoalHint.
  ///
  /// In en, this message translates to:
  /// **'How much focused time would feel meaningful each day?'**
  String get onboardingDailyGoalHint;

  /// No description provided for @onboardingFocusDurationHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the length of a typical focus session.'**
  String get onboardingFocusDurationHint;

  /// No description provided for @onboardingBreakDurationHint.
  ///
  /// In en, this message translates to:
  /// **'Leave a little space to pause and recharge.'**
  String get onboardingBreakDurationHint;

  /// No description provided for @chooseSetting.
  ///
  /// In en, this message translates to:
  /// **'Choose {setting}'**
  String chooseSetting(Object setting);

  /// No description provided for @selectedSettingSemantics.
  ///
  /// In en, this message translates to:
  /// **'{setting}: {duration}. Tap to change.'**
  String selectedSettingSemantics(Object duration, Object setting);

  /// No description provided for @saveAndStart.
  ///
  /// In en, this message translates to:
  /// **'Save & Start'**
  String get saveAndStart;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Your preferences could not be saved. Try again.'**
  String get onboardingSaveFailed;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @chooseProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Choose your profile picture'**
  String get chooseProfilePicture;

  /// No description provided for @chooseProfilePictureBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a cozy symbol for your sanctuary.'**
  String get chooseProfilePictureBody;

  /// No description provided for @tapPictureToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap your picture to change it'**
  String get tapPictureToChange;

  /// No description provided for @zenMaster.
  ///
  /// In en, this message translates to:
  /// **'🌱  Zen Master'**
  String get zenMaster;

  /// No description provided for @focusHours.
  ///
  /// In en, this message translates to:
  /// **'Focus Hours'**
  String get focusHours;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @decorations.
  ///
  /// In en, this message translates to:
  /// **'Decorations'**
  String get decorations;

  /// No description provided for @earnedBadges.
  ///
  /// In en, this message translates to:
  /// **'Earned Badges'**
  String get earnedBadges;

  /// No description provided for @yourJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Journey'**
  String get yourJourney;

  /// No description provided for @journeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to reflect on your progress.\nEvery focused minute builds a calmer you.'**
  String get journeySubtitle;

  /// No description provided for @focusSummary.
  ///
  /// In en, this message translates to:
  /// **'Focus Summary'**
  String get focusSummary;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY'**
  String get weekly;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'ALL TIME'**
  String get allTime;

  /// No description provided for @dailyGoalComplete.
  ///
  /// In en, this message translates to:
  /// **'Daily goal complete'**
  String get dailyGoalComplete;

  /// No description provided for @minutesToGoal.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min to your goal'**
  String minutesToGoal(Object minutes);

  /// No description provided for @currentRhythm.
  ///
  /// In en, this message translates to:
  /// **'Your current rhythm'**
  String get currentRhythm;

  /// No description provided for @journeyStartsHere.
  ///
  /// In en, this message translates to:
  /// **'Your journey starts here'**
  String get journeyStartsHere;

  /// No description provided for @growingPractice.
  ///
  /// In en, this message translates to:
  /// **'A growing focus practice'**
  String get growingPractice;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get dailyStreak;

  /// No description provided for @daysInARow.
  ///
  /// In en, this message translates to:
  /// **'DAYS IN A ROW'**
  String get daysInARow;

  /// No description provided for @weekRhythm.
  ///
  /// In en, this message translates to:
  /// **'This Week’s Rhythm'**
  String get weekRhythm;

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// No description provided for @sanctuaryKeeper.
  ///
  /// In en, this message translates to:
  /// **'Sanctuary Keeper'**
  String get sanctuaryKeeper;

  /// No description provided for @readyToClaim.
  ///
  /// In en, this message translates to:
  /// **'Ready to claim'**
  String get readyToClaim;

  /// No description provided for @everyRewardUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Every room reward is unlocked.'**
  String get everyRewardUnlocked;

  /// No description provided for @claimFinishedItem.
  ///
  /// In en, this message translates to:
  /// **'Claim the finished item to add it to your inventory.'**
  String get claimFinishedItem;

  /// No description provided for @focusedMinutesToFinish.
  ///
  /// In en, this message translates to:
  /// **'{minutes} focused minutes to finish'**
  String focusedMinutesToFinish(Object minutes);

  /// No description provided for @upcomingUnlocks.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING UNLOCKS'**
  String get upcomingUnlocks;

  /// No description provided for @allDecorationsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'All decorations unlocked'**
  String get allDecorationsUnlocked;

  /// No description provided for @focusedMinutesRequired.
  ///
  /// In en, this message translates to:
  /// **'{minutes} focused minutes required'**
  String focusedMinutesRequired(Object minutes);

  /// No description provided for @roomDecoration.
  ///
  /// In en, this message translates to:
  /// **'Room Decoration'**
  String get roomDecoration;

  /// No description provided for @buildSanctuary.
  ///
  /// In en, this message translates to:
  /// **'Build your sanctuary, one focus at a time.'**
  String get buildSanctuary;

  /// No description provided for @autoSaved.
  ///
  /// In en, this message translates to:
  /// **'Auto-saved'**
  String get autoSaved;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @availableCount.
  ///
  /// In en, this message translates to:
  /// **'{available}/{total} available'**
  String availableCount(Object available, Object total);

  /// No description provided for @inventoryHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an available item to place it in its designed home or store it.'**
  String get inventoryHint;

  /// No description provided for @gentleGoalCollection.
  ///
  /// In en, this message translates to:
  /// **'Gentle Goal Collection'**
  String get gentleGoalCollection;

  /// No description provided for @gentleGoalCollectionHint.
  ///
  /// In en, this message translates to:
  /// **'Complete the daily goal to open a non-repeating decor box. Tap an owned piece to place or store it.'**
  String get gentleGoalCollectionHint;

  /// No description provided for @mystery.
  ///
  /// In en, this message translates to:
  /// **'Mystery'**
  String get mystery;

  /// No description provided for @inRoom.
  ///
  /// In en, this message translates to:
  /// **'In room'**
  String get inRoom;

  /// No description provided for @stored.
  ///
  /// In en, this message translates to:
  /// **'Stored'**
  String get stored;

  /// No description provided for @needsItem.
  ///
  /// In en, this message translates to:
  /// **'Needs {item}'**
  String needsItem(Object item);

  /// No description provided for @crafting.
  ///
  /// In en, this message translates to:
  /// **'Crafting'**
  String get crafting;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get claim;

  /// No description provided for @ownedTapToPlace.
  ///
  /// In en, this message translates to:
  /// **'Owned • tap to place'**
  String get ownedTapToPlace;

  /// No description provided for @placedTapToStore.
  ///
  /// In en, this message translates to:
  /// **'Placed • tap to store'**
  String get placedTapToStore;

  /// No description provided for @waitingClaimQueue.
  ///
  /// In en, this message translates to:
  /// **'Waiting in claim queue'**
  String get waitingClaimQueue;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @switchDecoration.
  ///
  /// In en, this message translates to:
  /// **'{item}, tap to switch {state}'**
  String switchDecoration(Object item, Object state);

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// No description provided for @testFocusComplete.
  ///
  /// In en, this message translates to:
  /// **'Test focus complete!'**
  String get testFocusComplete;

  /// No description provided for @beautifulWork.
  ///
  /// In en, this message translates to:
  /// **'Beautiful work!'**
  String get beautifulWork;

  /// No description provided for @timeToBreathe.
  ///
  /// In en, this message translates to:
  /// **'Time to breathe'**
  String get timeToBreathe;

  /// No description provided for @readyToFocus.
  ///
  /// In en, this message translates to:
  /// **'Ready to focus?'**
  String get readyToFocus;

  /// No description provided for @testProgressRules.
  ///
  /// In en, this message translates to:
  /// **'Fast-forwarded time used the real progression rules.'**
  String get testProgressRules;

  /// No description provided for @sanctuaryGrew.
  ///
  /// In en, this message translates to:
  /// **'Your sanctuary grew a little calmer.'**
  String get sanctuaryGrew;

  /// No description provided for @focusSafe.
  ///
  /// In en, this message translates to:
  /// **'Your focus is safe. Take a gentle pause.'**
  String get focusSafe;

  /// No description provided for @settleIn.
  ///
  /// In en, this message translates to:
  /// **'Settle in and give one thing your full attention.'**
  String get settleIn;

  /// No description provided for @completeFocusNow.
  ///
  /// In en, this message translates to:
  /// **'Complete focus now'**
  String get completeFocusNow;

  /// No description provided for @endBreak.
  ///
  /// In en, this message translates to:
  /// **'End break'**
  String get endBreak;

  /// No description provided for @resetTimer.
  ///
  /// In en, this message translates to:
  /// **'Reset timer'**
  String get resetTimer;

  /// No description provided for @takeBreak.
  ///
  /// In en, this message translates to:
  /// **'Take a {minutes} min break'**
  String takeBreak(Object minutes);

  /// No description provided for @gentleReminder.
  ///
  /// In en, this message translates to:
  /// **'A gentle reminder: one small focus session is enough to begin.'**
  String get gentleReminder;

  /// No description provided for @todaysGentleGoal.
  ///
  /// In en, this message translates to:
  /// **'Today’s gentle goal'**
  String get todaysGentleGoal;

  /// No description provided for @durationOf.
  ///
  /// In en, this message translates to:
  /// **'{current} of {goal}'**
  String durationOf(Object current, Object goal);

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @startFocus.
  ///
  /// In en, this message translates to:
  /// **'Start focus'**
  String get startFocus;

  /// No description provided for @keepProgressSafe.
  ///
  /// In en, this message translates to:
  /// **'Keep your progress safe'**
  String get keepProgressSafe;

  /// No description provided for @guestProgressPrompt.
  ///
  /// In en, this message translates to:
  /// **'Guest progress stays on this device. Sign in to keep your focus history, rewards, and room after a reinstall or device change.'**
  String get guestProgressPrompt;

  /// No description provided for @protectMyProgress.
  ///
  /// In en, this message translates to:
  /// **'Protect my progress'**
  String get protectMyProgress;

  /// No description provided for @openAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Open account settings'**
  String get openAccountSettings;

  /// No description provided for @collectionComplete.
  ///
  /// In en, this message translates to:
  /// **'Your sanctuary collection is complete'**
  String get collectionComplete;

  /// No description provided for @craftingItem.
  ///
  /// In en, this message translates to:
  /// **'Crafting {item}'**
  String craftingItem(Object item);

  /// No description provided for @craftStage.
  ///
  /// In en, this message translates to:
  /// **'{current} / {required} focused minutes • stage {stage}/5'**
  String craftStage(Object current, Object required, Object stage);

  /// No description provided for @focusTimerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Focus timer {time}'**
  String focusTimerSemantics(Object time);

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent complete'**
  String percentComplete(Object percent);

  /// No description provided for @testPreview.
  ///
  /// In en, this message translates to:
  /// **'TEST PREVIEW'**
  String get testPreview;

  /// No description provided for @breakPaused.
  ///
  /// In en, this message translates to:
  /// **'BREAK PAUSED'**
  String get breakPaused;

  /// No description provided for @shortBreak.
  ///
  /// In en, this message translates to:
  /// **'SHORT BREAK'**
  String get shortBreak;

  /// No description provided for @focusing.
  ///
  /// In en, this message translates to:
  /// **'FOCUSING'**
  String get focusing;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// No description provided for @focusSession.
  ///
  /// In en, this message translates to:
  /// **'FOCUS SESSION'**
  String get focusSession;

  /// No description provided for @testMode.
  ///
  /// In en, this message translates to:
  /// **'Test Mode'**
  String get testMode;

  /// No description provided for @minutesPreviewed.
  ///
  /// In en, this message translates to:
  /// **'{elapsed} of {total} minutes previewed'**
  String minutesPreviewed(Object elapsed, Object total);

  /// No description provided for @testModeBody.
  ///
  /// In en, this message translates to:
  /// **'Fast-forward focus time while keeping the real production, claim, badge, and inventory rules.'**
  String get testModeBody;

  /// No description provided for @advanceMinutes.
  ///
  /// In en, this message translates to:
  /// **'Advance {minutes} min'**
  String advanceMinutes(Object minutes);

  /// No description provided for @testSessionsSaved.
  ///
  /// In en, this message translates to:
  /// **'Completed test sessions are saved exactly like normal focus sessions.'**
  String get testSessionsSaved;

  /// No description provided for @testSessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Test session complete'**
  String get testSessionComplete;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get sessionComplete;

  /// No description provided for @focusMinutesReward.
  ///
  /// In en, this message translates to:
  /// **'+{minutes} focus minutes'**
  String focusMinutesReward(Object minutes);

  /// No description provided for @minutesSaved.
  ///
  /// In en, this message translates to:
  /// **'Your focus minutes were saved. Keep going to finish the current item.'**
  String get minutesSaved;

  /// No description provided for @itemReadyToClaim.
  ///
  /// In en, this message translates to:
  /// **'{item} is ready to claim.'**
  String itemReadyToClaim(Object item);

  /// No description provided for @itemFromGoal.
  ///
  /// In en, this message translates to:
  /// **'{item} came from today’s gentle goal.'**
  String itemFromGoal(Object item);

  /// No description provided for @claimAndPlace.
  ///
  /// In en, this message translates to:
  /// **'Claim & Place'**
  String get claimAndPlace;

  /// No description provided for @claimForLater.
  ///
  /// In en, this message translates to:
  /// **'Claim for later'**
  String get claimForLater;

  /// No description provided for @moreRewardsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} more rewards waiting'**
  String moreRewardsWaiting(Object count);

  /// No description provided for @oneMoreRewardWaiting.
  ///
  /// In en, this message translates to:
  /// **'1 more reward waiting'**
  String get oneMoreRewardWaiting;

  /// No description provided for @continueBreak.
  ///
  /// In en, this message translates to:
  /// **'Continue break'**
  String get continueBreak;

  /// No description provided for @beginAnotherSession.
  ///
  /// In en, this message translates to:
  /// **'Begin another session'**
  String get beginAnotherSession;

  /// No description provided for @ambientSounds.
  ///
  /// In en, this message translates to:
  /// **'Ambient\nSounds'**
  String get ambientSounds;

  /// No description provided for @soundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mix your perfect background noise.'**
  String get soundsSubtitle;

  /// No description provided for @soundComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{sound} is coming soon.'**
  String soundComingSoon(Object sound);

  /// No description provided for @chooseSounds.
  ///
  /// In en, this message translates to:
  /// **'Choose sounds to create a mix.'**
  String get chooseSounds;

  /// No description provided for @activeSounds.
  ///
  /// In en, this message translates to:
  /// **'{count} sounds are in your active mix.'**
  String activeSounds(Object count);

  /// No description provided for @activeMix.
  ///
  /// In en, this message translates to:
  /// **'Active Mix ({count})'**
  String activeMix(Object count);

  /// No description provided for @stopAll.
  ///
  /// In en, this message translates to:
  /// **'Stop All'**
  String get stopAll;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get sleepTimer;

  /// No description provided for @cancelTimer.
  ///
  /// In en, this message translates to:
  /// **'Cancel timer • {time}'**
  String cancelTimer(Object time);

  /// No description provided for @playBeforeTimer.
  ///
  /// In en, this message translates to:
  /// **'Play at least one sound before starting the sleep timer.'**
  String get playBeforeTimer;

  /// No description provided for @startSleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Start sleep timer'**
  String get startSleepTimer;

  /// No description provided for @sleepTimerComplete.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer complete — all sounds stopped.'**
  String get sleepTimerComplete;

  /// No description provided for @soundsInfo.
  ///
  /// In en, this message translates to:
  /// **'Rain, campfire, forest, and piano are ready to mix. More ambience loops are coming soon.'**
  String get soundsInfo;

  /// No description provided for @playSound.
  ///
  /// In en, this message translates to:
  /// **'Play {sound}'**
  String playSound(Object sound);

  /// No description provided for @pauseSound.
  ///
  /// In en, this message translates to:
  /// **'Pause {sound}'**
  String pauseSound(Object sound);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get comingSoon;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String percent(Object percent);

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your cozy experience.'**
  String get settingsSubtitle;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'APP SETTINGS'**
  String get appSettings;

  /// No description provided for @focusReminders.
  ///
  /// In en, this message translates to:
  /// **'Focus Reminders'**
  String get focusReminders;

  /// No description provided for @focusRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Show a gentle nudge on the Focus screen'**
  String get focusRemindersBody;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @dailyGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Set your focus target'**
  String get dailyGoalBody;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceBody.
  ///
  /// In en, this message translates to:
  /// **'Light or Dark mode'**
  String get appearanceBody;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language'**
  String get languageBody;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @focusOptions.
  ///
  /// In en, this message translates to:
  /// **'FOCUS OPTIONS'**
  String get focusOptions;

  /// No description provided for @defaultFocusDuration.
  ///
  /// In en, this message translates to:
  /// **'Default Focus Duration'**
  String get defaultFocusDuration;

  /// No description provided for @defaultFocusDurationBody.
  ///
  /// In en, this message translates to:
  /// **'Used for new focus sessions'**
  String get defaultFocusDurationBody;

  /// No description provided for @shortBreakDuration.
  ///
  /// In en, this message translates to:
  /// **'Short Break Duration'**
  String get shortBreakDuration;

  /// No description provided for @shortBreakDurationBody.
  ///
  /// In en, this message translates to:
  /// **'Time to gently recharge'**
  String get shortBreakDurationBody;

  /// No description provided for @autoStartBreaks.
  ///
  /// In en, this message translates to:
  /// **'Auto-start Breaks'**
  String get autoStartBreaks;

  /// No description provided for @autoStartBreaksBody.
  ///
  /// In en, this message translates to:
  /// **'Start a {minutes} min break after focus ends'**
  String autoStartBreaksBody(Object minutes);

  /// No description provided for @testModeSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Preview timers, rewards, and unlocks'**
  String get testModeSettingsBody;

  /// No description provided for @accountAndSync.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT & SYNC'**
  String get accountAndSync;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get supportSection;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @helpCenterBody.
  ///
  /// In en, this message translates to:
  /// **'Cozy Focus works offline and securely syncs your progress when you connect a Google or email account.'**
  String get helpCenterBody;

  /// No description provided for @aboutCozyFocus.
  ///
  /// In en, this message translates to:
  /// **'About Cozy Focus'**
  String get aboutCozyFocus;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Cozy Focus • Version 1.0.0\nA calm, local-first productivity sanctuary.'**
  String get aboutBody;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @accountDeletionInfo.
  ///
  /// In en, this message translates to:
  /// **'Account deletion information'**
  String get accountDeletionInfo;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @accountSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Account & Sync'**
  String get accountSyncTitle;

  /// No description provided for @sanctuaryProtected.
  ///
  /// In en, this message translates to:
  /// **'Your sanctuary is protected'**
  String get sanctuaryProtected;

  /// No description provided for @accountKeepProgress.
  ///
  /// In en, this message translates to:
  /// **'Keep your progress safe'**
  String get accountKeepProgress;

  /// No description provided for @syncProtectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your focus history, rewards, inventory, and room are synced with your account.'**
  String get syncProtectedBody;

  /// No description provided for @guestSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Guest progress stays on this device. Connect Google or create an email account so it survives a reinstall or device change.'**
  String get guestSyncBody;

  /// No description provided for @storedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Stored safely on this device'**
  String get storedOnDevice;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing your sanctuary…'**
  String get syncing;

  /// No description provided for @cloudSyncActive.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is active'**
  String get cloudSyncActive;

  /// No description provided for @syncedAt.
  ///
  /// In en, this message translates to:
  /// **'Synced at {time}'**
  String syncedAt(Object time);

  /// No description provided for @offlineSyncLater.
  ///
  /// In en, this message translates to:
  /// **'Offline — changes will sync later'**
  String get offlineSyncLater;

  /// No description provided for @guestAccount.
  ///
  /// In en, this message translates to:
  /// **'Guest account'**
  String get guestAccount;

  /// No description provided for @cozyAccount.
  ///
  /// In en, this message translates to:
  /// **'Cozy account'**
  String get cozyAccount;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @accountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account services are temporarily unavailable. Your progress remains on this device.'**
  String get accountUnavailable;

  /// No description provided for @googleLinked.
  ///
  /// In en, this message translates to:
  /// **'Your progress is now linked to Google.'**
  String get googleLinked;

  /// No description provided for @continueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueGoogle;

  /// No description provided for @createEmailAccount.
  ///
  /// In en, this message translates to:
  /// **'Create email account'**
  String get createEmailAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out. A new guest space is ready.'**
  String get signedOut;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @deleteAccountData.
  ///
  /// In en, this message translates to:
  /// **'Delete account and data'**
  String get deleteAccountData;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @emailSignIn.
  ///
  /// In en, this message translates to:
  /// **'Email sign in'**
  String get emailSignIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get invalidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordSixChars.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters.'**
  String get passwordSixChars;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get resetEmailSent;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created. Your progress is syncing.'**
  String get accountCreated;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back. Your progress has been merged.'**
  String get welcomeBack;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your cloud progress and account. This cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get enterPassword;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account and cloud data were deleted.'**
  String get accountDeleted;

  /// No description provided for @accountActionFailed.
  ///
  /// In en, this message translates to:
  /// **'The account action failed.'**
  String get accountActionFailed;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already uses this email address.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password with at least 6 characters.'**
  String get authWeakPassword;

  /// No description provided for @authTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait and try again.'**
  String get authTooManyRequests;

  /// No description provided for @authNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get authNetwork;

  /// No description provided for @audioPlaybackFailed.
  ///
  /// In en, this message translates to:
  /// **'This sound could not be played.'**
  String get audioPlaybackFailed;

  /// No description provided for @audioVolumeFailed.
  ///
  /// In en, this message translates to:
  /// **'The sound volume could not be changed.'**
  String get audioVolumeFailed;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(Object minutes);

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String hoursShort(Object hours);

  /// No description provided for @hoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String hoursMinutes(Object hours, Object minutes);

  /// No description provided for @weekdayInitials.
  ///
  /// In en, this message translates to:
  /// **'M,T,W,T,F,S,S'**
  String get weekdayInitials;

  /// No description provided for @itemDesk.
  ///
  /// In en, this message translates to:
  /// **'Study Desk'**
  String get itemDesk;

  /// No description provided for @itemChair.
  ///
  /// In en, this message translates to:
  /// **'Study Chair'**
  String get itemChair;

  /// No description provided for @itemRug.
  ///
  /// In en, this message translates to:
  /// **'Botanical Rug'**
  String get itemRug;

  /// No description provided for @itemBookshelf.
  ///
  /// In en, this message translates to:
  /// **'Bookshelf'**
  String get itemBookshelf;

  /// No description provided for @itemCandle.
  ///
  /// In en, this message translates to:
  /// **'Moon Candle'**
  String get itemCandle;

  /// No description provided for @itemWallArt.
  ///
  /// In en, this message translates to:
  /// **'Botanical Print'**
  String get itemWallArt;

  /// No description provided for @itemHangingPlant.
  ///
  /// In en, this message translates to:
  /// **'Hanging Plant'**
  String get itemHangingPlant;

  /// No description provided for @itemSleepingCat.
  ///
  /// In en, this message translates to:
  /// **'Sleeping Cat'**
  String get itemSleepingCat;

  /// No description provided for @itemTeaCup.
  ///
  /// In en, this message translates to:
  /// **'Moon Tea'**
  String get itemTeaCup;

  /// No description provided for @itemNightFern.
  ///
  /// In en, this message translates to:
  /// **'Night Fern'**
  String get itemNightFern;

  /// No description provided for @itemOwlFigure.
  ///
  /// In en, this message translates to:
  /// **'Owl Figure'**
  String get itemOwlFigure;

  /// No description provided for @itemLeafLantern.
  ///
  /// In en, this message translates to:
  /// **'Leaf Lantern'**
  String get itemLeafLantern;

  /// No description provided for @categoryFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get categoryFurniture;

  /// No description provided for @categoryFloorDecor.
  ///
  /// In en, this message translates to:
  /// **'Floor decor'**
  String get categoryFloorDecor;

  /// No description provided for @categoryLighting.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get categoryLighting;

  /// No description provided for @categoryWallDecor.
  ///
  /// In en, this message translates to:
  /// **'Wall decor'**
  String get categoryWallDecor;

  /// No description provided for @categoryCeilingDecor.
  ///
  /// In en, this message translates to:
  /// **'Ceiling decor'**
  String get categoryCeilingDecor;

  /// No description provided for @categoryCompanion.
  ///
  /// In en, this message translates to:
  /// **'Companion'**
  String get categoryCompanion;

  /// No description provided for @categoryKeepsake.
  ///
  /// In en, this message translates to:
  /// **'Keepsake'**
  String get categoryKeepsake;

  /// No description provided for @avatarMoonleaf.
  ///
  /// In en, this message translates to:
  /// **'Moonleaf'**
  String get avatarMoonleaf;

  /// No description provided for @avatarCat.
  ///
  /// In en, this message translates to:
  /// **'Sleepy Cat'**
  String get avatarCat;

  /// No description provided for @avatarMoon.
  ///
  /// In en, this message translates to:
  /// **'Crescent Moon'**
  String get avatarMoon;

  /// No description provided for @avatarLamp.
  ///
  /// In en, this message translates to:
  /// **'Cozy Lamp'**
  String get avatarLamp;

  /// No description provided for @avatarForest.
  ///
  /// In en, this message translates to:
  /// **'Night Forest'**
  String get avatarForest;

  /// No description provided for @avatarTea.
  ///
  /// In en, this message translates to:
  /// **'Moon Tea'**
  String get avatarTea;

  /// No description provided for @badgeFirstFocusName.
  ///
  /// In en, this message translates to:
  /// **'First Bloom'**
  String get badgeFirstFocusName;

  /// No description provided for @badgeFirstFocusDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete your first focus session.'**
  String get badgeFirstFocusDescription;

  /// No description provided for @badgeFirstClaimName.
  ///
  /// In en, this message translates to:
  /// **'Room Maker'**
  String get badgeFirstClaimName;

  /// No description provided for @badgeFirstClaimDescription.
  ///
  /// In en, this message translates to:
  /// **'Claim your first crafted room item.'**
  String get badgeFirstClaimDescription;

  /// No description provided for @badgeFirstDailyGoalName.
  ///
  /// In en, this message translates to:
  /// **'Gentle Keeper'**
  String get badgeFirstDailyGoalName;

  /// No description provided for @badgeFirstDailyGoalDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete your first daily focus goal.'**
  String get badgeFirstDailyGoalDescription;

  /// No description provided for @badgeSoundWeaverName.
  ///
  /// In en, this message translates to:
  /// **'Sound Weaver'**
  String get badgeSoundWeaverName;

  /// No description provided for @badgeSoundWeaverDescription.
  ///
  /// In en, this message translates to:
  /// **'Play two ambient sounds together.'**
  String get badgeSoundWeaverDescription;

  /// No description provided for @badgeNightOwlName.
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get badgeNightOwlName;

  /// No description provided for @badgeNightOwlDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach 120 total focus minutes.'**
  String get badgeNightOwlDescription;

  /// No description provided for @badgeDeepWoodsName.
  ///
  /// In en, this message translates to:
  /// **'Deep Woods'**
  String get badgeDeepWoodsName;

  /// No description provided for @badgeDeepWoodsDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach 300 total focus minutes.'**
  String get badgeDeepWoodsDescription;

  /// No description provided for @badgeZenKeeperName.
  ///
  /// In en, this message translates to:
  /// **'Zen Keeper'**
  String get badgeZenKeeperName;

  /// No description provided for @badgeZenKeeperDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach 600 total focus minutes.'**
  String get badgeZenKeeperDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
