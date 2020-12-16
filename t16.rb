require 'pp'
require 'pry'

class Ticket
  attr_reader :numbers

  def initialize(ticket_line)
    @numbers = ticket_line.split(',').map(&:to_i)
  end
end

class Rule
  attr_reader :name
  attr_reader :ranges

  def initialize(rule_line)
    parts = rule_line.match(/^([^:]+):\s*(.+)$/).captures
    @name = parts[0]
    @ranges = parts[1].split(' or ').map do |r|
      min, max = r.split('-').map(&:to_i)
      Range.new(min, max)
    end
  end

  def match?(num)
    ranges.any? { |r| r.include?(num) }
  end

  def ==(r)
    r.name == self.name
  end

  def to_s
    name
  end
end

def parse_input(file)
  parts = File.read(file).split("\n\n")
  rule_lines = parts[0].split("\n")
  my_ticket_line = parts[1].split("\n")[1..]
  ticket_lines = parts[2].split("\n")[1..]

  tickets = ticket_lines.each_with_index.map { |l, i| Ticket.new(l) }
  my_ticket = Ticket.new(my_ticket_line[0])
  rules = rule_lines.map { |l| Rule.new(l) }

  [rules, my_ticket, tickets]
end


def part1
  rules, my_ticket, tickets = parse_input('input16.txt')

  invalid_field_values = []
  tickets.each do |ticket|
    ticket.numbers.each do |num|
      invalid_field_values << num unless rules.any? { |r| r.match? num }
    end
  end

  invalid_field_values.sum
end

def valid_tickets(tickets, rules)
  tickets.filter do |ticket|
    ticket.numbers.all? do |number|
      rules.any? { |r| r.match?(number) }
    end
  end
end

$find_cache = {}
def find_rule_for_column(rules, column)
  key = rules.map(&:name).sort.join(',') + column.sort.join(',')
  unless $find_cache[key]
    $find_cache[key] = rules.filter do |r|
      r if column.all? { |num| r.match?(num) }
    end
  end
  $find_cache[key]
end

def part2
  rules, my_ticket, tickets = parse_input('input16.txt')
  columns = 0.upto(my_ticket.numbers.size - 1).map do |col|
    valid_tickets(tickets, rules).map { |t| t.numbers[col] }
  end

  possible_rules_for_columns = Hash[columns.each_with_index.map do |col, i|
    [i, find_rule_for_column(rules, col)]
  end]

  assigned_columns = {}
  while assigned_columns.size != columns.size
    assigned_columns = possible_rules_for_columns.filter { |k, v| v.size == 1 }
    assigned_columns.each do |col, rule|
      possible_rules_for_columns.each do |col2, rules|
        next if col == col2
        possible_rules_for_columns[col2] = rules - rule
      end
    end
  end

  departure_colums = assigned_columns.filter { |k, r| r[0].name =~ /^departure/ }.keys
  departure_nums = my_ticket.numbers.each_with_index.filter { |value, i| departure_colums.include?(i) }.map { |v| v[0] }
  departure_nums.reduce(&:*)
end

puts "Part 1: #{part1}"
puts "Part 2: #{part2}"
