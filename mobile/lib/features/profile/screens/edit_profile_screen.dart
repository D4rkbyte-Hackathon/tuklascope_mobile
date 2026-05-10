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
  // Local state for UI mock-up: Fixed 3 slots (null means empty)
  final List<String?> _selectedBadges = [null, null, null];

  // Mock list of badges pulled from your assets
  final List<String> _availableBadges = [
    'assets/images/badges/badge_architect.png',
    'assets/images/badges/badge_chemist.png',
    'assets/images/badges/badge_chronicler.png',
    'assets/images/badges/badge_code.png',
    'assets/images/badges/badge_ecologist.png',
    'assets/images/badges/badge_engineering.png',
    'assets/images/badges/badge_gourmet.png',
    'assets/images/badges/badge_market.png',
    'assets/images/badges/badge_math.png',
    'assets/images/badges/badge_physics.png',
  ];

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

  // Passing the slotIndex so we know exactly which position to fill
  void _showBadgeSelectionSheet(ThemeData theme, int slotIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a Badge for Slot ${slotIndex + 1}',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _availableBadges.length,
                  itemBuilder: (context, index) {
                    final badge = _availableBadges[index];
                    // Check if this specific badge is already in ANY of the slots
                    final isSelected = _selectedBadges.contains(badge);

                    return GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          setState(() {
                            // Assign the badge directly to the correct index
                            _selectedBadges[slotIndex] = badge;
                          });
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Badge already equipped!', style: GoogleFonts.inter()),
                              backgroundColor: theme.colorScheme.error,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: Opacity(
                        opacity: isSelected ? 0.3 : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                                  : theme.colorScheme.secondary.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(badge, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedBadgeSlot(String badgePath, ThemeData theme, int slotIndex) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _showBadgeSelectionSheet(theme, slotIndex),
          child: Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.secondary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(badgePath, fit: BoxFit.contain),
            ),
          ),
        ),
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                // Clear out this exact slot
                _selectedBadges[slotIndex] = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBadgeSlot(ThemeData theme, int slotIndex) {
    return GestureDetector(
      onTap: () => _showBadgeSelectionSheet(theme, slotIndex),
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Icon(
          Icons.add,
          size: 32,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
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
            
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Display Badges',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Choose up to 3 badges to show on your profile card.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final currentBadge = _selectedBadges[index];
                if (currentBadge != null) {
                  return _buildSelectedBadgeSlot(currentBadge, theme, index);
                } else {
                  return _buildEmptyBadgeSlot(theme, index);
                }
              }),
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