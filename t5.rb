require 'pp'
require 'pry'

boardingpasses = File.readlines('input5.txt').map do |l|
  l.strip.chars
end

def mid(chars, up_char, down_char)
  left = 0
  right = 2 ** chars.count
  chars.each do |c|
    if c == up_char
      right -= (right - left) / 2
    end
    if c == down_char
      left += (right - left) / 2
    end
  end
  left
end

def parse(pass)
  row = mid(pass[0..6], 'F', 'B')
  col = mid(pass[7..],  'L', 'R')

  # "row=#{row}, col=#{col}, id=#{(row * 8 + col)}"
  {
    row: row,
    col: col,
    id: (row * 8 + col),
  }
end

parsed = boardingpasses.map { |bp| parse(bp) }
index = parsed.reduce({}) do |acc, bp|
  acc[bp[:id]] = bp
  acc
end
puts "max = #{index.keys.max}"

sorted_ids = index.keys.sort
(0...sorted_ids.length).each do |i|
  next if i == 0
  curr = sorted_ids[i]
  prev = sorted_ids[i - 1]

  if (curr - prev) > 1
    puts "missing id: #{prev + 1}"
    break
  end
end
