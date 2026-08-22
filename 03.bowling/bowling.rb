#!/usr/bin/env ruby
# frozen_string_literal: true

def parse_shots(input)
  input.split(',').map { |token| token == 'X' ? 10 : token.to_i }
end

def calculate_score(shots)
  total = 0
  index = 0

  10.times do |frame_no|
    if frame_no == 9
      total += shots[index..].sum
      break
    end

    if shots[index] == 10 # ストライク
      total += 10 + shots[index + 1, 2].sum
      index += 1
    elsif shots[index, 2].sum == 10 # スペア
      total += 10 + shots[index + 2]
      index += 2
    else
      total += shots[index, 2].sum
      index += 2
    end
  end

  total
end

input = ARGV[0]
shots = parse_shots(input)
puts calculate_score(shots)
