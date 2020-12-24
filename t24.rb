require 'pp'
require 'pry'
require 'ostruct'

class Direction
  attr_accessor :x, :y, :z

  def initialize(x: 0, y: 0, z: 0)
    @x = x
    @y = y
    @z = z
  end
end

def neighbours(tiles, tile)
  x = tile.x
  y = tile.y
  z = tile.z
  new_coords = [
    [ x + 1, y - 1, z ],
    [ x    , y - 1, z + 1 ],
    [ x - 1, y    , z + 1 ],
    [ x - 1, y + 1, z ],
    [ x    , y + 1, z - 1 ],
    [ x + 1, y    , z - 1 ],
  ]

  new_coords.map do |coords|
    tiles[coords] ||= Tile.new(*coords)
  end
end

class Tile
  attr_accessor :x, :y, :z, :color

  def initialize(x, y, z, start_color = :white)
    @x = x
    @y = y
    @z = z
    @color = start_color
    @flip_count = 0
  end

  def black?
    color == :black
  end

  def white?
    color == :white
  end

  def flip
    @flip_count += 1
    if color == :black
      @color = :white
    else
      @color = :black
    end
  end
end

def parse_line(line)
  dir = []
  while (line.length > 0)
    if line.start_with? 'e'
      dir << Direction.new(y: -1, x: 1)
      line = line[1..]
    end
    if line.start_with? 'se'
      dir << Direction.new(y: -1, z: 1)
      line = line[2..]
    end
    if line.start_with? 'sw'
      dir << Direction.new(x: -1, z: 1)
      line = line[2..]
    end
    if line.start_with? 'w'
      dir << Direction.new(y: 1, x: -1)
      line = line[1..]
    end
    if line.start_with? 'nw'
      dir << Direction.new(y: 1, z: -1)
      line = line[2..]
    end
    if line.start_with? 'ne'
      dir << Direction.new(x: 1, z: -1)
      line = line[2..]
    end
  end
  dir
end

def run_tile_dirs(tile_dirs, tiles)
  x = 0
  y = 0
  z = 0
  tile_dirs.each do |dir|
    x += dir.x
    y += dir.y
    z += dir.z
  end
  unless tiles[[x, y, z]]
    tiles[[x, y, z]] = Tile.new(x, y, z)
  end
  tiles[[x, y, z]].flip
  tiles
end

def run_file(tile_dirs_arr, tiles)
  tile_dirs_arr.each do |tile_dirs|
    tiles = run_tile_dirs(tile_dirs, tiles)
  end
  tiles
end

def mutate(tiles)
  tiles.values.each do |tile|
    neighbours(tiles, tile)
  end

  new_tiles = Hash[tiles.map { |k, v| [k, v.clone] }]
  tiles.values.each do |tile|
    ntiles = neighbours(tiles, tile)
    black_count = ntiles.count(&:black?)
    white_count = ntiles.count(&:white?)
    if tile.black? && (black_count == 0 || black_count > 2)
      new_tiles[[tile.x, tile.y, tile.z]].color = :white
    end
    if tile.white? && black_count == 2
      new_tiles[[tile.x, tile.y, tile.z]].color = :black
    end
  end
  new_tiles
end


tiles = {}
directions = File.readlines('input24.txt').map(&:strip).map { |l| parse_line(l) }
run_file(directions, tiles)
puts "part1: #{tiles.values.count(&:black?)}"

# seems to be that there is a 0th day to get the right sutff,
# can't be bothered to debug
101.times do |i|
  print "\r#{i}%"
  tiles = mutate(tiles)
end

puts "\rpart2: #{tiles.values.count(&:black?)}"
