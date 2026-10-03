# frozen_string_literal: true

class Frame
  STRIKE_BONUS_SHOT_COUNT = 2
  SPARE_BONUS_SHOT_COUNT = 1

  attr_reader :shots

  def initialize(shots, final: false)
    @shots = shots
    @final = final
  end

  def score
    shots.sum(&:pins)
  end

  # このフレームのボーナス計算に使う、後続のショット数
  # 最終フレームはボーナスなし
  def bonus_shot_count
    return 0 if final?

    if strike?
      STRIKE_BONUS_SHOT_COUNT
    elsif spare?
      SPARE_BONUS_SHOT_COUNT
    else
      0
    end
  end

  def strike?
    first_shot.strike?
  end

  def spare?
    !strike? && first_shot.pins + second_shot.pins == Shot::MAX_PINS
  end

  def final?
    @final
  end

  private

  def first_shot
    shots[0]
  end

  def second_shot
    shots[1]
  end
end
