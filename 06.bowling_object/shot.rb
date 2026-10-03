# frozen_string_literal: true

class Shot
  STRIKE_MARK = 'X'
  MAX_PINS = 10

  attr_reader :pins

  def initialize(mark)
    @pins = mark == STRIKE_MARK ? MAX_PINS : mark.to_i
  end

  def strike?
    pins == MAX_PINS
  end
end
