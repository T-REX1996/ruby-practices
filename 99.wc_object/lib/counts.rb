# frozen_string_literal: true

class Counts
  attr_reader :lines, :words, :bytes

  def self.from_text(text)
    new(text.count("\n"), text.split.size, text.bytesize)
  end

  def self.total(counts_list)
    counts_list.reduce(new(0, 0, 0), :+)
  end

  def initialize(lines, words, bytes)
    @lines = lines
    @words = words
    @bytes = bytes
  end

  def +(other)
    Counts.new(lines + other.lines, words + other.words, bytes + other.bytes)
  end

  def value_for(key)
    public_send(key)
  end
end
