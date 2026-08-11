import 'package:flutter/widgets.dart';

import '../core/models/badge_definition.dart';
import '../core/models/decoration_item.dart';
import '../core/services/app_controller.dart';
import 'app_localizations.dart';

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension CozyLocalization on AppLocalizations {
  String formatDuration(int totalMinutes) {
    if (totalMinutes < 60) return minutesShort(totalMinutes);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return minutes == 0 ? hoursShort(hours) : hoursMinutes(hours, minutes);
  }

  String decorationName(DecorationItem item) => switch (item.id) {
    'desk' => itemDesk,
    'chair' => itemChair,
    'rug' => itemRug,
    'bookshelf' => itemBookshelf,
    'candle' => itemCandle,
    'wall_art' => itemWallArt,
    'hanging_plant' => itemHangingPlant,
    'sleeping_cat' => itemSleepingCat,
    _ => item.name,
  };

  String collectibleName(CollectibleDecoration item) => switch (item.id) {
    'tea_cup' => itemTeaCup,
    'night_fern' => itemNightFern,
    'owl_figure' => itemOwlFigure,
    'leaf_lantern' => itemLeafLantern,
    _ => item.name,
  };

  String decorationNameById(String id) {
    for (final item in decorationCatalog) {
      if (item.id == id) return decorationName(item);
    }
    for (final item in dailyDecorationCatalog) {
      if (item.id == id) return collectibleName(item);
    }
    return id;
  }

  String decorationCategory(String category) => switch (category) {
    'Furniture' => categoryFurniture,
    'Floor decor' => categoryFloorDecor,
    'Lighting' => categoryLighting,
    'Wall decor' => categoryWallDecor,
    'Ceiling decor' => categoryCeilingDecor,
    'Companion' => categoryCompanion,
    _ => categoryKeepsake,
  };

  String avatarName(ProfileAvatarItem avatar) => switch (avatar.id) {
    'moonleaf' => avatarMoonleaf,
    'cat' => avatarCat,
    'moon' => avatarMoon,
    'lamp' => avatarLamp,
    'forest' => avatarForest,
    'tea' => avatarTea,
    _ => avatar.name,
  };

  String badgeName(BadgeDefinition badge) => switch (badge.id) {
    'first_focus' => badgeFirstFocusName,
    'first_claim' => badgeFirstClaimName,
    'first_daily_goal' => badgeFirstDailyGoalName,
    'sound_weaver' => badgeSoundWeaverName,
    'night_owl' => badgeNightOwlName,
    'deep_woods' => badgeDeepWoodsName,
    'zen_keeper' => badgeZenKeeperName,
    _ => badge.name,
  };

  String badgeDescription(BadgeDefinition badge) => switch (badge.id) {
    'first_focus' => badgeFirstFocusDescription,
    'first_claim' => badgeFirstClaimDescription,
    'first_daily_goal' => badgeFirstDailyGoalDescription,
    'sound_weaver' => badgeSoundWeaverDescription,
    'night_owl' => badgeNightOwlDescription,
    'deep_woods' => badgeDeepWoodsDescription,
    'zen_keeper' => badgeZenKeeperDescription,
    _ => badge.description,
  };

  String accountError(AccountErrorKind? kind) => switch (kind) {
    AccountErrorKind.invalidCredentials => authInvalidCredentials,
    AccountErrorKind.emailInUse => authEmailInUse,
    AccountErrorKind.weakPassword => authWeakPassword,
    AccountErrorKind.invalidEmail => invalidEmail,
    AccountErrorKind.tooManyRequests => authTooManyRequests,
    AccountErrorKind.network => authNetwork,
    AccountErrorKind.passwordRequired => enterPassword,
    _ => accountActionFailed,
  };

  String audioError(AudioErrorKind? kind) => switch (kind) {
    AudioErrorKind.volume => audioVolumeFailed,
    _ => audioPlaybackFailed,
  };
}
