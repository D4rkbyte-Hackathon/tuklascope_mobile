import 'dart:io';
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
  // Badges State
  final List<String?> _selectedBadges = [null, null, null];
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

  // Avatar Scroller State
  File? _customProfileImage;
  int _selectedAvatarIndex = 1;
  final int _basePage = 5500;
  late PageController _avatarPageController;
  bool _hasInitializedAvatar = false;
  bool _isUploadingAvatar = false;

  final List<String> _avatarOptions = [
    'CUSTOM',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas1&backgroundColor=b6e3f4',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas2&backgroundColor=c0aede',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas3&backgroundColor=d1d4f9',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas4&backgroundColor=ffd5dc',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas5&backgroundColor=ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas6&backgroundColor=b6e3f4',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas7&backgroundColor=c0aede',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas8&backgroundColor=d1d4f9',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas9&backgroundColor=ffd5dc',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas10&backgroundColor=ffdfbf',
  ];

  @override
  void initState() {
    super.initState();
    _avatarPageController = PageController(viewportFraction: 0.35, initialPage: _basePage + 1);
  }

  @override
  void dispose() {
    _avatarPageController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: isError ? theme.colorScheme.error : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.black.withValues(alpha: 0.3) 
            : Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.08) 
              : Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildCustomHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _buildGlassCard(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary, size: 20),
            ),
          ),
          Text(
            'Edit Profile',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 44), 
        ],
      ),
    );
  }

  Future<void> _showEditDialog(String title, String initialValue, Function(String) onSave) async {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: initialValue);
    
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: GoogleFonts.montserrat(color: theme.colorScheme.primary, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty && controller.text.trim() != initialValue) {
                final nav = Navigator.of(dialogContext);
                try {
                  await onSave(controller.text.trim());
                  ref.invalidate(appUserProvider);
                  ref.invalidate(profileStatsProvider);
                  nav.pop();
                  _showSnackBar('Updated successfully!');
                } catch (e) {
                  nav.pop();
                  _showSnackBar('Error: $e', isError: true);
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _customProfileImage = File(pickedFile.path);
        if (_selectedAvatarIndex != 0) {
           _avatarPageController.animateToPage(
            _basePage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _saveAvatar(String userId) async {
    setState(() => _isUploadingAvatar = true);
    try {
      String? finalAvatarUrl;
      
      if (_selectedAvatarIndex == 0 && _customProfileImage != null) {
        finalAvatarUrl = await ref.read(profileServiceProvider).uploadProfilePicture(_customProfileImage!.path);
      } else if (_selectedAvatarIndex > 0) {
        finalAvatarUrl = _avatarOptions[_selectedAvatarIndex];
      }

      if (finalAvatarUrl != null) {
        await Supabase.instance.client.from('profiles').update({
          'profile_picture_url': finalAvatarUrl,
        }).eq('id', userId);
        
        ref.invalidate(appUserProvider);
        _showSnackBar('Profile picture updated!');
      }
    } catch (e) {
      _showSnackBar('Error updating avatar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Widget _buildAvatarScroller(ThemeData theme, String? currentAvatarUrl) {
    // BUG FIX 1: Check if the custom slot has a valid image 
    // (either just uploaded, or currently saved in the DB as a custom URL)
    bool hasValidCustomImage = _customProfileImage != null || 
        (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty && !_avatarOptions.contains(currentAvatarUrl));
    
    // Enable the button if they select a pre-loaded avatar OR if they are on the custom slot and it has an image
    bool isButtonEnabled = _selectedAvatarIndex != 0 || hasValidCustomImage;

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _avatarPageController,
            onPageChanged: (int page) {
              setState(() {
                _selectedAvatarIndex = page % 11;
              });
            },
            itemBuilder: (context, index) {
              int realIndex = index % 11;
              return AnimatedBuilder(
                animation: _avatarPageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_avatarPageController.position.haveDimensions) {
                    value = _avatarPageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                  } else {
                    value = (index == _basePage + _selectedAvatarIndex) ? 1.0 : 0.7; 
                  }
                  
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 105, 
                      width: Curves.easeOut.transform(value) * 105,
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    _avatarPageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    if (realIndex == 0) {
                      _pickImage();
                    }
                  },
                  child: _buildAvatarItem(realIndex, theme, currentAvatarUrl),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_isUploadingAvatar)
          const CircularProgressIndicator()
        else
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              disabledBackgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: Text('Set as Profile Picture', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            onPressed: isButtonEnabled 
                ? () {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) _saveAvatar(user.id);
                  }
                : null, // Disables the button visually and functionally
          ).animate().fade(duration: 400.ms),
      ],
    );
  }

  Widget _buildAvatarItem(int index, ThemeData theme, String? currentAvatarUrl) {
    final isSelected = _selectedAvatarIndex == index;
    
    if (index == 0) {
      ImageProvider? bgImage;
      if (_customProfileImage != null) {
        bgImage = FileImage(_customProfileImage!);
      } else if (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty && !_avatarOptions.contains(currentAvatarUrl)) {
        bgImage = NetworkImage(currentAvatarUrl);
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: isSelected ? 4 : 1,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)]
              : [],
          image: bgImage != null ? DecorationImage(image: bgImage, fit: BoxFit.cover) : null,
        ),
        child: bgImage == null 
            ? Icon(Icons.add_a_photo_rounded, color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 32)
            : null,
      );
    } 
    else {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : Colors.transparent,
            width: isSelected ? 4 : 0,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)]
              : [],
        ),
        child: ClipOval(
          child: Image.network(
            _avatarOptions[index],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
               if (progress == null) return child;
               return Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.secondary.withValues(alpha: 0.5)));
            },
            errorBuilder: (context, error, stack) => Icon(Icons.person, color: theme.colorScheme.primary),
          ),
        ),
      );
    }
  }

  Widget _buildProfileFieldRow(String label, String value, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: _buildGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label, 
                      style: GoogleFonts.inter(
                        fontSize: 12, 
                        fontWeight: FontWeight.w600, 
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5)
                      )
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value, 
                      style: GoogleFonts.montserrat(
                        fontSize: 16, 
                        fontWeight: FontWeight.w700, 
                        color: theme.colorScheme.onSurface
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to format 'assets/.../badge_architect.png' into 'Architect'
  String _formatBadgeName(String path) {
    final filename = path.split('/').last; 
    final namePart = filename.replaceAll('badge_', '').replaceAll('.png', ''); 
    return namePart[0].toUpperCase() + namePart.substring(1); 
  }

  // --- UPDATED UX BADGE LOGIC ---
  void _showBadgeSelectionSheet(ThemeData theme, int slotIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface, // FIX 2: Solid background
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String? locallySelectedBadge; // Tracks which badge is tapped before saving

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    
                    Text(
                      'Equip Badge to Slot ${slotIndex + 1}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Grid View with fixed height to prevent sheet jumping
                    SizedBox(
                      height: 280,
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _availableBadges.length,
                        itemBuilder: (context, index) {
                          final badge = _availableBadges[index];
                          final isAlreadyEquipped = _selectedBadges.contains(badge);
                          final isCurrentlySelected = locallySelectedBadge == badge;

                          return GestureDetector(
                            onTap: () {
                              if (!isAlreadyEquipped) {
                                setModalState(() => locallySelectedBadge = badge);
                              } else {
                                _showSnackBar('Badge already equipped!', isError: true);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCurrentlySelected 
                                      ? theme.colorScheme.primary 
                                      : (isAlreadyEquipped 
                                          ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                                          : theme.colorScheme.secondary.withValues(alpha: 0.5)),
                                  width: isCurrentlySelected ? 4 : 2,
                                ),
                                color: isCurrentlySelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                                boxShadow: isCurrentlySelected 
                                    ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 10)]
                                    : [],
                              ),
                              child: Opacity(
                                opacity: isAlreadyEquipped ? 0.3 : 1.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(badge, fit: BoxFit.contain),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // UX FIX 3: Badge Preview & Confirm Button
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: locallySelectedBadge != null
                          ? Column(
                              key: ValueKey(locallySelectedBadge),
                              children: [
                                Text(
                                  _formatBadgeName(locallySelectedBadge!),
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 18, 
                                    color: theme.colorScheme.primary
                                  ),
                                ).animate().fade().slideY(begin: 0.2),
                                const SizedBox(height: 16),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 54),
                                    backgroundColor: theme.colorScheme.secondary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: () {
                                    setState(() => _selectedBadges[slotIndex] = locallySelectedBadge);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Confirm', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                                ).animate().scaleXY(begin: 0.9, curve: Curves.easeOutBack),
                              ],
                            )
                          : SizedBox(
                              height: 94, // Preserves space so layout doesn't jump
                              child: Center(
                                child: Text(
                                  'Tap a badge to preview',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
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
          child: _buildGlassCard(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 55,
              height: 55,
              child: Image.asset(badgePath, fit: BoxFit.contain),
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: () => setState(() => _selectedBadges[slotIndex] = null),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.error.withValues(alpha: 0.4), blurRadius: 8)
                ]
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
        ),
      ],
    );
  }

  Widget _buildEmptyBadgeSlot(ThemeData theme, int slotIndex) {
    return GestureDetector(
      onTap: () => _showBadgeSelectionSheet(theme, slotIndex),
      child: _buildGlassCard(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 55,
          height: 55,
          child: Icon(
            Icons.add_rounded,
            size: 32,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appUserState = ref.watch(appUserProvider);

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader().animate().fade().slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
            
            Expanded(
              child: appUserState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Error loading profile", style: GoogleFonts.inter())),
                data: (appUser) {
                  if (appUser == null) return Center(child: Text("Not logged in", style: GoogleFonts.inter()));
                  final profile = appUser.profile;

                  if (!_hasInitializedAvatar) {
                    if (profile.profilePictureUrl != null && profile.profilePictureUrl!.isNotEmpty) {
                      int foundIndex = _avatarOptions.indexOf(profile.profilePictureUrl!);
                      if (foundIndex != -1) {
                        _selectedAvatarIndex = foundIndex;
                      } else {
                        _selectedAvatarIndex = 0; 
                      }
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                       if (_avatarPageController.hasClients) {
                         _avatarPageController.jumpToPage(_basePage + _selectedAvatarIndex);
                       }
                    });
                    _hasInitializedAvatar = true;
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildAvatarScroller(theme, profile.profilePictureUrl)
                          .animate().fade(delay: 100.ms).scaleXY(begin: 0.95, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),

                      Text(
                        'Personal Info',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 18, color: theme.colorScheme.primary),
                      ).animate().fade(delay: 200.ms).slideX(begin: -0.1),
                      const SizedBox(height: 12),

                      _buildProfileFieldRow(
                        'Full Name', 
                        profile.fullName ?? 'Explorer', 
                        Icons.person_rounded,
                        () => _showEditDialog(
                          'Edit Name',
                          profile.fullName ?? '',
                          (v) => Supabase.instance.client.from('profiles').update({'full_name': v}).eq('id', profile.id),
                        ),
                      ).animate().fade(delay: 250.ms).slideY(begin: 0.1),

                      _buildProfileFieldRow(
                        'City', 
                        profile.city ?? 'Not set', 
                        Icons.location_city_rounded,
                        () => _showEditDialog(
                          'Edit City',
                          profile.city ?? '',
                          (v) => Supabase.instance.client.from('profiles').update({'city': v}).eq('id', profile.id),
                        ),
                      ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

                      _buildProfileFieldRow(
                        'Country', 
                        profile.country ?? 'Not set', 
                        Icons.public_rounded,
                        () => _showEditDialog(
                          'Edit Country',
                          profile.country ?? '',
                          (v) => Supabase.instance.client.from('profiles').update({'country': v}).eq('id', profile.id),
                        ),
                      ).animate().fade(delay: 350.ms).slideY(begin: 0.1),

                      _buildProfileFieldRow(
                        'Bio', 
                        profile.bio ?? 'Tell the world about your discoveries...', 
                        Icons.edit_note_rounded,
                        () => _showEditDialog(
                          'Edit Bio',
                          profile.bio ?? '',
                          (v) => ref.read(profileServiceProvider).updateBio(v),
                        ),
                      ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 32),
                      
                      Text(
                        'Display Badges',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 18, color: theme.colorScheme.primary),
                      ).animate().fade(delay: 450.ms).slideX(begin: -0.1),
                      const SizedBox(height: 4),
                      Text(
                        'Choose up to 3 badges to highlight on your profile.',
                        style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ).animate().fade(delay: 500.ms),
                      const SizedBox(height: 20),

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
                      ).animate().fade(delay: 550.ms).slideY(begin: 0.2, curve: Curves.easeOutBack),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}