import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/navigation/main_nav_scope.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../auth/providers/auth_controller.dart';
import '../auth/services/supabase_auth_service.dart';
import 'pathfinder_blueprint_sheet.dart';
import '../../core/theme/theme_provider.dart';

import '../auth/presentation/widgets/auth_gate.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context); // Cache theme
    final appUserState = ref.watch(appUserProvider);

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Profile & Skill Tree'),
        foregroundColor: theme.colorScheme.primary, // Themed AppBar Text
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: appUserState.when(
        loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: theme.colorScheme.error))),
        data: (appUser) {
          if (appUser == null) {
            return Center(child: Text('Please log in.', style: TextStyle(color: theme.colorScheme.onSurface)));
          }

          final profile = appUser.profile;

          String location = '';
          final city = profile.city ?? '';
          final country = profile.country ?? '';
          if (city.isNotEmpty && country.isNotEmpty) {
            location = '$city, $country';
          } else {
            location = city + country;
          }

          final List<Widget> profileItems = [
            _ProfileHeaderCard(
              theme: theme, // Pass theme to helper
              fullName: profile.fullName ?? 'New Explorer',
              educationLevel: profile.educationLevel ?? 'Curious Mind',
              location: location,
              streak: profile.currentStreak,
              onEditPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28, bottom: 12),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(
                      text: 'Your ',
                      style: TextStyle(color: theme.colorScheme.primary), // Themed Blue
                    ),
                    TextSpan(
                      text: 'Skill Tree',
                      style: TextStyle(color: theme.colorScheme.secondary), // Themed Orange
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Text(
                'Watch your knowledge grow! Every discovery adds to your personal skill network and unlocks new learning pathways.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8), // Themed Adaptive Text
                  height: 1.35,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _StatsGridCard(theme: theme), // Pass theme
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _SkillTreePlaceholderCard(theme: theme), // Pass theme
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ProfilePromoCard(
                theme: theme,
                borderColor: theme.colorScheme.secondary,
                title: 'Open Your Blueprint',
                description: 'From core principles to career path.',
                buttonLabel: 'Open Pathfinder →',
                buttonColor: theme.colorScheme.primary,
                onPressed: () => showPathfinderBlueprintSheet(
                  context,
                  onNavigateToScan: () =>
                      MainNavScope.maybeOf(context)?.goToTab(1),
                ),
              ),
            ),
            _ProfilePromoCard(
              theme: theme,
              borderColor: theme.colorScheme.primary.withValues(alpha: 0.35),
              title: 'Ready to expand your network?',
              description:
                  'Upload a photo of any object around you and discover the concepts behind it!',
              buttonLabel: 'Start Discovery →',
              buttonColor: theme.colorScheme.secondary,
              onPressed: () => MainNavScope.maybeOf(context)?.goToTab(1),
            ),
          ];

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.paddingOf(context).bottom + 88,
            ),
            itemCount: profileItems.length,
            itemBuilder: (context, index) {
              return profileItems[index]
                  .animate()
                  .fade(duration: 600.ms, delay: (100 * index).ms)
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                    delay: (100 * index).ms,
                  );
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS BELOW
// -----------------------------------------------------------------------------

class _ProfilePromoCard extends StatelessWidget {
  final ThemeData theme; // Themed
  final Color borderColor;
  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _ProfilePromoCard({
    required this.theme,
    required this.borderColor,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Surface
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary, // Themed Title
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7), // Themed Subtitle
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: theme.colorScheme.onPrimary, // Ensures contrast on button
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final ThemeData theme;
  final String fullName;
  final String educationLevel;
  final String location;
  final int streak;
  final VoidCallback onEditPressed;

  const _ProfileHeaderCard({
    required this.theme,
    required this.fullName,
    required this.educationLevel,
    required this.location,
    required this.streak,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Surface
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), width: 1), // Themed Border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary, width: 4), // Themed Primary
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  child: Icon(Icons.person, size: 40, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary, // Themed Primary
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.isNotEmpty
                          ? '$educationLevel • $location'
                          : educationLevel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary, // Themed Secondary (Orange)
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6), // Themed adaptive text
                        ),
                        children: [
                          const TextSpan(text: 'Daily Streak '),
                          TextSpan(
                            text: '$streak',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary, // Themed Secondary (Orange)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onEditPressed,
              child: Text(
                'Edit Profile →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.tertiary, // Used tertiary for link color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGridCard extends StatelessWidget {
  final ThemeData theme;

  const _StatsGridCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Surface
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: '67%',
                  label: 'Total Progress',
                  valueColor: theme.colorScheme.secondary, // Themed Orange
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatCell(
                  value: '420',
                  label: 'Total EXP',
                  valueColor: theme.colorScheme.primary, // Themed Blue
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: '33',
                  label: 'Concepts Mastered',
                  valueColor: const Color(0xFF4CAF50), // Standard Green is safe
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatCell(
                  value: '1',
                  label: 'Average Level',
                  valueColor: theme.colorScheme.secondary, // Themed Orange
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final ThemeData theme; // Require theme for text colors

  const _StatCell({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6), // Themed Adaptive Label
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillTreePlaceholderCard extends StatelessWidget {
  final ThemeData theme;

  const _SkillTreePlaceholderCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Surface
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor, // Uses the active background mode color for the graph box
                child: CustomPaint(painter: _SkillTreeGraphPainter(theme: theme)), // Passes theme to painter
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '(placeholder pic)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45), // Themed text
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillTreeGraphPainter extends CustomPainter {
  final ThemeData theme;

  _SkillTreeGraphPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // Determine line color based on theme brightness
    final Color lineColor = theme.brightness == Brightness.dark 
        ? Colors.white.withValues(alpha: 0.24) 
        : Colors.black.withValues(alpha: 0.1);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5;

    final nodes = <Offset>[
      Offset(size.width * 0.22, size.height * 0.28),
      Offset(size.width * 0.48, size.height * 0.18),
      Offset(size.width * 0.78, size.height * 0.32),
      Offset(size.width * 0.35, size.height * 0.52),
      Offset(size.width * 0.62, size.height * 0.48),
      Offset(size.width * 0.28, size.height * 0.75),
      Offset(size.width * 0.55, size.height * 0.82),
      Offset(size.width * 0.82, size.height * 0.68),
    ];

    void edge(int a, int b) {
      canvas.drawLine(nodes[a], nodes[b], linePaint);
    }

    edge(0, 1);
    edge(1, 2);
    edge(0, 3);
    edge(1, 4);
    edge(2, 4);
    edge(3, 5);
    edge(4, 6);
    edge(4, 7);
    edge(5, 6);

    final colors = [
      Colors.orange,
      Colors.amber,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.orangeAccent,
      Colors.deepPurpleAccent,
      Colors.cyanAccent,
      Colors.limeAccent,
    ];

    for (var i = 0; i < nodes.length; i++) {
      canvas.drawCircle(
        nodes[i],
        5,
        Paint()..color = colors[i % colors.length].withValues(alpha: 0.9),
      );
      canvas.drawCircle(
        nodes[i],
        5,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// NEW SCREEN: EDIT PROFILE SCREEN (WITH REFERENCE DATA)
// =============================================================================

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🚀 NEW FUNCTION: Opens a dialog and updates Supabase
  Future<void> _showEditNameDialog(String currentName) async {
    final theme = Theme.of(context);
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface, // Themed Dialog Background
          title: Text('Edit Full Name', style: TextStyle(color: theme.colorScheme.primary)),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: theme.colorScheme.onSurface), // Themed Input Text
            decoration: InputDecoration(
              hintText: 'Enter your new name',
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.secondary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.secondary), // Themed Orange
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != currentName) {
                  try {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId != null) {
                      // 1. Send to Supabase
                      await Supabase.instance.client
                          .from('profiles')
                          .update({'full_name': newName})
                          .eq('id', userId);

                      // 2. Tell Riverpod to refresh the data so the UI updates instantly!
                      ref.invalidate(appUserProvider);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating profile: $e'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 🚀 NEW FUNCTION: Edit city dialog
  Future<void> _showEditCityDialog(String currentCity) async {
    final theme = Theme.of(context);
    final TextEditingController cityController = TextEditingController(
      text: currentCity,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface, // Themed Dialog Background
          title: Text('Edit City', style: TextStyle(color: theme.colorScheme.primary)),
          content: TextField(
            controller: cityController,
            style: TextStyle(color: theme.colorScheme.onSurface), // Themed Input Text
            decoration: InputDecoration(
              hintText: 'Enter your city',
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.secondary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
              onPressed: () async {
                final newCity = cityController.text.trim();
                if (newCity != currentCity) {
                  try {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId != null) {
                      await Supabase.instance.client
                          .from('profiles')
                          .update({'city': newCity})
                          .eq('id', userId);

                      ref.invalidate(appUserProvider);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('City updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating city: $e'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  }
                } else {
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 🚀 NEW FUNCTION: Edit country dialog
  Future<void> _showEditCountryDialog(String currentCountry) async {
    final theme = Theme.of(context);
    final TextEditingController countryController = TextEditingController(
      text: currentCountry,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface, // Themed Dialog Background
          title: Text('Edit Country', style: TextStyle(color: theme.colorScheme.primary)),
          content: TextField(
            controller: countryController,
            style: TextStyle(color: theme.colorScheme.onSurface), // Themed Input Text
            decoration: InputDecoration(
              hintText: 'Enter your country',
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.secondary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
              onPressed: () async {
                final newCountry = countryController.text.trim();
                if (newCountry != currentCountry) {
                  try {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId != null) {
                      await Supabase.instance.client
                          .from('profiles')
                          .update({'country': newCountry})
                          .eq('id', userId);

                      ref.invalidate(appUserProvider);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Country updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating country: $e'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  }
                } else {
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 🚀 NEW FUNCTION: Edit education level dialog with better-styled dropdown
  Future<void> _showEditEducationLevelDialog(String currentLevel) async {
    final theme = Theme.of(context);
    final List<String> educationLevels = [
      'Elementary',
      'High School',
      'Senior High School',
      'Others',
    ];
    String? selectedLevel = currentLevel.isNotEmpty && educationLevels.contains(currentLevel)
        ? currentLevel
        : null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface, // Themed Dialog Background
              title: Text('Edit Education Level', style: TextStyle(color: theme.colorScheme.primary)),
              content: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.secondary, width: 2), // Themed Border
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: theme.colorScheme.surface, // Themed Dropdown list
                    isExpanded: true,
                    hint: Text(
                      'Select your education level',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                    value: selectedLevel,
                    icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.secondary),
                    items: educationLevels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface, // Themed Text
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLevel = newValue;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
                  onPressed: selectedLevel != null && selectedLevel != currentLevel
                      ? () async {
                          try {
                            final userId =
                                Supabase.instance.client.auth.currentUser?.id;
                            if (userId != null) {
                              await Supabase.instance.client
                                  .from('profiles')
                                  .update({'education_level': selectedLevel})
                                  .eq('id', userId);

                              ref.invalidate(appUserProvider);

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Education level updated successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating education level: $e'),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🚀 NEW FUNCTION: Change password dialog
  Future<void> _showChangePasswordDialog() async {
    final theme = Theme.of(context);
    
    // Check if user is a Google sign-in user
    final authService = ref.read(authServiceProvider);
    if (authService.isGoogleUser()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Google Sign-In users cannot change password. Please sign in with email and password to change your password.',
            ),
            backgroundColor: theme.colorScheme.secondary, // Themed Warning
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface, // Themed Background
              title: Text('Change Password', style: TextStyle(color: theme.colorScheme.primary)), // Themed Title
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Current Password Field
                    TextField(
                      controller: currentPasswordController,
                      obscureText: !showCurrentPassword,
                      enabled: !isLoading,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Current password',
                        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: theme.colorScheme.secondary),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showCurrentPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              showCurrentPassword = !showCurrentPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // New Password Field
                    TextField(
                      controller: newPasswordController,
                      obscureText: !showNewPassword,
                      enabled: !isLoading,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'New password',
                        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: theme.colorScheme.secondary),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              showNewPassword = !showNewPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password Field
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !showConfirmPassword,
                      enabled: !isLoading,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Confirm new password',
                        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: theme.colorScheme.secondary),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final currentPassword =
                              currentPasswordController.text.trim();
                          final newPassword =
                              newPasswordController.text.trim();
                          final confirmPassword =
                              confirmPasswordController.text.trim();

                          // Validation
                          if (currentPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Please enter your current password'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                            return;
                          }

                          if (newPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Please enter a new password'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                            return;
                          }

                          if (newPassword.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Password must be at least 6 characters'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                            return;
                          }

                          if (newPassword != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Passwords do not match'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                            return;
                          }

                          if (newPassword == currentPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('New password must be different from current password'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            // First, verify current password by signing in
                            final userEmail =
                                Supabase.instance.client.auth.currentUser?.email;
                            if (userEmail == null) {
                              throw Exception('User email not found');
                            }

                            // Verify current password
                            await Supabase.instance.client.auth
                                .signInWithPassword(
                              email: userEmail,
                              password: currentPassword,
                            );

                            // If verification succeeds, update password
                            await authService.changePassword(newPassword);

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password changed successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().contains('Invalid login credentials')
                                        ? 'Current password is incorrect'
                                        : 'Error changing password: $e',
                                  ),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(theme.colorScheme.onSecondary), // Themed loader color
                          ),
                        )
                      : const Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache theme

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        foregroundColor: theme.colorScheme.primary, // Themed AppBar text
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // THE CUSTOM PILL TAB-BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, // Themed Surface
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), width: 1), // Themed Border
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary, // Themed Active Tab Highlight
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: theme.colorScheme.onPrimary, // Ensures text is visible on the blue tab
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6), // Themed Unselected text
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Settings'),
                  Tab(text: 'About'),
                ],
              ),
            ),
          ),

          // THE TAB CONTENT VIEWS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(theme),
                _buildSettingsTab(theme),
                _buildAboutTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: PROFILE
  // ---------------------------------------------------------------------------
  Widget _buildProfileTab(ThemeData theme) {
    final appUserState = ref.watch(appUserProvider);

    return appUserState.when(
      loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      error: (err, stack) => Center(child: Text('Error loading profile', style: TextStyle(color: theme.colorScheme.error))),
      data: (appUser) {
        if (appUser == null) return Center(child: Text('Not logged in', style: TextStyle(color: theme.colorScheme.onSurface)));

        final profile = appUser.profile;
        final currentName = profile.fullName ?? 'Explorer';
        final currentCity = profile.city ?? '';
        final currentCountry = profile.country ?? '';
        final currentEducationLevel = profile.educationLevel ?? 'Not set';
        final email =
            Supabase.instance.client.auth.currentUser?.email ?? 'No email';

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          physics: const BouncingScrollPhysics(),
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.secondary, width: 3), // Themed Avatar Border (Orange)
                    ),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface, // Themed Edit Button background
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: theme.shadowColor.withValues(alpha: 0.2), blurRadius: 4), // Themed Shadow
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: theme.colorScheme.secondary, // Themed Icon Color
                          size: 22,
                        ),
                        onPressed: () {}, // Image picker logic goes here later
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Edit Info Card
            Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface, // Themed Surface
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)), // Themed Border
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_outline, color: theme.colorScheme.primary), // Themed Icon
                        title: Text(
                          'Full Name',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12), // Themed adaptive label
                        ),
                        subtitle: Text(
                          currentName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface, // Themed Value
                          ),
                        ),
                        trailing: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary, // Themed Orange
                          size: 20,
                        ),
                        onTap: () => _showEditNameDialog(currentName),
                      ),
                      Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                      ListTile(
                        leading: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                        title: Text(
                          'Email',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                        ),
                        subtitle: Text(
                          email,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                      ListTile(
                        leading: Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
                        title: Text(
                          'City',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                        ),
                        subtitle: Text(
                          currentCity.isNotEmpty ? currentCity : 'Not set',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        onTap: () => _showEditCityDialog(currentCity),
                      ),
                      Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                      ListTile(
                        leading: Icon(Icons.public_outlined, color: theme.colorScheme.primary),
                        title: Text(
                          'Country',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                        ),
                        subtitle: Text(
                          currentCountry.isNotEmpty ? currentCountry : 'Not set',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        onTap: () => _showEditCountryDialog(currentCountry),
                      ),
                      Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                      ListTile(
                        leading: Icon(Icons.school_outlined, color: theme.colorScheme.primary),
                        title: Text(
                          'Education Level',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                        ),
                        subtitle: Text(
                          currentEducationLevel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        onTap: () => _showEditEducationLevelDialog(currentEducationLevel),
                      ),
                    ],
                  ),
                )
                .animate()
                .fade(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: SETTINGS
  // ---------------------------------------------------------------------------
  Widget _buildSettingsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, // Themed Surface
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)), // Themed Border
          ),
          child: Column(
            children: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: appThemeNotifier,
                builder: (context, currentMode, child) {
                  final isDarkMode = currentMode == ThemeMode.dark;

                  return SwitchListTile(
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode, 
                      color: theme.colorScheme.primary, // Themed Blue Icon
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface), // Themed Adaptive Text
                    ),
                    value: isDarkMode,
                    activeColor: theme.colorScheme.primary, // Themed Primary Color for active switch
                    onChanged: (bool value) {
                      if (value) {
                        appThemeNotifier.value = ThemeMode.dark;
                      } else {
                        appThemeNotifier.value = ThemeMode.light;
                      }
                    },
                  );
                },
              ),
              Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              SwitchListTile(
                secondary: Icon(Icons.vibration, color: theme.colorScheme.secondary), // Themed Orange
                title: Text(
                  'Vibration',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                value: true,
                activeColor: theme.colorScheme.secondary, // Themed Orange switch
                onChanged: (bool value) {},
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.1),
        // Account Actions
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary, // Themed Blue Title
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, // Themed Surface
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Change Password',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface), // Themed Text
                ),
                trailing: Icon(Icons.lock_outline, color: theme.colorScheme.secondary), // Themed Orange
                onTap: () => _showChangePasswordDialog(),
              ),
              Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ListTile(
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error, // Themed Error Color
                  ),
                ),
                trailing: Icon(Icons.logout, color: theme.colorScheme.error), // Themed Error Color
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const AuthGate()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: ABOUT
  // ---------------------------------------------------------------------------
  Widget _buildAboutTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // App Info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, // Themed Surface
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Icon(Icons.school, size: 48, color: theme.colorScheme.primary), // Themed Blue Icon
              const SizedBox(height: 16),
              Text(
                'Tuklascope is a modern learning companion that helps you discover, track, and engage with educational content. Built with love and purpose to make learning accessible for everyone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.9), // Themed Description Text
                  height: 1.4,
                ),
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),

        // Developers
        Text(
          'Developed by:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary, // Themed Primary Title
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, // Themed Surface Background
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)), // Themed border
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.code, color: theme.colorScheme.secondary), // Themed secondary
                title: Text(
                  'John Michael A. Nave',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary), // Themed Name
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ListTile(
                leading: Icon(Icons.code, color: theme.colorScheme.secondary),
                title: Text(
                  'James Andrew S. Ologuin',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ListTile(
                leading: Icon(Icons.code, color: theme.colorScheme.secondary),
                title: Text(
                  'John Peter D. Pestaño',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ListTile(
                leading: Icon(Icons.code, color: theme.colorScheme.secondary),
                title: Text(
                  'Jordan A. Cabandon',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ListTile(
                leading: Icon(Icons.code, color: theme.colorScheme.secondary),
                title: Text(
                  'John Zachary N. Gillana',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),
      ],
    );
  }
}