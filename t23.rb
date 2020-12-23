require 'pp'
require 'pry'
require 'linked-list'

class LinkedList::List
  attr_accessor :tail, :head
end

def print_a(current_i, cups)
  cups = cups.dup
  cups[current_i] = "(#{cups[current_i]})"
  puts "cups: #{cups.join('  ')}"
end

def to_a(current, cups, picked_values = [])
  cups_a = []
  cups_a << current.data
  c = current.next
  while c != current
    cups_a << c.data unless picked_values.include? c.data
    c = c.next
  end
  cups_a
end

def find_dest(current, cups, picked_values, index, max)
  dest_value = current.data
  while true
    dest_value -= 1
    if !picked_values.include?(dest_value) && index[dest_value]
      return index[dest_value]
    end
    if dest_value == 0
      dest_value = max + 1
    end
  end
end

def round(current, cups, index, i, max)
  picked_head = current.next
  picked_tail = current.next.next.next
  picked_values = [
    picked_head.data,
    picked_head.next.data,
    picked_head.next.next.data,
  ]
  dest = find_dest(current, cups, picked_values, index, max)

  # cups_a = to_a(current, cups)
  # puts "\n -- move #{i} --"
  # print_a(cups_a.index(current.data), cups_a)
  # puts "picked: #{picked_values.join('  ')}"
  # puts "dest: #{dest.data}"

  old_dest_next = dest.next
  old_picked_head_prev = picked_head.prev
  old_picked_tail_next = picked_tail.next

  old_picked_head_prev.next = old_picked_tail_next
  old_picked_tail_next.prev = old_picked_head_prev

  dest.next = picked_head
  picked_head.prev = dest

  picked_tail.next = old_dest_next
  old_dest_next.prev = picked_tail

  [current.next, cups]
end

def generate_list(input)
  list = LinkedList::List.new
  index = []
  cups = input.chars.map(&:to_i)
  cups.each do |cup|
    list << cup
    index[cup] = list.tail
  end
  list.head.prev = list.tail
  list.tail.next = list.head
  current = index[cups[0]]

  [current, list, index, cups.max]
end

def generate_list2(input)
  list = LinkedList::List.new
  index = []
  cups = input.chars.map(&:to_i)
  max = cups.max
  cups += (max + 1..1_000_000).to_a
  cups.each do |cup|
    list << cup
    index[cup] = list.tail
  end
  list.head.prev = list.tail
  list.tail.next = list.head
  current = index[cups[0]]

  [current, list, index, cups.max]
end

current, list, index, max = generate_list('871369452')
100.times do |i|
  current, list = round(current, list, index, i + 1, max)
end
cups_a = to_a(current, list)
puts "part1: #{cups_a.rotate(cups_a.index(1))[1..].join('')}"

current, list, index, max = generate_list2('871369452')
10_000_000.times do |i|
  print "\r#{(i / 100_000).to_i}%" if i % 100_000 == 0
  current, list = round(current, list, index, i + 1, max)
end
print "\r"
puts "part2: #{index[1].next.data * index[1].next.next.data}"
