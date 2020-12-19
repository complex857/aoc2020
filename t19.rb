require 'pp'
require 'pry'

class RuleSet
  attr_reader :rules

  def initialize(rules)
    @rules = rules
  end

  def resolve(part:)
    replaced = -1
    while replaced != 0
      replaced = 0
      simple_rules.each do |simple_rule_index, simple_rule|
        rules.each do |i, rule|
          rule.each_with_index do |r, ii|
            if r == simple_rule_index
              rule[ii] = "(?:#{simple_rule.join})"
              replaced += 1
            end
          end
        end
      end
    end

    return Regexp.new("^#{rules[0].map { |r| "(#{r})"}.join}$") if part == 1

    # don't judge me :D
    rules[8] = "(?:#{rules[8].join})"
    rules[11] = "(?:#{rules[11].join})"
    0.upto(5) do
      rules[8] = rules[8].sub('8', "(?:#{rules[8]})")
      rules[11] = rules[11].sub('11', "(?:#{rules[11]})")
    end
    rules[11] = rules[11].gsub('11', '')
    rules[8] = rules[8].gsub('8', '')
    Regexp.new('^('+rules[8]+')('+rules[11]+')$')
  end

  def simple_rules
    rules.select do |i, r|
      r.count { |c| c.is_a? String } == r.size
    end
  end
end

rules, messages = File.readlines('input19.txt').map(&:strip).inject([{}, []]) do |(rules, messages), line|
  if line.match(/^(\d+):\s(.+)$/)
    index, r = line.match(/^(\d+):\s(.+)$/).captures
    rules[index.to_i] = r.split(/\s+/).map do |p|
      if p =~ /^\d+$/
        p.to_i
      elsif p =~ /^"\w+"$/
        p[1...-1]
      else
        p
      end
    end
    rules
  elsif line != ''
    messages << line
  end
  [rules, messages]
end

regex = RuleSet.new(rules).resolve(part: 1)
puts "part1: #{messages.count { |m| regex.match(m)}}"

rules[8] = [42, "|", 42, 8]
rules[11] = [42, 31, "|", 42, 11, 31]
regex = RuleSet.new(rules).resolve(part: 2)
puts "part2: #{messages.count { |m| regex.match(m)}}"

