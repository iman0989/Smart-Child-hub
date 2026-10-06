import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../widgets/common/app_illustration.dart';
import '../../widgets/common/motion.dart';

/// Blue-to-violet accent sampled from the login design's primary button.
///
/// The design pairs a violet highlight with a blue core and a violet base, so
/// the same three stops drive the CTA, the compact banner and the accent glows.
/// Each stop is the sampled hue deepened just enough that white text on top
/// still clears 4.5:1.
const LinearGradient kLoginBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[Color(0xFF8452E8), Color(0xFF3A62F0), Color(0xFF6152F3)],
  stops: <double>[0.0, 0.52, 1.0],
);

/// Near-white panel colour sampled from the form side of the login design.
const Color kLoginPanelLight = Color(0xFFFAF9FE);

/// Hairline used to seat the framed form on compact widths.
const Color kLoginBorderLight = Color(0xFFE7E4F5);

/// Accent of the sign-in CTA, sampled from the login design button.
const LinearGradient kLoginCtaGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[Color(0xFF8452E8), Color(0xFF3A62F0), Color(0xFF6152F3)],
  stops: <double>[0.0, 0.5, 1.0],
);

/// Height of the sign-in CTA, matched to the design's proportions.
const double kLoginCtaHeight = 62;

/// Left-hand panel of the desktop split layout (55% of the viewport).
///
/// In the supplied design this column is the artwork itself: the illustration
/// fills the panel edge to edge, is cropped rather than letterboxed, and carries
/// no copy or scrim on top of it, so all branding lives in the form column.
class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Entrance(
      child: Image.asset(
        IllustrationAssets.loginGirl,
        fit: BoxFit.cover,
        alignment: Alignment.centerLeft,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// Compact banner shown above the form on phones and small tablets.
///
/// It reuses the same supplied illustration, cropped from the top so the girl's
/// face stays visible inside a short banner, and keeps the design's copy on top
/// of the matching gradient.
class LoginCompactBanner extends StatelessWidget {
  const LoginCompactBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Entrance(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(
              child: DecoratedBox(decoration: BoxDecoration(gradient: kLoginBrandGradient)),
            ),
            Positioned.fill(
              child: Image.asset(
                IllustrationAssets.loginGirl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      const Color(0xFF241C63).withValues(alpha: 0.76),
                      const Color(0xFF241C63).withValues(alpha: 0.38),
                      const Color(0xFF241C63).withValues(alpha: 0.12),
                    ],
                    stops: const <double>[0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    AppConstants.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome back!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.tagline,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFE6E9FF),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brand lockup and headline that open the form column on the split layout.
class LoginFormHeader extends StatelessWidget {
  const LoginFormHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: kLoginBrandGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              ),
              child: const AppIllustration(IllustrationAssets.logoMark, width: 30, height: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppConstants.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Baloo2',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceXl),
        Semantics(
          header: true,
          child: Text(
            'Welcome back!',
            style: theme.textTheme.displaySmall?.copyWith(
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Text(
          AppConstants.tagline,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSection),
      ],
    );
  }
}
