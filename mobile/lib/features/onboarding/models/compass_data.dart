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
  ],
  'Others': [
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
  ],
};