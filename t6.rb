require 'pp'
require 'pry'
require 'set'

answers = File
  .read('input6.txt')
  .split(/\n\n/)
  .map do |l|
    {
      count: l.count("\n"),
      all_answers: Set.new(l.gsub(/\s+/, '').chars),
      answers: l.split("\n").map do |ll|
        Set.new(ll.chars)
      end,
    }
  end

part1 = answers.reduce(0) { |acc, a| acc + a[:all_answers].length }
part2 = answers.reduce(0) do |acc, a|
  acc + (a[:answers].reduce do |acc, a2|
    acc & a2.to_a
  end.count)
end

pp part1
pp part2
