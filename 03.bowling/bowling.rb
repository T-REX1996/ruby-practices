#!/usr/bin/env ruby
# frozen_string_literal: true

def parse_shots(input)
  input.split(',').map { |token| token == 'X' ? 10 : token.to_i }
end

def calculate_score(shots)
  total = 0
  index = 0
  9.times do
    score_shot_count, thrown_shot_count =
      if shots[index] == 10 # ストライク
        [3, 1]
      elsif shots[index, 2].sum == 10 # スペア
        [3, 2]
      else
        [2, 2]
      end
    total += shots[index, score_shot_count].sum
    index += thrown_shot_count
  end
  total += shots[index..].sum
  total
end

input = ARGV[0]
shots = parse_shots(input)
puts calculate_score(shots)
