require 'pp'
require 'pry'

class Integer
  alias :part1_to_i :to_i
  alias :part2_to_i :to_i
end

class Expr
  attr_reader :tokens

  def initialize(tokens = [])
    @tokens = tokens
    parse()
    @tokens.map! { |t| t.to_s =~ /^\d+$/ ? t.to_i : t }
  end

  def parse
    return unless tokens.index('(')
    while (start = tokens.index('(')) != nil
      depth = 0
      end_pos = start
      tokens[start..].each_with_index do |token, i|
        end_pos = start + i
        depth += 1 if token == '('
        depth -= 1 if token == ')'
        break if depth == 0
      end
      @tokens[start..end_pos] = Expr.new(tokens[start+1..end_pos-1])
    end
    self
  end

  def part1_to_i
    re = tokens[0]
    i = 1
    while i + 1 < tokens.size
      re = re.part1_to_i.send(tokens[i], tokens[i+1].part1_to_i)
      i += 2
    end
    re
  end

  def part2_to_i
    while i = tokens.find_index { |token| token == '+' }
      @tokens[(i-1)..(i+1)] = tokens[i-1].part2_to_i.send(tokens[i], tokens[i + 1].part2_to_i)
    end
    re = tokens[0]
    i = 1
    while i + 1 < tokens.size
      re = re.part2_to_i.send(tokens[i], tokens[i+1].part2_to_i)
      i += 2
    end
    re
  end

  def to_s
    "(#{@tokens.join(' ')})"
  end
end

def tokenize(line)
  line.gsub(/\s+/, '').scan(/\d+|\+|\*|\(|\)/).to_a
end

# input = File.readlines('input18_t.txt').map(&:strip).map { |line| Expr.new(tokenize(line)) }
# puts "part1:"
# input.each do |expr|
#   puts "#{expr}: #{expr.part1_to_i}"
# end
# puts "\npart2:"
# input.each do |expr|
#   puts "#{expr}: #{expr.part2_to_i}"
# end

input = File.readlines('input18.txt').map(&:strip).map { |line| Expr.new(tokenize(line)) }
puts "part1: #{input.map(&:part1_to_i).sum}"
puts "part2: #{input.map(&:part2_to_i).reduce(&:+)}"

