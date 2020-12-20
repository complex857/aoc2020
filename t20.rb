require 'pp'
require 'pry'

module Enumerable
  def index_by
    if block_given?
      result = {}
      each { |elem| result[yield(elem)] = elem }
      result
    else
      to_enum(:index_by) { size if respond_to?(:size) }
    end
  end
end

class Tile
  attr_reader :id, :rows
  attr_accessor :col, :row

  def initialize(id, rows)
    @id = id
    @rows = rows
    @col = nil
    @row = nil
    @perms = []
  end

  def get_col(c)
    (0...rows.size).map { |i| rows[i][c] }.join
  end

  def get_row(r)
    rows[r]
  end

  def possible_sides
    sides = {}
    tile = self
    4.times do
      sides[tile.get_row(0)] = tile.id
      sides[tile.get_row(-1)] = tile.id
      sides[tile.get_col(0)] = tile.id
      sides[tile.get_col(-1)] = tile.id
      tile = Tile.flip(tile)
      sides[tile.get_row(0)] = tile.id
      sides[tile.get_row(-1)] = tile.id
      sides[tile.get_col(0)] = tile.id
      sides[tile.get_col(-1)] = tile.id
      tile = Tile.rotate(tile)
    end
    sides
  end

  def permutations
    return @perms if @perms.size > 0
    @perms = []
    @perms << self
    @perms << flip
    @perms << rotate
    @perms << rotate.flip
    @perms << rotate.rotate
    @perms << rotate.rotate.flip
    @perms << rotate.rotate.rotate
    @perms << rotate.rotate.rotate.flip
    @perms
  end

  def valid_for(tile, side)
    cmd_pair = case side
    when :top
      [
        [:get_row, -1], # top of other
        [:get_row,  0], # bottom of self
      ]
    when :bottom
      [
        [:get_row,  0], # bottom of other
        [:get_row, -1], # top of self
      ]
    when :left
      [
        [:get_col,  0],  # right of other
        [:get_col, -1], # left of self
      ]
    when :right
      [
        [:get_col, -1], # left of other
        [:get_col,  0], # right of self
      ]
    end

    permutations.each do |perm|
      other_side = tile.send(*cmd_pair[0])
      self_side  = perm.send(*cmd_pair[1])
      if other_side == self_side
        return perm
      end
    end
    false
  end

  def rotate
    Tile.rotate(self)
  end

  def flip
    Tile.flip(self)
  end

  def self.parse(raw)
    head, raw_text = raw.split("\n", 2)
    rows = raw_text.split("\n").map(&:strip)
    id = head.match(/([0-9]+)/).captures[0].to_i
    Tile.new(id, rows)
  end

  def self.flip(tile)
    Tile.new(
      tile.id,
      tile.rows.map do |row|
        row.chars.reverse.join
      end
    )
  end

  def self.rotate(tile)
    new_rows = tile.rows.map(&:dup)
    width = tile.rows.size
    width.times do |row|
      width.times do |col|
        new_rows[col][width - 1 - row] = tile.rows[row][col]
      end
    end
    Tile.new(tile.id, new_rows)
  end

  def key
    [col, row]
  end

  def to_s
    "#{rows.join("\n")}\n"
  end

  def to_shaved
    Tile.new(
      id,
      rows[1...-1].map(&:chars).map { |chars| chars[1...-1].join }
    )
  end
end

class Puzzle
  attr_reader :tiles, :min_row, :min_col, :max_col, :max_row, :tile_width

  def initialize(tiles)
    @tiles = Hash[tiles.map { |k, v| [k, v.to_shaved] }]
    # @tiles = tiles
    @min_col, @max_col = tiles.keys.map { |(col, row)| col }.minmax
    @min_row, @max_row = tiles.keys.map { |(col, row)| row }.minmax
    @tile_width = @tiles[[0,0]].rows[0].size
  end

  def to_s
    s = ""
    (min_row..max_row).each do |row|
      (0...tile_width).each do |tile_row|
        s += (min_col..max_col).map do |col|
          tiles[[col, row]].rows[tile_row].strip
        end.join(" ") + "\n"
      end
      s += "\n"
    end
    s
  end

  def to_ids
    s = ""
    (min_row..max_row).each do |row|
      s += (min_col..max_col).map do |col|
        " #{tiles[[col, row]].id} "
      end.join+"\n"
    end
    s += "\n"
    s
  end

  def to_tile
    rows = []
    (min_row..max_row).each do |row|
      (0...tile_width).each do |tile_row|
        rows << (min_col..max_col).map do |col|
          tiles[[col, row]].rows[tile_row].strip
        end.join
      end
    end
    Tile.new('picture', rows)
  end
end

tiles = File.read('input20.txt').strip.split("\n\n").map { |r| Tile.parse(r.strip) }
tile_map = tiles.index_by(&:id)
all_possible_sides = tiles.map(&:possible_sides)
side_map = all_possible_sides.reduce({}) do |acc, pairs|
  pairs.each { |k, v| (acc[k] ||= []) << v }
  acc
end
uniq_side_counts = side_map.reduce({}) do |acc, (side, ids)|
  acc[ids[0]] = ((acc[ids[0]] || 0) + 1) if ids.size == 1
  acc
end
corner_ids = uniq_side_counts.select { |id, count| count == 4 }.keys
puts "part1: #{corner_ids.reduce(&:*)}"

puzzle = {}
current = tile_map[corner_ids[0]]
current.col = 0
current.row = 0
puzzle[current.key] = current
ids_left = tile_map.keys - [current.id]
while ids_left.size != 0
  puzzle.values.each do |current|
    ids_left.each do |id|
      candidates = {
        [ 0,  1]  => tile_map[id].valid_for(current, :right),
        [ 0, -1]  => tile_map[id].valid_for(current, :left),
        [ 1,  0]  => tile_map[id].valid_for(current, :top),
        [-1,  0]  => tile_map[id].valid_for(current, :bottom),
      }
      candidates.each do |(off_row, off_col), t|
        if t
          t.row = current.row + off_row
          t.col = current.col + off_col
          puzzle[t.key] = t
          ids_left -= [t.id]
          break
        end
      end
    end
  end
end

puzzle = Puzzle.new(puzzle)
puts puzzle
puts puzzle.to_ids
puzzle_tile = puzzle.to_tile
pattern = [
  /..................#./,
  /#....##....##....###/,
  /.#..#..#..#..#..#.../,
]
monsters = {}
puzzle_tile.permutations.each_with_index do |pt, i|
  possible_start_rows = (0...(pt.rows.size - 2)).to_a
  possible_start_columns = (0...(pt.rows[0].size - 19)).to_a
  possible_start_rows.each do |start_row|
    possible_start_columns.each do |start_column|
      if (pt.rows[start_row  ][start_column..(start_column+19)] =~ pattern[0] &&
          pt.rows[start_row+1][start_column..(start_column+19)] =~ pattern[1] &&
          pt.rows[start_row+2][start_column..(start_column+19)] =~ pattern[2])
        monsters[i] = (monsters[i] || 0) + 1
      end
    end
  end
end
valid_permutation = puzzle_tile.permutations[monsters.keys[0]]
monster_count = monsters.values[0]
monster_body_hashes = monster_count * 15
puts "part2: #{valid_permutation.to_s.count('#') - monster_body_hashes}"
