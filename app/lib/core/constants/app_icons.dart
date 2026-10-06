/// Icon and illustration asset registry backed by the Phase 2 SVG set.
library;

class AppIcons {
  AppIcons._();

  static const String addChild = 'add_child';
  static const String badge = 'badge';
  static const String bed = 'bed';
  static const String bell = 'bell';
  static const String book = 'book';
  static const String calendar = 'calendar';
  static const String chart = 'chart';
  static const String check = 'check';
  static const String chevDown = 'chev_down';
  static const String chevLeft = 'chev_left';
  static const String chevRight = 'chev_right';
  static const String child = 'child';
  static const String clock = 'clock';
  static const String coin = 'coin';
  static const String cross = 'cross';
  static const String download = 'download';
  static const String edit = 'edit';
  static const String eye = 'eye';
  static const String eyeOff = 'eye_off';
  static const String food = 'food';
  static const String gear = 'gear';
  static const String heart = 'heart';
  static const String help = 'help';
  static const String home = 'home';
  static const String homework = 'homework';
  static const String info = 'info';
  static const String lightning = 'lightning';
  static const String lock = 'lock';
  static const String mail = 'mail';
  static const String medal = 'medal';
  static const String message = 'message';
  static const String minus = 'minus';
  static const String moon = 'moon';
  static const String music = 'music';
  static const String paint = 'paint';
  static const String parent = 'parent';
  static const String person = 'person';
  static const String pets = 'pets';
  static const String plants = 'plants';
  static const String plus = 'plus';
  static const String run = 'run';
  static const String search = 'search';
  static const String send = 'send';
  static const String shield = 'shield';
  static const String sparkle = 'sparkle';
  static const String star = 'star';
  static const String sun = 'sun';
  static const String target = 'target';
  static const String tasks = 'tasks';
  static const String trash = 'trash';
  static const String trophy = 'trophy';
  static const String verified = 'verified';
  static const String water = 'water';
}

/// Resolves an icon name to its asset path.
class IconAssets {
  IconAssets._();

  static const String _base = 'assets/icons/sch_icon_';

  static String get(String name) => '$_base$name.svg';
}

/// Illustration asset registry.
///
/// [get] resolves SVG names; raster artwork is exposed as a full asset path.
class IllustrationAssets {
  IllustrationAssets._();

  static const String celebration = 'sch_ill_celebration';
  static const String emptyTasks = 'sch_ill_empty_tasks';
  static const String errorState = 'sch_ill_error_state';
  static const String sunnyMascot = 'sch_ill_sunny_mascot';
  static const String welcomeHero = 'sch_ill_welcome_hero';
  static const String logoMark = 'sch_logo_mark';

  /// Raster artwork, so it is referenced by full path instead of [get].
  ///
  /// This is the illustration supplied with the login design; it is bundled
  /// verbatim (no re-encode) and rendered with `Image.asset`.
  static const String loginGirl = 'assets/images/sch_ill_login_girl.jpeg';

  static const String _base = 'assets/images/';

  static String get(String name) => '$_base$name.svg';
}
