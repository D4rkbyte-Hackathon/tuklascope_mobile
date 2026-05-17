enum Affinity { stem, abm, humss, tvl }

class CompassOption {
  final String text;
  final Affinity affinity;
  const CompassOption({required this.text, required this.affinity});
}

class CompassQuestion {
  final String question;
  final List<CompassOption> options;
  const CompassQuestion({required this.question, required this.options});
}

final Map<String, List<CompassQuestion>> compassQuestionBanks = {
  'Elementary': [
    const CompassQuestion(
      question: 'What is your favorite activity at school?',
      options: [
        CompassOption(text: 'Doing science experiments or math puzzles.', affinity: Affinity.stem),
        CompassOption(text: 'Being the group leader or selling items at the fair.', affinity: Affinity.abm),
        CompassOption(text: 'Reading stories or helping my classmates.', affinity: Affinity.humss),
        CompassOption(text: 'Building things with blocks or doing arts and crafts.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'If you had a free afternoon, what would you do?',
      options: [
        CompassOption(text: 'Watch a video about space or animals.', affinity: Affinity.stem),
        CompassOption(text: 'Play a board game where you manage money.', affinity: Affinity.abm),
        CompassOption(text: 'Write a story or talk with friends.', affinity: Affinity.humss),
        CompassOption(text: 'Help fix something broken in the house.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'When solving a puzzle, how do you do it?',
      options: [
        CompassOption(text: 'Sort the pieces by color and shape first.', affinity: Affinity.stem),
        CompassOption(text: 'Plan who does what part if I have help.', affinity: Affinity.abm),
        CompassOption(text: 'Ask someone how they would solve it.', affinity: Affinity.humss),
        CompassOption(text: 'Just start putting pieces together to see what fits.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What kind of hero do you like the most?',
      options: [
        CompassOption(text: 'The genius inventor with cool gadgets.', affinity: Affinity.stem),
        CompassOption(text: 'The smart leader who creates the master plan.', affinity: Affinity.abm),
        CompassOption(text: 'The kind hero who saves the town and makes peace.', affinity: Affinity.humss),
        CompassOption(text: 'The strong hero who builds the base and weapons.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What would be a fun field trip?',
      options: [
        CompassOption(text: 'A science museum or a zoo.', affinity: Affinity.stem),
        CompassOption(text: 'A big office building or a bank.', affinity: Affinity.abm),
        CompassOption(text: 'A history museum or watching a play.', affinity: Affinity.humss),
        CompassOption(text: 'A factory or a giant bakery.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What is your favorite kind of toy or game?',
      options: [
        CompassOption(text: 'A chemistry set or a rubiks cube.', affinity: Affinity.stem),
        CompassOption(text: 'Monopoly or games where you collect coins.', affinity: Affinity.abm),
        CompassOption(text: 'Dolls, action figures, or role-playing games.', affinity: Affinity.humss),
        CompassOption(text: 'Lego bricks or Play-Doh.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'How do you like to help out at home?',
      options: [
        CompassOption(text: 'Measuring ingredients exactly when baking.', affinity: Affinity.stem),
        CompassOption(text: 'Counting the change or organizing allowance.', affinity: Affinity.abm),
        CompassOption(text: 'Babysitting younger siblings or pets.', affinity: Affinity.humss),
        CompassOption(text: 'Gardening, sweeping, or fixing broken toys.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'If you started a school club, what would it be?',
      options: [
        CompassOption(text: 'The Math and Science Explorer Club.', affinity: Affinity.stem),
        CompassOption(text: 'The Student Store and Selling Club.', affinity: Affinity.abm),
        CompassOption(text: 'The Reading and Helping Others Club.', affinity: Affinity.humss),
        CompassOption(text: 'The Cooking and Crafting Club.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What kind of TV show or movie do you enjoy most?',
      options: [
        CompassOption(text: 'Documentaries about space, dinosaurs, or tech.', affinity: Affinity.stem),
        CompassOption(text: 'Shows about people running businesses or stores.', affinity: Affinity.abm),
        CompassOption(text: 'Dramas or cartoons with emotional stories.', affinity: Affinity.humss),
        CompassOption(text: 'Shows about building houses or cooking competitions.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'If you had a magic power, what would it be?',
      options: [
        CompassOption(text: 'Telekinesis to move objects and see how they work.', affinity: Affinity.stem),
        CompassOption(text: 'Mind-reading to know exactly what people want to buy.', affinity: Affinity.abm),
        CompassOption(text: 'Healing magic to cure anyone who is hurt.', affinity: Affinity.humss),
        CompassOption(text: 'Super strength to build giant structures quickly.', affinity: Affinity.tvl),
      ],
    ),
  ],
  'High School': [
    const CompassQuestion(
      question: 'What kind of school project excites you the most?',
      options: [
        CompassOption(text: 'Coding a program or conducting a lab experiment.', affinity: Affinity.stem),
        CompassOption(text: 'Creating a business plan or marketing a product.', affinity: Affinity.abm),
        CompassOption(text: 'Writing an essay on social issues or debating.', affinity: Affinity.humss),
        CompassOption(text: 'Drafting a design or assembling a physical model.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'In a group activity, what role do you naturally take?',
      options: [
        CompassOption(text: 'The researcher finding data and facts.', affinity: Affinity.stem),
        CompassOption(text: 'The manager assigning tasks and tracking progress.', affinity: Affinity.abm),
        CompassOption(text: 'The communicator ensuring everyone gets along.', affinity: Affinity.humss),
        CompassOption(text: 'The creator making the final presentation or prototype.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'Which of these problems would you most want to solve?',
      options: [
        CompassOption(text: 'Finding a cure for a disease or inventing a new tech.', affinity: Affinity.stem),
        CompassOption(text: 'Improving the economy or starting a successful company.', affinity: Affinity.abm),
        CompassOption(text: 'Fighting for human rights or helping communities.', affinity: Affinity.humss),
        CompassOption(text: 'Designing better infrastructure or creating culinary recipes.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What is your preferred way of learning?',
      options: [
        CompassOption(text: 'Understanding the underlying formulas and logic.', affinity: Affinity.stem),
        CompassOption(text: 'Analyzing case studies and real-world strategies.', affinity: Affinity.abm),
        CompassOption(text: 'Discussing theories and understanding human behavior.', affinity: Affinity.humss),
        CompassOption(text: 'Hands-on practice and repetition.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'Which extracurricular activity sounds best?',
      options: [
        CompassOption(text: 'Robotics or Math Club.', affinity: Affinity.stem),
        CompassOption(text: 'Student Council or Finance Club.', affinity: Affinity.abm),
        CompassOption(text: 'School Paper or Drama Club.', affinity: Affinity.humss),
        CompassOption(text: 'Culinary Arts or Drafting/Woodshop.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What would be your ideal summer job?',
      options: [
        CompassOption(text: 'IT intern or lab assistant.', affinity: Affinity.stem),
        CompassOption(text: 'Retail sales or working at a bank.', affinity: Affinity.abm),
        CompassOption(text: 'Camp counselor or community volunteer.', affinity: Affinity.humss),
        CompassOption(text: 'Mechanic, baker, or construction assistant.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'If you were organizing a school dance, what would you do?',
      options: [
        CompassOption(text: 'Set up the sound system and lighting tech.', affinity: Affinity.stem),
        CompassOption(text: 'Manage the budget and ticket sales.', affinity: Affinity.abm),
        CompassOption(text: 'Promote the event and write the announcements.', affinity: Affinity.humss),
        CompassOption(text: 'Build the decorations and prepare the food.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What do you watch most on YouTube or TikTok?',
      options: [
        CompassOption(text: 'Tech reviews, coding tutorials, or science experiments.', affinity: Affinity.stem),
        CompassOption(text: 'Crypto, stock market tips, or side-hustle ideas.', affinity: Affinity.abm),
        CompassOption(text: 'Vlogs, social commentary, or historical deep-dives.', affinity: Affinity.humss),
        CompassOption(text: 'DIY crafting, cooking channels, or car rebuilds.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'When faced with a difficult academic topic, how do you approach it?',
      options: [
        CompassOption(text: 'Look for research papers and objective data.', affinity: Affinity.stem),
        CompassOption(text: 'Find out how it applies to the real-world market.', affinity: Affinity.abm),
        CompassOption(text: 'Discuss it with peers to hear different perspectives.', affinity: Affinity.humss),
        CompassOption(text: 'Try to build a physical model or try it myself.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What is your favorite elective class?',
      options: [
        CompassOption(text: 'Computer Science or Advanced Physics.', affinity: Affinity.stem),
        CompassOption(text: 'Accounting or Business Management.', affinity: Affinity.abm),
        CompassOption(text: 'Psychology, Sociology, or Literature.', affinity: Affinity.humss),
        CompassOption(text: 'Woodshop, Culinary Arts, or Auto Mechanics.', affinity: Affinity.tvl),
      ],
    ),
  ],
  
  // 🚀 CHANGED THIS KEY TO 'Senior High School' = 'Others'
  'Senior High School': [
    const CompassQuestion(
      question: 'You are faced with a complex, real-world challenge. How do you approach it?',
      options: [
        CompassOption(text: 'Analyze the situation systematically using data and algorithms.', affinity: Affinity.stem),
        CompassOption(text: 'Evaluate resource allocation, risks, and financial impact.', affinity: Affinity.abm),
        CompassOption(text: 'Consider the societal impact and ethical implications.', affinity: Affinity.humss),
        CompassOption(text: 'Take practical, hands-on steps to build a functional solution.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What kind of environment do you thrive in the most?',
      options: [
        CompassOption(text: 'A structured lab or highly technical research facility.', affinity: Affinity.stem),
        CompassOption(text: 'A fast-paced corporate boardroom or entrepreneurial hub.', affinity: Affinity.abm),
        CompassOption(text: 'A collaborative NGO, classroom, or public service sector.', affinity: Affinity.humss),
        CompassOption(text: 'A dynamic workshop, kitchen, or fieldwork environment.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'When reading the news, what section do you jump to first?',
      options: [
        CompassOption(text: 'Technology, Science, or Medicine.', affinity: Affinity.stem),
        CompassOption(text: 'Markets, Business, or the Economy.', affinity: Affinity.abm),
        CompassOption(text: 'World News, Politics, or Opinion Editorials.', affinity: Affinity.humss),
        CompassOption(text: 'Lifestyle, Automotive, or Craftsmanship.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'If you were to write a book, what would it be about?',
      options: [
        CompassOption(text: 'The future of artificial intelligence and space travel.', affinity: Affinity.stem),
        CompassOption(text: 'Strategies for scaling a global enterprise.', affinity: Affinity.abm),
        CompassOption(text: 'A deep dive into human psychology or history.', affinity: Affinity.humss),
        CompassOption(text: 'A comprehensive guide to mastering a trade or craft.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What is your ultimate career goal?',
      options: [
        CompassOption(text: 'To discover or invent something entirely new.', affinity: Affinity.stem),
        CompassOption(text: 'To lead a successful enterprise or multinational venture.', affinity: Affinity.abm),
        CompassOption(text: 'To inspire, teach, or create positive social change.', affinity: Affinity.humss),
        CompassOption(text: 'To be recognized as a master of a highly specialized skill.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'If you had to invest your savings, where would you put it?',
      options: [
        CompassOption(text: 'Emerging tech startups and biotech.', affinity: Affinity.stem),
        CompassOption(text: 'Real estate, stocks, and mutual funds.', affinity: Affinity.abm),
        CompassOption(text: 'Social enterprises and educational non-profits.', affinity: Affinity.humss),
        CompassOption(text: 'Manufacturing, agriculture, or a local restaurant.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'How do you prefer to volunteer your time?',
      options: [
        CompassOption(text: 'Doing data analysis or IT support for a charity.', affinity: Affinity.stem),
        CompassOption(text: 'Organizing fundraisers and managing donations.', affinity: Affinity.abm),
        CompassOption(text: 'Counseling, mentoring, or teaching others.', affinity: Affinity.humss),
        CompassOption(text: 'Building shelters, cooking meals, or cleaning parks.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What kind of podcast are you most likely to listen to?',
      options: [
        CompassOption(text: 'Science breakthroughs and coding logic.', affinity: Affinity.stem),
        CompassOption(text: 'Economics, leadership, and market trends.', affinity: Affinity.abm),
        CompassOption(text: 'Philosophy, history, and human stories.', affinity: Affinity.humss),
        CompassOption(text: 'Maker spaces, DIY tips, and craftsmanship.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'How do you handle conflict in the workplace?',
      options: [
        CompassOption(text: 'Rely on objective data and logical reasoning.', affinity: Affinity.stem),
        CompassOption(text: 'Negotiate a compromise that benefits the bottom line.', affinity: Affinity.abm),
        CompassOption(text: 'Mediate the emotional issues and build consensus.', affinity: Affinity.humss),
        CompassOption(text: 'Find a practical, hands-on workaround immediately.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What legacy do you want to leave behind?',
      options: [
        CompassOption(text: 'A groundbreaking technological invention.', affinity: Affinity.stem),
        CompassOption(text: 'A massive, sustainable global empire.', affinity: Affinity.abm),
        CompassOption(text: 'A movement that changed society for the better.', affinity: Affinity.humss),
        CompassOption(text: 'A tangible masterpiece or perfectly built infrastructure.', affinity: Affinity.tvl),
      ],
    ),
  ],
};