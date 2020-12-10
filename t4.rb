require 'pp'
require 'pry'
require 'set'

passports = File
  .read('input4.txt')
  .split(/\n\n/)
  .map do |l|
    Hash[l
      .gsub(/\n/, ' ')
      .split(/\s+/)
      .map { |f| f.split(':') }
    ]
  end

required_keys = Set[*%w{byr iyr eyr hgt hcl ecl pid}.sort] # cid

rules = {
  byr: Proc.new { |v| v.match(/^\d{4}$/) && 1920 <= v.to_i && v.to_i <= 2002 },
  iyr: Proc.new { |v| v.match(/^\d{4}$/) && 2010 <= v.to_i && v.to_i <= 2020 },
  eyr: Proc.new { |v| v.match(/^\d{4}$/) && 2020 <= v.to_i && v.to_i <= 2030 },
  hgt: Proc.new do |v|
    v.match(/^\d+(in|cm)$/) &&
      if v =~ /cm/
        150 <= v.to_i && v.to_i <= 193
      else
        59  <= v.to_i && v.to_i <= 76
      end
  end,
  hcl: Proc.new { |v| v.match(/^#[0-9a-f]{6}$/) },
  pid: Proc.new { |v| v.match(/^[0-9]{9}$/) },
  ecl: Proc.new { |v| %{amb blu brn gry grn hzl oth}.include?(v) },
  cid: Proc.new { |v| true },
}


c = passports.count do |passp|
  if Set[*passp.keys.sort].superset? required_keys
    passp.map do |k, v|
      rules[k.to_sym].call(v)
    end.all?
  else
    false
  end
end

pp c
