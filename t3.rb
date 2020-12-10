require 'pp'
require 'pry'

field = File.readlines('input3.txt').map do |l|
  l.strip.chars * 1000 # lazy
end

def treecount(field, offset_x, offset_y)
  trees = 0
  x = 0
  y = 0
  height = field.length
  while true do
    if field[y][x] == '#'
      trees += 1
    end

    x += offset_x
    y += offset_y

    break if (y + 1 > height)
  end

  return trees
end


puts "Right 1, down 1. = #{treecount(field, 1, 1)}"
puts "Right 3, down 1. = #{treecount(field, 3, 1)}"
puts "Right 5, down 1. = #{treecount(field, 5, 1)}"
puts "Right 7, down 1. = #{treecount(field, 7, 1)}"
puts "Right 1, down 2. = #{treecount(field, 1, 2)}"

pp treecount(field, 1, 1) * treecount(field, 3, 1) * treecount(field, 5, 1) * treecount(field, 7, 1) * treecount(field, 1, 2)
