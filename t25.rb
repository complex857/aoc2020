require 'pry'
require 'pp'

SUBJECT = 7
# door_pub = 17807724
# card_pub = 5764801
door_pub = 8335663
card_pub = 8614349

def transform(subject, loop_size)
  val = 1
  loop_size.times do
    val *= subject
    val = val % 20201227
  end
  val
end

def find_loop_size(subject, key)
  loop_size = 0
  val = 1
  begin
    loop_size += 1
    val *= subject
    val = val % 20201227
  end while val != key
  loop_size
end

card_loop_size = find_loop_size(SUBJECT, card_pub)
enc_key = transform(door_pub, card_loop_size)
pp enc_key
