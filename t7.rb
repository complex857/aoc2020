require 'pp'
require 'pry'
require 'ostruct'
require 'set'

$rules = File.readlines('input7.txt').reduce({}) do |acc, l|
  parts = l.split(/bags contain|bags[.,]/).map(&:strip)
  acc[parts[0]] = parts[1..].inject([]) do |acc2, ll|
    next if ll == 'no other'
    parts2 = ll.split(/, /).map { |x| x.match(/(\d+) (\w+ \w+)/).captures }
    parts2.each do |p|
      acc2 << OpenStruct.new({
        color: p[1],
        num: p[0].to_i,
      })
    end
    acc2
  end
  acc
end

def can_contain_color?(rules, color)
  rules.any? { |x| x.color == color }
end

def find_parents(search_color)
  parents = []
  $rules.each do |color, rules|
    next unless rules
    if can_contain_color?(rules, search_color)
      parents << color
      parents += find_parents(color)
    end
  end
  parents
end

def expand_chain(rules)
  chain = []
  rules.each do |r|
    if $rules[r.color]
      chain << OpenStruct.new({
        head: r,
        children: expand_chain($rules[r.color])
      })
    else
      chain << OpenStruct.new({
        head: r,
        children: [],
      })
    end
  end
  chain
end

def count_chain(chain)
  chain.map do |c|
    if c.children.size > 0
      c.head.num + (c.head.num * count_chain(c.children).sum)
    else
      c.head.num
    end
  end
end

pp find_parents('shiny gold').uniq.size
pp count_chain(expand_chain($rules['shiny gold'])).sum
