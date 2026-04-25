import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // 1. IMPORT ADDED
import '../../core/widgets/gradient_scaffold.dart';

class PathwaysScreen extends StatelessWidget {
  const PathwaysScreen({super.key});

  @override
  Widget build(BuildContext context) { //main Editing area
    return PopScope(
    canPop: true, // Allows the back button to work
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      // You can add custom logic here if you wanted to show a "Are you sure?" dialog
    }, 
    child: GradientScaffold(
      //appBar: AppBar(title: const Text('Learning Pathways')),
      body: Center(
        child: ListView.builder(
          itemCount: 1 + myProjects.length, // Total items in our "array"
          itemBuilder: (context, index) {
            Widget item;
            
            if (index == 0) {
              item = const HeaderSection(); // Your custom header widget
            } else {
              // This function runs for every item in the list
              item = ProjectCard(data: myProjects[index - 1]);
            }
            
            // 2. STAGGERED ANIMATION APPLIED HERE
            return item
                .animate()
                .fade(duration: 600.ms, delay: (100 * index).ms)
                .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (100 * index).ms);
          },
        ),
      ),
    ),
    );
  }
}

// HARDCODED FOR TESTING. CHANGE TO SUPABASE DATA
int activePathways = 2;
double averageProgress = 37.5;
int totalPoints = 900;

// Helper logic for the points section colors
  Color _getProgressColor(int progress) {
    if (progress <= 40) return Colors.orangeAccent;
    if (progress <= 60) return Colors.yellow[700]!;
    if (progress <= 80) return Colors.lime;
    return Colors.green;
  }

//NEW REWARD SCREEN
class RewardScreen extends StatelessWidget {
  final ProjectData data; // Receiving the same data

  const RewardScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    bool isCompleted = data.progress == 100;
    final theme = Theme.of(context); // Dynamically grab the theme

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Themed Background
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE (Full Screen or half)
          Image.network(
            data.image,
            height: MediaQuery.of(context).size.height * 0.6, // Covers top 60%
            width: double.infinity,
            fit: BoxFit.cover,
            // Fallback for dead Discord links so it doesn't crash
            errorBuilder: (context, error, stackTrace) => Container(
              height: MediaQuery.of(context).size.height * 0.6,
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              child: Icon(Icons.image_not_supported, size: 50, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ),
          ),

          // 2. MAIN CONTENT SCROLLER
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100), // Push the badge down over the image
                
                // 3. THE BADGE/MEDAL (Overlapping)
                Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 6),
                    ),
                    child: Icon(Icons.star_rounded, size: 70, color: isCompleted ? Colors.yellow : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  ),
                ),
                
                // 4. TITLE
                const SizedBox(height: 15),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1, shadows: [Shadow(color: Colors.black54, blurRadius: 10)]),
                ),
                
                // 5. THE CONTENT BLOCK (Like image_1.png)
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface, // Themed Surface
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DESCRIPTION (Conditional)
                      Text(
                        isCompleted
                            ? "Congratulations! You've completed the ${data.title} journey."
                            : "You have not completed this task yet. Track your milestones below.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.9)), // Themed Text
                      ),
                      
                      // POINTS & DATE BLOCK (Using a custom Widget class below)
                      const SizedBox(height: 25),
                      StatsBlock(data: data), 

                      // MILESTONES SECTION
                      const SizedBox(height: 30),
                      Text("Quest Milestones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)), // Themed Title
                      _buildMilestone("Task A", true, theme),
                      _buildMilestone("Task B", false, theme),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // BACK BUTTON (Over the image)
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.3), // Added slight background to ensure visibility over light images
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to keep things clean
  Widget _buildMilestone(String title, bool isDone, ThemeData theme) {
    return ListTile(
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isDone ? Colors.green : theme.colorScheme.onSurface.withValues(alpha: 0.4), // Themed unchecked icon
      ),
      title: Text(title, style: TextStyle(color: isDone ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.6))), // Themed text
    );
  }
}

// 6. THE STATS BLOCK (Points & Date)
class StatsBlock extends StatelessWidget {
  final ProjectData data;
  const StatsBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Dynamically grab the theme

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // Themed Background inside the card
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), width: 1), // Themed Border
      ),
      child: IntrinsicHeight( // Crucial: Makes the vertical divider work
        child: Row(
          children: [
            // Left Side: Date/Progress
            Expanded(
              child: Column(
                children: [
                  Text( data.progress == 100 ? "Completion Date" : "Current Progress", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))), // Themed Label
                  Text(
                    data.progress == 100 ? "December 13, 2025" : "${data.progress}% Done",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _getProgressColor(data.progress)),
                  ),
                ],
              ),
            ),
            
            // The Specialized Vertical Divider
            VerticalDivider(width: 30, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)), // Themed Divider

            // Right Side: Points
            Expanded(
              child: Column(
                children: [
                  Text("Points", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))), // Themed Label
                  Text("${data.points}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: theme.colorScheme.primary)), // Themed Blue
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// HEADER SECTION WIDGET
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Dynamically grab the theme

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // "Learning Pathways" with two colors
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Learning ',
                  style: TextStyle(color: theme.colorScheme.primary), // Themed Primary
                ),
                TextSpan(
                  text: 'Pathways',
                  style: TextStyle(color: theme.colorScheme.secondary), // Themed Secondary
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Structured learning journeys that elevate the experience...",
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)), // Themed Subtitle
          ),
          const SizedBox(height: 30),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("($activePathways)", "Active Pathways", Colors.green, theme),
              _buildStat("$averageProgress%", "Average Progress", theme.colorScheme.secondary, theme), // Themed Secondary
            ],
          ),
          const SizedBox(height: 20),
          _buildStat("($totalPoints)", "Total Points Earned", theme.colorScheme.primary, theme), // Themed Primary
        ],
      ),
    );
  }

  // Helper method to keep things clean (like a small function in C)
  Widget _buildStat(String value, String label, Color numcolor, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: numcolor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6), // Themed Label
          ),
        ),
      ],
    );
  }
}


// DATA STRUCT FOR CUSTOM CARD
class ProjectData {
  final String title;
  final String description;
  final String image;
  final String difficulty;
  final int points;
  final int progress;

  ProjectData({
    required this.title,
    required this.description,
    required this.image,
    required this.difficulty,
    required this.points,
    required this.progress,
  });
}

// CUSTOM CARD WIDGET FOR REUSABILITY
class ProjectCard extends StatelessWidget {
  final ProjectData data; // Receiving the "struct"

  const ProjectCard({super.key, required this.data});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Dynamically grab the theme

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface, // Themed Surface
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), width: 1), // Subtle themed border
      ),
      elevation: theme.brightness == Brightness.dark ? 0 : 2, // Remove hard shadow in dark mode
      clipBehavior: Clip.antiAlias, // Ensures image corners are clipped
      child: InkWell(
        onTap: () {
          // 2. TRIGGER NAVIGATION HERE
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RewardScreen(data: data), // We are passing the same 'data' object
            ),
          );
        },
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Half: Image
          Image.network(
            data.image,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            // I added a quick errorBuilder here too just so it doesn't crash your list if a discord link dies!
            errorBuilder: (context, error, stackTrace) => Container(
              height: 140,
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              child: Icon(Icons.image_not_supported, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ),
          ),

          // Bottom Half: Text Content
          Padding(
            padding: const EdgeInsets.all(16.0), // Slightly increased padding for premium feel
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1: Difficulty and Points
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.difficulty,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary, // Themed Blue
                      ),
                    ),
                    Text(
                      "${data.points} Points",
                      style: TextStyle(
                        color: theme.colorScheme.secondary, // Themed Orange
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Line 2: Title
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface, // Themed Text
                  ),
                ),
                const SizedBox(height: 4), // Small spacing
                // Line 3: Description
                Text(
                  data.description,
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13), // Themed Description
                ),
                const SizedBox(height: 16),
                // Line 4: Progress with fixed-width number
                Row(
                  children: [
                    Text("Progress:", style: TextStyle(color: theme.colorScheme.onSurface)), // Themed Label
                    const SizedBox(width: 8), // "m" space
                    SizedBox(
                      width: 30, // Reserved space for the number
                      child: Text(
                        "${data.progress}",
                        textAlign: TextAlign.end,
                        style: TextStyle(fontWeight: FontWeight.bold, color: _getProgressColor(data.progress)),
                      ),
                    ),
                    Text("% Completed", style: TextStyle(color: _getProgressColor(data.progress))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
      );
  }
}

// PLACEHOLDER DATA FOR TESTING THE CUSTOM CARD
// CHANGE THIS LATER SO THAT DATA CAN BE RETRIEVE FROM SUPABASE THEN PARSED INTO THE STRUCT
final List<ProjectData> myProjects = [
  ProjectData(
    title: "Smiling Masterclass",
    description: "Smile no matter the situation you're in.",
    image: "https://picsum.photos/id/10/400/200",
    difficulty: "Advanced",
    points: 670,
    progress: 100,
  ),
  ProjectData(
    title: "Database Basics",
    description: "Setting up your first Supabase table.",
    image: "https://picsum.photos/id/10/400/200",
    difficulty: "Beginner",
    points: 150,
    progress: 80,
  ),
  ProjectData(
    title: "UI Mastery",
    description: "Advanced layout and widget nesting.",
    image: "https://picsum.photos/id/20/400/200",
    difficulty: "Intermediate",
    points: 300,
    progress: 45,
  ),
  ProjectData(
    title: "State Management",
    description: "Handling data flow across your app.",
    image: "https://picsum.photos/id/30/400/200",
    difficulty: "Advanced",
    points: 500,
    progress: 10,
  ),
  ProjectData(
    title: "Final Integration",
    description: "Connecting the frontend to the backend.",
    image: "https://picsum.photos/id/40/400/200",
    difficulty: "Intermediate",
    points: 250,
    progress: 0,
  ),
];