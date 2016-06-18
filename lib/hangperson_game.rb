class HangpersonGame

  # add the necessary class methods, attributes, etc. here
  # to make the tests in spec/hangperson_game_spec.rb pass.

  # Get a word from remote "random word" service

  # def initialize()
  # end
  attr_accessor :word, :guesses, :wrong_guesses
  
  def initialize(word)
    @word = word
    @guesses = ''
    @wrong_guesses = ''
  end

  def self.get_random_word
    require 'uri'
    require 'net/http'
    uri = URI('http://watchout4snakes.com/wo4snakes/Random/RandomWord')
    Net::HTTP.post_form(uri ,{}).body
  end

  def guess letter
    raise ArgumentError if letter.nil? or letter.empty? or !(letter =~ /[a-z]/i)
    letter.downcase!
    if @word.include? letter and !@guesses.include? letter
      @guesses << letter
      return true
    end
    if !@word.include? letter and !@wrong_guesses.include? letter
      @wrong_guesses << letter
     return true
    end
    false
  end
  
  def word_with_guesses
    test_string = ''
    @word.split('').each do |letter|
      test_string << letter if @guesses.include? letter
      test_string << '-' if !@guesses.include? letter
    end
    test_string
  end
  
  def check_win_or_lose
    if word_with_guesses.include? '-'
      if @wrong_guesses.length < 7
        return :play
      else
        return :lose
      end
    else
      return :win
    end
  end
  
end
