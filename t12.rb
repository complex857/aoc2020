require 'pp'
require 'pry'

class Ship
  attr_accessor :north
  attr_accessor :west

  attr_accessor :waypoint

  def initialize(waypoint:)
    @north = 0
    @west = 0

    @waypoint = Waypoint.new(*waypoint)
  end

  def run(dirs)
    dirs.each do |dir|
      command = dir[0]
      value = dir[1]
      if %w{L R}.include? command
        waypoint.turn(dir)
      elsif %w{N W E S}.include? command
        waypoint.move(dir)
      elsif command == 'F'
        forward(dir)
      end
      # pp [dir, to_h]
    end
  end

  def to_h
    {
      north: north,
      west: west,
      waypoint: {
        north: waypoint.north,
        west: waypoint.west,
      }
    }
  end

  def forward(dir)
    self.north += waypoint.north * dir[1]
    self.west  += waypoint.west  * dir[1]
  end
end

class Waypoint
  attr_accessor :north
  attr_accessor :west

  def initialize(north, west)
    @north = north
    @west = west
  end

  def turn(dir)
    if dir[0] == 'R'
      case dir[1]
      when 90
        self.west,  self.north = -1 *  self.north,     self.west
      when 180
        self.north, self.west  = -1 * self.north, -1 * self.west
      when 270
        self.west,  self.north =      self.north, -1 * self.west
      end
    end

    if dir[0] == 'L'
      case dir[1]
      when 90
        self.west,  self.north =      self.north, -1 * self.west
      when 180
        self.north, self.west  = -1 * self.north, -1 * self.west
      when 270
        self.west,  self.north = -1 * self.north,      self.west
      end
    end
  end

  def move(dir)
    case dir[0]
    when 'N'
      self.north += dir[1]
    when 'S'
      self.north -= dir[1]
    when 'W'
      self.west  += dir[1]
    when 'E'
      self.west  -= dir[1]
    end
  end
end

def manhattan(ship)
  ship.north.abs + ship.west.abs
end


dirs = File.readlines('input12.txt').map { |l| l.match(/([A-Z])(\d+)/).captures }.map { |l| [l[0], l[1].to_i] }
ship = Ship.new(waypoint: [1, -10])
ship.run(dirs)

pp manhattan(ship)
