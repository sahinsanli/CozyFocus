import 'package:flutter/material.dart';

import '../assets/app_assets.dart';
import '../assets/atlas_sprite.dart';
import '../models/decoration_item.dart';
import '../theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.avatarId,
    this.size = 48,
    this.onTap,
    this.showEditBadge = false,
    super.key,
  });

  final String avatarId;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;

  @override
  Widget build(BuildContext context) {
    final avatar = profileAvatarCatalog.firstWhere(
      (item) => item.id == avatarId,
      orElse: () => profileAvatarCatalog.first,
    );
    final image = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.sageSoft,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .32),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: AtlasSprite(
        assetPath: AppAssets.rewardAvatarAtlasV2,
        columns: 4,
        rows: 4,
        column: avatar.atlasColumn,
        row: avatar.atlasRow,
        fit: BoxFit.cover,
      ),
    );
    return Semantics(
      button: onTap != null,
      label: onTap == null
          ? '${avatar.name} profile picture'
          : 'Change profile picture, currently ${avatar.name}',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            image,
            if (showEditBadge)
              Positioned(
                right: -3,
                bottom: -2,
                child: Container(
                  width: size * .32,
                  height: size * .32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2.5,
                    ),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: size * .16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
