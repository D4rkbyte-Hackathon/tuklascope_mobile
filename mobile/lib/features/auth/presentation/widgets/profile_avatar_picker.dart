import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_avatar_constants.dart';

class ProfileAvatarPicker extends StatefulWidget {
  const ProfileAvatarPicker({super.key});

  @override
  ProfileAvatarPickerState createState() => ProfileAvatarPickerState();
}

class ProfileAvatarPickerState extends State<ProfileAvatarPicker> {
  File? customProfileImage;
  int selectedAvatarIndex = 1;
  final int _basePage = 5500;
  late final PageController _avatarPageController;

  @override
  void initState() {
    super.initState();
    _avatarPageController = PageController(
      viewportFraction: 0.35,
      initialPage: _basePage + selectedAvatarIndex,
    );
  }

  @override
  void dispose() {
    _avatarPageController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => customProfileImage = File(pickedFile.path));
    }
  }

  bool get isValidSelection {
    if (selectedAvatarIndex == 0) {
      return customProfileImage != null;
    }
    return selectedAvatarIndex > 0;
  }

  Future<String?> resolveAvatarUrl(
    Future<String?> Function(String path) uploadCustom,
  ) async {
    if (selectedAvatarIndex == 0 && customProfileImage != null) {
      return uploadCustom(customProfileImage!.path);
    }
    if (selectedAvatarIndex > 0) {
      return kProfileAvatarOptions[selectedAvatarIndex];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _avatarPageController,
            onPageChanged: (page) {
              setState(() => selectedAvatarIndex = page % kProfileAvatarCount);
            },
            itemBuilder: (context, index) {
              final realIndex = index % kProfileAvatarCount;
              return AnimatedBuilder(
                animation: _avatarPageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_avatarPageController.position.haveDimensions) {
                    value = _avatarPageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                  } else {
                    value = (index == _basePage + selectedAvatarIndex) ? 1.0 : 0.7;
                  }

                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 100,
                      width: Curves.easeOut.transform(value) * 100,
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
                      pickImage();
                    }
                  },
                  child: _buildAvatarItem(realIndex, theme),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your avatar or upload a picture.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarItem(int index, ThemeData theme) {
    final isSelected = selectedAvatarIndex == index;

    if (index == 0) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.secondary
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: isSelected ? 4 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
          image: customProfileImage != null
              ? DecorationImage(
                  image: FileImage(customProfileImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: customProfileImage == null
            ? Icon(
                Icons.add_a_photo_rounded,
                color: isSelected
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 32,
              )
            : null,
      );
    }

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
            ? [
                BoxShadow(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: ClipOval(
        child: Image.network(
          kProfileAvatarOptions[index],
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.secondary.withValues(alpha: 0.5),
              ),
            );
          },
          errorBuilder: (context, error, stack) =>
              Icon(Icons.person, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
