require 'pp'
require 'pry'

class Field
  attr_reader :field

  def initialize(cubes = [])
    @field = {}
    cubes.each { |c| self << c }
  end

  def [](*coords)
    field[coords]
  end

   def <<(c)
     @field[c.coords] = c
   end

  def neighboors_of_active_cubes
    active_cubes.map(&:all_neighboor_coords).flatten(1).uniq
  end

  def active_cubes
    field.values.filter(&:active)
  end

  def active_neighboor_count_of(cube)
    cube.all_neighboor_coords.count do |coords|
      self[*coords] && self[*coords].active?
    end
  end

  def run
    new_state = Field.new
    (neighboors_of_active_cubes).each do |coords|
      c = self[*coords] || Cube.new(coords, false)
      active_neighboors_count = active_neighboor_count_of(c)
      if c.active?
        if active_neighboors_count == 2 || active_neighboors_count == 3
          new_state << c
        end
      else
        if active_neighboors_count == 3
          new_state << c.activate
        end
      end
    end
    new_state
  end
end

class Cube
  attr_reader :coords, :active

  alias :active? :active

  def initialize(coords, active)
    @coords = coords
    @active = !!active
  end

  def activate
    @active = true
    self
  end

  def all_neighboor_coords
    off_z = 0
    off_w = 0
    re = []
    (-1..1).each do |off_x|
      (-1..1).each do |off_y|
        (-1..1).each do |off_z|
          (-1..1).each do |off_w| # comment this loop for part 1
            re << [coords[0] + off_x, coords[1] + off_y, coords[2] + off_z, coords[3] + off_w] unless off_x == 0 && off_y == 0 && off_z == 0 && off_w == 0
          end
        end
      end
    end
    re
  end
end

def read_input(f)
  cubes = []
  File.readlines(f).map(&:strip).map(&:chars).each_with_index do |line, x|
    line.each_with_index do |char, y|
      cubes << Cube.new([x, y, 0, 0], true) if char == '#'
    end
  end
  Field.new(cubes)
end

field = read_input('input17.txt')
6.times do
  field = field.run
end
pp field.active_cubes.count
