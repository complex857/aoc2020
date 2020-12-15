require 'pp'
require 'pry'

INPUT = [2, 20, 0, 4, 1, 17]

class Game
  attr_accessor :spoken, :round, :nums, :positions

  def initialize(nums)
    @nums = nums
    @spoken = nums.dup
    @round = 0
    @positions = {}
  end

  def save_position(number)
    if positions[number]
      positions[number] << round
    else
      positions[number] = [round]
    end
  end

  def iterate
    unless spoken[round]
      last_spoken = spoken[-1]
      if positions[last_spoken] && positions[last_spoken].count > 1
        last_spoken_round = positions[last_spoken][-1]
        prev_to_last_spoken_round = positions[last_spoken][-2]
        spoken << last_spoken_round - prev_to_last_spoken_round
      else
        spoken << 0
      end
    end
    save_position(spoken[round])
    self.round += 1
    spoken[round - 1]
  end
end

def run(input, rounds)
  game = Game.new(input)
  last_spoken = nil
  rounds.times do
    last_spoken = game.iterate
    # puts "Round #{game.round}: #{last_spoken}"
  end
  last_spoken
end

puts "part1: #{run(INPUT, 2020)}"
puts "part2: #{run(INPUT, 30000000)}"
