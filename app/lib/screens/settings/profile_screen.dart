import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/services/session_reset.dart';
import '../../core/theme/app_colors.dart';
import '../../models/child_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/child_card.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/child_avatar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_state_widget.dart'
    show showAppError, showAppSnackBar, showConfirmDialog;
import '../../widgets/common/secondary_button.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/world_screen.dart';
import '../child/child_form_dialog.dart';
import '../child/pin_change_dialog.dart';

/// Profile: parent account, family management and sign-out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final ThemeData theme = Theme.of(context);
    final AuthProvider auth = context.watch<AuthProvider>();
    final ChildProvider childrenProvider = context.watch<ChildProvider>();
    final UserModel? user = auth.user;

    return WorldScreen(
      title: 'Profile',
      subtitle: 'Account & family',
      child: ListView(
        children: [
          DashboardCard(
            icon: AppIcons.person,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ChildAvatar(
                  name: user?.fullName ?? 'Parent',
                  avatarKey: user?.avatarKey.isNotEmpty == true ? user!.avatarKey : 'grape',
                  size: 56,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Parent',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      if (user?.email != null)
                        Text(
                          user!.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.onSurfaceVariant,
                          ),
                        ),
                      if (user?.phone.isNotEmpty == true)
                        Text(
                          user!.phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit profile',
                  onPressed: () => _editUser(context, auth),
                  icon: const AppIcon(AppIcons.edit, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Children',
            subtitle: '${childrenProvider.children.length} profiles',
            trailing: TextButton.icon(
              onPressed: () => _addChild(context, childrenProvider),
              icon: const AppIcon(AppIcons.plus, size: 16),
              label: const Text('Add'),
            ),
          ),
          const SizedBox(height: 4),
          for (final ChildModel child in childrenProvider.children)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ChildCard(child: child, onTap: () => _manageChild(context, child)),
            ),
          const SizedBox(height: 20),
          SectionHeader(title: 'More'),
          DashboardCard(
            icon: AppIcons.gear,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const AppIcon(AppIcons.shield, size: 22),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your login password'),
                  trailing: const AppIcon(AppIcons.chevRight, size: 20),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.changePassword),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const AppIcon(AppIcons.gear, size: 22),
                  title: const Text('Settings'),
                  subtitle: const Text('Appearance, notifications & privacy'),
                  trailing: const AppIcon(AppIcons.chevRight, size: 20),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const AppIcon(AppIcons.info, size: 22),
                  title: const Text('About'),
                  subtitle: const Text('Version & credits'),
                  trailing: const AppIcon(AppIcons.chevRight, size: 20),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.error,
              side: BorderSide(color: palette.error.withValues(alpha: 0.5)),
            ),
            icon: const AppIcon(AppIcons.cross, size: 18),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 8),
          Center(
            child: SecondaryButton(
              label: 'Switch to child zone',
              icon: AppIcons.child,
              expanded: false,
              onPressed: () {
                // Always route through the picker so a profile is chosen
                // explicitly (and the PIN is verified) before entering the
                // child zone.
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.chooseProfile, (route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editUser(BuildContext context, AuthProvider auth) async {
    final UserModel? current = auth.user;
    if (current == null) return;
    final TextEditingController nameController = TextEditingController(text: current.fullName);
    final TextEditingController phoneController = TextEditingController(text: current.phone);

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                label: 'Full name',
                prefixIcon: AppIcons.person,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: phoneController,
                label: 'Phone',
                prefixIcon: AppIcons.mail,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
        ],
      ),
    );

    if (saved == true && nameController.text.trim().isNotEmpty) {
      await auth.updateProfile(
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
      if (!context.mounted) return;
      if (auth.error != null) {
        showAppError(context, auth.error);
      } else {
        showAppSnackBar(context, 'Profile updated');
      }
    }
  }

  Future<void> _addChild(BuildContext context, ChildProvider provider) async {
    final ChildModel? result = await showDialog<ChildModel>(
      context: context,
      builder: (_) => const ChildFormDialog(),
    );
    if (result == null) return;
    final ChildModel? created = await provider.addChild(result);
    if (!context.mounted) return;
    if (created == null) {
      showAppError(context, provider.error);
    } else {
      showAppSnackBar(context, '${created.name} was added!');
    }
  }

  Future<void> _editChild(BuildContext context, ChildProvider provider, ChildModel child) async {
    final ChildModel? result = await showDialog<ChildModel>(
      context: context,
      builder: (_) => ChildFormDialog(child: child),
    );
    if (result == null) return;
    final bool ok = await provider.updateChild(result);
    if (!context.mounted) return;
    if (ok) {
      showAppSnackBar(context, '${result.name} was updated!');
    } else {
      showAppError(context, provider.error);
    }
  }

  Future<void> _uploadChildPhoto(
    BuildContext context,
    ChildProvider provider,
    ChildModel child,
  ) async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // XFile exposes length() and readAsBytes() on every platform, including Web
    // where the picked file is a blob with no readable filesystem path.
    final int byteLength = await picked.length();
    if (byteLength == 0) {
      if (!context.mounted) return;
      showAppError(context, 'Could not read the selected image.');
      return;
    }
    if (byteLength > AppConstants.maxPhotoUploadBytes) {
      if (!context.mounted) return;
      showAppError(context, 'The photo must be 5 MB or smaller.');
      return;
    }

    final ChildModel? updated = await provider.uploadPhoto(
      childId: child.id,
      bytes: await picked.readAsBytes(),
      filename: picked.name,
    );
    if (!context.mounted) return;
    if (updated != null) {
      showAppSnackBar(context, 'Photo updated for ${updated.name}');
    } else {
      showAppError(context, provider.error);
    }
  }

  Future<void> _removeChildPhoto(
    BuildContext context,
    ChildProvider provider,
    ChildModel child,
  ) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Remove photo?',
      message: "This will remove ${child.name}'s profile photo. You can add a new one at any time.",
      confirmLabel: 'Remove',
      danger: true,
    );
    if (!confirmed || !context.mounted) return;

    final ChildModel? updated = await provider.removePhoto(child.id);
    if (!context.mounted) return;
    if (updated != null) {
      showAppSnackBar(context, 'Photo removed from ${updated.name}');
    } else {
      showAppError(context, provider.error);
    }
  }

  void _manageChild(BuildContext context, ChildModel child) {
    final ChildProvider childrenProvider = context.read<ChildProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                child.name,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const AppIcon(AppIcons.edit, size: 22),
                title: const Text('Edit Profile'),
                subtitle: const Text('Update name, age, grade or avatar'),
                trailing: const AppIcon(AppIcons.chevRight, size: 20),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _editChild(context, childrenProvider, child);
                },
              ),
              const Divider(),
              ListTile(
                leading: const AppIcon(AppIcons.tasks, size: 22),
                title: const Text('Manage Tasks'),
                subtitle: const Text('Add, edit or delete daily tasks'),
                trailing: const AppIcon(AppIcons.chevRight, size: 20),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamed(AppRoutes.childTasks, arguments: child);
                },
              ),
              const Divider(),
              ListTile(
                leading: const AppIcon(AppIcons.shield, size: 22),
                title: const Text('Change PIN'),
                subtitle: const Text('Update the 4-digit PIN'),
                trailing: const AppIcon(AppIcons.chevRight, size: 20),
                onTap: () {
                  Navigator.of(ctx).pop();
                  showDialog(
                    context: context,
                    builder: (_) => PinChangeDialog(child: child),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const AppIcon(AppIcons.child, size: 22),
                title: Text(child.photoUrl.isEmpty ? 'Upload Photo' : 'Change Photo'),
                subtitle: const Text('Set a profile picture'),
                trailing: const AppIcon(AppIcons.chevRight, size: 20),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _uploadChildPhoto(context, childrenProvider, child);
                },
              ),
              if (child.photoUrl.isNotEmpty) ...[
                const Divider(),
                ListTile(
                  leading: AppIcon(
                    AppIcons.trash,
                    size: 22,
                    color: Theme.of(ctx).colorScheme.error,
                  ),
                  title: Text(
                    'Remove Photo',
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                  ),
                  subtitle: const Text('Go back to the coloured monogram'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _removeChildPhoto(context, childrenProvider, child);
                  },
                ),
              ],
              const Divider(),
              ListTile(
                leading: AppIcon(AppIcons.trash, size: 22, color: Theme.of(ctx).colorScheme.error),
                title: Text(
                  'Delete ${child.name}',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
                subtitle: const Text('Remove this child permanently'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final bool confirmed = await showConfirmDialog(
                    context,
                    title: 'Delete child?',
                    message:
                        'Are you sure you want to delete ${child.name}? This '
                        'action cannot be undone. All tasks, sleep records and '
                        'other data for this child will be lost.',
                    confirmLabel: 'Delete',
                    danger: true,
                  );
                  if (!confirmed || !context.mounted) return;
                  final bool ok = await childrenProvider.deleteChild(child.id);
                  if (!context.mounted) return;
                  if (ok) {
                    showAppSnackBar(context, '${child.name} has been deleted');
                  } else {
                    showAppError(context, childrenProvider.error);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    resetSessionData(context);
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}
