# top class
class Player
  attr_accessor :choice, :name, :score, :choices

  def initialize
    set_name
    @score = 0
    @choices = []
  end
end
# ------------------------------------------------------------------------------
class Human < Player
  def set_name
    puts 'Set your name: '
    answer = gets.chomp
    if answer.squeeze == ' ' || answer == ''
      puts 'Name can not be set to empty!'
      ask_name
    else
      self.name = answer.split.map(&:capitalize).join(' ')
    end
  end

  def regularize_choice(choice)
    Choice::MOVES_AND_WINS.keys.each do |full_move|
      if choice.downcase.start_with?('s')
        return '' if choice.length < 2
        return full_move if full_move.match(Regexp.new(choice[0, 2], true))
      elsif full_move.start_with?(choice.downcase)
        return full_move
      end
    end
  end

  def ask_choice
    prompt_valid_choices
    answer = gets.chomp # r or rock
    regularize_choice(answer)
  end

  def prompt_valid_choices
    puts "\nPlease choose from (#{Choice::MOVES_AND_WINS.keys.join(', ')}): "
    puts 'Or use simplified: (r, p, sc, l, sp)'
  end

  def choose
    choice = nil
    loop do
      choice = ask_choice
      break if Choice::MOVES_AND_WINS.keys.include?(choice)
      puts 'Sorry, invalid choice!'
    end
    chosed = Choice.new(choice)
    self.choice = chosed
    choices << chosed.value
  end
end
# ----------------------------------------------------------------------
class Computer < Player
  attr_accessor :weights, :personality

  def initialize
    @personality = Personality.new
    super
  end

  def set_name
    self.name = personality.type + ' ' + ('a'..'z').to_a.sample(4).join.upcase
  end

  def weightest_choice
    personality.weights.max_by { |_, v| v }[0]
  end

  def choose
    chosed = Choice.new(weightest_choice)
    self.choice = chosed
    choices << chosed.value
  end
end
# ------------------------------------------------------------------------------
module Stylable
  def lazilize
    weights[preference] *= 1.2
  end

  def rockilize
    weights['rock'] *= 1.2
  end

  def stubbornize
    weights.each { |k, _| weights[k] = 0 unless k == preference }
  end

  def casualize
    weights.each { |k, _| weights[k] = rand(100) }
  end
end
# ------------------------------------------------------------------------------
class Personality
  include Stylable
  attr_accessor :type, :preference, :weights
  TYPES = %w[Rocky Stubborn Casual Lazy].freeze
  # lazy: choose one option and continuely allocate more weight to this choice
  # rocky: will allocate more weight to rock, always
  # stubborn: randomly choose one item then stick to it
  # casual: randomly chooses

  def initialize
    @type = TYPES.sample
    if @type == 'Lazy' || @type == 'Stubborn'
      @preference = Choice::MOVES_AND_WINS.keys.sample
    elsif @type == 'Rocky'
      @preference = 'rock'
    end
    @weights = {}
    Choice::MOVES_AND_WINS.keys.each { |choice| @weights[choice] = 20 }
  end

  def reallocate_weights(last_winner, last_choice)
    case last_winner
    when 'human'
      @weights[last_choice] -= 10
    when 'computer'
      @weights[last_choice] += 10
    end
    readjust_weights
  end

  def readjust_weights
    case type
    when 'Lazy' then lazilize
    when 'Rocky' then rockilize
    when 'Stubborn' then stubbornize
    when 'Casual' then casualize
    end
  end
end
# ------------------------------------------------------------------------------
class Choice
  include Comparable
  MOVES_AND_WINS = {
    'rock' => %w[scissors lizard],
    'paper' => %w[rock spock],
    'scissors' => %w[paper lizard],
    'lizard' => %w[spock paper],
    'spock' => %w[rock scissors]
  }.freeze
  attr_accessor :value
  def initialize(value)
    @value = value
  end

  def <=>(other)
    c1 = value
    c2 = other.value
    if MOVES_AND_WINS[c1].include?(c2)
      1
    elsif c1 == c2
      0
    else
      -1
    end
  end

  def to_s
    @value
  end
end
# ------------------------------------------------------------------------------
class RPSGame
  attr_accessor :human, :computer, :finnal_winner, :last_winner
  @@winning_score = 1

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def set_winning_score
    puts "\nPlease set a winning score(number of rounds to win): "
    answer = gets.chomp
    if answer.to_i.to_s == answer
      @@winning_score = answer.to_i
      puts " The one who first won #{@@winning_score} \
  rounds would be the finnal winner".centralize
    else
      puts 'You should enter a number: '
      set_winning_score
    end
  end

  def update_winner_and_score
    self.last_winner =
      if human.choice == computer.choice
        'none'
      elsif human.choice > computer.choice
        'human'
      else
        'computer'
      end
    update_scores
  end

  def display_result
    case last_winner
    when 'none'
      puts 'It\'s a Tie this round!!!'
    when 'computer'
      puts 'You Lost this round!!!'
    else
      puts 'You Won this round!!!'
    end
  end

  def conclude
    update_winner_and_score
    computer.personality.reallocate_weights(last_winner, computer.choice.value)
  end

  def update_scores
    case last_winner
    when 'human' then human.score += 1
    when 'computer' then computer.score += 1
    end
  end

  def display_choices_and_scores
    system('clear')
    puts "(You)[#{human.choice}] VS [#{computer.choice}](#{computer.name})"
    display_result
    puts "\nCurrent scores: #{human.name}( #{human.score} ) \
VS #{computer.name}( #{computer.score} )"
  end

  def operate_game
    if computer.score >= @@winning_score then self.finnal_winner = computer
    elsif human.score >= @@winning_score then self.finnal_winner = human
    else
      round_fight
      operate_game
    end
  end

  def round_fight
    human.choose
    computer.choose
    conclude
    display_choices_and_scores
  end

  def display_players
    puts " #{human.name} VS #{computer.name} ".centralize('-')
  end

  def play_again?
    puts "\nPlay again? Press 'y' to continue, any other input to exit"
    answer = gets.chomp
    if answer.downcase.start_with?('y')
      true
    else
      false
    end
  end

  def reset_score
    human.score = 0
    computer.score = 0
  end

  def begin
    loop do
      system('clear')
      puts " Hello #{human.name}! Welcome to Rock Paper Scissors! ".centralize
      set_winning_score
      display_players
      operate_game
      puts " #{finnal_winner.name} finally won!!! ".centralize('-')
      break unless play_again?
      reset_score
    end
  end
end
# ------------------------------------------------------------------------------
class String
  def centralize(sym = ' ')
    center(80, sym)
  end
end

RPSGame.new.begin
