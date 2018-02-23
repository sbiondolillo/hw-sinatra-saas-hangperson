require 'uri'
require 'net/http'

class HangpersonGame
  class RandomWordGenerator
    URL_RANDOM_WORD_SERVICE = 'http://watchout4snakes.com/wo4snakes/Random/RandomWord'

    def generate
      Net::HTTP.post_form(uri ,{}).body
    end

    private
      def uri
        URI(URL_RANDOM_WORD_SERVICE)
      end
  end

  REGEXP_VALID_GUESS = /[a-z]/i
  CHAR_DISPLAY_UNGUESSED_LETTER = '-'
  MAX_GUESSES = 7

  GAME_STATUS_PLAY = :play
  GAME_STATUS_WIN = :win
  GAME_STATUS_LOSE = :lose

  attr_accessor :word, :guesses, :wrong_guesses
  def initialize(word)
    @word = word
    @guesses = ''
    @wrong_guesses = ''
  end

  # Get a word from remote "random word" service
  def self.get_random_word
    RandomWordGenerator.new.generate
  end

  def guess(letter)
    if letter.nil? || letter.empty? || !(letter =~ REGEXP_VALID_GUESS)
      raise ArgumentError
    end
    letter.downcase!

    if word.include?(letter) && !guesses.include?(letter)
      guesses << letter
      true
    elsif !word.include?(letter) && !wrong_guesses.include?(letter)
      wrong_guesses << letter
      true
    else
      false
    end
  end
  
  def word_with_guesses
    test_string = ''
    word.split('').each do |letter|
      test_string << letter if guesses.include?(letter)
      test_string << CHAR_DISPLAY_UNGUESSED_LETTER if !guesses.include?(letter)
    end
    test_string
  end
  
  def game_status
    if word_with_guesses.include?(CHAR_DISPLAY_UNGUESSED_LETTER)
      wrong_guesses.length < MAX_GUESSES ? GAME_STATUS_PLAY : GAME_STATUS_LOSE
    else
      GAME_STATUS_WIN
    end
  end
end
