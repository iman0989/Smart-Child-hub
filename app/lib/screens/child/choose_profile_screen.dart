import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart' show AppMode;
import '../../core/utils/responsive.dart';
import '../../models/child_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/child_avatar.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError, showAppSnackBar;
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/responsive_content.dart';
import 'child_form_dialog.dart';

/// Kiosk-style profile picker for the child zone.
class ChooseProfileScreen extends StatefulWidget {
  const ChooseProfileScreen({super.key});

  @override
  State<ChooseProfileScreen> createState() => _ChooseProfileScreenState();
}

class _ChooseProfileScreenState extends State<ChooseProfileScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    final ChildProvider provider = context.read<ChildProvider>();
    // Only an explicit selection may be pre-highlighted — never a default.
    _selectedId = provider.selectedChildId;
    if (!provider.hasLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) provider.load();
      });
    }
  }

  Future<void> _addChild() async {
    final ChildProvider provider = context.read<ChildProvider>();
    final AuthProvider auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn) {
      final bool? goLogin = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Parent sign-in required'),
          content: const Text(
            'To add a new child you need to sign in as a parent first. '
            'Tap OK to sign in.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('OK')),
          ],
        ),
      );
      if (goLogin == true && mounted) {
        Navigator.of(context).pushNamed(AppRoutes.login);
      }
      return;
    }

    final ChildModel? result = await showDialog<ChildModel>(
      context: context,
      builder: (_) => const ChildFormDialog(),
    );
    if (result == null) return;
    if (!mounted) return;
    final ChildModel? created = await provider.addChild(result);
    if (!mounted) return;
    if (created == null) {
      showAppError(context, provider.error);
      return;
    }
    provider.selectChild(created.id);
    setState(() => _selectedId = created.id);
    showAppSnackBar(context, '${created.name} was added!');
  }

  void _continue() {
    if (_selectedId == null) return;
    context.read<ChildProvider>().selectChild(_selectedId!);

    final ChildModel? child = context.read<ChildProvider>().childById(_selectedId!);
    if (child != null && child.hasPin) {
      Navigator.of(context).pushNamed(AppRoutes.childPin, arguments: {'child': child});
    } else {
      context.read<AuthProvider>().setMode(AppMode.child);
      Navigator.of(context).pushReplacementNamed(AppRoutes.childShell);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final ThemeData theme = Theme.of(context);
    final ChildProvider provider = context.watch<ChildProvider>();
    final List<ChildModel> children = provider.children;

    return Scaffold(
      appBar: AppBar(
        title: Text('Who’s playing?', style: theme.textTheme.titleLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
            child: const Text('Sign in as parent'),
          ),
        ],
      ),
      body: ResponsiveContent(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pick a profile to start My Day',
              style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: provider.isLoading && children.isEmpty
                  ? const LoadingWidget(message: 'Loading profiles…')
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.canUseGrid(context) ? 3 : 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: Responsive.canUseGrid(context) ? 1.05 : 0.95,
                      ),
                      itemCount: children.length + 2,
                      itemBuilder: (context, index) {
                        if (index < children.length) {
                          return _ChildCard(
                            child: children[index],
                            selected: children[index].id == _selectedId,
                            onTap: () => setState(() => _selectedId = children[index].id),
                          );
                        }
                        if (index == children.length) {
                          return _AddChildCard(onTap: _addChild);
                        }
                        return _ParentCard(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.login),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: _selectedChildName(children),
              icon: AppIcons.child,
              onPressed: _selectedId == null ? null : _continue,
            ),
          ],
        ),
      ),
    );
  }

  String _selectedChildName(List<ChildModel> children) {
    for (final ChildModel child in children) {
      if (child.id == _selectedId) return 'Continue as ${child.name}';
    }
    return 'Select a profile';
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.selected, required this.onTap});

  final ChildModel child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;

    return Card(
      color: selected ? palette.primaryContainer.withValues(alpha: 0.5) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: selected ? BorderSide(color: palette.primary, width: 2.5) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChildAvatar(
                name: child.name,
                avatarKey: child.avatarKey,
                size: 56,
                photoUrl: child.photoUrl,
              ),
              const SizedBox(height: 10),
              Text(
                child.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Baloo2',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${child.age} years',
                style: theme.textTheme.bodySmall?.copyWith(color: palette.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: palette.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(AppIcons.coin, size: 14, color: palette.onSecondaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      '${child.coins}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: palette.onSecondaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChildCard extends StatelessWidget {
  const _AddChildCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final bool dark = theme.brightness == Brightness.dark;
    return Card(
      // Light mode keeps its original cream tile; dark mode must not paint a
      // near-white surface under `onSurface` text.
      color: dark ? palette.surfaceContainerHigh : const Color(0xFFFFF7E0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: palette.secondaryContainer, shape: BoxShape.circle),
              child: AppIcon(AppIcons.addChild, size: 28, color: palette.onSecondaryContainer),
            ),
            const SizedBox(height: 10),
            Text('Add a new child', style: theme.textTheme.titleSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ParentCard extends StatelessWidget {
  const _ParentCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    return Card(
      color: palette.primaryContainer.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: AppIcon(AppIcons.lock, size: 26, color: palette.onPrimary),
              ),
              const SizedBox(height: 10),
              Text('Parent zone', style: theme.textTheme.titleSmall, textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(
                'Family Manager',
                style: theme.textTheme.bodySmall?.copyWith(color: palette.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
