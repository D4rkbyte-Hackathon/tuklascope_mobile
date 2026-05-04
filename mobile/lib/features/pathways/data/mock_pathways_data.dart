import '../models/project_data.dart';

// HARDCODED FOR TESTING. CHANGE TO SUPABASE DATA LATER
const int mockActivePathways = 2;
const double mockAverageProgress = 37.5;
const int mockTotalPoints = 900;

final List<ProjectData> myProjects = [

  ProjectData(

    title: "Kitchen Chemist",

    description: "Discover chemistry principles using everyday kitchen materials and ingredients.",

    image: "https://picsum.photos/id/102/400/200",

    difficulty: "Beginner",

    points: 200,

    progress: 0,

    tasks: [

      "Scan a box of baking soda and learn about acid-base reactions.",

      "Scan vinegar and discover how it reacts with other substances.",

      "Find a fruit and explore the vitamin C (ascorbic acid) content.",

      "Scan cooking oil and learn about lipid chemistry.",

      "Photograph a boiling pot and study heat transfer and phase changes.",

    ],

  ),

  ProjectData(

    title: "Backyard Ecologist",

    description: "Explore the living ecosystem right outside your door.",

    image: "https://picsum.photos/id/145/400/200",

    difficulty: "Beginner",

    points: 180,

    progress: 0,

    tasks: [

      "Scan a plant leaf and identify its role in photosynthesis.",

      "Find an insect and learn about its place in the food chain.",

      "Scan soil and discover the microorganisms living inside it.",

      "Photograph a bird and study its adaptation to its environment.",

      "Find a puddle or small water source and learn about the water cycle.",

    ],

  ),

  ProjectData(

    title: "Code Creator",

    description: "Uncover the technology and logic behind the devices around you.",

    image: "https://picsum.photos/id/180/400/200",

    difficulty: "Intermediate",

    points: 350,

    progress: 0,

    tasks: [

      "Scan a computer keyboard and learn about input devices and binary.",

      "Photograph a router and discover how data travels over the internet.",

      "Scan a USB drive and explore how data is stored digitally.",

      "Find a circuit board and learn about transistors and logic gates.",

      "Scan your phone screen and study how touchscreens detect input.",

    ],

  ),

  ProjectData(

    title: "Math in Nature",

    description: "Find mathematical patterns hidden in the natural world around you.",

    image: "https://picsum.photos/id/119/400/200",

    difficulty: "Beginner",

    points: 220,

    progress: 0,

    tasks: [

      "Scan a flower and count its petals to find Fibonacci numbers.",

      "Photograph a snail shell and study the golden spiral.",

      "Find a honeycomb or hexagonal pattern and explore tessellation.",

      "Scan a tree and learn about fractal geometry in branches.",

      "Photograph a spider web and discover radial symmetry and angles.",

    ],

  ),

  ProjectData(

    title: "Physics Explorer",

    description: "Investigate the forces and energy at work in your everyday surroundings.",

    image: "https://picsum.photos/id/160/400/200",

    difficulty: "Intermediate",

    points: 300,

    progress: 0,

    tasks: [

      "Scan a light bulb and study electricity and energy conversion.",

      "Photograph a swinging door and learn about levers and torque.",

      "Find a ramp or slope and explore inclined planes and gravity.",

      "Scan a magnet and discover the principles of magnetic fields.",

      "Photograph a mirror and learn about the law of reflection.",

    ],

  ),

  ProjectData(

    title: "Engineering Innovator",

    description: "Analyze the structures and machines built to solve real-world problems.",

    image: "https://picsum.photos/id/133/400/200",

    difficulty: "Advanced",

    points: 450,

    progress: 0,

    tasks: [

      "Scan a bridge or overpass and learn about load distribution.",

      "Photograph a gear or pulley and study mechanical advantage.",

      "Find a building and analyze how its foundation handles stress.",

      "Scan a water pipe system and explore fluid dynamics.",

      "Photograph a wind turbine or solar panel and study renewable energy.",

    ],

  ),

  ProjectData(

    title: "Market Maestro",

    description: "Understand business principles by observing trade and commerce around you.",

    image: "https://picsum.photos/id/152/400/200",

    difficulty: "Intermediate",

    points: 280,

    progress: 0,

    tasks: [

      "Scan a product label and learn about branding and target markets.",

      "Photograph a price tag and study supply, demand, and pricing strategy.",

      "Find a receipt and analyze cost, revenue, and profit margin.",

      "Scan an advertisement and explore marketing and consumer behavior.",

      "Photograph a local market stall and study micro-entrepreneurship.",

    ],

  ),

  ProjectData(

    title: "Community Chronicler",

    description: "Document and understand the history and culture of your local community.",

    image: "https://picsum.photos/id/111/400/200",

    difficulty: "Beginner",

    points: 200,

    progress: 0,

    tasks: [

      "Scan a historical marker or monument and research its significance.",

      "Photograph a traditional Filipino dish and learn its cultural origin.",

      "Find a local jeepney and discover its history as a cultural icon.",

      "Scan a piece of woven fabric (like banig) and learn its regional roots.",

      "Photograph a public mural and explore its social or political message.",

    ],

  ),

  ProjectData(

    title: "Gourmet Artisan",

    description: "Master the science and culture behind food preparation and culinary arts.",

    image: "https://picsum.photos/id/169/400/200",

    difficulty: "Intermediate",

    points: 260,

    progress: 0,

    tasks: [

      "Scan a raw egg and learn about protein denaturation when cooking.",

      "Photograph a loaf of bread and study fermentation and yeast activity.",

      "Find a spice like turmeric and learn about its chemical properties.",

      "Scan a knife and explore the metallurgy and engineering behind blades.",

      "Photograph a plated dish and study food presentation and aesthetics.",

    ],

  ),

  ProjectData(

    title: "Story Architect",

    description: "Build narratives and explore the art of storytelling through what you observe.",

    image: "https://picsum.photos/id/106/400/200",

    difficulty: "Beginner",

    points: 190,

    progress: 0,

    tasks: [

      "Scan an old photograph and write a short story about the people in it.",

      "Photograph an abandoned object and create a narrative about its past.",

      "Find a newspaper and analyze how journalists structure a story.",

      "Scan a book cover and predict the plot using visual cues.",

      "Photograph a street scene and write a descriptive paragraph using sensory details.",

    ],

  ),

];