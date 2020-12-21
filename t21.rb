require 'pp'
require 'pry'

products = {}
ingredients = []
i = 0
File.readlines('input21.txt').map(&:strip).each do |line|
  parts = line.split('(')
  ings = parts[0].strip.split(' ')
  algs = parts[1].gsub('contains ', '').gsub(')', '').split(', ').sort
  products[i] = { allergens: algs.dup, ingredients: ings.dup }
  ingredients += ings
  i += 1
end
ingredients.uniq!

def find_allergen_names(products)
  re = {}

  # allergen => [potential names]
  products.values.map { |p| p[:allergens] }.flatten.uniq.each do |a|
    re[a] = products.values.filter { |p| p[:allergens].include? a }.map { |p| p[:ingredients ] }.reduce(:&)
  end

  while !re.values.map(&:size).all?(1)
    with_1 = re.filter { |k, v| v.size == 1}
    with_1.each do |solved_alg, solved_ings|
      re.each do |unsolved_alg, unsolved_ings|
        re[unsolved_alg] = unsolved_ings - solved_ings if unsolved_alg != solved_alg
      end
    end
  end
  return Hash[re.map { |k, v| [k, v[0]] }]
end

combo = find_allergen_names(products)
remaining = ingredients - combo.values
# pp combo
part1_count = 0
products.each do |i, prod|
  remaining.each do |ing|
    part1_count += 1 if prod[:ingredients].include? ing
  end
end
puts "part1: #{part1_count}"
puts "part2: #{combo.keys.sort.map { |a| combo[a] }.join(',')}"
