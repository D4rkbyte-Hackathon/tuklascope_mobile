import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/navigation/main_nav_scope.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../auth/providers/auth_controller.dart'; 
import 'pathfinder_blueprint_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const Color _navy = Color(0xFF0D3B66);
  static const Color _cream = Color(0xFFF9F6F0);
  static const Color _linkBlue = Color(0xFF42A5F5);
  static const Color _avgLevel = Color(0xFFE65100);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserState = ref.watch(appUserProvider);

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Profile & Skill Tree'),
        foregroundColor: _navy,
        backgroundColor: Colors.transparent, 
        elevation: 0, 
      ),
      body: appUserState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (appUser) {
          if (appUser == null) {
            return const Center(child: Text('Please log in.'));
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
              navy: _navy,
              linkBlue: _linkBlue,
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
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(
                      text: 'Your ',
                      style: TextStyle(color: _navy),
                    ),
                    TextSpan(
                      text: 'Skill Tree',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 28),
              child: Text(
                'Watch your knowledge grow! Every discovery adds to your personal skill network and unlocks new learning pathways.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.35,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: _StatsGridCard(navy: _navy, avgLevelColor: _avgLevel),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _SkillTreePlaceholderCard(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ProfilePromoCard(
                borderColor: Colors.orange,
                title: 'Open Your Blueprint',
                description: 'From core principles to career path.',
                buttonLabel: 'Open Pathfinder →',
                buttonColor: _navy,
                onPressed: () => showPathfinderBlueprintSheet(
                  context,
                  onNavigateToScan: () =>
                      MainNavScope.maybeOf(context)?.goToTab(1),
                ),
              ),
            ),
            _ProfilePromoCard(
              borderColor: _navy.withValues(alpha: 0.35),
              title: 'Ready to expand your network?',
              description:
                  'Upload a photo of any object around you and discover the concepts behind it!',
              buttonLabel: 'Start Discovery →',
              buttonColor: Colors.orange,
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
  final Color borderColor;
  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _ProfilePromoCard({
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
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B66),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
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
  final Color navy;
  final Color linkBlue;
  final String fullName;
  final String educationLevel;
  final String location;
  final int streak;
  final VoidCallback onEditPressed;

  const _ProfileHeaderCard({
    required this.navy,
    required this.linkBlue,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12, width: 0.5),
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
                  border: Border.all(color: navy, width: 4),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
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
                        color: navy,
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
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                        children: [
                          const TextSpan(text: 'Daily Streak '),
                          TextSpan(
                            text: '$streak',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
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
                  color: linkBlue,
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
  final Color navy;
  final Color avgLevelColor;

  const _StatsGridCard({required this.navy, required this.avgLevelColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: _StatCell(
                  value: '67%',
                  label: 'Total Progress',
                  valueColor: Colors.orange,
                ),
              ),
              Expanded(
                child: _StatCell(
                  value: '420',
                  label: 'Total EXP',
                  valueColor: navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: _StatCell(
                  value: '33',
                  label: 'Concepts Mastered',
                  valueColor: Colors.green,
                ),
              ),
              Expanded(
                child: _StatCell(
                  value: '1',
                  label: 'Average Level',
                  valueColor: avgLevelColor,
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

  const _StatCell({
    required this.value,
    required this.label,
    required this.valueColor,
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillTreePlaceholderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(
                color: Colors.black,
                child: CustomPaint(painter: _SkillTreeGraphPainter()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '(placeholder pic)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillTreeGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.2;

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
          ..color = Colors.white24
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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const Color _navy = Color(0xFF0D3B66);

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

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        foregroundColor: _navy,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black12, width: 1),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                _buildProfileTab(),
                _buildSettingsTab(),
                _buildAboutTab(),
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
  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // Avatar Section
        Center(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 3),
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, size: 70, color: Colors.grey[500]),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.orange, size: 22),
                    onPressed: () {}, // Placeholder
                  ),
                ),
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.1),

        const SizedBox(height: 30),

        // Edit Info Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: _navy),
                title: const Text('Username', style: TextStyle(color: Colors.black54, fontSize: 12)),
                subtitle: const Text('JohnDelaCruz_01', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: const Icon(Icons.edit, color: Colors.orange, size: 20),
                onTap: () {}, // Placeholder
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.email_outlined, color: _navy),
                title: Text('Email', style: TextStyle(color: Colors.black54, fontSize: 12)),
                subtitle: Text('johndelacruz@example.com', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),

        const SizedBox(height: 30),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: SETTINGS
  // ---------------------------------------------------------------------------
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode, color: Colors.orange),
                title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                value: false, // Placeholder
                activeColor: Colors.orange,
                onChanged: (bool value) {},
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.vibration, color: Colors.orange),
                title: const Text('Vibration', style: TextStyle(fontWeight: FontWeight.bold)),
                value: true, // Placeholder
                activeColor: Colors.orange,
                onChanged: (bool value) {},
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.1),
        // Account Actions
        const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navy)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.lock_outline, color: Colors.orange),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Exit App', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                trailing: const Icon(Icons.cancel_outlined, color: Colors.amber),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                trailing: const Icon(Icons.logout, color: Colors.red),
                onTap: () {},
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
  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // App Info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12),
          ),
          child: const Column(
            children: [
              Icon(Icons.school, size: 48, color: _navy),
              SizedBox(height: 16),
              Text(
                'Tuklascope is a modern learning companion that helps you discover, track, and engage with educational content. Built with love and purpose to make learning accessible for everyone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),

        // Developers
        const Text('Developed by:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _navy)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.code, color: Colors.orange),
                title: const Text('John Michael A. Nave', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.code, color: Colors.orange),
                title: const Text('James Andrew S. Ologuin', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.code, color: Colors.orange),
                title: const Text('John Peter D. Pestaño', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.code, color: Colors.orange),
                title: const Text('Jordan A. Cabandon', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.code, color: Colors.orange),
                title: const Text('John Zachary N. Gillana', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)),
                onTap: () {},
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),

        // Credits
        const Text('Credits:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _navy)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('chuchuchu', style: TextStyle(fontSize: 12, color: Colors.black54)),
                subtitle: const Text('chuchuchu', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('chuchuchu', style: TextStyle(fontSize: 12, color: Colors.black54)),
                subtitle: const Text('chuchuchu', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('chuchuchu', style: TextStyle(fontSize: 12, color: Colors.black54)),
                subtitle: const Text('chuchuchu', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)),
                onTap: () {},
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }
}