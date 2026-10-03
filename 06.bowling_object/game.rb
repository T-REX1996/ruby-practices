# frozen_string_literal: true

require_relative 'frame'
require_relative 'shot'

class Game
  NORMAL_FRAME_COUNT = 9

  attr_reader :frames

  def initialize(marks_text)
    shots = marks_text.split(',').map { |mark| Shot.new(mark) }
    @frames = build_frames(shots)
  end

  def score
    frames.each_with_index.sum do |frame, index|
      frame.score + bonus_score(frame, index)
    end
  end

  private

  def build_frames(shots)
    frames = []
    position = 0

    NORMAL_FRAME_COUNT.times do
      shot_count = shots[position].strike? ? 1 : 2
      frames << Frame.new(shots[position, shot_count])
      position += shot_count
    end

    frames << Frame.new(shots[position..], final: true)
  end

  def bonus_score(frame, index)
    following_shots = frames[(index + 1)..].flat_map(&:shots)
    following_shots.first(frame.bonus_shot_count).sum(&:pins)
  end
end
