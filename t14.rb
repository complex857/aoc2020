require 'pry'
require 'pp'

WIDTH = 36

def parse(line)
  return line.match(/([X01]+$)/).captures[0] if line =~ /^mask/
  return Write.new(*line.match(/^mem\[(\d+)\]\s*=\s*(\d+)$/).captures) if line =~ /^mem/
end

def to_bits(dec)
  dec.to_i.to_s(2).rjust(WIDTH, '0')
end

def to_dec(str)
  Integer("0b#{str}")
end

class Write
  attr_accessor :index, :index_bits, :value, :value_bits

  def initialize(index, value)
    @index = index.to_i
    @value = value.to_i
    @value_bits = to_bits(value)
    @index_bits = to_bits(index)
  end
end

def apply(mem, mask, write)
  new_value = ""
  mask.chars.each_with_index do  |c, index|
    if c == 'X'
      new_value += write.value_bits[index]
    else
      new_value += c
    end
  end
  mem[write.index] = to_dec(new_value)
end

def part1(cmds)
  current_mask = nil
  mem = {}

  cmds.each do |cmd|
    if cmd.is_a? Write
      apply(mem, current_mask, cmd)
    else
      current_mask = cmd
    end
  end
  puts "part1: #{mem.values.sum}"
end

def permutatations(address)
  addr0 = address.dup
  addr1 = address.dup
  addr0[address.index('X')] = '0'
  addr1[address.index('X')] = '1'
  if address.count('X') > 1
    return permutatations(addr0) + permutatations(addr1)
  else
    return [addr0, addr1]
  end
end

def apply2(mem, mask, write)
  new_address_mask = ''
  mask.chars.each_with_index do  |c, index|
    if c == 'X'
      new_address_mask += 'X'
    elsif c == '0'
      new_address_mask += write.index_bits[index]
    elsif c == '1'
      new_address_mask += '1'
    end
  end

  addresses = permutatations(new_address_mask)
  addresses.each do |addr|
    mem[to_dec(addr)] = write.value
  end
end

def part2(cmds)
  current_mask = nil
  mem = {}

  cmds.each do |cmd|
    if cmd.is_a? Write
      apply2(mem, current_mask, cmd)
    else
      current_mask = cmd
    end
  end
  puts "part2: #{mem.values.sum}"
end

cmds = File.readlines('input14.txt').map(&:strip).map { |l| parse(l) }

part1(cmds)
part2(cmds)
