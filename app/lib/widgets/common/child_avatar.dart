import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Circular avatar with a coloured background derived from the accent token.
/// When a [photoUrl] is provided it is shown instead of the monogram.
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    super.key,
    required this.name,
    required this.avatarKey,
    this.size = 48,
    this.onTap,
    this.photoUrl = '',
  });

  final String name;
  final String avatarKey;
  final double size;
  final VoidCallback? onTap;

  /// Absolute http(s) URL of the child's uploaded photo, or empty to fall back
  /// to the monogram. Local file paths are intentionally not supported: the
  /// photo lives on the server, and accepting a path here would let a device
  /// path get persisted as if it were a real photo.
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final Color bg = avatarColorFromKey(context.sch, avatarKey);
    final Color fg = avatarForeground(bg);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: _buildContent(fg),
      ),
    );
  }

  Widget _buildContent(Color fg) {
    final String url = photoUrl.trim();
    if (url.isEmpty) return _monogram(fg);

    // Anything that is not an absolute http(s) URL is treated as "no photo"
    // rather than rendered, so a stray local path can never leak into the UI.
    final Uri? uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        uri.scheme != 'http' && uri.scheme != 'https') {
      return _monogram(fg);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => _monogram(fg),
    );
  }

  Widget _monogram(Color fg) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(
        color: fg,
        fontSize: size * 0.42,
        fontWeight: FontWeight.w800,
        fontFamily: 'Baloo2',
      ),
    );
  }
}

/// Maps an accent token to a concrete color.
Color avatarColorFromKey(AppPalette palette, String key) {
  switch (key) {
    case 'sunshine':
      return const Color(0xFFFFC93C);
    case 'candy':
      return const Color(0xFFFF7BA9);
    case 'sky':
      return const Color(0xFF54C3F6);
    case 'grape':
      return const Color(0xFFA98BFF);
    case 'mint':
      return const Color(0xFF3DDB9E);
    case 'peach':
      return const Color(0xFFFFB37A);
    default:
      return palette.primary;
  }
}

/// Contrasting text color for a given background.
Color avatarForeground(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : const Color(0xFF2A2416);
}
