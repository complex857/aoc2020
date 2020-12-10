require 'pp'
require 'pry'

jolts = File.readlines('input10.txt').map(&:to_i).sort.reverse

$possible_cache = {}
def possible_adapters(jolts, adapter_for)
  return $possible_cache[adapter_for] if $possible_cache[adapter_for]
  $possible_cache[adapter_for] = jolts.filter { |j| j < adapter_for && j >= (adapter_for - 3) }
  $possible_cache[adapter_for]
end

def find_max_chain(found, left, curr, max)
  return ([max + 3] + found + [0]) if left.size == 0
  possible_adapters(left, curr).each do |j|
    max_chain = find_max_chain(found + [j], left - [j], j, max)
    return max_chain if max_chain
  end
  false
end

$find_count_cache = {}
def find_chain_count(found, left, curr, max)
  sum = 0
  if curr - 3 <= 0
    sum += 1
  end

  possible_adapters(left, curr).each do |j|
    key = "#{(found + left + [j]).sort.join('-')}"
    count = if $find_count_cache[key]
      $find_count_cache[key]
    else
      $find_count_cache[key] = find_chain_count(found + [j], left - [j], j, max)
      $find_count_cache[key]
    end
    sum += count
  end
  sum
end

def diff_counts_product(chain)
  diff_1_count = 0
  diff_3_count = 0

  (1...chain.size).each do |i|
    diff = chain[i - 1] - chain[i]
    diff_1_count += 1 if diff == 1
    diff_3_count += 1 if diff == 3
  end

  puts "diff 1: #{diff_1_count}"
  puts "diff 3: #{diff_3_count}"
  return diff_1_count * diff_3_count
end

chain_count = find_chain_count([], jolts, jolts.max + 3, jolts.max)
max_chain = find_max_chain([], jolts, jolts.max + 3, jolts.max)
puts "diff product: #{diff_counts_product(max_chain)}"
puts "valid permutations: #{chain_count}"
