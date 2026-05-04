import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/gradient_scaffold.dart';
import '../services/profile_service.dart';
import '../../auth/providers/auth_controller.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  
  Future<void> _showEditDialog(
    String title,
    String initialValue,
    Function(String) onSave,
  ) async {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: initialValue);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          title, 
          style: GoogleFonts.montserrat(
            color: theme.colorScheme.primary, 
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.secondary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
            ),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty &&
                  controller.text.trim() != initialValue) {
                final nav = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await onSave(controller.text.trim());
                  ref.invalidate(appUserProvider);
                  ref.invalidate(profileStatsProvider);
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Updated successfully!', style: GoogleFonts.inter()),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: $e', style: GoogleFonts.inter()),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              } else {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text('Save', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _changeProfilePicture() async {
    final theme = Theme.of(context);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final nav = Navigator.of(context, rootNavigator: true);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 20),
                  Text('Uploading...', style: GoogleFonts.inter()),
                ],
              ),
            ),
          ),
        );
        await ref
            .read(profileServiceProvider)
            .uploadProfilePicture(pickedFile.path);
        nav.pop();
        ref.invalidate(appUserProvider);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Profile picture updated!', style: GoogleFonts.inter()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: GoogleFonts.inter()),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  Widget _buildProfileTab(ThemeData theme) {
    final appUserState = ref.watch(appUserProvider);
    return appUserState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error", style: GoogleFonts.inter())),
      data: (appUser) {
        if (appUser == null) return Center(child: Text("Not logged in", style: GoogleFonts.inter()));
        final profile = appUser.profile;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.secondary,
                        width: 3,
                      ),
                      color: theme.colorScheme.surface,
                    ),
                    child: profile.profilePictureUrl?.isNotEmpty == true
                        ? ClipOval(
                            child: Image.network(
                              profile.profilePictureUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _changeProfilePicture,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: theme.colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Change profile picture',
                          style: GoogleFonts.inter(
                            color: theme.colorScheme.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Full Name', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                    subtitle: Text(profile.fullName ?? 'Explorer', style: GoogleFonts.inter()),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(
                      'Edit Name',
                      profile.fullName ?? '',
                      (v) => Supabase.instance.client
                          .from('profiles')
                          .update({'full_name': v})
                          .eq('id', profile.id),
                    ),
                  ),
                  ListTile(
                    title: Text('City', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                    subtitle: Text(profile.city ?? 'Not set', style: GoogleFonts.inter()),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(
                      'Edit City',
                      profile.city ?? '',
                      (v) => Supabase.instance.client
                          .from('profiles')
                          .update({'city': v})
                          .eq('id', profile.id),
                    ),
                  ),
                  ListTile(
                    title: Text('Country', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                    subtitle: Text(profile.country ?? 'Not set', style: GoogleFonts.inter()),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(
                      'Edit Country',
                      profile.country ?? '',
                      (v) => Supabase.instance.client
                          .from('profiles')
                          .update({'country': v})
                          .eq('id', profile.id),
                    ),
                  ),
                  ListTile(
                    title: Text('Bio', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                    subtitle: Text(profile.bio ?? 'Not set', style: GoogleFonts.inter()),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(
                      'Edit Bio',
                      profile.bio ?? '',
                      (v) => ref.read(profileServiceProvider).updateBio(v),
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientScaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        foregroundColor: theme.colorScheme.primary,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildProfileTab(theme),
    );
  }
}