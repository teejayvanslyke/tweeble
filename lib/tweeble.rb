$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
gem     'twitter'
require 'twitter'

module Tweeble
  VERSION = '0.0.1'

  class Game
    def initialize
      @twitter = Twitter::Base.new('tweeble', '1q2w3e4raqwsderf')
    end

    def play!
      @start = @twitter.update("*#{puzzle}*")
    end

    def puzzle 
      @puzzle ||= Tweeble::Puzzle.new
    end

    def tally!
      @twitter.update("*#{puzzle}* winner is @#{winning_reply.user} with '#{winning_reply.text}'")
    end

    def winning_reply
      replies = Twitter::Search.new('#tweeble').since(@start.id)

      winning_reply = nil
      replies.each do |r| 
        reply = Tweeble::Reply.new(self.puzzle, r)
        if winning_reply.nil?
          winning_reply = reply
        elsif reply.score > winning_reply.score
          winning_reply = reply
        end
      end

      return winning_reply
    end

  end

  class Reply
    attr_reader :text, :user

    def initialize(puzzle, status)
      @puzzle = puzzle
      puts status.inspect
      @text = status.text.gsub('#tweeble','').downcase.gsub(/[^a-z]/,'')
      @user = status.from_user
    end

    LETTER_SCORES = 
      {
      'a' => 1,
      'b' => 3,
      'c' => 3,
      'd' => 2,
      'e' => 1,
      'f' => 4,
      'g' => 2,
      'h' => 4,
      'i' => 1,
      'j' => 8,
      'k' => 5,
      'l' => 1,
      'm' => 3,
      'n' => 1,
      'o' => 1,
      'p' => 3,
      'q' => 10,
      'r' => 1,
      's' => 1,
      't' => 1,
      'u' => 1,
      'v' => 4,
      'w' => 4,
      'x' => 8,
      'y' => 4,
      'z' => 10
      }
    def score
      return @score if @score
      @score = 0
      @text.each_byte do |c|
        if LETTER_SCORES[c]
          @score += LETTER_SCORES[c]
        end
      end
      @score
    end

    def match?
      @puzzle.match?(self) && is_word?
    end

    def is_word?
      ! `echo '#{@text}' | aspell -a`.include?('dissatisfied')
    end
  end

  class Puzzle
    LETTER_FREQUENCIES = 
      {
      'a' => 8.167,
      'b' => 1.492,
      'c' => 2.782,
      'd' => 4.253,
      'e' => 12.702,
      'f' => 2.228,
      'g' => 2.015,
      'h' => 6.094,
      'i' => 6.966,
      'j' => 0.153,
      'k' => 0.772,
      'l' => 4.025,
      'm' => 2.406,
      'n' => 6.749,
      'o' => 7.507,
      'p' => 1.929,
      'q' => 0.095,
      'r' => 5.987,
      's' => 6.327,
      't' => 9.056,
      'u' => 2.758,
      'v' => 0.978,
      'w' => 2.360,
      'x' => 0.150,
      'y' => 1.974,
      'z' => 0.074
      }
    def to_s
      return @s if @s
      @s = ''
      10.times { @s << random_char }
      @s.upcase
    end

    def random_char
      r = rand(1000) / 10
      puts r
      acc = 0
      LETTER_FREQUENCIES.sort.each do |arr|
        acc += arr[1]
        if acc > r
          return arr[0]
        end
      end
    end

  end
end
