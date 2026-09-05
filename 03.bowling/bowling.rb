#!/usr/bin/env ruby
# frozen_string_literal: true

def parse_shots(input)
  input.split(',').map { |token| token == 'X' ? 10 : token.to_i }
end

def calculate_score(shots)
  total = 0
  index = 0
  9.times do
    if shots[index] == 10 # ストライク
      total += shots[index, 3].sum
      index += 1
    elsif shots[index, 2].sum == 10 # スペア
      total += shots[index, 3].sum
      index += 2
    else
      total += shots[index, 2].sum
      index += 2
    end
  end
  total += shots[index..].sum
  total
end

input = ARGV[0]
shots = parse_shots(input)
puts calculate_score(shots)
