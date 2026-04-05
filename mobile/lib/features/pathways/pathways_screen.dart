import 'package:flutter/material.dart';

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
    child: Scaffold(
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
    ),
    );
  }
}

// HARDCODED FOR TESTING. CHANGE TO SUPABASE DATA
int activePathways = 2;
double averageProgress = 37.5;
int totalPoints = 900;

// --- SECONDARY SKELETON ---         ///OLD REWARD SCREEN
/*class RewardScreen extends StatelessWidget { 
  const RewardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward Unlocked!')), // Free Back Button!
      body: const Center(child: Text('Screen 4.2: Action Success / Reward UI, edit herrreee')),
    );
  }
}*/

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

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), // Matching background in image
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE (Full Screen or half)
          Image.network(
            data.image,
            height: MediaQuery.of(context).size.height * 0.6, // Covers top 60%
            width: double.infinity,
            fit: BoxFit.cover,
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
                      color: isCompleted ? Colors.green : Colors.grey[400],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 6),
                    ),
                    child: Icon(Icons.star_rounded, size: 70, color: isCompleted ? Colors.yellow : Colors.white70),
                  ),
                ),
                
                // 4. TITLE
                const SizedBox(height: 15),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                ),
                
                // 5. THE CONTENT BLOCK (Like image_1.png)
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(25.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
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
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      
                      // POINTS & DATE BLOCK (Using a custom Widget class below)
                      const SizedBox(height: 25),
                      StatsBlock(data: data), 

                      // MILESTONES SECTION
                      const SizedBox(height: 30),
                      const Text("Quest Milestones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildMilestone("Task A", true),
                      _buildMilestone("Task B", false),
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

  // Helper widget to keep things clean (like image_1.png)
  Widget _buildMilestone(String title, bool isDone) {
    return ListTile(
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isDone ? Colors.green : Colors.grey,
      ),
      title: Text(title, style: TextStyle(color: isDone ? Colors.black87 : Colors.black54)),
    );
  }
}

// 6. THE STATS BLOCK (Points & Date)
class StatsBlock extends StatelessWidget {
  final ProjectData data;
  const StatsBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: IntrinsicHeight( // Crucial: Makes the vertical divider work
        child: Row(
          children: [
            // Left Side: Date/Progress
            Expanded(
              child: Column(
                children: [
                  Text( data.progress == 100 ? "Completion Date" : "Current Progress", style: TextStyle(color: Colors.black54)),
                  Text(
                    data.progress == 100 ? "December 13, 2025" : "${data.progress}% Done",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _getProgressColor(data.progress)),
                  ),
                ],
              ),
            ),
            
            // The Specialized Vertical Divider
            const VerticalDivider(width: 30, color: Colors.black26),

            // Right Side: Points
            Expanded(
              child: Column(
                children: [
                  const Text("Points", style: TextStyle(color: Colors.black54)),
                  Text("${data.points}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF0D3B66))),
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
              _buildStat("(${activePathways})", "Active Pathways", Colors.green),
              _buildStat("${averageProgress}%", "Average Progress", Colors.orange),
            ],
          ),
          const SizedBox(height: 20),
          _buildStat("(${totalPoints})", "Total Points Earned", const Color(0xFF0D3B66)),
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
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
    image: "https://cdn.discordapp.com/attachments/515699608580521984/1490364058266763365/jonard_smile.png?ex=69d3c931&is=69d277b1&hm=8b9ae869d22d9e440b6419886f887ac650baaa0e051075656661581195b54aad",
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
