import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_child_hub/core/repositories/activity_repository.dart';
import 'package:smart_child_hub/core/repositories/child_repository.dart';
import 'package:smart_child_hub/core/repositories/notification_repository.dart';
import 'package:smart_child_hub/core/repositories/report_repository.dart';
import 'package:smart_child_hub/core/theme/app_theme.dart';
import 'package:smart_child_hub/models/app_notification_model.dart';
import 'package:smart_child_hub/models/child_model.dart';
import 'package:smart_child_hub/models/homework_model.dart';
import 'package:smart_child_hub/models/meal_model.dart';
import 'package:smart_child_hub/models/mood_record_model.dart';
import 'package:smart_child_hub/models/report_model.dart';
import 'package:smart_child_hub/models/sleep_record_model.dart';
import 'package:smart_child_hub/models/task_model.dart';
import 'package:smart_child_hub/models/water_intake_model.dart';
import 'package:smart_child_hub/providers/auth_provider.dart';
import 'package:smart_child_hub/providers/child_provider.dart';
import 'package:smart_child_hub/providers/dummy_data.dart';
import 'package:smart_child_hub/providers/homework_provider.dart';
import 'package:smart_child_hub/providers/meal_provider.dart';
import 'package:smart_child_hub/providers/mood_provider.dart';
import 'package:smart_child_hub/providers/notification_provider.dart';
import 'package:smart_child_hub/providers/report_provider.dart';
import 'package:smart_child_hub/providers/settings_provider.dart';
import 'package:smart_child_hub/providers/sleep_provider.dart';
import 'package:smart_child_hub/providers/task_provider.dart';
import 'package:smart_child_hub/providers/water_provider.dart';
import 'package:smart_child_hub/screens/activities/activity_hub_screen.dart';
import 'package:smart_child_hub/screens/activities/homework_screen.dart';
import 'package:smart_child_hub/screens/activities/meal_tracking_screen.dart';
import 'package:smart_child_hub/screens/activities/mood_tracking_screen.dart';
import 'package:smart_child_hub/screens/activities/sleep_tracking_screen.dart';
import 'package:smart_child_hub/screens/activities/task_form_dialog.dart';
import 'package:smart_child_hub/screens/activities/water_intake_screen.dart';
import 'package:smart_child_hub/screens/authentication/forgot_password_screen.dart';
import 'package:smart_child_hub/screens/authentication/login_screen.dart';
import 'package:smart_child_hub/screens/authentication/register_screen.dart';
import 'package:smart_child_hub/screens/authentication/reset_password_screen.dart';
import 'package:smart_child_hub/screens/child/child_dashboard_screen.dart';
import 'package:smart_child_hub/screens/child/child_form_dialog.dart';
import 'package:smart_child_hub/screens/child/child_pin_screen.dart';
import 'package:smart_child_hub/screens/child/child_profile_screen.dart';
import 'package:smart_child_hub/screens/child/child_task_management_screen.dart';
import 'package:smart_child_hub/screens/child/choose_profile_screen.dart';
import 'package:smart_child_hub/screens/child/pin_change_dialog.dart';
import 'package:smart_child_hub/screens/notifications/notifications_screen.dart';
import 'package:smart_child_hub/screens/onboarding/onboarding_screen.dart';
import 'package:smart_child_hub/screens/parent/parent_dashboard_screen.dart';
import 'package:smart_child_hub/screens/reports/reports_screen.dart';
import 'package:smart_child_hub/screens/settings/about_screen.dart';
import 'package:smart_child_hub/screens/settings/change_password_screen.dart';
import 'package:smart_child_hub/screens/settings/profile_screen.dart';
import 'package:smart_child_hub/screens/settings/settings_screen.dart';
import 'package:smart_child_hub/screens/splash/splash_screen.dart';
import 'package:smart_child_hub/widgets/common/animated_background.dart';
import 'package:smart_child_hub/widgets/common/app_icon.dart';

// ---------------------------------------------------------------------------
// Offline fakes so every screen can be pumped with realistic data.
// ---------------------------------------------------------------------------

class _FakeActivityRepository extends ActivityRepository {
  @override
  Future<List<TaskModel>> activities(String childId, {DateTime? date}) async =>
      DummyData.tasks(childId);

  @override
  Future<List<SleepRecord>> sleep(String childId) async => DummyData.sleep(childId);

  @override
  Future<List<MealModel>> meals(String childId, {DateTime? date}) async => DummyData.meals(childId);

  @override
  Future<List<WaterIntakeModel>> water(String childId, {DateTime? date}) async =>
      DummyData.water(childId);

  @override
  Future<List<MoodRecord>> moods(String childId) async => DummyData.moods(childId);

  @override
  Future<List<HomeworkModel>> homework(String childId) async => DummyData.homework(childId);
}

class _FakeChildRepository extends ChildRepository {
  @override
  Future<List<ChildModel>> children() async => DummyData.children();

  @override
  Future<ParentDashboard> dashboard() async => const ParentDashboard(
    childrenCount: 3,
    totalCoins: 515,
    todayTasksDone: 7,
    todayTasksTotal: 11,
    pendingHomework: 2,
    unreadNotifications: 3,
    averageSleepHours: 8.2,
    waterGoalProgress: 0.75,
    childSummaries: {'c-1': (4, 5), 'c-2': (2, 3), 'c-3': (1, 3)},
  );
}

class _FakeNotificationRepository extends NotificationRepository {
  @override
  Future<List<AppNotificationModel>> notifications({int page = 1, int perPage = 50}) async =>
      DummyData.notifications();

  @override
  Future<int> unreadCount() async => 3;
}

class _FakeReportRepository extends ReportRepository {
  @override
  Future<ReportStatsModel> report(String childId, ReportPeriod period) async =>
      const ReportStatsModel(
        tasksDone: 22,
        completionRate: 0.82,
        coins: 240,
        dayStreak: 5,
        sleepHours: 8.4,
        waterGlasses: 6,
        taskChart: [
          ChartDatum('Mon', 4),
          ChartDatum('Tue', 5),
          ChartDatum('Wed', 3),
          ChartDatum('Thu', 6),
          ChartDatum('Fri', 4),
        ],
        trendChart: [
          ChartDatum('W1', 60),
          ChartDatum('W2', 74),
          ChartDatum('W3', 68),
          ChartDatum('W4', 82),
        ],
        categoryChart: [
          ChartDatum('Health', 8),
          ChartDatum('Learning', 6),
          ChartDatum('Activity', 5),
          ChartDatum('Routine', 3),
        ],
      );
}

// ---------------------------------------------------------------------------
// WCAG contrast maths.
// ---------------------------------------------------------------------------

double _channel(double v) =>
    v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double _contrast(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  final double hi = math.max(la, lb);
  final double lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

Color _over(Color fg, Color bg) {
  final double a = fg.a;
  return Color.from(
    alpha: 1,
    red: fg.r * a + bg.r * (1 - a),
    green: fg.g * a + bg.g * (1 - a),
    blue: fg.b * a + bg.b * (1 - a),
  );
}

String _hex(Color c) =>
    '#${(c.r * 255).round().toRadixString(16).padLeft(2, '0')}'
    '${(c.g * 255).round().toRadixString(16).padLeft(2, '0')}'
    '${(c.b * 255).round().toRadixString(16).padLeft(2, '0')}'
    '${c.a >= 1 ? '' : '@${(c.a * 100).round()}%'}';

/// One audited piece of content on one screen.
class Finding {
  Finding({
    required this.screen,
    required this.kind,
    required this.label,
    required this.fg,
    required this.bg,
    required this.ratio,
    required this.threshold,
    this.path = '',
  });

  final String screen;
  final String kind;
  final String label;
  final Color fg;
  final Color bg;
  final double ratio;
  final double threshold;

  /// Widget types from root to the audited element, so a finding in the dump
  /// points at the code that produced it without a second lookup pass.
  final String path;

  @override
  String toString() {
    final String head =
        '${screen.padRight(30)} ${kind.padRight(6)} ${ratio.toStringAsFixed(2).padLeft(5)}'
        ' (min ${threshold.toStringAsFixed(1)})  ${_hex(fg)} on ${_hex(bg)}  "$label"';
    return path.isEmpty ? head : '$head\n        path: $path';
  }
}

// ---------------------------------------------------------------------------
// Background resolution: composite every painted ancestor from the root down.
// ---------------------------------------------------------------------------

const List<Color> _worldDark = [Color(0xFF0C1026), Color(0xFF171A3A), Color(0xFF0E2A3E)];

const List<Color> _worldLight = [Color(0xFFEFF4FF), Color(0xFFF6F0FF), Color(0xFFE8FAFF)];

List<Color>? _paintedBy(Element ctx, [Rect? leafRect, List<Element>? chain, int? index]) {
  final Widget widget = ctx.widget;
  final BuildContext context = ctx;
  List<Color>? one(Color? c) => (c == null || c.a <= 0.001) ? null : <Color>[c];

  if (widget is AnimatedBackground) {
    return widget.dark == false || Theme.of(context).brightness == Brightness.light
        ? _worldLight
        : _worldDark;
  }
  if (widget is ChoiceChip) {
    // ChoiceChip is a StatelessWidget that delegates to an internal RawChip, so
    // the fill has to be read off it directly. Without this the audit walks past
    // the pill to the card behind it.
    final ChipThemeData chipTheme = ChipTheme.of(context);
    final Color? fill = widget.selected
        ? widget.selectedColor ?? chipTheme.secondarySelectedColor
        : widget.backgroundColor ?? chipTheme.backgroundColor;
    return one(fill);
  }
  if (widget is RawChip) {
    // A chip paints its fill through an internal transparent Material, so the
    // selection/background colour is only reachable from the widget itself.
    // Without this the audit walks past the pill to the card behind it and
    // reports the label against a background the chip never shows.
    final bool selected = widget.selected;
    final Color? fill = widget.disabledColor != null && widget.onSelected == null
        ? widget.disabledColor
        : selected
        ? widget.selectedColor ?? ChipTheme.of(context).selectedColor
        : widget.backgroundColor ?? ChipTheme.of(context).backgroundColor;
    return one(fill);
  }
  if (widget is Stack) {
    // Later children paint on top of earlier siblings, so a label inside a
    // Stack sits on whatever its preceding siblings painted. Resolve that run
    // and hand it back as this ancestor's own paint.
    return chain == null ? null : _stackBackdrop(ctx, chain, index!, leafRect);
  }
  if (widget is ShaderMask) {
    // The child is painted through a gradient supplied as an opaque closure, so
    // the colour that actually reaches the screen is neither the child's colour
    // nor anything behind it. There is nothing to resolve here; [_auditElement]
    // skips chains that contain one.
    return null;
  }
  if (widget is Scaffold) {
    final Color? bg = widget.backgroundColor;
    return bg != null && bg.a > 0.001
        ? <Color>[bg]
        : one(Theme.of(context).scaffoldBackgroundColor);
  }
  if (widget is ColoredBox) return one(widget.color);

  Decoration? decoration;
  Color? color;
  if (widget is Container) {
    decoration = widget.decoration;
    color = widget.color;
  } else if (widget is AnimatedContainer) {
    decoration = widget.decoration;
  } else if (widget is DecoratedBox) {
    decoration = widget.decoration;
  } else if (widget is Ink) {
    decoration = widget.decoration;
  } else if (widget is Material) {
    color = widget.color;
    if (color == null && !_insideChip(ctx)) {
      // A chip fills itself through an internal Material that leaves `color`
      // null. Substituting the canvas/card colour there would paint an opaque
      // default surface over the chip's own selection colour and hide it.
      if (widget.type == MaterialType.canvas) {
        color = Theme.of(context).canvasColor;
      } else if (widget.type == MaterialType.card) {
        color = Theme.of(context).cardTheme.color;
      }
    }
  } else if (widget is Card) {
    color = widget.color ?? Theme.of(context).cardTheme.color;
  }

  if (decoration is BoxDecoration) {
    final Gradient? gradient = decoration.gradient;
    if (gradient != null) {
      final List<Color> stops = gradient.colors.where((Color c) => c.a > 0.001).toList();
      if (stops.isEmpty) return null;
      final Rect? box = leafRect != null ? _globalRect(ctx) : null;
      if (box == null) return stops;
      final List<double> ts = _gradientSpan(gradient, box, leafRect!);
      final List<Color> sampled = <Color>[];
      for (final double t in ts) {
        final Color c = _sampleGradient(gradient, t);
        if (c.a > 0.001) sampled.add(c);
      }
      return sampled.isEmpty ? stops : sampled;
    }
    if (decoration.color != null && decoration.color!.a > 0.001) {
      return <Color>[decoration.color!];
    }
  }
  return one(color);
}

/// Whether [element] sits anywhere inside a chip.
///
/// Used to keep the chip's internal `Material` from contributing a colour; the
/// chip's own selection/background colour is the one that reaches the screen.
bool _insideChip(Element element) {
  bool found = false;
  element.visitAncestorElements((Element ancestor) {
    if (ancestor.widget is RawChip || ancestor.widget is ChoiceChip) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

/// Paint of [el], or of its first painting descendant.
///
/// Stack children are often `Positioned` wrappers around the widget that
/// actually paints, and neither `Positioned` nor `Opacity` contributes a colour
/// of its own, so a plain `_paintedBy` walk would miss them.
List<Color>? _paintOrDescendant(Element el, Rect? leafRect) {
  final List<Color>? own = _paintedBy(el, leafRect);
  if (own != null) return own;
  List<Color>? found;
  el.visitChildren((Element child) {
    if (found != null) return;
    found = _paintOrDescendant(child, leafRect);
  });
  return found;
}

/// Composite of the paints laid down by the children of the Stack at
/// [index] that precede the branch [chain] takes to the audited leaf.
///
/// [chain] is root-first, so the Stack's child on the path to the leaf is the
/// element right after it. Returns null unless the preceding run ends in an
/// opaque paint, because otherwise the result would still depend on whatever
/// sits behind the Stack.
List<Color>? _stackBackdrop(Element stack, List<Element> chain, int index, Rect? leafRect) {
  if (index + 1 >= chain.length) return null;
  final Element target = chain[index + 1];

  List<Color>? acc;
  bool opaque = false;
  bool reached = false;
  stack.visitChildren((Element child) {
    if (reached) return;
    if (identical(child, target)) {
      reached = true;
      return;
    }
    final List<Color>? paint = _paintOrDescendant(child, leafRect);
    if (paint == null) return;
    for (final Color p in paint) {
      if (p.a >= 1) opaque = true;
    }
    acc = acc == null
        ? paint
        : <Color>[
            for (final Color p in paint)
              for (final Color b in acc!) _over(p, b),
          ];
  });
  return opaque ? acc : null;
}

/// Returns the candidate backgrounds directly behind [chain] (ordered
/// root-most first, leaf last), one per gradient/alpha branch that could be
/// visible at that point.
///
/// [leafRect] is the on-screen rect of the audited element; when supplied,
/// linear gradients are sampled over that rect instead of offering every stop
/// as a full-area candidate.
List<Color> backgroundsBehind(List<Element> chain, Color root, {Rect? leafRect}) {
  List<Color> result = <Color>[root];
  for (int i = 0; i < chain.length; i++) {
    final Element ctx = chain[i];
    final List<Color>? paint = _paintedBy(ctx, leafRect, chain, i);
    if (paint == null) continue;
    final List<Color> next = <Color>[];
    for (final Color p in paint) {
      for (final Color base in result) {
        next.add(_over(p, base));
      }
    }
    result = next;
    if (result.length > 12) result = result.sublist(0, 12);
  }
  return result;
}

/// Samples [gradient] at [t] in `0..1`, honouring per-stop offsets.
Color _sampleGradient(Gradient gradient, double t) {
  final List<Color> colors = gradient.colors;
  final int n = colors.length;
  if (n == 1) return colors.first;
  final List<double> stops = gradient.stops ?? <double>[for (int i = 0; i < n; i++) i / (n - 1)];
  final double x = t.clamp(0.0, 1.0);
  for (int i = 0; i < n - 1; i++) {
    final double a = stops[i];
    final double b = stops[i + 1];
    if (x <= b || i == n - 2) {
      final double span = (b - a).abs() < 1e-6 ? 1.0 : b - a;
      final double f = ((x - a) / span).clamp(0.0, 1.0);
      return Color.lerp(colors[i], colors[i + 1], f)!;
    }
  }
  return colors.last;
}

/// Returns the linear-gradient `t` values covered by [inner] inside [outer].
List<double> _gradientSpan(Gradient gradient, Rect outer, Rect inner) {
  if (gradient is! LinearGradient || outer.isEmpty || inner.isEmpty) {
    return const <double>[0.0, 0.25, 0.5, 0.75, 1.0];
  }
  final Alignment beginA = gradient.begin is Alignment
      ? gradient.begin as Alignment
      : Alignment.center;
  final Alignment endA = gradient.end is Alignment ? gradient.end as Alignment : Alignment.center;
  final Offset begin = beginA.alongSize(outer.size);
  final Offset end = endA.alongSize(outer.size);
  final Offset delta = end - begin;
  final double lenSq = delta.dx * delta.dx + delta.dy * delta.dy;
  if (lenSq < 1e-6) return const <double>[0.0, 1.0];
  double tOf(Offset p) {
    final Offset rel = p - outer.topLeft - begin;
    return (rel.dx * delta.dx + rel.dy * delta.dy) / lenSq;
  }

  final Rect clipped = inner.intersect(outer);
  if (clipped.isEmpty) return const <double>[0.5];
  final List<double> ts = <double>[
    tOf(clipped.topLeft),
    tOf(clipped.topRight),
    tOf(clipped.bottomLeft),
    tOf(clipped.bottomRight),
    tOf(clipped.center),
  ];
  return ts.map((double v) => v.clamp(0.0, 1.0)).toList();
}

Rect? _globalRect(Element element) {
  final RenderObject? ro = element.renderObject;
  if (ro is! RenderBox || !ro.attached || ro.size.isEmpty) return null;
  return ro.localToGlobal(Offset.zero) & ro.size;
}

// ---------------------------------------------------------------------------
// Text / icon extraction.
// ---------------------------------------------------------------------------

bool _isHidden(List<Element> chain) {
  for (final Element ancestor in chain) {
    final Widget w = ancestor.widget;
    if (w is Visibility && !w.visible) return true;
    if (w is Offstage && w.offstage) return true;
    if (w is Opacity && w.opacity <= 0.01) return true;
  }
  return false;
}

bool _onScreen(Element element, Size view) {
  final RenderObject? ro = element.renderObject;
  if (ro == null || !ro.attached) return false;
  if (ro is! RenderBox) return false;
  if (ro.size.isEmpty) return false;
  final RenderBox box = ro;
  if (!box.paintBounds.overlaps(Offset.zero & view)) return false;
  final Offset origin = box.localToGlobal(Offset.zero);
  return origin.dx < view.width &&
      origin.dy < view.height &&
      origin.dx + box.size.width > 0 &&
      origin.dy + box.size.height > 0;
}

Iterable<InlineSpan> _flatten(InlineSpan span) sync* {
  yield span;
  if (span is TextSpan) {
    for (final InlineSpan child in span.children ?? const <InlineSpan>[]) {
      yield* _flatten(child);
    }
  }
}

void _auditElement(
  Element element,
  List<Element> chain,
  TextStyle ambient, {
  required String screen,
  required Color root,
  required Size view,
  required List<Finding> out,
  bool icon = false,
}) {
  if (_isHidden(chain) || !_onScreen(element, view)) return;
  // A ShaderMask repaints its child through a gradient the test cannot read, so
  // the child's declared colour is not what lands on screen and no verdict
  // about it would be meaningful.
  if (chain.any((Element e) => e.widget is ShaderMask)) return;

  final TextStyle style = ambient;
  final double fontSize = style.fontSize ?? 14;
  final FontWeight weight = style.fontWeight ?? FontWeight.w400;
  final bool large = fontSize >= 24 || (fontSize >= 18.66 && weight.index >= FontWeight.w700.index);
  final double threshold = icon ? 3.0 : (large ? 3.0 : 4.5);

  final Color? fg = style.color;
  if (fg == null || fg.a <= 0.001) return;

  for (final Color bg in backgroundsBehind(chain, root, leafRect: _globalRect(element))) {
    final Color solidFg = fg.a < 1 ? _over(fg, bg) : fg;
    final double ratio = _contrast(solidFg, bg);
    if (ratio < threshold) {
      out.add(
        Finding(
          screen: screen,
          kind: icon ? 'icon' : 'text',
          label: '${(style.fontSize ?? 14).toStringAsFixed(0)}px/$weight ${_describe(element)}',
          fg: solidFg,
          bg: bg,
          ratio: ratio,
          threshold: threshold,
          path: chain.map((Element e) => e.widget.runtimeType.toString()).toList().join(' > '),
        ),
      );
      return;
    }
  }
}

String _describe(Element element) {
  final Widget w = element.widget;
  if (w is Text) {
    final String? data = w.data ?? w.textSpan?.toPlainText();
    if (data != null && data.trim().isNotEmpty) return data.trim();
  }
  if (w is RichText) {
    final String data = w.text.toPlainText().trim();
    if (data.isNotEmpty) return data;
  }
  if (w is AppIcon) return 'icon:${w.icon}';
  if (w is Icon) return 'icon:${w.icon}';
  return w.runtimeType.toString();
}

List<Finding> audit(WidgetTester tester, String screen, Size view) {
  final List<Finding> out = <Finding>[];
  final Element rootCtx = tester.element(find.byType(MaterialApp).first);
  // Theme.of() above the app's Theme widget returns the fallback theme, so read
  // the real theme from inside the navigator instead.
  final ThemeData theme = Theme.of(tester.element(find.byType(Navigator).first));
  final Color root = theme.scaffoldBackgroundColor;

  void visit(Element element, List<Element> stack) {
    final Widget w = element.widget;
    // Ancestors ordered root-most first so paint composites in the right order.
    final List<Element> chain = <Element>[...stack, element];
    if (w is Text) {
      _auditElement(
        element,
        chain,
        DefaultTextStyle.of(element).style.merge(w.style),
        screen: screen,
        root: root,
        view: view,
        out: out,
      );
    } else if (w is RichText) {
      final TextStyle base = DefaultTextStyle.of(element).style;
      final InlineSpan root_ = w.text;
      {
        for (final InlineSpan span in _flatten(root_)) {
          if (span is! TextSpan) continue;
          final TextStyle merged = base.merge(root_.style).merge(span.style);
          if (span.recognizer != null && span.toPlainText().isEmpty) continue;
          _auditElement(element, chain, merged, screen: screen, root: root, view: view, out: out);
        }
      }
    } else if (w is AppIcon) {
      _auditElement(
        element,
        chain,
        TextStyle(
          color: w.color ?? Theme.of(element).colorScheme.onSurface,
          fontSize: w.size,
          fontWeight: FontWeight.w400,
        ),
        screen: screen,
        root: root,
        view: view,
        out: out,
        icon: true,
      );
    } else if (w is Icon) {
      final IconThemeData iconTheme = IconTheme.of(element);
      _auditElement(
        element,
        chain,
        TextStyle(
          color: w.color ?? iconTheme.color,
          fontSize: w.size ?? iconTheme.size,
          fontWeight: FontWeight.w400,
        ),
        screen: screen,
        root: root,
        view: view,
        out: out,
        icon: true,
      );
    }
    element.visitChildren((Element child) {
      visit(child, chain);
    });
  }

  visit(rootCtx, const <Element>[]);
  return out;
}

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

Widget _seeded(Widget screen, {required bool dark, required bool childMode}) {
  final ChildProvider childProvider = ChildProvider(repository: _FakeChildRepository());
  childProvider.seedChild(DummyData.children().first);

  final SettingsProvider settings = SettingsProvider()..setDarkMode(dark);
  final AuthProvider auth = AuthProvider()
    ..updateUser(DummyData.parentUser())
    ..setMode(childMode ? AppMode.child : AppMode.parent);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: settings),
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ChangeNotifierProvider<ChildProvider>.value(value: childProvider),
      ChangeNotifierProvider<TaskProvider>(
        create: (_) => TaskProvider(repository: _FakeActivityRepository()),
      ),
      ChangeNotifierProvider<SleepProvider>(
        create: (_) => SleepProvider(repository: _FakeActivityRepository()),
      ),
      ChangeNotifierProvider<MealProvider>(
        create: (_) => MealProvider(repository: _FakeActivityRepository()),
      ),
      ChangeNotifierProvider<WaterProvider>(
        create: (_) => WaterProvider(repository: _FakeActivityRepository()),
      ),
      ChangeNotifierProvider<MoodProvider>(
        create: (_) => MoodProvider(repository: _FakeActivityRepository()),
      ),
      ChangeNotifierProvider<HomeworkProvider>(
        create: (_) => HomeworkProvider(repository: _FakeActivityRepository()),
      ),
      ChangeNotifierProvider<NotificationProvider>(
        create: (_) => NotificationProvider(repository: _FakeNotificationRepository()),
      ),
      ChangeNotifierProvider<ReportProvider>(
        create: (_) => ReportProvider(repository: _FakeReportRepository()),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: childMode
          ? (dark ? AppTheme.childDark() : AppTheme.childLight())
          : (dark ? AppTheme.dark() : AppTheme.light()),
      home: screen,
    ),
  );
}

typedef ScreenBuilder = Widget Function();

final Map<String, ScreenBuilder> _screens = <String, ScreenBuilder>{
  'splash': SplashScreen.new,
  'onboarding': OnboardingScreen.new,
  'login': LoginScreen.new,
  'register': RegisterScreen.new,
  'forgot-password': ForgotPasswordScreen.new,
  'reset-password': () => const ResetPasswordScreen(email: 'dana@example.com', token: 'abc123'),
  'choose-profile': ChooseProfileScreen.new,
  'child-pin': () => ChildPinScreen(child: DummyData.children().first),
  'child-dashboard': ChildDashboardScreen.new,
  'child-profile': ChildProfileScreen.new,
  'child-tasks': () => ChildTaskManagementScreen(
    childId: DummyData.children().first.id,
    child: DummyData.children().first,
  ),
  'parent-dashboard': ParentDashboardScreen.new,
  'activity-hub': ActivityHubScreen.new,
  'sleep': SleepTrackingScreen.new,
  'meals': MealTrackingScreen.new,
  'water': WaterIntakeScreen.new,
  'mood': MoodTrackingScreen.new,
  'homework': HomeworkScreen.new,
  'reports': ReportsScreen.new,
  'notifications': NotificationsScreen.new,
  'settings': SettingsScreen.new,
  'profile': ProfileScreen.new,
  'change-password': ChangePasswordScreen.new,
  'about': AboutScreen.new,
  'task-form-dialog': () => const TaskFormDialog(childId: 'c-1'),
  'child-form-dialog': () => const ChildFormDialog(),
  'pin-change-dialog': () => PinChangeDialog(child: DummyData.children().first),
};

/// Every finding collected across all screen/width/theme combinations.
final List<Finding> _findings = <Finding>[];

void main() {
  SharedPreferences.setMockInitialValues(<String, Object>{});

  const List<bool> modes = <bool>[false, true];
  const List<Size> viewports = <Size>[Size(430, 3000), Size(1280, 3000)];

  for (final bool dark in modes) {
    for (final Size size in viewports) {
      final String sizeTag = size.width > 860 ? 'wide' : 'phone';
      final String tag = dark ? 'DARK' : 'LIGHT';

      for (final MapEntry<String, ScreenBuilder> entry in _screens.entries) {
        final bool isChild = entry.key.startsWith('child');

        testWidgets('$tag/$sizeTag ${entry.key}', (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          // Pre-existing layout/ink warnings are unrelated to colour auditing;
          // swallow them so one broken layout does not hide a screen's colours.
          final void Function(FlutterErrorDetails)? previous = FlutterError.onError;
          FlutterError.onError = (FlutterErrorDetails details) {};

          await tester.pumpWidget(_seeded(entry.value(), dark: dark, childMode: isChild));
          for (final Duration step in <Duration>[
            const Duration(milliseconds: 300),
            const Duration(milliseconds: 300),
            const Duration(milliseconds: 600),
            const Duration(milliseconds: 600),
          ]) {
            await tester.pump(step);
          }

          final String screen = '$tag/$sizeTag/${entry.key}';
          _findings.addAll(audit(tester, screen, size));
          FlutterError.onError = previous;
        });
      }
    }
  }

  test('contrast report', () {
    final List<Finding> sorted = List<Finding>.from(_findings)
      ..sort((Finding a, Finding b) => a.ratio.compareTo(b.ratio));

    // ignore: avoid_print
    print('\n################ CONTRAST REPORT ################');
    for (final Finding f in sorted) {
      // ignore: avoid_print
      print(f);
    }
    final List<Finding> real = sorted.where((Finding f) => f.kind != 'nocol').toList();
    // ignore: avoid_print
    print('total=${real.length} violations / ${_findings.length} findings');
    expect(real, isEmpty, reason: 'Low-contrast content found (see report)');
  });
}
