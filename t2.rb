require 'pp'
require 'pry'
require 'ostruct'

lines = File.readlines('input2.txt').map do |l|
  range_from, range_to, letter, password = l.match(/^(\d+)-(\d+)\s+(\w):\s(\w+)$/).captures
  OpenStruct.new(
    range: Range.new(range_from.to_i, range_to.to_i),
    pos: [range_from.to_i - 1, range_to.to_i - 1],
    letter: letter,
    password: password.chars,
  )
end

count = lines.reduce(0) do |acc, line|
  # acc += 1 if line.range.include?(line.password.count(line.letter))
  matches = line.pos.reduce(0) do |mc, p|
    mc += 1 if line.password[p] == line.letter
    mc
  end
  acc += 1 if matches == 1
  acc
end

pp count
