# frozen_string_literal: true

require_relative 'frame'
require_relative 'shot'

class Game
  NORMAL_FRAME_COUNT = 9
  # ボーナス計算に必要な後続ショットは最大2投。1フレームに最低1投あるので2フレームで足りる
  BONUS_FRAME_COUNT = 2

  attr_reader :frames

  def initialize(marks_text)
    shots = marks_text.split(',').map { |mark| Shot.new(mark) }
    @frames = build_frames(shots)
  end

  def score
    frames.each_with_index.sum do |frame, index|
      frame.score + frame.bonus_score(frames[index + 1, BONUS_FRAME_COUNT])
    end
  end

  private

  def build_frames(shots)
    frames = []
    position = 0

    NORMAL_FRAME_COUNT.times do
      shot_count = shots[position].all_pins_down? ? 1 : 2
      frames << Frame.new(shots[position, shot_count])
      position += shot_count
    end

    frames << Frame.new(shots[position..], final: true)
  end
end
