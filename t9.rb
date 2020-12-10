require 'pp'
require 'pry'

input = File.readlines('input9.txt').map(&:to_i)

def find_pair(nums, sum)
  nums.each do |a|
    nums.each do |b|
      if a != b && a + b == sum
        return [a, b]
      end
    end
  end
  return false
end

def find_seq(input, sum)
  head = 0
  tail = 1
  while (head != input.size)
    tail = head + 1
    while (tail != input.size)
      range = input[head..tail]
      return range if (range.sum == sum)
      tail += 1
    end
    head += 1
  end
end


def find_invalid(input, window)
  i = window
  while (i != input.size)
    curr = input[i]
    pair = find_pair(input[i - window...i], curr)
    return curr unless pair
    i += 1
  end
end

invalid = find_invalid(input, 25)
seq = find_seq(input, invalid)
pp invalid
pp seq.min + seq.max
