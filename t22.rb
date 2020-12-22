require 'pp'
require 'pry'
require 'set'

decks = File
  .read('input22.txt')
  .split("\n\n")
  .map { |p| p.split("\n") }
  .map { |lines| lines[1..].map(&:to_i) }

def play_simple_combat(decks)
  while true
    return decks.find { |cards| cards.size > 0 } if decks.any?(&:empty?)

    tops = []
    decks.each_with_index do |cards, player_i|
      tops[player_i] = cards[0]
    end

    winner_card = tops.max
    winner_player_i = tops.index(winner_card)

    decks.each_with_index do |cards, player_i|
      if player_i == winner_player_i
        decks[player_i] = cards[1..] + tops.sort.reverse
      else
        decks[player_i] = cards[1..]
      end
    end
  end
end

def subgame_needed?(tops, decks)
  tops.each_with_index.all? { |card, player_i| (decks[player_i][1..]).size >= card }
end

def play_recursive_combat(decks)
  infinity_guard = Set.new
  while true
    h = decks.hash
    if infinity_guard.include? h
      return [0, decks]
    end
    infinity_guard << h

    return [
      decks.index { |cards| cards.size > 0 },
      decks,
    ] if decks.any?(&:empty?)

    tops = decks.map { |cards| cards[0] }
    if subgame_needed?(tops, decks)
      new_decks = decks.map { |cards| cards[1..(cards[0])] }
      winner_player_i, _ = play_recursive_combat(new_decks)
      winner_card = tops[winner_player_i]
    else
      winner_card = tops.max
      winner_player_i = tops.index(winner_card)
    end

    decks.each_with_index do |cards, player_i|
      if player_i == winner_player_i
        decks[player_i] = (cards[1..] + [winner_card] + [tops - [winner_card]]).flatten
      else
        decks[player_i] = cards[1..]
      end
    end
  end
end

def score(deck)
  score = 0
  deck.reverse.each_with_index do |card, i|
    score += card * (i + 1)
  end
  score
end

winner_deck = play_simple_combat(decks.map(&:dup))
puts "part1: #{score(winner_deck)}"

winner_player_i, final_decks = play_recursive_combat(decks.map(&:dup))
puts "part2: #{score(final_decks[winner_player_i])}"
