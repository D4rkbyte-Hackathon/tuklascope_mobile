import 'package:flutter/material.dart';

class PathwaysScreen extends StatelessWidget {
  const PathwaysScreen({super.key});

  @override
  Widget build(BuildContext context) { //main Editing area
    return Scaffold(
      //appBar: AppBar(title: const Text('Learning Pathways')),
      body: Center(
        child: ListView.builder(
          itemCount: 1 + myProjects.length, // Total items in our "array"
          itemBuilder: (context, index) {
            if (index == 0) {
              return const HeaderSection(); // Your custom header widget
            }
            // This function runs for every item in the list
            return ProjectCard(data: myProjects[index - 1]);
          },
        ),
      ),
    );
  }
}

// HARDCODED FOR TESTING. CHANGE TO SUPABASE DATA
int ActivePathways = 2;
double AverageProgress = 37.5;
int TotalPoints = 900;

// --- SECONDARY SKELETON ---
class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward Unlocked!')), // Free Back Button!
      body: const Center(child: Text('Screen 4.2: Action Success / Reward UI, edit herrreee')),
    );
  }
}

// HEADER SECTION WIDGET
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // "Learning Pathways" with two colors
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Learning ',
                  style: TextStyle(color: Color(0xFF0D3B66)),
                ),
                TextSpan(
                  text: 'Pathways',
                  style: TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Structured learning journeys that elevate the experience...",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 30),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("(${ActivePathways})", "Active Pathways", Colors.green),
              _buildStat("${AverageProgress}%", "Average Progress", Colors.orange),
            ],
          ),
          const SizedBox(height: 20),
          _buildStat("(${TotalPoints})", "Total Points Earned", const Color(0xFF0D3B66)),
        ],
      ),
    );
  }

  // Helper method to keep things clean (like a small function in C)
  Widget _buildStat(String value, String label, Color numcolor) {
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
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

// CUSTOM CARD WIDGET FOR REUSABILITY (thanks geminein)
class ProjectCard extends StatelessWidget {
  final ProjectData data; // Receiving the "struct"

  const ProjectCard({super.key, required this.data});
  
  Color _getProgressColor(int progress) {
    if (progress <= 40) {
      return Colors.orangeAccent; // Dull orange
    } else if (progress <= 60) {
      return Colors.yellow[700]!; // Yellow (using a shade)
    } else if (progress <= 80) {
      return Colors.lime; // Lime
    } else {
      return Colors.green; // Green for 81%+
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias, // Ensures image corners are clipped
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Half: Image
          Image.network(
            data.image,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // Bottom Half: Text Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1: Difficulty and Points
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.difficulty,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      "${data.points} Points",
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Line 2: Title
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Line 3: Description
                Text(
                  data.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                // Line 4: Progress with fixed-width number
                Row(
                  children: [
                    const Text("Progress:"),
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
    );
  }
}

// PLACEHOLDER DATA FOR TESTING THE CUSTOM CARD
// CHANGE THIS LATER SO THAT DATA CAN BE RETRIEVE FROM SUPABASE THEN PARSED INTO THE STRUCT
final List<ProjectData> myProjects = [
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
