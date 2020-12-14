require 'pp'
require 'pry'

class Bus
  attr_accessor :interval, :time, :position

  def initialize(interval, position = 0)
    @interval = interval
    @time = 0
    @position = position
  end

  def roll_past(target_time)
    roll while (time <= target_time)
  end

  def roll
    self.time += interval
  end

  def distance_from(target_time)
    [self, time - target_time]
  end

  def departs_at_minute?(depart_time)
    depart_time % interval == 0
  end
end

def part1(now, intervals)
  buses = intervals.map { |i| Bus.new(i) }
  buses.each { |b| b.roll_past(now) }
  distances = buses.map { |b| b.distance_from(now) }
  bus, wait_time = distances.min_by { |bus, distance| distance }
  pp [bus, wait_time]
  pp bus.interval * wait_time
end


# from rosetacode
def extended_gcd(a, b)
  last_remainder, remainder = a.abs, b.abs
  x, last_x, y, last_y = 0, 1, 1, 0
  while remainder != 0
    last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
    x, last_x = last_x - quotient*x, x
    y, last_y = last_y - quotient*y, y
  end
  return last_remainder, last_x * (a < 0 ? -1 : 1)
end

def invmod(e, et)
  g, x = extended_gcd(e, et)
  x % et
end

def chinese_remainder(mods, remainders)
  max = mods.reduce(:*)  # product of all moduli
  series = remainders.zip(mods).map { |r,m| (r * max * invmod(max/m, m) / m) }
  series.reduce(:+) % max
end

def part2(gapped_intervals)
  buses = gapped_intervals
    .each_with_index
    .map { |int, idx| int != 'x' ? Bus.new(int, idx) : nil }
    .filter { |x| x != nil }
    .sort_by { |b| b.position }

  mods = buses.map(&:interval)
  remainders = buses.map { |bus| bus.interval - bus.position }
  pp mods, remainders
  pp chinese_remainder(mods, remainders)
end

lines = File.readlines('input13.txt')
now = lines[0].to_i
intervals = lines[1].split(',').filter { |i| i != 'x' }.map(&:to_i)
gapped_intervals = lines[1].split(',').map { |i| i != 'x' ? i.to_i : i }

part1(now, intervals)
part2(gapped_intervals)
