require 'pp'
require 'pry'

lines = File.readlines('input1.txt').map(&:to_i).sort
lines.each do |l|
  lines.each do |ll|
    lines.each do |lll|
      if l + ll + lll == 2020
        pp l, ll, lll, l * ll * lll
        exit
      end
    end
  end
end
