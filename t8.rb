require 'pp'
require 'pry'
require 'ostruct'
require 'set'

instructions = File.readlines('input8.txt').map do |l|
  inst, offset = l.split(/\s+/)
  {
    instruction: inst,
    offset: offset.to_i,
    ran: 0,
    seq: 0,
  }
end

def clone_insts(instructions)
  instructions.clone.map(&:clone)
end

def run(instructions)
  pc = 0
  acc = 0
  seq = 0

  while (pc != instructions.size)
    curr = instructions[pc]
    if curr[:ran] != 0
      curr[:ran] += 1
      break
    end

    curr[:ran] += 1
    curr[:seq] = seq

    if curr[:instruction] == 'acc'
      acc += curr[:offset]
      pc += 1
    elsif curr[:instruction] == 'jmp'
      pc += curr[:offset]
    elsif curr[:instruction] == 'nop'
      pc += 1
    end
    seq += 1
  end
  { pc: pc, acc: acc }
end

def try_mutations(instructions)
  change_index = 0
  while (change_index != instructions.size) do
    unless %w{jmp nop}.include? instructions[change_index][:instruction]
      change_index += 1
      next
    end

    clone = clone_insts(instructions)
    clone[change_index][:instruction] = clone[change_index][:instruction] == 'nop' ? 'jmp' : 'nop'

    re = run(clone)
    if re[:pc] == clone.size
      return re
    end
    change_index += 1
  end
end

pp run(clone_insts(instructions))
pp try_mutations(clone_insts(instructions))
