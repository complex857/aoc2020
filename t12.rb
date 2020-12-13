require 'pp'
require 'pry'

dirs = File.readlines('input12.txt').map { |l| l.match(/([A-Z])(\d+)/).captures }.map { |l| [l[0], l[1].to_i] }

ship = {
  heading: 90,
  north: 0,
  west: 0,
}

def turn(ship, dir)
  case dir[0]
  when 'R'
    ship[:heading] += dir[1]
  when 'L'
    ship[:heading] -= dir[1]
  end
  ship[:heading] = (ship[:heading] % 360).abs
  ship
end

def move_dir(ship, dir)
  case dir[0]
  when 'N'
    ship[:north] += dir[1]
  when 'S'
    ship[:north] -= dir[1]
  when 'W'
    ship[:west]  += dir[1]
  when 'E'
    ship[:west]  -= dir[1]
  end
  ship
end

def move_forward(ship, dir)
  ship
  case ship[:heading]
  when 0
    ship[:north] += dir[1]
  when 90
    ship[:west]  -= dir[1]
  when 180
    ship[:north] -= dir[1]
  when 270
    ship[:west]  += dir[1]
  end
  ship
end

def manhattan(ship)
  ship[:north].abs + ship[:west].abs
end

def run(ship, dirs)
  dirs.each do |dir|
    command = dir[0]
    value = dir[1]
    ship = if %w{L R}.include? command
             turn(ship, dir)
           elsif %w{N W E S}.include? command
             move_dir(ship, dir)
           elsif command == 'F'
             move_forward(ship, dir)
           end
  end
  ship
end

pp run(ship, dirs)
pp manhattan(ship)
