// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Cozy Focus Room';

  @override
  String get settings => 'Ayarlar';

  @override
  String get openProfile => 'Profili aç';

  @override
  String get focus => 'Odak';

  @override
  String get room => 'Oda';

  @override
  String get stats => 'İstatistikler';

  @override
  String get sounds => 'Sesler';

  @override
  String get newBadge => 'YENİ ROZET';

  @override
  String get lovely => 'Harika!';

  @override
  String get splashTagline => 'Büyümek için huzurlu alanın.';

  @override
  String get tapToBegin => 'BAŞLAMAK İÇİN DOKUN';

  @override
  String get onboardingFocusTitle => 'Odağını Bul';

  @override
  String get onboardingFocusBody =>
      'Derin çalışma ve farkındalık için kendine özel bir alan oluştur. Süreni seç ve dünyanın yavaşça uzaklaşmasına izin ver.';

  @override
  String get onboardingProgressTitle => 'İlerlemenin Büyümesini İzle';

  @override
  String get onboardingProgressBody =>
      'Odaklandığın her dakika odan için yeni dekorların kilidini açmana yardımcı olur. Hedeflerine ulaşırken kendi huzurlu alanını kur.';

  @override
  String get onboardingSanctuaryTitle => 'Kişisel Huzur Alanın';

  @override
  String get onboardingSanctuaryBody =>
      'Onu kendine göre düzenle. Odanı bitkiler, mobilyalar ve sakinleştirici seslerle kişiselleştir. Yolculuğuna başlamaya hazır mısın?';

  @override
  String get onboardingRhythmTitle => 'Odak Ritmini Ayarla';

  @override
  String get onboardingRhythmBody =>
      'Sakin ve gerçekçi hissettiren bir tempo seç. Bu ayarları daha sonra istediğin zaman değiştirebilirsin.';

  @override
  String get onboardingDailyGoalHint =>
      'Her gün ne kadar odaklanmak senin için anlamlı olur?';

  @override
  String get onboardingFocusDurationHint =>
      'Tipik bir odak seansının uzunluğunu seç.';

  @override
  String get onboardingBreakDurationHint =>
      'Durup yenilenmek için kendine biraz alan bırak.';

  @override
  String chooseSetting(Object setting) {
    return '$setting seç';
  }

  @override
  String selectedSettingSemantics(Object duration, Object setting) {
    return '$setting: $duration. Değiştirmek için dokun.';
  }

  @override
  String get saveAndStart => 'Kaydet ve Başla';

  @override
  String get onboardingSaveFailed => 'Tercihlerin kaydedilemedi. Tekrar dene.';

  @override
  String get skip => 'Atla';

  @override
  String get next => 'İleri';

  @override
  String get getStarted => 'Başla';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get done => 'Bitti';

  @override
  String get name => 'Ad';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get chooseProfilePicture => 'Profil resmini seç';

  @override
  String get chooseProfilePictureBody =>
      'Huzur alanın için sıcak bir simge seç.';

  @override
  String get tapPictureToChange => 'Değiştirmek için resmine dokun';

  @override
  String get zenMaster => '🌱  Zen Ustası';

  @override
  String get focusHours => 'Odak Saati';

  @override
  String get dayStreak => 'Günlük Seri';

  @override
  String get decorations => 'Dekorasyon';

  @override
  String get earnedBadges => 'Kazanılan Rozetler';

  @override
  String get yourJourney => 'Yolculuğun';

  @override
  String get journeySubtitle =>
      'İlerlemeni değerlendirmek için bir an ayır.\nOdaklandığın her dakika daha sakin bir seni oluşturur.';

  @override
  String get focusSummary => 'Odak Özeti';

  @override
  String get today => 'BUGÜN';

  @override
  String get weekly => 'HAFTALIK';

  @override
  String get allTime => 'TÜM ZAMANLAR';

  @override
  String get dailyGoalComplete => 'Günlük hedef tamamlandı';

  @override
  String minutesToGoal(Object minutes) {
    return 'Hedefine $minutes dk kaldı';
  }

  @override
  String get currentRhythm => 'Mevcut ritmin';

  @override
  String get journeyStartsHere => 'Yolculuğun burada başlıyor';

  @override
  String get growingPractice => 'Gelişen bir odak alışkanlığı';

  @override
  String get dailyStreak => 'Günlük Seri';

  @override
  String get daysInARow => 'GÜN ÜST ÜSTE';

  @override
  String get weekRhythm => 'Bu Haftanın Ritmi';

  @override
  String get milestones => 'Kilometre Taşları';

  @override
  String get sanctuaryKeeper => 'Huzur Alanı Koruyucusu';

  @override
  String get readyToClaim => 'Alınmaya hazır';

  @override
  String get everyRewardUnlocked => 'Tüm oda ödüllerinin kilidi açıldı.';

  @override
  String get claimFinishedItem =>
      'Tamamlanan eşyayı envanterine eklemek için al.';

  @override
  String focusedMinutesToFinish(Object minutes) {
    return 'Bitirmek için $minutes odak dakikası kaldı';
  }

  @override
  String get upcomingUnlocks => 'YAKLAŞAN KİLİTLER';

  @override
  String get allDecorationsUnlocked => 'Tüm dekorasyonların kilidi açıldı';

  @override
  String focusedMinutesRequired(Object minutes) {
    return '$minutes odak dakikası gerekli';
  }

  @override
  String get roomDecoration => 'Oda Dekorasyonu';

  @override
  String get buildSanctuary => 'Her odak seansıyla huzur alanını büyüt.';

  @override
  String get autoSaved => 'Otomatik kaydedildi';

  @override
  String get inventory => 'Envanter';

  @override
  String availableCount(Object available, Object total) {
    return '$available/$total kullanılabilir';
  }

  @override
  String get inventoryHint =>
      'Kullanılabilir bir eşyayı tasarlanan yerine koymak veya saklamak için dokun.';

  @override
  String get gentleGoalCollection => 'Nazik Hedef Koleksiyonu';

  @override
  String get gentleGoalCollectionHint =>
      'Tekrarlanmayan bir dekor kutusu açmak için günlük hedefi tamamla. Sahip olduğun parçayı yerleştirmek veya saklamak için dokun.';

  @override
  String get mystery => 'Gizemli';

  @override
  String get inRoom => 'Odada';

  @override
  String get stored => 'Saklandı';

  @override
  String needsItem(Object item) {
    return '$item gerekli';
  }

  @override
  String get crafting => 'Üretiliyor';

  @override
  String get claim => 'Al';

  @override
  String get ownedTapToPlace => 'Senin • yerleştirmek için dokun';

  @override
  String get placedTapToStore => 'Yerleştirildi • saklamak için dokun';

  @override
  String get waitingClaimQueue => 'Alınmayı bekliyor';

  @override
  String get inProgress => 'Devam ediyor';

  @override
  String switchDecoration(Object item, Object state) {
    return '$item, $state yapmak için dokun';
  }

  @override
  String get on => 'açık';

  @override
  String get off => 'kapalı';

  @override
  String get testFocusComplete => 'Test odağı tamamlandı!';

  @override
  String get beautifulWork => 'Harika iş!';

  @override
  String get timeToBreathe => 'Nefes alma zamanı';

  @override
  String get readyToFocus => 'Odaklanmaya hazır mısın?';

  @override
  String get testProgressRules =>
      'Hızlandırılan süre gerçek ilerleme kurallarını kullandı.';

  @override
  String get sanctuaryGrew => 'Huzur alanın biraz daha sakinleşti.';

  @override
  String get focusSafe => 'Odağın güvende. Nazik bir mola ver.';

  @override
  String get settleIn => 'Yerleş ve tüm dikkatini tek bir şeye ver.';

  @override
  String get completeFocusNow => 'Odağı şimdi tamamla';

  @override
  String get endBreak => 'Molayı bitir';

  @override
  String get resetTimer => 'Sayacı sıfırla';

  @override
  String takeBreak(Object minutes) {
    return '$minutes dk mola ver';
  }

  @override
  String get gentleReminder =>
      'Küçük bir hatırlatma: Başlamak için tek bir kısa odak seansı yeterli.';

  @override
  String get todaysGentleGoal => 'Bugünün nazik hedefi';

  @override
  String durationOf(Object current, Object goal) {
    return '$current / $goal';
  }

  @override
  String get pause => 'Duraklat';

  @override
  String get resume => 'Sürdür';

  @override
  String get startFocus => 'Odaklanmaya başla';

  @override
  String get keepProgressSafe => 'İlerlemeni güvende tut';

  @override
  String get guestProgressPrompt =>
      'Misafir ilerlemesi bu cihazda kalır. Yeniden yükleme veya cihaz değişikliğinde odak geçmişini, ödüllerini ve odanı korumak için giriş yap.';

  @override
  String get protectMyProgress => 'İlerlememi koru';

  @override
  String get openAccountSettings => 'Hesap ayarlarını aç';

  @override
  String get collectionComplete => 'Huzur alanı koleksiyonun tamamlandı';

  @override
  String craftingItem(Object item) {
    return '$item üretiliyor';
  }

  @override
  String craftStage(Object current, Object required, Object stage) {
    return '$current / $required odak dakikası • aşama $stage/5';
  }

  @override
  String focusTimerSemantics(Object time) {
    return 'Odak sayacı $time';
  }

  @override
  String percentComplete(Object percent) {
    return 'Yüzde $percent tamamlandı';
  }

  @override
  String get testPreview => 'TEST ÖNİZLEMESİ';

  @override
  String get breakPaused => 'MOLA DURAKLATILDI';

  @override
  String get shortBreak => 'KISA MOLA';

  @override
  String get focusing => 'ODAKLANIYOR';

  @override
  String get paused => 'DURAKLATILDI';

  @override
  String get focusSession => 'ODAK SEANSI';

  @override
  String get testMode => 'Test Modu';

  @override
  String minutesPreviewed(Object elapsed, Object total) {
    return '$total dakikanın $elapsed dakikası önizlendi';
  }

  @override
  String get testModeBody =>
      'Gerçek üretim, ödül alma, rozet ve envanter kurallarını koruyarak odak süresini hızlandır.';

  @override
  String advanceMinutes(Object minutes) {
    return '$minutes dk ilerlet';
  }

  @override
  String get testSessionsSaved =>
      'Tamamlanan test seansları normal odak seanslarıyla aynı şekilde kaydedilir.';

  @override
  String get testSessionComplete => 'Test seansı tamamlandı';

  @override
  String get sessionComplete => 'Seans tamamlandı';

  @override
  String focusMinutesReward(Object minutes) {
    return '+$minutes odak dakikası';
  }

  @override
  String get minutesSaved =>
      'Odak dakikaların kaydedildi. Mevcut eşyayı bitirmek için devam et.';

  @override
  String itemReadyToClaim(Object item) {
    return '$item alınmaya hazır.';
  }

  @override
  String itemFromGoal(Object item) {
    return '$item, bugünün nazik hedefinden geldi.';
  }

  @override
  String get claimAndPlace => 'Al ve Yerleştir';

  @override
  String get claimForLater => 'Sonra almak üzere sakla';

  @override
  String moreRewardsWaiting(Object count) {
    return '$count ödül daha bekliyor';
  }

  @override
  String get oneMoreRewardWaiting => '1 ödül daha bekliyor';

  @override
  String get continueBreak => 'Molaya devam et';

  @override
  String get beginAnotherSession => 'Yeni bir seans başlat';

  @override
  String get ambientSounds => 'Ortam\nSesleri';

  @override
  String get soundsSubtitle => 'Mükemmel arka plan sesini karıştır.';

  @override
  String soundComingSoon(Object sound) {
    return '$sound yakında geliyor.';
  }

  @override
  String get chooseSounds => 'Bir karışım oluşturmak için sesleri seç.';

  @override
  String activeSounds(Object count) {
    return 'Etkin karışımında $count ses var.';
  }

  @override
  String activeMix(Object count) {
    return 'Etkin Karışım ($count)';
  }

  @override
  String get stopAll => 'Tümünü Durdur';

  @override
  String get sleepTimer => 'Uyku Zamanlayıcısı';

  @override
  String cancelTimer(Object time) {
    return 'Zamanlayıcıyı iptal et • $time';
  }

  @override
  String get playBeforeTimer =>
      'Uyku zamanlayıcısını başlatmadan önce en az bir ses çal.';

  @override
  String get startSleepTimer => 'Uyku zamanlayıcısını başlat';

  @override
  String get sleepTimerComplete =>
      'Uyku zamanlayıcısı tamamlandı — tüm sesler durdu.';

  @override
  String get soundsInfo =>
      'Yağmur, kamp ateşi, orman ve piyano karıştırılmaya hazır. Daha fazla ortam sesi yakında geliyor.';

  @override
  String playSound(Object sound) {
    return '$sound çal';
  }

  @override
  String pauseSound(Object sound) {
    return '$sound duraklat';
  }

  @override
  String get comingSoon => 'YAKINDA';

  @override
  String percent(Object percent) {
    return 'Yüzde $percent';
  }

  @override
  String get settingsSubtitle => 'Sıcak deneyimini kişiselleştir.';

  @override
  String get appSettings => 'UYGULAMA AYARLARI';

  @override
  String get focusReminders => 'Odak Hatırlatıcıları';

  @override
  String get focusRemindersBody => 'Odak ekranında nazik bir hatırlatma göster';

  @override
  String get dailyGoal => 'Günlük Hedef';

  @override
  String get dailyGoalBody => 'Odak hedefini belirle';

  @override
  String get appearance => 'Görünüm';

  @override
  String get appearanceBody => 'Açık veya Koyu tema';

  @override
  String get light => 'Açık';

  @override
  String get dark => 'Koyu';

  @override
  String get language => 'Dil';

  @override
  String get languageBody => 'Uygulama dilini seç';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';

  @override
  String get focusOptions => 'ODAK SEÇENEKLERİ';

  @override
  String get defaultFocusDuration => 'Varsayılan Odak Süresi';

  @override
  String get defaultFocusDurationBody => 'Yeni odak seanslarında kullanılır';

  @override
  String get shortBreakDuration => 'Kısa Mola Süresi';

  @override
  String get shortBreakDurationBody => 'Nazikçe yenilenme zamanı';

  @override
  String get autoStartBreaks => 'Molaları Otomatik Başlat';

  @override
  String autoStartBreaksBody(Object minutes) {
    return 'Odak bitince $minutes dk mola başlat';
  }

  @override
  String get testModeSettingsBody => 'Sayaçları, ödülleri ve kilitleri önizle';

  @override
  String get accountAndSync => 'HESAP VE SENKRONİZASYON';

  @override
  String get supportSection => 'DESTEK';

  @override
  String get helpCenter => 'Yardım Merkezi';

  @override
  String get helpCenterBody =>
      'Cozy Focus çevrimdışı çalışır ve Google ya da e-posta hesabı bağladığında ilerlemeni güvenle eşitler.';

  @override
  String get aboutCozyFocus => 'Cozy Focus Hakkında';

  @override
  String get aboutBody =>
      'Cozy Focus • Sürüm 1.0.0\nSakin, yerel öncelikli bir üretkenlik alanı.';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfUse => 'Kullanım Koşulları';

  @override
  String get accountDeletionInfo => 'Hesap silme bilgileri';

  @override
  String get support => 'Destek';

  @override
  String get accountSyncTitle => 'Hesap ve Senkronizasyon';

  @override
  String get sanctuaryProtected => 'Huzur alanın korunuyor';

  @override
  String get accountKeepProgress => 'İlerlemeni güvende tut';

  @override
  String get syncProtectedBody =>
      'Odak geçmişin, ödüllerin, envanterin ve odan hesabınla eşitleniyor.';

  @override
  String get guestSyncBody =>
      'Misafir ilerlemesi bu cihazda kalır. Yeniden yükleme veya cihaz değişikliğinde korumak için Google hesabını bağla ya da e-posta hesabı oluştur.';

  @override
  String get storedOnDevice => 'Bu cihazda güvenle saklanıyor';

  @override
  String get syncing => 'Huzur alanın eşitleniyor…';

  @override
  String get cloudSyncActive => 'Bulut eşitleme etkin';

  @override
  String syncedAt(Object time) {
    return '$time tarihinde eşitlendi';
  }

  @override
  String get offlineSyncLater =>
      'Çevrimdışı — değişiklikler daha sonra eşitlenecek';

  @override
  String get guestAccount => 'Misafir hesabı';

  @override
  String get cozyAccount => 'Cozy hesabı';

  @override
  String get syncNow => 'Şimdi eşitle';

  @override
  String get accountUnavailable =>
      'Hesap hizmetleri geçici olarak kullanılamıyor. İlerlemen bu cihazda kalır.';

  @override
  String get googleLinked => 'İlerlemen artık Google hesabına bağlı.';

  @override
  String get continueGoogle => 'Google ile devam et';

  @override
  String get createEmailAccount => 'E-posta hesabı oluştur';

  @override
  String get alreadyHaveAccount => 'Zaten bir hesabım var';

  @override
  String get signedOut => 'Çıkış yapıldı. Yeni bir misafir alanı hazır.';

  @override
  String get logOut => 'Çıkış yap';

  @override
  String get deleteAccountData => 'Hesabı ve verileri sil';

  @override
  String get createAccount => 'Hesap oluştur';

  @override
  String get emailSignIn => 'E-posta ile giriş';

  @override
  String get email => 'E-posta';

  @override
  String get invalidEmail => 'Geçerli bir e-posta gir.';

  @override
  String get password => 'Parola';

  @override
  String get passwordSixChars => 'En az 6 karakter kullan.';

  @override
  String get resetEmailSent => 'Parola sıfırlama e-postası gönderildi.';

  @override
  String get forgotPassword => 'Parolanı mı unuttun?';

  @override
  String get create => 'Oluştur';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get accountCreated => 'Hesap oluşturuldu. İlerlemen eşitleniyor.';

  @override
  String get welcomeBack => 'Tekrar hoş geldin. İlerlemen birleştirildi.';

  @override
  String get deleteAccountQuestion => 'Hesap silinsin mi?';

  @override
  String get deleteAccountWarning =>
      'Bu işlem bulut ilerlemeni ve hesabını kalıcı olarak siler. Geri alınamaz.';

  @override
  String get confirmPassword => 'Parolanı doğrula';

  @override
  String get enterPassword => 'Parolanı gir.';

  @override
  String get deletePermanently => 'Kalıcı olarak sil';

  @override
  String get accountDeleted => 'Hesabın ve bulut verilerin silindi.';

  @override
  String get accountActionFailed => 'Hesap işlemi başarısız oldu.';

  @override
  String get authInvalidCredentials => 'E-posta veya parola yanlış.';

  @override
  String get authEmailInUse => 'Bu e-posta adresiyle zaten bir hesap var.';

  @override
  String get authWeakPassword =>
      'En az 6 karakterli daha güçlü bir parola seç.';

  @override
  String get authTooManyRequests =>
      'Çok fazla deneme yapıldı. Bir süre bekleyip yeniden dene.';

  @override
  String get authNetwork => 'Bağlantını kontrol edip yeniden dene.';

  @override
  String get audioPlaybackFailed => 'Bu ses çalınamadı.';

  @override
  String get audioVolumeFailed => 'Ses seviyesi değiştirilemedi.';

  @override
  String minutesShort(Object minutes) {
    return '$minutes dk';
  }

  @override
  String hoursShort(Object hours) {
    return '$hours sa';
  }

  @override
  String hoursMinutes(Object hours, Object minutes) {
    return '$hours sa $minutes dk';
  }

  @override
  String get weekdayInitials => 'P,S,Ç,P,C,C,P';

  @override
  String get itemDesk => 'Çalışma Masası';

  @override
  String get itemChair => 'Çalışma Sandalyesi';

  @override
  String get itemRug => 'Botanik Halı';

  @override
  String get itemBookshelf => 'Kitaplık';

  @override
  String get itemCandle => 'Ay Mumu';

  @override
  String get itemWallArt => 'Botanik Tablo';

  @override
  String get itemHangingPlant => 'Asılı Bitki';

  @override
  String get itemSleepingCat => 'Uyuyan Kedi';

  @override
  String get itemTeaCup => 'Ay Çayı';

  @override
  String get itemNightFern => 'Gece Eğreltisi';

  @override
  String get itemOwlFigure => 'Baykuş Figürü';

  @override
  String get itemLeafLantern => 'Yaprak Feneri';

  @override
  String get categoryFurniture => 'Mobilya';

  @override
  String get categoryFloorDecor => 'Zemin dekoru';

  @override
  String get categoryLighting => 'Aydınlatma';

  @override
  String get categoryWallDecor => 'Duvar dekoru';

  @override
  String get categoryCeilingDecor => 'Tavan dekoru';

  @override
  String get categoryCompanion => 'Dost';

  @override
  String get categoryKeepsake => 'Hatıra';

  @override
  String get avatarMoonleaf => 'Ay Yaprağı';

  @override
  String get avatarCat => 'Uykucu Kedi';

  @override
  String get avatarMoon => 'Hilal';

  @override
  String get avatarLamp => 'Sıcak Lamba';

  @override
  String get avatarForest => 'Gece Ormanı';

  @override
  String get avatarTea => 'Ay Çayı';

  @override
  String get badgeFirstFocusName => 'İlk Tomurcuk';

  @override
  String get badgeFirstFocusDescription => 'İlk odak seansını tamamla.';

  @override
  String get badgeFirstClaimName => 'Oda Kurucusu';

  @override
  String get badgeFirstClaimDescription => 'Üretilen ilk oda eşyanı al.';

  @override
  String get badgeFirstDailyGoalName => 'Nazik Koruyucu';

  @override
  String get badgeFirstDailyGoalDescription =>
      'İlk günlük odak hedefini tamamla.';

  @override
  String get badgeSoundWeaverName => 'Ses Dokuyucusu';

  @override
  String get badgeSoundWeaverDescription => 'İki ortam sesini birlikte çal.';

  @override
  String get badgeNightOwlName => 'Gece Kuşu';

  @override
  String get badgeNightOwlDescription => 'Toplam 120 odak dakikasına ulaş.';

  @override
  String get badgeDeepWoodsName => 'Derin Orman';

  @override
  String get badgeDeepWoodsDescription => 'Toplam 300 odak dakikasına ulaş.';

  @override
  String get badgeZenKeeperName => 'Zen Koruyucusu';

  @override
  String get badgeZenKeeperDescription => 'Toplam 600 odak dakikasına ulaş.';
}
