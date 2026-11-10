# frozen_string_literal: true

class Counts
  attr_reader :lines, :words, :bytes

  def self.from_text(text)
    new(text.count("\n"), text.split.size, text.bytesize)
  end

  def self.total(counts_list)
    new(counts_list.sum(&:lines), counts_list.sum(&:words), counts_list.sum(&:bytes))
  end

  def initialize(lines, words, bytes)
    @lines = lines
    @words = words
    @bytes = bytes
  end

  def value_for(key)
    public_send(key)
  end
end
