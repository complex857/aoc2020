require 'pp'
require 'pry'

def clone(seats)
  seats.dup.map(&:dup)
end

def size(seats)
  [seats[0].count, seats.count]
end

def in_bounds?(row, col, width, height)
  row >= 0 && col >= 0 && col < width && row < height
end

def adjecent_coords(size, row, col)
  coords = []
  coords << [row,      col + 1]
  coords << [row,      col - 1]
  coords << [row + 1,  col    ]
  coords << [row - 1,  col    ]
  coords << [row - 1,  col + 1]
  coords << [row + 1,  col - 1]
  coords << [row - 1,  col - 1]
  coords << [row + 1,  col + 1]
  coords.filter { |row, col| in_bounds? row, col, *size}
end

def adjecent_seats(seats, row, col)
  adjecent_coords(size(seats), row, col).map do |r, c|
    seats[r][c]
  end
end

def visible_coords(seats, row, col)
  width, height = size(seats)
  re = {
    n:  [],
    ne: [],
    e:  [],
    se: [],
    s:  [],
    sw: [],
    w:  [],
    nw: [],
  }
  (0..row - 1).to_a.reverse.each do |r|
    re[:n] << [r, col]
  end

  c = col + 1
  r = row - 1
  while (r >= 0 && c < width)
    re[:ne] << [r, c]
    c += 1
    r -= 1
  end

  (col + 1...width).each do |c|
    re[:e] << [row, c]
  end

  c = col + 1
  r = row + 1
  while (c < width && r < height)
    re[:se] << [r, c]
    c += 1
    r += 1
  end

  (0..col - 1).to_a.reverse.each do |c|
    re[:w] << [row, c]
  end

  c = col - 1
  r = row + 1
  while (r < height && c >= 0)
    re[:sw] << [r, c]
    c -= 1
    r += 1
  end

  (row + 1...height).each do |r|
    re[:s] << [r, col]
  end

  c = col - 1
  r = row - 1
  while (c >= 0 && r >= 0)
    re[:nw] << [r, c]
    c -= 1
    r -= 1
  end

  re
end

def visible_occupied_count(seats, from_row, from_col)
  empty = 0
  occupied = 0
  coords = visible_coords(seats, from_row, from_col)
  coords.each do |dir, cc|
    cc.each do |row, col|
      seat = seats[row][col]
      if seat == '#'
        occupied += 1
        break
      end
      if seat == 'L'
        empty =+ 1
        break
      end
    end
  end
  {
    empty: empty,
    occupied: occupied,
  }
end


def mutate(seats)
  mutated = clone(seats)
  width, height = size(seats)

  (0...width).each do |col|
    (0...height).each do |row|
      seat = seats[row][col]
      next if seat == '.'

      occupied_count = adjecent_seats(seats, row, col).count { |s| s == '#' }
      if seat == 'L' && occupied_count == 0
        mutated[row][col] = '#'
      end
      if seat == '#' && occupied_count >= 4
        mutated[row][col] = 'L'
      end
    end
  end
  mutated
end

def mutate2(seats)
  mutated = clone(seats)
  width, height = size(seats)

  (0...width).each do |col|
    (0...height).each do |row|
      seat = seats[row][col]
      next if seat == '.'

      seeing = visible_occupied_count(seats, row, col)
      if seat == 'L' && seeing[:occupied] == 0
        mutated[row][col] = '#'
      end
      if seat == '#' && seeing[:occupied] >= 5
        mutated[row][col] = 'L'
      end
    end
  end
  mutated
end

def find_stable(seats, mutate_method)
  prev = clone(seats)
  while true
    current = mutate_method.call(prev)
    return current if flatten(current) == flatten(prev)
    prev = current
  end
end

def flatten(seats)
  seats.map { |row| row.join('') }.join("\n")
end

def count_occupied(seats)
  flatten(seats).chars.count { |c| c == '#' }
end

seats = File.readlines('input11.txt').map { |l| l.strip.chars }

stable = find_stable(clone(seats), method(:mutate))
pp count_occupied(stable)

stable = find_stable(clone(seats), method(:mutate2))
pp count_occupied(stable)

# coords.each do |dir, cc|
#   cc.each do |row, col|
#     seats[row][col] = 'x'
#   end
# end
